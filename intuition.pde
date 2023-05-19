// set your resolution for both screens to 1920x1080!

boolean printFPS = false; // print frames per second to console
boolean monophonic = true;
boolean starsFullScreen = true;
boolean hideStarsWhenInactive = true;
int waitSecondsToHideWhenInactive = 22;
int historyLength = 30; // how many stars to draw
float lineThickness = 1.75;

PWindow stars;
String savepath;
int screensSaved;
int currentScreen;
boolean saved = false;

//import processing.sound.*;
//SoundFile[] file;
import ddf.minim.*;
Minim minim;
AudioPlayer[] file;
int numSounds = 88;

int n_clicked = 0;
int wait = 0;

PFont Font1;
final int noCircles = 324;
Circle[] circles = new Circle[noCircles];

ArrayList<PVector> history = new ArrayList<PVector>();

void setup() {
  fullScreen(P3D, 3);
  //size(1080, 1080, P3D);
  
  savepath = sketchPath() + "/saves/";
  screensSaved = numberOfFiles(savepath);
  currentScreen = screensSaved;
  
  textSize(28);
  Font1 = createFont("Arial Bold", 28);
  textFont(Font1);
  textAlign(CENTER, CENTER);
  
  String[] lines = loadStrings("numbers.csv");
  String[] numbers = split(lines[0], ", ");

  minim = new Minim(this);
  file = new AudioPlayer[numSounds];
  for (int i = 0; i < numSounds; i++) {
    file[i] = minim.loadFile((i+1) + ".wav");
  }

  boolean s = false;
  for (int i = 0; i < noCircles; i++) {
    int col = i % 18;
    int line = i / 18;
    if (i % 18 == 0) {
      s = (line % 2 == 1);
    }
    circles[i] = new Circle(int(numbers[i]), col*60+30, line*60+30, s);
    s = !s;
  }

  stars = new PWindow();
}

void draw() {
  background(0);
  if (printFPS)
    println("FPS: ", frameRate);

  translate(420, 0);
  stroke(255);
  for (int i = 0; i < noCircles; i++) {
    circles[i].draw();
  }
}

void mouseClicked() {
  //int start = millis();
  if (monophonic && n_clicked > 0) {
    file[n_clicked-1].pause();
    file[n_clicked-1].rewind();
    println("stopped", n_clicked);
  }
  n_clicked = 0;
  for (int i = 0; i < noCircles; i++) {
    n_clicked = circles[i].clicked(mouseX-420, mouseY);
    if (n_clicked > 0) break;
  }
  if (n_clicked > 0) {
    for (int i = 0; i < noCircles; i++) {
      if (circles[i].freshness > 0) {
        circles[i].freshness--;
      }
    }
    file[n_clicked-1].play();
  }
  //println("TIME:", millis() - start);
}


int numberOfFiles(String dir) {
  File file = new File(dir);
  if (file.isDirectory()) {
    String names[] = file.list();
    return names.length;
  } else {
    // If it's not a directory
    return 0;
  }
}
