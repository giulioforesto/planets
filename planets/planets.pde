import java.util.Iterator;
import java.io.InputStreamReader;

int FRAME_RATE_PARAM = 30;
String INPUT_FILE_ABSOLUTE_PATH = "outfile.json";
float MASS_TO_DIAMETER_RATIO = 1; // pxDiam / mass
int MIN_PLANET_SIZE = 2;
int MAX_PLANET_SIZE = 40;
int[] DIMENSIONS;
float DEFAULT_TIME_RATIO = 300; // ms / time
float DEFAULT_SCALE_RATIO = 20; // px / dist

int[] origin;
float timeRatio = DEFAULT_TIME_RATIO;
long timeOrigin = 0; // ms. for rewind and fast forward
float scaleRatio = DEFAULT_SCALE_RATIO;

JSONObject currentDataFrame;
JSONObject newDataFrame;

boolean paused = true;
float pauseTime = 0;

File inputFile;
BufferedReader reader;

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
      println("Error: No mass for planet " + objectKey);
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
      println(origin[0] + x*scaleRatio);
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
}

void draw() {  
  // getLiveData(); // TODO condition to "live mode"
  
  background(255,255,255);
  
  drawGrid();
  
  if (!paused) {
    newDataFrame = Data.getNextAtTime((millis() - timeOrigin) / timeRatio, FRAME_RATE_PARAM * timeRatio);
  }
  
  if (newDataFrame != null) {
    currentDataFrame = newDataFrame;
  }
  if (currentDataFrame != null) {
    display(currentDataFrame);
  }
  
  if (paused) {
    textSize(20);
    fill(0);
    text("Paused", 10, 30);
  }
  
  if (timeRatio != DEFAULT_TIME_RATIO) {
    textSize(20);
    fill(0);
    text("Speed: " + floor(DEFAULT_TIME_RATIO*100/timeRatio) + "%", 10, 60);
  }
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

