class PWindow extends PApplet {
  PWindow() {
    super();
    PApplet.runSketch(new String[] {this.getClass().getSimpleName()}, this);
  }

  void settings() {
    if (starsFullScreen)
      fullScreen(1);
    else
      size(1000, 1000);
    //noSmooth();
  }

  void setup() {
  }

  void draw() {
    boolean saveFrame = false;
    background(0);
    if (hideStarsWhenInactive && n_clicked > 0) {
      if (!file[n_clicked-1].isPlaying()) {
        if (wait > waitSecondsToHideWhenInactive * frameRate) {
          saveFrame = true;
          if (saveFrame && saved) {
            // print("DONE");
            saveFrame = false;
            if (history.size() > 0)
              currentScreen++;
            else
              return;
            history.clear();
            for (int i = 0; i < noCircles; i++) {
              circles[i].freshness = 0;
              circles[i].brightness = 0.;
            }
            return;            
          }
        }
        else {
          wait++;
        }
      } else {
        wait = 0;
        saved = false;
      }
    }
    strokeWeight(0);

    if (starsFullScreen)
      translate(420, 0);

    // draw lines (from history[])
    pushStyle();
    stroke(100);
    strokeWeight(1);
    for (int i = 0; i < history.size() - 1; i++) {
      float x1 = starsFullScreen ? history.get(i).x : map(history.get(i).x, 0, 1080, 0, width);
      float x2 = starsFullScreen ? history.get(i+1).x : map(history.get(i+1).x, 0, 1080, 0, width);
      line(x1, history.get(i).y, x2, history.get(i+1).y);
    }
    popStyle();

    // draw circles (from circles[].brightness)
    for (int i = 0; i < noCircles; i++) {
      if (circles[i].freshness > 0) {
        float f = circles[i].brightness * (255./historyLength) + random(0.01);
        fill(f);
        float x = starsFullScreen ? circles[i].x : map(circles[i].x, 0, 1080, 0, width);
        circle(x, circles[i].y, circles[i].r);
      }
    }
    
    if (saveFrame) {
      String filename = savepath + "s" + currentScreen + ".png";
      println("SAVIN ", filename);
      save(filename);
      saved = true;
    }
  }
}
