int FRAME_RATE_PARAM = 30; // TODO fixe. à fixer en fct des résultats de gab
String FILE_NAME = ""; // TODO À définir

float timeRatio; // TODO timeRatio = realPlotTime/simulationTimeVariable - voir avec gabriel le standard
int timeOrigin = 0; // for rewind and fast forward

BufferedReader reader;

static class Data {
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

void getData() {
  reader = createReader(FILE_NAME);
  
  String line = "";
  JSONObject dataFrame;
  int insertTime = 0;
  int lastTime;
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
  // TODO Implement this
}

void setup() {
  frameRate(FRAME_RATE_PARAM);
  size(displayWidth, displayHeight);
}

void draw() {
  getData();

  JSONObject nextDataFrame = Data.getNextAtTime(floor((millis() - timeOrigin) / timeRatio));
  display(nextDataFrame);
}

