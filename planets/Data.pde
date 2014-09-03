import java.util.TreeMap;

public static class Data {
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
