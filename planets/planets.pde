import java.util.TreeMap;
import java.util.Iterator;

int FRAME_RATE_PARAM = 30; // TODO fixe. à fixer en fct des résultats de gab
String FILE_NAME = ""; // TODO À définir
int MASS_DISPLAY_RATIO; // TODO À définir: d/m where d is the sketch diameter (to scale) and m the given mass.
int[] DIMENSIONS = new int[] {displayWidth, displayHeight};
int[] ORIGIN = new int[] {DIMENSIONS[0]/2, DIMENSIONS[1]/2};

float timeRatio; // TODO timeRatio = realPlotTime/simulationTimeVariable - voir avec gabriel le standard
int timeOrigin = 0; // for rewind and fast forward
int scaleRatio; // define default

TreeMap<String,Integer> colors = new TreeMap<String,Integer>();

BufferedReader reader;

static class Data { // TODO Update this according to what is decided about the writing order (issue #3)
  private static JSONArray data = new JSONArray();

  public static int cursor = 0;
  
  public static int lastTime;
  
  public static JSONObject getNextAtTime(int time) {
    while (cursor < data.size()) {
      cursor++;
      JSONObject dataFrame = data.getJSONObject(cursor);
      if (dataFrame.getInt("t") > time) {
        return dataFrame;
      }
    }
    return null;
  }
  
  public static void add(JSONObject dataFrame) {
    data.append(dataFrame);
  }
}

void getData() { // TODO Update this according to what is decided about the writing order (issue #3)
  reader = createReader(FILE_NAME);
  
  String line = "";
  JSONObject dataFrame;
  int lastTime = 0, insertTime = 0;
  try {
    line = reader.readLine();
    dataFrame = JSONObject.parse(line);
    lastTime = insertTime = dataFrame.getInt("t");
    while (insertTime >= Data.lastTime) {
      line = reader.readLine();
      dataFrame = JSONObject.parse(line);
      insertTime = dataFrame.getInt("t");
    }
  }
  catch (IOException e) {
    // TODO Implement this
  }
  catch (NullPointerException e) {}
  
  Data.lastTime = lastTime;
}

void display(JSONObject dataFrame) {
  JSONObject positions = dataFrame.getJSONObject("x");
  JSONObject newMasses = dataFrame.getJSONObject("m"); // must be {} (empty object) if no new masses
  
  Iterator<String> keys = positions.keys().iterator();
  while(keys.hasNext()) {
    String objectKey = keys.next();
    
    float[] planetCoords;
    float planetMass;
    color planetColor;
    
    JSONArray planetCoordsJSON = positions.getJSONArray(objectKey);
    planetCoords = new float[] {planetCoordsJSON.getFloat(0), planetCoordsJSON.getFloat(1)};
    
    if (newMasses.has(objectKey)) {
      planetMass = newMasses.getFloat(objectKey);
    } else {
      // TODO Implement this according to what is decided about the writing order (issue #3)
      planetMass = 1;
    }
    
    if (colors.has(objectKey)) {
      planetColor = colors.get(objecKey);
    } else {
      // TODO Implement this
      planetColor = color(204, 153, 0);
    }
    
    display(planetCoords, planetMass, planetColor);
  }
}

void display(float[] coords, float mass, color planetColor) {
  int diameter = mass * MASS_DISPLAY_RATIO * scaleRatio;
  int x = ORIGIN[0] + coords[0]*scaleRatio;
  int y = ORIGIN[1] + coords[1]*scaleRatio;
  fill(planetColor);
  ellipse(x, y, diameter, diameter);
}

void setup() {
  frameRate(FRAME_RATE_PARAM);
  size(DIMENSIONS[0], DIMENSIONS[1]);
  noStroke();
}

void draw() {
  getData();

  JSONObject nextDataFrame = Data.getNextAtTime(floor((millis() - timeOrigin) / timeRatio));
  display(nextDataFrame);
}

