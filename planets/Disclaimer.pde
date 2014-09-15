public class Disclaimer {
  public void display(boolean paused, float timeRatio) {
    textSize(20);
    fill(0);
    if (paused) {
      text("Paused", 10, 30);
    }
    
    if (timeRatio != DEFAULT_TIME_RATIO) {
      text("Speed: " + floor(DEFAULT_TIME_RATIO*100/timeRatio) + "%", 10, 60);
    }
  }
}
