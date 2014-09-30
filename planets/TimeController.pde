public class TimeController {
  private float timeRatio = DEFAULT_TIME_RATIO;
  private long timeOrigin = millis(); // ms
  
  public boolean paused = true;
  private float pauseTime = 0; // simulation time
  
  public float getTime() {
    return (millis() - timeOrigin) / timeRatio;
  }

  public float getDeltaRatio() {
    return FRAME_RATE_PARAM * timeRatio;
  }
  
  public float getTimeRatio() {
    return timeRatio;
  }
  
  public void setPauseTime(float time) {
    pauseTime = time;
  }
  
  public float setTimeRatio(float newTimeRatio) {
    float ratio = DEFAULT_TIME_RATIO/newTimeRatio;
    if (ratio > 0.95 && ratio < 1.05) {
      newTimeRatio = DEFAULT_TIME_RATIO;
    }
    float var = newTimeRatio/timeRatio;
    timeOrigin = floor(millis()*(1-var) + timeOrigin*var);
    timeRatio = newTimeRatio;
    
    return newTimeRatio;
  }
  
  public float increaseTimeRatio(float var) {
    return setTimeRatio(timeRatio*var);
  }
  
  public void pause() {
    if (!paused) {
      paused = true;
      pauseTime = (millis() - timeOrigin) / timeRatio; // should be the same as currentDataFrame.getFloat("t");
    } else {
      timeOrigin = floor(millis() - pauseTime*timeRatio);
      paused = false;
    }
  }
  
  public void jumpAtTime(float time) {
    timeOrigin = floor(millis() - time*1000*timeRatio/DEFAULT_TIME_RATIO);
    if (paused) {
      pauseTime = time*1000/DEFAULT_TIME_RATIO;
    }
  }
}
