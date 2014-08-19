int FRAME_RATE_PARAM = 30; // fixe. à fixer en fct des résultats de gab

float timeRatio; // timeRatio = realPlotTime/simulationTimeVariable - voir avec gabriel le standard
int timeOrigin = 0; // for rewind and fast forward

static class Data {
  private static JSONArray data = new JSONArray();

  private static int cursor = 0;

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
}

void getData() {
  
}

void setup() {
  frameRate(FRAME_RATE_PARAM);
}

void draw() {
  getData();

  JSONObject nextDataFrame = Data.getNextAtTime(floor((millis() - timeOrigin) / timeRatio));
}

