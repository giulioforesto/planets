import controlP5.*;

import java.util.Iterator;
import java.io.InputStreamReader;

int FRAME_RATE_PARAM = 30; // fps
String INPUT_FILE_ABSOLUTE_PATH = "outfile.json"; // for live mode
float MASS_TO_DIAMETER_RATIO = 1; // pxDiam / mass
int MIN_PLANET_SIZE = 2; // px
int MAX_PLANET_SIZE = 40; // px
int[] DIMENSIONS;
float DEFAULT_TIME_RATIO = 300; // ms / time
float DEFAULT_SCALE_RATIO = 20; // px / dist

int[] origin;
float scaleRatio = DEFAULT_SCALE_RATIO;
float timeRatio = DEFAULT_TIME_RATIO;
long timeOrigin = 0; // ms. for rewind and fast forward
float maxTime;

JSONObject currentDataFrame;
JSONObject newDataFrame;

boolean paused = true;
float pauseTime = 0;

boolean enableGrid = true;

File inputFile;
BufferedReader reader;

Disclaimer disclaimer = new Disclaimer();

ControlP5 cp5;
CheckBox enableGridCheckbox;
Slider timeline;

color randomColor() {
  int r = floor(random(256));
  int g = floor(random(256));
  int b = floor(random(256));
  return color(r, g, b);
}

void getLiveData() {
  try {
    inputFile = new File(INPUT_FILE_ABSOLUTE_PATH);
    reader = new BufferedReader(new InputStreamReader(new ReverseLineInputStream(inputFile)));
  
    String line = "";
    JSONObject dataFrame;
  
    line = reader.readLine();
    if (line != null) {
      dataFrame = JSONObject.parse(line);
    } else {
      return;
    }
    
    JSONArray buffer = new JSONArray();
    float insertTime = dataFrame.getFloat("t");
    while (insertTime > Data.lastTime) {
      buffer.append(dataFrame);
      line = reader.readLine();
      if (line != null) {
        dataFrame = JSONObject.parse(line);
      } else {
        break;
      }
      insertTime = dataFrame.getFloat("t");
    }
    reader.close();
  
    for (int i = buffer.size() - 1; i >= 0; i--) {
        Data.add(buffer.getJSONObject(i));
    }
  }
  catch (IOException e) {
    e.printStackTrace();
  }
}

void fileSelected(File file) {
  Data.setData(loadJSONArray(file));
  timeOrigin = millis();
  newDataFrame = Data.getNextAtTime((millis() - timeOrigin) / timeRatio, FRAME_RATE_PARAM * timeRatio); // First frame paused
  
  timeline.setRange(0, Data.getMaxTime()*DEFAULT_TIME_RATIO/1000); // s
}

void getData() {
  selectInput("Select source file:", "fileSelected");
}

void display(JSONObject dataFrame) {
  JSONObject positions = dataFrame.getJSONObject("x");
  
  Iterator<String> keys = positions.keys().iterator();
  while(keys.hasNext()) {
    String objectKey = keys.next();
    
    float[] planetCoords;
    float planetMass;
    color planetColor;
    
    JSONArray planetCoordsJSON = positions.getJSONArray(objectKey);
    planetCoords = new float[] {planetCoordsJSON.getFloat(0), planetCoordsJSON.getFloat(1)};
    
    if (Data.currentMasses.hasKey(objectKey)) {
      planetMass = Data.currentMasses.getFloat(objectKey);
    } else {
      planetMass = 1;
      println("Warning: No mass for planet " + objectKey + " at time: " + dataFrame.getFloat("t"));
    }
    
    if (Data.currentColors.containsKey(objectKey)) {
      planetColor = Data.currentColors.get(objectKey);
    } else {
      planetColor = randomColor();
      Data.currentColors.put(objectKey, planetColor);
    }
    
    display(planetCoords, planetMass, planetColor);
  }
}

void display(float[] coords, float mass, color planetColor) {
  noStroke();
  int diameter = min(
    max(
      floor(sqrt(mass) * MASS_TO_DIAMETER_RATIO * sqrt(scaleRatio)), // sqrt is to reduce the size gaps due to huge mass differences and distances between planets
      MIN_PLANET_SIZE
    ),
    MAX_PLANET_SIZE
  );
  int x = floor(origin[0] + coords[0]*scaleRatio);
  int y = floor(origin[1] + coords[1]*scaleRatio);
  fill(planetColor);
  ellipse(x, y, diameter, diameter);
}

void drawGrid() {
  for (int i = 0; i < 3; i++) {
    float delta = pow(2,i);
    int alpha = floor(128 * pow(2,i)/4 * scaleRatio/(4*DEFAULT_SCALE_RATIO)); // 128 constant and 4 factor to DEFAULT_SCALE_RATIO are empirical
    stroke(0, alpha);
    float x = 0;
    float y = 0;
    while(origin[0] + x*scaleRatio < width
        || origin[0] - x*scaleRatio > 0 
        || origin[1] + y*scaleRatio < height
        || origin[1] - y*scaleRatio > 0) {
      line(origin[0] + x*scaleRatio, -5, origin[0] + x*scaleRatio, height+5);
      line(origin[0] - x*scaleRatio, -5, origin[0] - x*scaleRatio, height+5);
      x += delta;
      line(-5, origin[1] + y*scaleRatio, width+5, origin[1] + y*scaleRatio);
      line(-5, origin[1] - y*scaleRatio, width+5, origin[1] - y*scaleRatio);
      y += delta;
    }
  }
}

void setup() {
  DIMENSIONS = new int[] {displayWidth*9/10, displayHeight*9/10};
  
  frameRate(FRAME_RATE_PARAM);
  size(DIMENSIONS[0], DIMENSIONS[1]);
  
  getData(); // TODO condition to "replay mode"
  
  origin = new int [] {DIMENSIONS[0]/2, DIMENSIONS[1]/2};
  
  cp5 = new ControlP5(this);
  Group menu = cp5.addGroup("menu")
    .setPosition(width - 300, 10)
    .setWidth(300)
    .activateEvent(true)
    .setBackgroundColor(color(100, 110))
    .setBackgroundHeight(100)
    .setLabel("Menu")
    .close()
    ;            
  enableGridCheckbox = cp5.addCheckBox("enableGridCheckbox")
    .setGroup("menu")
    .setPosition(10, 10)
    .setColorForeground(color(120))
    .setColorActive(color(255))
    .setColorLabel(color(255))
    .setSize(10, 10)
    .addItem("Enable grid", 0) // Internal value is not used
    .toggle(0)
    ;
  timeline = cp5.addSlider("timeline")
    .setPosition(0, height-10)
    .setWidth(width)
    .setValue(0)
    .setSliderMode(Slider.FLEXIBLE)
    ;
}

void draw() {  
  // getLiveData(); // TODO condition to "live mode"
  
  background(255,255,255);
  if (enableGrid) {
    drawGrid();
  }
  
  if (!paused) {
    newDataFrame = Data.getNextAtTime((millis() - timeOrigin) / timeRatio, FRAME_RATE_PARAM * timeRatio);
  }
  
  if (newDataFrame != null) {
    currentDataFrame = newDataFrame;
    timeline.setValue(currentDataFrame.getFloat("t")*DEFAULT_TIME_RATIO/1000);
  }
  if (currentDataFrame != null) {
    display(currentDataFrame);
  }
  
  disclaimer.display();
}

/*
 * ZOOM
 */
void mouseWheel(MouseEvent event) {
  float e = event.getCount();
  if (keyPressed && key == CODED && keyCode == CONTROL) { // Time speed
    float var = 1 + e/10;
    timeOrigin = floor(millis()*(1-var) + timeOrigin*var);
    timeRatio *= var;
    
    if (DEFAULT_TIME_RATIO/timeRatio > 0.95 && DEFAULT_TIME_RATIO/timeRatio < 1.05) {
      timeRatio = DEFAULT_TIME_RATIO;
    }
  } else { // Zoom
    float var = 1 - e/10;
    
    origin[0] = floor(var*origin[0] + (1-var)*mouseX);
    origin[1] = floor(var*origin[1] + (1-var)*mouseY);
    
    scaleRatio *= var;
  }
}

/**
 * NAVIGATION
 */
void mouseDragged() {
  origin[0] += mouseX - pmouseX;
  origin[1] += mouseY - pmouseY;
}

void timeline(float time) {
  if (timeline.isMousePressed()) {
    Data.resetCursor();
    timeOrigin = floor(millis() - time*1000*timeRatio/DEFAULT_TIME_RATIO);
    if (paused) {
      pauseTime = time*1000/DEFAULT_TIME_RATIO;
    }
    currentDataFrame = Data.getNextAtTime((millis() - timeOrigin) / timeRatio, FRAME_RATE_PARAM * timeRatio);
    newDataFrame = null;
  }
}

void keyPressed() {
  switch (key) {
    case 32: // SPACE: pause
      if (!paused) {
        paused = true;
        pauseTime = (millis() - timeOrigin) / timeRatio; // Simulation time: should be the same as currentDataFrame.getFloat("t");
      } else {
        timeOrigin = floor(millis() - pauseTime*timeRatio);
        paused = false;
      }
      break;
    case 43: // +: zoom in
      scaleRatio *= 1.1;
      break;
    case 45: // -: zoom out
      scaleRatio *= 0.9;
      break;
    case CODED:
      switch (keyCode) {
        case RIGHT: // next frame
        case LEFT: // prev frame
          if (paused) {
            newDataFrame = Data.getNextDataFrame(keyCode-38); // keyCode is 37 (LEFT) or 39 (RIGHT)
            pauseTime = newDataFrame.getFloat("t");
          }
          break;
      }
      break;
  }
}

void controlEvent(ControlEvent event) {
  if (event.isFrom(enableGridCheckbox)){
    enableGrid = (enableGridCheckbox.getArrayValue()[0] == 1.0);
  }
}

