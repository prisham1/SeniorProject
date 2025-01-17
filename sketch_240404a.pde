import processing.serial.*;

Serial myPort;
String angle = "";
String distance = "";
int iAngle, iDistance;
PFont orcFont;

void setup() {
  size(1920, 1800);
  smooth();
  myPort = new Serial(this, "COM3", 9600);
  myPort.bufferUntil('.'); 
  orcFont = createFont("OCRAExtended-30.vlw", 30);
}

void draw() {
  fill(98, 245, 31);
  textFont(orcFont);
  noStroke();
  fill(0, 4);
  rect(0, 0, width, 1010);
  
  fill(98, 245, 31);
  drawRadar();
  drawLine();
  drawObject();
  drawText();
}

void serialEvent(Serial myPort) {
  String data = myPort.readStringUntil('.');
  if (data != null) {
    data = data.substring(0, data.length() - 1);
    int index1 = data.indexOf(",");
    if (index1 != -1) {
      angle = data.substring(0, index1);
      distance = data.substring(index1 + 1);
      iAngle = int(angle);
      iDistance = int(distance);
    }
  }
}

void drawRadar() {
  pushMatrix();
  translate(960, 1000);
  noFill();
  strokeWeight(2);
  stroke(98, 245, 31);
  arc(0, 0, 1800, 1800, PI, TWO_PI);
  arc(0, 0, 1400, 1400, PI, TWO_PI);
  arc(0, 0, 1000, 1000, PI, TWO_PI);
  arc(0, 0, 600, 600, PI, TWO_PI);
  line(-960, 0, 960, 0);
  line(0, 0, -960 * cos(radians(30)), -960 * sin(radians(30)));
  line(0, 0, -960 * cos(radians(60)), -960 * sin(radians(60)));
  line(0, 0, -960 * cos(radians(90)), -960 * sin(radians(90)));
  line(0, 0, -960 * cos(radians(120)), -960 * sin(radians(120)));
  line(0, 0, -960 * cos(radians(150)), -960 * sin(radians(150)));
  line(-960 * cos(radians(30)), 0, 960, 0);
  popMatrix();
}

void drawObject() {
  pushMatrix();
  translate(960, 1000);
  strokeWeight(9);
  stroke(255, 10, 10);
  float pixsDistance = iDistance * 22.5;
  if (iDistance < 40) {
    line(pixsDistance * cos(radians(iAngle)), -pixsDistance * sin(radians(iAngle)), 950 * cos(radians(iAngle)), -950 * sin(radians(iAngle)));
  }
  popMatrix();
}

void drawLine() {
  pushMatrix();
  strokeWeight(9);
  stroke(30, 250, 60);
  translate(960, 1000);
  line(0, 0, 950 * cos(radians(iAngle)), -950 * sin(radians(iAngle)));
  popMatrix();
}

void drawText() {
  pushMatrix();
  String noObject = (iDistance > 40) ? "Out of Range" : "In Range";
  fill(0);
  noStroke();
  rect(0, 1010, width, 1080);
  fill(98, 245, 31);
  textSize(25);
  text("10cm", 1180, 990);
  text("20cm", 1380, 990);
  text("30cm", 1580, 990);
  text("40cm", 1780, 990);
  textSize(40);
  text("Object: " + noObject, 240, 1050);
  text("Angle: " + iAngle + " °", 1050, 1050);
  text("Distance: " + iDistance + " cm", 1380, 1050);
  textSize(25);
  fill(98, 245, 60);
  translate(961 + 960 * cos(radians(30)), 982 - 960 * sin(radians(30)));
  rotate(-radians(-60));
  text("30°", 0, 0);
  resetMatrix();
  translate(954 + 960 * cos(radians(60)), 984 - 960 * sin(radians(60)));
  rotate(-radians(-30));
  text("60°", 0, 0);
  resetMatrix();
  translate(945 + 960 * cos(radians(90)), 990 - 960 * sin(radians(90)));
  rotate(radians(0));
  text("90°", 0, 0);
  resetMatrix();
  translate(935 + 960 * cos(radians(120)), 1003 - 960 * sin(radians(120)));
  rotate(radians(-30));
  text("120°", 0, 0);
  resetMatrix();
  translate(940 + 960 * cos(radians(150)), 1018 - 960 * sin(radians(150)));
  rotate(radians(-60));
  text("150°", 0, 0);
  popMatrix();
}
