class Circle {
  int x, y, r;
  int number;
  float clickedAnim;
  int freshness;
  float brightness;
  boolean small;

  Circle (int _n, int _x, int _y, boolean _s) {
    number = _n;
    small = _s;
    clickedAnim = 0.;
    freshness = 0;
    brightness = 0.;
    if (small) {
      r = 30;
      strokeWeight(5);
    } else {
      r = 60;
      strokeWeight(6);
    }
    x = _x;
    y = _y;
  }

  void draw() {
    if (clickedAnim > 12) {
      clickedAnim *= 0.96;
      //println(clickedAnim);
    } else {
      clickedAnim = 0;
    }

    if (brightness > freshness) {
      brightness *= 0.99 + random(0.01);
    } else {
      brightness = freshness;
    }
    // draw circle
    fill(clickedAnim);
    circle(x, y, r + sin(clickedAnim) * (clickedAnim/100.));
    // number text
    fill(255);
    if (small) {
      textSize(14);
    } else {
      textSize(28);
    }
    text(number, x, y-(4 - int(small) * 2));
  }

  int clicked(int mx, int my) {
    if (abs(x - mx) + abs(y - my) <= 30) {
      println(number);
      // for drawing stars
      freshness = historyLength;        // 15
      brightness = historyLength + 1.;  // 16.
      
      // for animating the button on click
      clickedAnim = 166.;

      history.add(new PVector(x, y));
      if (history.size() == historyLength) {
        history.remove(0);
      }
      //printArray(history);
      return number;
    }
    return 0;
  }
}
