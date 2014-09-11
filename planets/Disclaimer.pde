public class Disclaimer {
  public void display() {
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
}
