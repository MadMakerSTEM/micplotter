import processing.serial.*; // import the Serial library

String serial;
Serial port;


int numPoints = 1000;        // number of points on the graph
int currentPoint = 0;

int box = 20;
int offset = 50;            // offset of x-axis, in pixels
int mode = 0;               // mode x, y or z (0, 1,2)
float px, py;
int mic;
boolean canPlot = true;
float[] data = new float[numPoints];
float[] xAxis = new float[numPoints];

void setup() {
  printArray(Serial.list());   // print the serial ports available
  String comPort = Serial.list()[0];    // should work on linux
  //String comPort = Serial.list()[Serial.list().length-1];    // should work on windows and mac
  try {
    port = new Serial(this, comPort, 9600);   // 0 is the first port, you may have to change
  }
  catch (Exception e) {
    println(e);
    println("Please make sure the Serial Monitor is closed and you have selected the correct port.");
    exit();
  }
  size(800, 600);           // new window
  frame.setTitle("Accelerometer plot");
  reset();
}

void draw() {
  while (port.available() > 0) {
    serial = port.readStringUntil('\n');
  }
  if (serial != null) {               // if string is not empty
    serial = trim(serial);
    mic = int(serial);
    if (mic >= 0) {

      drawPlot();
    } else {
      println("Problem detected! Are you sending all the axes with a comma separating them?");
      exit();
    }
  } else {
    println("Could not connect to Esplora! Make sure it is connected to the computer,  and the correct port is selected!");
    exit();
  }
}

void drawPlot() {
  if (canPlot == false) {
    background(255);
    drawBorders();
    for (int i = 1; i < numPoints; i++)
      line(xAxis[i-1], data[i-1], xAxis[i], data[i]);
  }
  if (currentPoint < numPoints && canPlot == false) {
    background(255);
    drawBorders();
    float x = map(currentPoint, 0, numPoints, box, width-box);
    float y = map(mic, 0, 1023, height-box, box+100);      
    data[currentPoint] = y;
    xAxis[currentPoint] = x;
    text("value: " + mic, width-box-120, box+40);
    for (int i = 1; i < currentPoint; i++) {
      line(xAxis[i-1], data[i-1], xAxis[i], data[i]);
    }
    currentPoint++;
  } else {
    canPlot = false;
  }
}

// Draw the borders and axes
void drawBorders() {
  fill(255);                          // fill box with white
  strokeWeight(1);
  rectMode(CORNERS);                  // first two args are top left, second two bottom right
  rect(box, box, width-box, height-box);
  strokeWeight(2);
  fill(0);                            // make text black
  int x1 = box;
  int x2 = width-box;
  // draw the horizontal dots
  for (int i = 0; i <= 50; i++) {
    float x = lerp(x1, x2, i/50.0);
    for (int j = 1; j < 6; j++) {
      float yvalues = map(j, 0, 5, height-box, box+100);
      float y = map(yvalues, 0, 1023, 0, 1000);
      point(x, y+12);
    }
  }
  // draw the y value text 500 to 1000
  for (int k = 0; k < 6; k++) {
    float yval = lerp(0, 1000, k/5.0);
    float y = map(yval, 0, 1000, height-box-5, box+115-5);
    text(int(yval), box+5, y);
  }
  float y = map(mouseY, height-box, box+100, 0, 1023);
  text("light: " +y, width-box-120, box+60);
  textSize(16);
  text("Light Meter", box+5, box+20);
  textSize(12);
  text("Press r to restart", box+5, box+40);
  strokeWeight(1);
  textSize(12);
}

// Reset the plot
void reset() {
  currentPoint = 0;
  canPlot = true;
}

void keyPressed() {
  if (key == 'r')
    reset();
}