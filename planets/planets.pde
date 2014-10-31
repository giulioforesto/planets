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
int DEFAULT_TRACE_LENGTH = 3; // time

int[] origin;
float scaleRatio = DEFAULT_SCALE_RATIO;
int traceLength = DEFAULT_TRACE_LENGTH;

JSONObject currentDataFrame;
JSONObject newDataFrame;

boolean enableGrid = true;
boolean enableTrace = true;

File inputFile;
BufferedReader reader;

TimeController timeController = new TimeController();
Disclaimer disclaimer = new Disclaimer();

ControlP5 cp5;
CheckBox enableGridCheckbox;
Slider timeSpeedSlider;
Slider timeline;
Textlabel maxTimeLabel;

color randomColor() {
  int r = floor(random(256));
  int g = floor(random(256));
  int b = floor(random(256));
  return color(r, g, b);
}

void getLiveData() { // TODO update according to new architecture
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
  timeController = new TimeController();
  newDataFrame = Data.getNextAtTime(timeController.getTime(), timeController.getDeltaRatio()); // First frame paused
  
  Float maxTime = (Float)Data.getMaxTime()*DEFAULT_TIME_RATIO/1000;
  timeline.setRange(0, maxTime); // s
  maxTimeLabel.setText(maxTime.toString());
  
  synchronized (this) {
    this.notify();
  }
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

void displayTrace() {
  float currentTime = currentDataFrame.getFloat("t");
  float frameTime = currentTime;
  int distance = -2;
  int cursor = Data.getCursor();
  int dataSize = Data.getSize();
  while (frameTime >= currentTime - traceLength
    && cursor + distance >= 0
    && cursor + distance < dataSize) {
    JSONObject dataFrame2 = Data.getDataFrameFromCursor(distance+1);
    JSONObject dataFrame1 = Data.getDataFrameFromCursor(distance);
    
    frameTime = dataFrame1.getFloat("t");
    
    JSONObject positions2 = dataFrame2.getJSONObject("x");
    JSONObject positions1 = dataFrame1.getJSONObject("x");
    
    Iterator<String> keys = positions2.keys().iterator();
    while(keys.hasNext()) {
      int alpha = floor((frameTime - (currentTime - traceLength)) * 255 / traceLength);
      stroke(255,0,0, alpha);
      String objectKey = keys.next();
      
      JSONArray planetCoordsJSON2 = positions2.getJSONArray(objectKey);
      JSONArray planetCoordsJSON1 = positions1.getJSONArray(objectKey);
      
      int x2 = floor(origin[0] + planetCoordsJSON2.getFloat(0)*scaleRatio);
      int y2 = floor(origin[1] + planetCoordsJSON2.getFloat(1)*scaleRatio);
      int x1 = floor(origin[0] + planetCoordsJSON1.getFloat(0)*scaleRatio);
      int y1 = floor(origin[1] + planetCoordsJSON1.getFloat(1)*scaleRatio);
      
      line(x2, y2, x1, y1);
    }
    distance--;
  }
}

void drawGrid() {
  for (int i = 0; i < 3; i++) {
    float delta = pow(2,i);
    int alpha = floor(8 * pow(2,i) * scaleRatio/DEFAULT_SCALE_RATIO); // 8 factor is empirical
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
  frame.setResizable(true);
  
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
    .setItemsPerRow(2)
    .setSpacingColumn(60)
    .setSize(10, 10)
    .addItem("Enable grid", 0) // Internal value is not used
    .addItem("Enable trace", 0) // Internal value is not used
    .toggle(0)
    .toggle(1)
    ;
  timeSpeedSlider = cp5.addSlider("timeSpeedSlider")
    .setGroup("menu")
    .setPosition(10, 30)
    .setWidth(270)
    .setRange(0,10)
    .setValue(1)
    .setSliderMode(Slider.FLEXIBLE)
    ;
  cp5.addButton("changeSourceFileButton")
    .setGroup("menu")
    .setPosition(10,50)
    .setSize(100,10)
    .setLabel("Change source file")
    ;
    
  timeline = cp5.addSlider("timeline")
    .setPosition(0, height-10)
    .setWidth(width)
    .setValue(0)
    .setSliderMode(Slider.FLEXIBLE)
    ;
  maxTimeLabel = cp5.addTextlabel("maxTimeLabel")
    .setPosition(width-30, height-10); // Text is set in fileSelected method
    ;
    
  synchronized (this) { // Waits for the file to be selected.
    try {
      this.wait();
    } catch (InterruptedException e) {}
  }
}

void draw() {  
  // getLiveData(); // TODO condition to "live mode"
  
  background(255,255,255);
  if (enableGrid) {
    drawGrid();
  }
  
  if (!timeController.paused) {
    newDataFrame = Data.getNextAtTime(timeController.getTime(), timeController.getDeltaRatio());
  }
  
  if (newDataFrame != null) {
    currentDataFrame = newDataFrame;
    timeline.setValue(currentDataFrame.getFloat("t")*DEFAULT_TIME_RATIO/1000);
  }
  if (currentDataFrame != null) {
    display(currentDataFrame);
    if (enableTrace) {
      displayTrace();
    }
  }
  
  disclaimer.display(
    timeController.paused,
    timeController.getTimeRatio()
  );
}

/*
 * ZOOM & TIME SPEED
 */
void mouseWheel(MouseEvent event) {
  float e = event.getCount();
  if (keyPressed && key == CODED && keyCode == CONTROL) { // Time speed
    float var = 1 + e/10;
    float newTimeRatio = timeController.increaseTimeRatio(var);
    timeSpeedSlider.setValue(DEFAULT_TIME_RATIO/newTimeRatio);
  }
  else { // Zoom
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
  if (!cp5.isMouseOver()) {
    origin[0] += mouseX - pmouseX;
    origin[1] += mouseY - pmouseY;
  }
}

void keyPressed() {
  switch (key) {
    case 32: // SPACE: pause
      timeController.pause();
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
          if (timeController.paused) {
            newDataFrame = Data.getNextDataFrame(keyCode-38); // keyCode is 37 (LEFT) or 39 (RIGHT)
            timeController.setPauseTime(newDataFrame.getFloat("t"));
          }
          break;
      }
      break;
  }
}

void controlEvent(ControlEvent event) { // Checkbox event
  if (event.isFrom(enableGridCheckbox)){
    enableGrid = (enableGridCheckbox.getArrayValue()[0] == 1.0);
    enableTrace = (enableGridCheckbox.getArrayValue()[1] == 1.0);
  }
}

void timeSpeedSlider(float ratio) {
  if (timeSpeedSlider.isMousePressed()) {
    timeController.setTimeRatio(DEFAULT_TIME_RATIO/ratio);
    if (ratio > 0.95 && ratio < 1.05) {
      timeSpeedSlider.setValue(1);
    }
  }
}

void changeSourceFileButton(int value) {
  if (!timeController.paused) {
    timeController.pause();
  }
  getData();
}

/**
 * Jumps at the selected time.
 * Sets the currentDataFrame instead of the newDataFrame in order to avoid refreshing the timeline again.
 */
void timeline(float time) {
  if (timeline.isMousePressed()) {
    Data.resetCursor();
    timeController.jumpAtTime(time);
    currentDataFrame = Data.getNextAtTime(timeController.getTime(), timeController.getDeltaRatio());
    newDataFrame = null;
  }
}
