import java.util.TreeMap;

public static class Data {
  private static JSONArray data = new JSONArray();
  
  public static JSONObject currentMasses = new JSONObject();
  public static TreeMap<String,Integer> currentColors = new TreeMap<String,Integer>();

  public static int cursor = 0;
  
  public static float lastTime;
  
  public static JSONObject getNextAtTime(float time, float deltaRatio) {
    while (cursor < data.size()) {
      JSONObject dataFrame = data.getJSONObject(cursor);
      
      if (dataFrame.hasKey("m")) {
        currentMasses = dataFrame.getJSONObject("m");
      }
      
      float dataFrameTime = dataFrame.getFloat("t");
      if (dataFrameTime >= time) {
        if (dataFrameTime < time + 1000/deltaRatio) {
          cursor++;
          return dataFrame;
        } else {
          return null;
        }
      }
      cursor++;
    }
    return null;
  }
  
  public static JSONObject getNextDataFrame(int dir) {
    cursor = min(max(cursor + dir, 0), data.size());
    return data.getJSONObject(cursor);
  }
  
  public static void add(JSONObject dataFrame) {
    data.append(dataFrame);
    lastTime = dataFrame.getFloat("t");
  }
  
  public static void setData(JSONArray inputData) {
    data = inputData;
  }
}
