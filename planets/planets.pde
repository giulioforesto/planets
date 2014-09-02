import java.util.TreeMap;
import java.util.Iterator;
import java.io.InputStreamReader;
import java.awt.event.KeyEvent;

int FRAME_RATE_PARAM = 30;
String INPUT_FILE_ABSOLUTE_PATH = "outfile.json";
float MASS_TO_DIAMETER_RATIO = 1; // pxDiam / mass
int[] DIMENSIONS;

int[] origin;
float timeRatio = 1; // s / time
long timeOrigin = 0; // ms. for rewind and fast forward
float scaleRatio = 20; // px / dist

JSONObject currentDataFrame;

boolean paused = false;
long pauseTime;

File inputFile;
BufferedReader reader;

static class Data { // TODO Put in new file
  private static JSONArray data = new JSONArray();
  
  public static JSONObject currentMasses = new JSONObject();
  public static TreeMap<String,Integer> currentColors = new TreeMap<String,Integer>();

  public static int cursor = 0;
  
  public static int lastTime;
  
  public static JSONObject getNextAtTime(float time) {
    while (cursor < data.size()) {
      JSONObject dataFrame = data.getJSONObject(cursor);
      cursor++;
      
      if (dataFrame.hasKey("m")) {
        currentMasses = dataFrame.getJSONObject("m");
      }
      
      if (dataFrame.getInt("t") > time) {
        return dataFrame;
      }
    }
    return null;
  }
  
  public static void add(JSONObject dataFrame) {
    data.append(dataFrame);
    lastTime = dataFrame.getInt("t");
  }
  
  public static void setData(JSONArray inputData) {
    data = inputData;
  }
}

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
    int insertTime = dataFrame.getInt("t");
    while (insertTime > Data.lastTime) {
      buffer.append(dataFrame);
      line = reader.readLine();
      if (line != null) {
        dataFrame = JSONObject.parse(line);
      } else {
        break;
      }
      insertTime = dataFrame.getInt("t");
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
}

void getData() {
  selectInput("Select source file:", "fileSelected");
}

void display(JSONObject dataFrame) {
  background(255,255,255);
  
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
  int diameter = floor(sqrt(mass) * MASS_TO_DIAMETER_RATIO * sqrt(scaleRatio)); // sqrt is to reduce the size gaps due to huge mass differences and distances between planets
  int x = floor(origin[0] + coords[0]*scaleRatio);
  int y = floor(origin[1] + coords[1]*scaleRatio);
  fill(planetColor);
  ellipse(x, y, diameter, diameter);
}

void setup() {
  DIMENSIONS = new int[] {displayWidth*9/10, displayHeight*9/10};
  
  frameRate(FRAME_RATE_PARAM);
  size(DIMENSIONS[0], DIMENSIONS[1]);
  noStroke();
  
  getData(); // TODO condition to "replay mode"
  
  origin = new int [] {DIMENSIONS[0]/2, DIMENSIONS[1]/2};
  timeOrigin = millis();
}

void draw() {  
  // getLiveData(); // TODO condition to "live mode"
  
  if (!paused) {
    currentDataFrame = Data.getNextAtTime((millis() - timeOrigin) / (1000 * timeRatio));
  }
  
  if (currentDataFrame != null) {
    display(currentDataFrame);
  }
}

void mouseWheel(MouseEvent event) {
  float e = event.getCount();
  scaleRatio *= 1 - e/10;
}

void mouseDragged() {
  origin[0] += mouseX - pmouseX;
  origin[1] += mouseY - pmouseY;
}

void keyPressed() {
  switch (key) {
    case 32: // SPACE: pause
      if (!paused) {
        paused = true;
        pauseTime = millis();
      } else {
        timeOrigin += (millis() - pauseTime);
        paused = false;
      }
      break;
  }
}


