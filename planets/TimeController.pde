public class TimeController {
  private float timeRatio = DEFAULT_TIME_RATIO;
  private long timeOrigin = 0; // ms. for rewind and fast forward
  
  public boolean paused = true;
  private float pauseTime = 0;
  
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
  
  public void setTimeRatio(float newTimeRatio) {
    float var = newTimeRatio/timeRatio;
    timeOrigin = floor(millis()*(1-var) + timeOrigin*var);
    timeRatio = newTimeRatio;
    float ratio = DEFAULT_TIME_RATIO/timeRatio;
    if (ratio > 0.95 && ratio < 1.05) {
      timeRatio = DEFAULT_TIME_RATIO;
    }
  }
  
  public float increaseTimeRatio(float var) {
    float newTimeRatio = timeRatio*var;
    if (DEFAULT_TIME_RATIO/newTimeRatio > 0.95 && DEFAULT_TIME_RATIO/newTimeRatio < 1.05) {
      newTimeRatio = DEFAULT_TIME_RATIO;
    }
    setTimeRatio(newTimeRatio);
    
    return newTimeRatio;
  }
  
  public void pause() {
    if (!paused) {
      paused = true;
      pauseTime = (millis() - timeOrigin) / timeRatio; // Simulation time: should be the same as currentDataFrame.getFloat("t");
    } else {
      timeOrigin = floor(millis() - pauseTime*timeRatio);
      paused = false;
    }
  }
  
  public void resetOrigin() {
    timeOrigin = millis();
  }
  
  public void jumpAtTime(float time) {
    timeOrigin = floor(millis() - time*1000*timeRatio/DEFAULT_TIME_RATIO);
    if (paused) {
      pauseTime = time*1000/DEFAULT_TIME_RATIO;
    }
  }
}
