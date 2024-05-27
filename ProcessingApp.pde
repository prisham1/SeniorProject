/*
 * Sketch     Sketch for control Freenove Hexapod Robot
 * Brief      This sketch is used to control Freenove Hexapod Robot through Serial or Wi-Fi.
 *            To use Serial, the robot should connect to the device run this sketch.
 *            To use Wi-Fi, the device run this sketch should connect to the Wi-Fi of the robot.
 * Author     Ethan Pan @ Freenove (support@freenove.com)
 * Date       2021/05/28
 * Version    V12.0
 * Copyright  Copyright © Freenove (http://www.freenove.com)
 * License    Creative Commons Attribution ShareAlike 3.0
 *            (http://creativecommons.org/licenses/by-sa/3.0/legalcode)
 * -----------------------------------------------------------------------------------------------*/

// control robot
ControlRobot controlRobot = new ControlRobot(this);
// gui
import controlP5.*;
ControlP5 cp5;
PFont font;
Textlabel textlabelInfo;
Textlabel textlabelVoltage;
Slider2D slider2dMove;
Slider2D slider2dRotate;
// images for gui
PImage pImageControl;
PImage pImageTwistBody;
PImage pImageCalibration;
PImage pImageInstallation;
// constants for gui
final color backgroundColor = color(128);
final color globalTabColor = color(102);
final int globalTapHeight = 100;
final int tabWidth = 128;
final int tabHeight = 24;
// event
int eventId = 0;
boolean isProcessEvent = false;
// voltage
int lastGetVoltage = 0;

//Radar Imports 
import processing.serial.*;

Serial myPort;
String angle = "";
String distance = "";
int iAngle, iDistance;
PFont orcFont;

//pH & moisture
float[] moistureData = new float[600];
float[] pHData = new float[600];
int maxDataPoints = 600;
int dataPointIndex = 0;
boolean newData = false;
float moistureLevel = 0;
float pHLevel = 0;
String crop = "";


void drawRadar() {
  pushMatrix();
  translate(420, 450);  // Adjusted radar center
  noFill();
  strokeWeight(1);  // Adjusted stroke weight
  stroke(98, 245, 31);
  arc(0, 0, 450, 450, PI, TWO_PI);  // Adjusted radar size
  arc(0, 0, 350, 350, PI, TWO_PI);  // Adjusted radar size
  arc(0, 0, 250, 250, PI, TWO_PI);  // Adjusted radar size
  arc(0, 0, 150, 150, PI, TWO_PI);  // Adjusted radar size
  line(-325, 0, 325, 0);  // Adjusted radar size
  line(0, 0, -325 * cos(radians(30)), -325 * sin(radians(30)));  // Adjusted radar size
  line(0, 0, -325 * cos(radians(60)), -325 * sin(radians(60)));  // Adjusted radar size
  line(0, 0, -325 * cos(radians(90)), -325 * sin(radians(90)));  // Adjusted radar size
  line(0, 0, -325 * cos(radians(120)), -325 * sin(radians(120)));  // Adjusted radar size
  line(0, 0, -325 * cos(radians(150)), -325 * sin(radians(150)));  // Adjusted radar size
  line(-325 * cos(radians(30)), 0, 325, 0);  // Adjusted radar size
  popMatrix();
}

void drawObject() {
  pushMatrix();
  translate(420, 450);   // Adjusted radar center
  strokeWeight(4);  // Adjusted stroke weight
  float alpha = map(millis() % 3000, 0, 3000, 255, 0);
  stroke(30, 250, 60, alpha);
  stroke(255, 10, 10);
  float pixsDistance = iDistance * 11.25;  // Adjusted distance scaling
  if (iDistance < 40) {
    line(pixsDistance * cos(radians(iAngle)), -pixsDistance * sin(radians(iAngle)), 300 * cos(radians(iAngle)), -300 * sin(radians(iAngle)));  // Adjusted line length
  }
  popMatrix();
}

void drawLine() {
  pushMatrix();
  strokeWeight(4);  // Adjusted stroke weight
  float alpha = map(millis() % 1000, 0, 3000, 255, 0);
  stroke(30, 250, 60, alpha);
  translate(420, 450);  // Adjusted radar center
  line(0, 0, 300 * cos(radians(iAngle)), -300 * sin(radians(iAngle)));  // Adjusted line length
  popMatrix();
}

void drawText() {
  pushMatrix();
  String noObject = (iDistance > 40) ? "Out of Range" : "In Range";
  fill(0);
  noStroke();
  rect(0, 500, width, 360);  // Adjusted text area
  fill(98, 245, 31);
  textSize(14);  // Adjusted text size
  textAlign(CENTER, CENTER);  // Centered text
  text("10cm", 510, 460);  // Adjusted position
  text("20cm", 565, 460);  // Adjusted position
  text("30cm", 610, 460);  // Adjusted position
  text("40cm", 660, 460);  // Adjusted position
  textSize(20);  // Adjusted text size
  
  text("Object: " + noObject, 160, 540);  // Adjusted position
  text("Angle: " + iAngle + " °", 365, 540);  // Adjusted position
  text("Distance: " + iDistance + " cm", 515, 540);  // Adjusted position
  
  textSize(14);  // Adjusted text size
  fill(98, 245, 60);
  translate(326 + 325 * cos(radians(30)), 242 - 325 * sin(radians(30)));  // Adjusted position
  rotate(-radians(-60));  // Adjusted rotation
  text("30°", 205, 80);
  resetMatrix();
  translate(328 + 325 * cos(radians(60)), 244 - 325 * sin(radians(60)));  // Adjusted position
  rotate(-radians(-30));  // Adjusted rotation
  text("60°", 160, 180);
  resetMatrix();
  translate(331 + 325 * cos(radians(90)), 247 - 325 * sin(radians(90)));  // Adjusted position
  rotate(radians(0));  // Adjusted rotation
  text("90°", 70, 250);
  resetMatrix();
  translate(334 + 325 * cos(radians(120)), 250 - 325 * sin(radians(120)));  // Adjusted position
  rotate(radians(-30));  // Adjusted rotation
  text("120°", 0, 260);
  resetMatrix();
  translate(337 + 325 * cos(radians(150)), 253 - 325 * sin(radians(150)));  // Adjusted position
  rotate(radians(-60));  // Adjusted rotation
  text("150°", -100, 200);
  popMatrix();
}

void drawMoisture_pH(){
  text("Moisture Level: " + nf(moistureLevel, 0, 2) + "%", width/2, 195);

  // Display "Moisture in range" below the moisture level
  boolean withinMoistureRange = checkMoistureInRange(crop, moistureLevel);
  fill(withinMoistureRange ? color(0, 255, 0) : color(255, 0, 0)); // Green when in range, red when not
  text(withinMoistureRange ? "Moisture in range" : "Moisture out of range", width/2, 210);
  
  // Display pH level
  fill(255);
  text("pH Level: " + nf(pHLevel, 0, 2), width/2, 240);

  // Display "pH in range" or "pH out of range" below the pH level
  boolean withinpHRange = checkpHInRange(crop, pHLevel);
  fill(withinpHRange ? color(0, 255, 0) : color(255, 0, 0)); // Green when in range, red when not
  text(withinpHRange ? "pH in range" : "pH out of range", width/2, 255);


  // Display title for moisture graph
  fill(255);
  textSize(20);
  textAlign(CENTER);
  text("_____________________________________________________________________________", width/2, 280);
  text("Moisture Percentage", width / 4, 320); // Adjusted title position

  // Display title for pH graph
  fill(255);
  textSize(20);
  textAlign(CENTER);
  text("pH Value", width * 3/4, 320); // Adjusted title position

  // Draw the moisture graph axes
  drawMoistureAxes();

  // Draw the pH graph axes
  drawpHAxes();

  // Draw the data points and connect them with lines for moisture graph
  drawMoistureDataPoints();

  // Draw the data points and connect them with lines for pH graph
  drawpHDataPoints();

  // Display time and y-value on hover for moisture graph
  displayMoistureHoverInfo();

  // Display time and y-value on hover for pH graph
  displaypHHoverInfo();
  
  textSize(20);
     text("Crop:", width/2-125, 160); // Position the label to the left of the text box

    // Display user input text box centered relative to the label
    fill(255); // Set text color to white
    textSize(16);
    textAlign(CENTER, CENTER); // Center align text
   // rectMode(CENTER);
    rect(width/2-85, 135, 250, 40, 10); // Centered based on canvas width relative to the label
    fill(0); // Set text color to black
    // Draw text within the text box, centered
    text(crop.substring(0, min(crop.length(), 20)), width/2+30, 155);
}

// Function to draw grid lines and numbers on moisture graph axes
void drawMoistureAxes() {
  // Draw y-axis for moisture graph
  stroke(255);
  line(50, height - 280, 50, height - 30); // Adjusted y-axis position
  textAlign(RIGHT, CENTER);
  textSize(12);
  for (int i = 0; i <= 10; i++) {
    float y = map(i * 10, 0, 100, height - 30, height - 280);
    line(45, y, 55, y);
    fill(255); // Set text color to white
    text((i * 10), 40, y);
  }
  // Label y-axis for moisture graph
  textAlign(CENTER, CENTER);
  textSize(14);
  rotate(-HALF_PI);
  for (int i = 0; i <= 10; i++) {
    float yLabel = map(i * 10, 0, 100, height - 30, height - 280);
    fill(255); // Set text color to white
    text(i * 10 + "%", 20, yLabel); // Adjusted label position
  }
  rotate(HALF_PI);

  // Draw x-axis for moisture graph
  line(50, height - 30, width / 2 - 50, height - 30);
  textAlign(CENTER);
  textSize(12);
  int interval = 60; // One minute interval
  for (int i = 0; i < (width / 2 - 100); i += interval) {
    line(50 + i, height - 25, 50 + i, height - 35);
    fill(255); // Set text color to white
   // text((i / interval) + " min", 50 + i, height - 30);
  }
  // Label x-axis for moisture graph
  textAlign(CENTER);
  textSize(14);
  text("Time", (width / 4-150) + (width / 2 - 100) / 2, height - 10);
}

// Function to draw data points for moisture graph
void drawMoistureDataPoints() {
  noFill();
  stroke(255); // Set line color to white
  beginShape();
  // Determine the index of the first visible data point
  int startIndex = max(0, dataPointIndex - (width / 2 - 100));
  for (int i = startIndex; i < dataPointIndex; i++) {
    float x = map(i, startIndex, dataPointIndex - 1, 50, (width / 2) - 50);
    float y = map(moistureData[i], 1, 100, height - 30, height - 280);
    vertex(x, y);
  }
  endShape();
}

// Function to display time and y-value on hover for moisture graph
void displayMoistureHoverInfo() {
  for (int i = 0; i < dataPointIndex; i++) {
    float x = map(i, 1, dataPointIndex - 1, 50, (width / 2) - 50);
    float y = map(moistureData[i], 1, 100, height - 30, height - 280);
    if (dist(mouseX, mouseY, x, y) < 6) {
      fill(255);
      textAlign(LEFT);
      textSize(14);
      text("Time: " + (i * 60/62*8/10) + " sec", mouseX + 10, mouseY - 20);
      text("Moisture: " + moistureData[i] + "%", mouseX + 10, mouseY);
      textAlign(CENTER);
      return;
    }
  }
}

// Function to draw grid lines and numbers on pH graph axes
void drawpHAxes() {
  // Draw y-axis for pH graph
  stroke(255);
  line(width / 2 + 50, height - 280, width / 2 + 50, height - 30); // Adjusted y-axis position for pH graph
  textAlign(RIGHT, CENTER);
  textSize(12);
  for (int i = 0; i <= 14; i++) { // pH scale from 0 to 14
    float y = map(i, 0, 14, height - 30, height - 280);
    line(width / 2 + 45, y, width / 2 + 55, y);
    fill(255); // Set text color to white
    text(i, width / 2 + 40, y);
  }
  // Label y-axis for pH graph
  textAlign(CENTER, CENTER);
  textSize(14);
  rotate(-HALF_PI);
  for (int i = 0; i <= 14; i++) { // pH scale from 0 to 14
    float yLabel = map(i, 0, 14, height - 30, height - 280);
    fill(255); // Set text color to white
    text(i, width / 2 + 20, yLabel); // Adjusted label position for pH graph
  }
  rotate(HALF_PI);

  // Draw x-axis for pH graph
  line(width / 2 + 50, height - 30, width - 50, height - 30);
  textAlign(CENTER);
  textSize(12);
  int interval = 60; // One minute interval
  for (int i = 0; i < (width / 2 - 100); i += interval) {
    line(width / 2 + 50 + i, height - 25, width / 2 + 50 + i, height - 35);
    fill(255); // Set text color to white
 //   text((i / interval) + " min", width / 2 + 50 + i, height - 30);
  }
  // Label x-axis for pH graph
  textAlign(CENTER);
  textSize(14);
  text("Time", width / 2 + 50 + (width / 2 - 100) / 2, height - 10);
}

// Function to draw data points for pH graph
void drawpHDataPoints() {
  noFill();
  stroke(255); // Set line color to white
  beginShape();
  // Determine the index of the first visible data point
  int startIndex = max(0, dataPointIndex - (width / 2 - 100));
  for (int i = startIndex; i < dataPointIndex; i++) {
    float x = map(i, startIndex, dataPointIndex - 1, width / 2 + 50, width - 50);
    float y = map(pHData[i], 14, 0, height - 280, height - 30); // Adjusted pH mapping
    vertex(x, y);
  }
  endShape();
}

// Function to display time and y-value on hover for pH graph
void displaypHHoverInfo() {
  for (int i = 0; i < dataPointIndex; i++) {
    float x = map(i, 0, dataPointIndex - 1, width / 2 + 50, width - 50);
    float y = map(pHData[i], 0, 14, height - 30, height - 280);
    if (dist(mouseX, mouseY, x, y) < 6) {
      fill(255);
      textAlign(LEFT);
      textSize(14);
      text("Time: " + (i * 60/62*8/10) + " sec", mouseX + 10, mouseY - 20);
      text("pH: " + pHData[i], mouseX + 10, mouseY);
      textAlign(CENTER);
      return;
    }
  }
}

// Function to check if moisture level is in range for a specific crop
boolean checkMoistureInRange(String crop, float moistureLevel) {
  boolean withinRange = false;
  if (crop.equalsIgnoreCase("potato")) {
    withinRange = (moistureLevel >= 70 && moistureLevel <= 80);
  }
  if (crop.equalsIgnoreCase("tomato")) {
    withinRange = (moistureLevel >= 60 && moistureLevel <= 80);
  }
  if (crop.equalsIgnoreCase("broccoli")) {
    withinRange = (moistureLevel >= 65 && moistureLevel <= 75);
  }
  if (crop.equalsIgnoreCase("cucumber")) {
    withinRange = (moistureLevel >= 80 && moistureLevel <= 85);
  }
  if (crop.equalsIgnoreCase("bellpepper")) {
    withinRange = (moistureLevel >= 60 && moistureLevel <= 70);
  }
  return withinRange;
}

// Function to check if pH level is in range for a specific crop
boolean checkpHInRange(String crop, float pHLevel) {
  boolean withinRange = false;
  if (crop.equalsIgnoreCase("potato")) {
    withinRange = (pHLevel >= 6.0 && pHLevel <= 6.5);
  }
  if (crop.equalsIgnoreCase("tomato")) {
    withinRange = (pHLevel >= 6.2 && pHLevel <= 6.8);
  }
  if (crop.equalsIgnoreCase("broccoli")) {
    withinRange = (pHLevel >= 6.0 && pHLevel <= 6.8);
  }
  if (crop.equalsIgnoreCase("cucumber")) {
    withinRange = (pHLevel >= 6.0 && pHLevel <= 6.8);
  }
  if (crop.equalsIgnoreCase("bellpepper")) {
    withinRange = (pHLevel >= 6.5 && pHLevel <= 7.0);
  }
  // Add more crop pH ranges as needed
  return withinRange;
}

void setup() {
  size(800, 600);
  noStroke();
  font = createFont("Lucida Sans Regular", 16);
  textFont(font);
  textAlign(CENTER, CENTER);
  textSize(20);
  pImageControl = loadImage("control.png");
  pImageTwistBody = loadImage("twistBody.png");
  pImageCalibration = loadImage("calibration.png");
  pImageInstallation = loadImage("installation.png");
  
  smooth();
  //HERE
  myPort = new Serial(this, "COM6", 9600);
  myPort.bufferUntil('\n'); 
  
  int xOffset = 50;
  int yOffset = 50;
//  int graphWidth = width - xOffset * 2;
//  int graphHeight = height - 300 - yOffset * 2;
  
  setControlP5();
}

void draw() {
  background(backgroundColor); // Clear the background

  noStroke();
  fill(globalTabColor);
  rect(0, tabHeight, width, globalTapHeight);

  fill(255, 255, 255);

  if (cp5.getTab("default").isActive()) {
    image(pImageControl, 0, tabHeight + globalTapHeight);
  } else if (cp5.getTab("twist body").isActive()) {
    image(pImageTwistBody, 0, tabHeight + globalTapHeight);
  } else if (cp5.getTab("calibration").isActive()) {
    image(pImageCalibration, 0, tabHeight + globalTapHeight);
  } else if (cp5.getTab("installation").isActive()) {
    image(pImageInstallation, 0, tabHeight + globalTapHeight);
  } else if (cp5.getTab("Telemetry").isActive()) {
    drawRadar();
    drawLine();
    drawObject();
    drawText();
  } else if (cp5.getTab("Sensors").isActive()) {
    strokeWeight(1);
    drawMoisture_pH();
    }
  getVoltage();
  processEvent();
  
}

void serialEvent(Serial myPort) {
  
  String data = myPort.readStringUntil('\n');
  // data = moistureLevel,pHLevel,iAngle,iDistance
  
  if (data == null) {
    println("data is null!");
    return;
  }
  
  String[] parts = split(data, ',');
  if (parts.length != 4) {
    println("data is not formatted correctly " + data);
  }
  
  moistureLevel = float(parts[0].trim());
  pHLevel = float(parts[1].trim());
  iAngle = int(parts[2].trim());
  iDistance = int(parts[3].trim());
 
  
  //println(parts[0] + " " + parts[1] + " " + parts[2] + " " + parts[3]);
  
  // Add the new data point to the arrays
  if (dataPointIndex < maxDataPoints) {
    moistureData[dataPointIndex] = moistureLevel;
    pHData[dataPointIndex] = pHLevel;
    dataPointIndex++;
  } else {
    // Shift existing data points to make space for the new one
    for (int i = 0; i < maxDataPoints - 1; i++) {
      moistureData[i] = moistureData[i + 1];
      pHData[i] = pHData[i + 1];
    }
    // Add the new data point at the end
    moistureData[maxDataPoints - 1] = moistureLevel;
    pHData[maxDataPoints - 1] = pHLevel;
  }
  
  newData = true;
  
  return;
}

void getVoltage() {
  if (millis() - lastGetVoltage > 1500) {
    float voltage = controlRobot.GetVoltage();
    textlabelVoltage.setText(String.valueOf(voltage) + "V");
    lastGetVoltage = millis();
  }
}

void keyPressed() {
  if (keyCode >= 32 && keyCode <= 126 && crop.length() < 10) { // Only printable ASCII characters
    // Restrict the length of the crop name to fit within the text box
    crop += key;
  } else if (keyCode == BACKSPACE && crop.length() > 0) { // Backspace to delete characters
    crop = crop.substring(0, crop.length()-1);
  }
}

boolean isNumeric(String str) {
  if (str == null || str.length() == 0) {
    return false;
  }
  try {
    float d = Float.parseFloat(str);
  } catch (NumberFormatException nfe) {
    return false;
  }
  return true;
}

void setEvent(int id) {
  if (eventId == 0) {
    eventId = id;
  }
}

void processEvent() {
  if (isProcessEvent) {
    processEvent(eventId);
    isProcessEvent = false;
    eventId = 0;
    textlabelInfo.setText("Ready");
  }
  if (eventId != 0) {
    isProcessEvent = true;
    textlabelInfo.setText("Processing...");
  }
}

void setControlP5() {
  cp5 = new ControlP5(this);
  cp5.setFont(font);  

  setControlP5Tab();
  setControlP5Key();
}

void setControlP5TabTelemetry() {
  cp5.addButton("TelemetryButton")
    .setId(400)
    .setLabel("Begin Telemetry") // Set button label
    .setPosition(20, 150) // Set button position
    .setSize(150, 30) // Set button size
    .moveTo("Telemetry")
    .getCaptionLabel().align(CENTER, CENTER); // Align button label
    
   cp5.addButton("TelemetryButton1")
    .setId(401)
    .setLabel("Stop Telemetry") // Set button label
    .setPosition(20, 200) // Set button position
    .setSize(150, 30) // Set button size
    .moveTo("Telemetry")
    .getCaptionLabel().align(CENTER, CENTER); // Align button label
  
}


void setControlP5Tab() {
  setControlP5TabGlobal();

  cp5.getTab("default")
    .setId(2)
    .setCaptionLabel("control")
    .setHeight(tabHeight)
    .setWidth(tabWidth-40)
    .activateEvent(true)
    .getCaptionLabel().align(CENTER, CENTER)
    ;
  setControlP5TabControl();

  cp5.addTab("twist body")
    .setId(3)
    .setHeight(tabHeight)
    .setWidth(tabWidth)
    .activateEvent(true)
    .getCaptionLabel().align(CENTER, CENTER)
    ;
  setControlP5TabTwistBody();

  cp5.addTab("calibration")
    .setId(4)
    .setHeight(tabHeight)
    .setWidth(tabWidth)
    .activateEvent(true)
    .getCaptionLabel().align(CENTER, CENTER)
    ;
  setControlP5TabCalibration();

  cp5.addTab("installation")
    .setId(5)
    .setHeight(tabHeight)
    .setWidth(tabWidth)
    .activateEvent(true)
    .getCaptionLabel().align(CENTER, CENTER)
    ;
    
  cp5.addTab("Telemetry")
    .setId(6)
    .setHeight(tabHeight)
    .setWidth(tabWidth)
    .activateEvent(true)
    .getCaptionLabel().align(CENTER, CENTER)
    ;
  setControlP5TabTelemetry();
  
  cp5.addTab("Sensors")
    .setId(6)
    .setHeight(tabHeight)
    .setWidth(tabWidth-30)
    .activateEvent(true)
    .getCaptionLabel().align(CENTER, CENTER)
    ;

}




void setControlP5TabGlobal() {
  cp5.addRadioButton("radioButton1")
    .setId(101)
    .setPosition(4, tabHeight + 11)
    .setSize(20, 20)
    .setItemsPerRow(2)
    .setSpacingRow(4)
    .setSpacingColumn(60)
    .addItem("serial", 1)
    .addItem("wi-fi", 2)
    .activate(0)
    .moveTo("global")
    ;

  cp5.addButton("connect")
    .setId(102)
    .setPosition(4, tabHeight + 11 + 20 + 10)
    .setSize(128, 48)
    .moveTo("global")
    .getCaptionLabel().align(CENTER, CENTER)
    ;

  textlabelInfo = cp5.addTextlabel("labelInfo")
    .setText(" ")
    .setPosition(4 + 128 + 24, tabHeight + 11 + 20 + 14)
    .setFont(createFont("Lucida Sans Regular", 32))
    .moveTo("global")
    ;

  textlabelVoltage = cp5.addTextlabel("labelVoltage")
    .setText("0.0V")
    .setPosition(width - 128, tabHeight + 11 + 20 + 14)
    .setFont(createFont("Lucida Sans Regular", 32))
    .moveTo("global")
    ;
}

void setControlP5TabControl() {
  ////
  int buttonWidth = 128;
  int buttonHeight = 48;
  int buttonSpacingX = 4;
  int buttonSpacingY = 4;
  //
  cp5.addButton("Forward(W)")
    .setId(201)
    .setPosition(4 + (buttonWidth + buttonSpacingX) * 1, 136 + (buttonHeight + buttonSpacingY) * 0)
    .setSize(buttonWidth, buttonHeight)
    .getCaptionLabel().align(CENTER, CENTER)
    ;

  cp5.addButton("Backward(S)")
    .setId(202)
    .setPosition(4 + (buttonWidth + buttonSpacingX) * 1, 136 + (buttonHeight + buttonSpacingY) * 2)
    .setSize(buttonWidth, buttonHeight)
    .getCaptionLabel().align(CENTER, CENTER)
    ;

  cp5.addButton("Left(A)")
    .setId(203)
    .setPosition(4 + (buttonWidth + buttonSpacingX) * 0, 136 + (buttonHeight + buttonSpacingY) * 1)
    .setSize(buttonWidth, buttonHeight)
    .getCaptionLabel().align(CENTER, CENTER)
    ;

  cp5.addButton("Right(D)")
    .setId(204)
    .setPosition(4 + (buttonWidth + buttonSpacingX) * 2, 136 + (buttonHeight + buttonSpacingY) * 1)
    .setSize(buttonWidth, buttonHeight)
    .getCaptionLabel().align(CENTER, CENTER)
    ;

  cp5.addButton("Turn left(Q)")
    .setId(205)
    .setPosition(4 + (buttonWidth + buttonSpacingX) * 0, 136 + (buttonHeight + buttonSpacingY) * 0)
    .setSize(buttonWidth, buttonHeight)
    .getCaptionLabel().align(CENTER, CENTER)
    ;

  cp5.addButton("Turn right(E)")
    .setId(206)
    .setPosition(4 + (buttonWidth + buttonSpacingX) * 2, 136 + (buttonHeight + buttonSpacingY) * 0)
    .setSize(buttonWidth, buttonHeight)
    .getCaptionLabel().align(CENTER, CENTER)
    ;
  //
  cp5.addButton("activate(z)")
    .setId(207)
    .setPosition(4 + (buttonWidth + buttonSpacingX) * 0, 136 + (buttonHeight + buttonSpacingY) * 4)
    .setSize(buttonWidth, buttonHeight)
    .getCaptionLabel().align(CENTER, CENTER)
    ;

  cp5.addButton("switch(x)")
    .setId(208)
    .setPosition(4 + (buttonWidth + buttonSpacingX) * 1, 136 + (buttonHeight + buttonSpacingY) * 4)
    .setSize(buttonWidth, buttonHeight)
    .getCaptionLabel().align(CENTER, CENTER)
    ;

  cp5.addButton("deactivate(c)")
    .setId(209)
    .setPosition(4 + (buttonWidth + buttonSpacingX) * 2, 136 + (buttonHeight + buttonSpacingY) * 4)
    .setSize(buttonWidth, buttonHeight)
    .getCaptionLabel().align(CENTER, CENTER)
    ;
  //
  cp5.addSlider("zBody")
    .setPosition(4 + (buttonWidth + buttonSpacingX) * 3 + 32, 136 + (buttonHeight + buttonSpacingY) * 0)
    .setId(210)
    .setSize(20, buttonHeight * 3 + buttonSpacingY * 2 - 24)
    .setRange(0, 45)
    .setDecimalPrecision(0) 
    .setValue(0)
    ;
  cp5.getController("zBody").getCaptionLabel().align(ControlP5.CENTER, ControlP5.BOTTOM_OUTSIDE).setPaddingX(0);

  ////
  int toggleWidth = 95;
  int toggleHeight = 32;
  int toggleSpacingX = 4;
  int toggleSpacingY = 4;

  cp5.addToggle("20")
    .setId(211)
    .setPosition(4 + (toggleWidth + toggleSpacingX) * 0, 136 + (buttonHeight + buttonSpacingY) * 6 + (toggleHeight + toggleSpacingY) * 0)
    .setSize(toggleWidth, toggleHeight)
    .getCaptionLabel().align(CENTER, CENTER)
    ;

  cp5.addToggle("21")
    .setId(212)
    .setPosition(4 + (toggleWidth + toggleSpacingX) * 1, 136 + (buttonHeight + buttonSpacingY) * 6 + (toggleHeight + toggleSpacingY) * 0)
    .setSize(toggleWidth, toggleHeight)
    .getCaptionLabel().align(CENTER, CENTER)
    ;

  cp5.addToggle("a0")
    .setId(213)
    .setPosition(4 + (toggleWidth + toggleSpacingX) * 2, 136 + (buttonHeight + buttonSpacingY) * 6 + (toggleHeight + toggleSpacingY) * 0)
    .setSize(toggleWidth, toggleHeight)
    .getCaptionLabel().align(CENTER, CENTER)
    ;

  cp5.addToggle("a1")
    .setId(214)
    .setPosition(4 + (toggleWidth + toggleSpacingX) * 3, 136 + (buttonHeight + buttonSpacingY) * 6 + (toggleHeight + toggleSpacingY) * 0)
    .setSize(toggleWidth, toggleHeight)
    .getCaptionLabel().align(CENTER, CENTER)
    ;

  cp5.addToggle("15")
    .setId(215)
    .setPosition(4 + (toggleWidth + toggleSpacingX) * 0, 136 + (buttonHeight + buttonSpacingY) * 6 + (toggleHeight + toggleSpacingY) * 1)
    .setSize(toggleWidth, toggleHeight)
    .getCaptionLabel().align(CENTER, CENTER)
    ;

  cp5.addToggle("14")
    .setId(216)
    .setPosition(4 + (toggleWidth + toggleSpacingX) * 1, 136 + (buttonHeight + buttonSpacingY) * 6 + (toggleHeight + toggleSpacingY) * 1)
    .setSize(toggleWidth, toggleHeight)
    .getCaptionLabel().align(CENTER, CENTER)
    ;

  cp5.addToggle("2")
    .setId(217)
    .setPosition(4 + (toggleWidth + toggleSpacingX) * 2, 136 + (buttonHeight + buttonSpacingY) * 6 + (toggleHeight + toggleSpacingY) * 1)
    .setSize(toggleWidth, toggleHeight)
    .getCaptionLabel().align(CENTER, CENTER)
    ;

  cp5.addToggle("3")
    .setId(218)
    .setPosition(4 + (toggleWidth + toggleSpacingX) * 3, 136 + (buttonHeight + buttonSpacingY) * 6 + (toggleHeight + toggleSpacingY) * 1)
    .setSize(toggleWidth, toggleHeight)
    .getCaptionLabel().align(CENTER, CENTER)
    ;
}

void setControlP5TabTwistBody() {
  slider2dMove = cp5.addSlider2D("move")
    .setId(301)
    .setPosition(36, 136)
    .setSize(180, 180)
    .setMinMax(30, 30, -30, -30)
    .setValue(0, 0)
    .moveTo("twist body")
    ;

  cp5.addSlider("zMove")
    .setPosition(252, 136)
    .setId(302)
    .setSize(20, 180)
    .setRange(0, 45)
    .setDecimalPrecision(0) 
    .setValue(0)
    .moveTo("twist body")
    ;
  cp5.getController("zMove").getCaptionLabel().align(ControlP5.CENTER, ControlP5.BOTTOM_OUTSIDE).setPaddingX(0);

  slider2dRotate = cp5.addSlider2D("rotate")
    .setId(303)
    .setPosition(36, 136 + 180 + 32)
    .setSize(180, 180)
    .setMinMax(-10, 10, 10, -10)
    .setValue(0, 0)
    .moveTo("twist body")
    ;

  cp5.addSlider("zRotate")
    .setPosition(252, 136 + 180 + 32)
    .setId(304)
    .setSize(20, 180)
    .setRange(10, -10)
    .setDecimalPrecision(0) 
    .setValue(0)
    .moveTo("twist body")
    ;
  cp5.getController("zRotate").getCaptionLabel().align(ControlP5.CENTER, ControlP5.BOTTOM_OUTSIDE).setPaddingX(0);
}

void setControlP5TabCalibration() {
  cp5.addRadioButton("radioButton2")
    .setId(401)
    .setPosition(4, 136)
    .setSize(20, 20)
    .setItemsPerRow(6)
    .setSpacingRow(4)
    .setSpacingColumn(60)
    .addItem("leg1", 1)
    .addItem("leg2", 2)
    .addItem("leg3", 3)
    .addItem("leg4", 4)
    .addItem("leg5", 5)
    .addItem("leg6", 6)
    .activate(0)
    .moveTo("calibration")
    ;

  ////
  int buttonWidth = 64;
  int buttonHeight = 48;
  int buttonSpacingX = 4;
  int buttonSpacingY = 4;
  //
  cp5.addButton("y+(w)")
    .setId(402)
    .setPosition(4 + (buttonWidth + buttonSpacingX) * 1, 136 + (buttonHeight + buttonSpacingY) * 1)
    .setSize(buttonWidth, buttonHeight)
    .moveTo("calibration")
    .getCaptionLabel().align(CENTER, CENTER)
    ;

  cp5.addButton("y-(s)")
    .setId(403)
    .setPosition(4 + (buttonWidth + buttonSpacingX) * 1, 136 + (buttonHeight + buttonSpacingY) * 3)
    .setSize(buttonWidth, buttonHeight)
    .moveTo("calibration")
    .getCaptionLabel().align(CENTER, CENTER)
    ;

  cp5.addButton("x+(a)")
    .setId(404)
    .setPosition(4 + (buttonWidth + buttonSpacingX) * 0, 136 + (buttonHeight + buttonSpacingY) * 2)
    .setSize(buttonWidth, buttonHeight)
    .moveTo("calibration")
    .getCaptionLabel().align(CENTER, CENTER)
    ;

  cp5.addButton("x-(d)")
    .setId(405)
    .setPosition(4 + (buttonWidth + buttonSpacingX) * 2, 136 + (buttonHeight + buttonSpacingY) * 2)
    .setSize(buttonWidth, buttonHeight)
    .moveTo("calibration")
    .getCaptionLabel().align(CENTER, CENTER)
    ;

  cp5.addButton("z+(r)")
    .setId(406)
    .setPosition(4 + (buttonWidth + buttonSpacingX) * 3.5, 136 + (buttonHeight + buttonSpacingY) * 1)
    .setSize(buttonWidth, buttonHeight)
    .moveTo("calibration")
    .getCaptionLabel().align(CENTER, CENTER)
    ;

  cp5.addButton("z-(f)")
    .setId(407)
    .setPosition(4 + (buttonWidth + buttonSpacingX) * 3.5, 136 + (buttonHeight + buttonSpacingY) * 3)
    .setSize(buttonWidth, buttonHeight)
    .moveTo("calibration")
    .getCaptionLabel().align(CENTER, CENTER)
    ;
  //
  cp5.addButton("confirm")
    .setId(408)
    .setPosition(4 + (buttonWidth + buttonSpacingX) * 0, 136 + (buttonHeight + buttonSpacingY) * 4.5)
    .setSize(buttonWidth * 2 + buttonSpacingX, buttonHeight)
    .moveTo("calibration")
    .getCaptionLabel().align(CENTER, CENTER)
    ;

  cp5.addButton("reset")
    .setId(409)
    .setPosition(4 + (buttonWidth + buttonSpacingX) * 2.5, 136 + (buttonHeight + buttonSpacingY) * 4.5)
    .setSize(buttonWidth * 2 + buttonSpacingX, buttonHeight)
    .moveTo("calibration")
    .getCaptionLabel().align(CENTER, CENTER)
    ;

  cp5.addButton("verify")
    .setId(410)
    .setPosition(4 + (buttonWidth + buttonSpacingX) * 0, 136 + (buttonHeight + buttonSpacingY) * 6.5)
    .setSize(buttonWidth * 2 + buttonSpacingX, buttonHeight)
    .moveTo("calibration")
    .getCaptionLabel().align(CENTER, CENTER)
    ;
}


void setControlP5Key() {
  cp5.mapKeyFor(new ControlKey() {
    public void keyEvent() {
      if (cp5.getTab("default").isActive()) {
        setEvent(201);
      } else if (cp5.getTab("calibration").isActive()) {
        setEvent(402);
      }
    }
  }
  , 'w');

  cp5.mapKeyFor(new ControlKey() {
    public void keyEvent() {
      if (cp5.getTab("default").isActive()) {
        setEvent(202);
      } else if (cp5.getTab("calibration").isActive()) {
        
        setEvent(403);
      }
    }
  }
  , 's');

  cp5.mapKeyFor(new ControlKey() {
    public void keyEvent() {
      if (cp5.getTab("default").isActive()) {
        setEvent(203);
      } else if (cp5.getTab("calibration").isActive()) {
        setEvent(404);
      }
    }
  }
  , 'a');

  cp5.mapKeyFor(new ControlKey() {
    public void keyEvent() {
      if (cp5.getTab("default").isActive()) {
        setEvent(204);
      } else if (cp5.getTab("calibration").isActive()) {
        setEvent(405);
      }
    }
  }
  , 'd');

  cp5.mapKeyFor(new ControlKey() {
    public void keyEvent() {
      if (cp5.getTab("default").isActive()) {
        setEvent(205);
      }
    }
  }
  , 'q');

  cp5.mapKeyFor(new ControlKey() {
    public void keyEvent() {
      if (cp5.getTab("default").isActive()) {
        setEvent(206);
      }
    }
  }
  , 'e');

  cp5.mapKeyFor(new ControlKey() {
    public void keyEvent() {
      if (cp5.getTab("default").isActive()) {
        setEvent(207);
      }
    }
  }
  , 'z');

  cp5.mapKeyFor(new ControlKey() {
    public void keyEvent() {
      if (cp5.getTab("default").isActive()) {
        setEvent(208);
      }
    }
  }
  , 'x');

  cp5.mapKeyFor(new ControlKey() {
    public void keyEvent() {
      if (cp5.getTab("default").isActive()) {
        setEvent(209);
      }
    }
  }
  , 'c');

  cp5.mapKeyFor(new ControlKey() {
    public void keyEvent() {
      if (cp5.getTab("calibration").isActive()) {
        setEvent(406);
      }
    }
  }
  , 'r');

  cp5.mapKeyFor(new ControlKey() {
    public void keyEvent() {
      if (cp5.getTab("calibration").isActive()) {
        setEvent(407);
      }
    }
  }
  , 'f');
}

public void controlEvent(ControlEvent theEvent) {
  setEvent(theEvent.getId());
}

int zBodyLast, xMoveLast, yMoveLast, zMoveLast, xRotateLast, yRotateLast, zRotateLast;

public void processEvent(int id) {
  final int dL = 1;

  float value[];

  switch(id) {
    // connection
    case(102):
    if (cp5.getGroup("radioButton1").getValue() == 1) {
      if (!controlRobot.communication.isSerialAvailable) {
        if (controlRobot.communication.StartSerial())
        {
          cp5.getController("connect").setCaptionLabel("disconnect");
          cp5.getGroup("radioButton1").getController("serial").lock();
          cp5.getGroup("radioButton1").getController("wi-fi").lock();
          cp5.getGroup("radioButton1").getController("serial").setColorLabel(160);
          cp5.getGroup("radioButton1").getController("wi-fi").setColorLabel(160);

          if (cp5.getTab("default").isActive()) {
            processEvent(2);
          } else if (cp5.getTab("twist body").isActive()) {
            processEvent(3);
          } else if (cp5.getTab("calibration").isActive()) {
            processEvent(4);
          } else if (cp5.getTab("installation").isActive()) {
            processEvent(5);
          }
        }
      } else {
        controlRobot.communication.StopSerial();
        cp5.getController("connect").setCaptionLabel("connect");
        cp5.getGroup("radioButton1").getController("serial").unlock();
        cp5.getGroup("radioButton1").getController("wi-fi").unlock();
        cp5.getGroup("radioButton1").getController("serial").setColorLabel(255);
        cp5.getGroup("radioButton1").getController("wi-fi").setColorLabel(255);
      }
    } else {
      if (!controlRobot.communication.isClientAvailable) {
        if (controlRobot.communication.StartClient())
        {
          cp5.getController("connect").setCaptionLabel("disconnect");
          cp5.getGroup("radioButton1").getController("serial").lock();
          cp5.getGroup("radioButton1").getController("wi-fi").lock();
          cp5.getGroup("radioButton1").getController("serial").setColorLabel(160);
          cp5.getGroup("radioButton1").getController("wi-fi").setColorLabel(160);

          if (cp5.getTab("default").isActive()) {
            processEvent(2);
          } else if (cp5.getTab("twist body").isActive()) {
            processEvent(3);
          } else if (cp5.getTab("calibration").isActive()) {
            processEvent(4);
          } else if (cp5.getTab("installation").isActive()) {
            processEvent(5);
          }
        }
      } else {
        controlRobot.communication.StopClient();
        cp5.getController("connect").setCaptionLabel("connect");
        cp5.getGroup("radioButton1").getController("serial").unlock();
        cp5.getGroup("radioButton1").getController("wi-fi").unlock();
        cp5.getGroup("radioButton1").getController("serial").setColorLabel(255);
        cp5.getGroup("radioButton1").getController("wi-fi").setColorLabel(255);
      }
    }
    break;

    // switch tab
    case(2):
    cp5.getController("zBody").setValue(0);
    controlRobot.ChangeBodyHeight(0);
    controlRobot.ActiveMode();
    zBodyLast = 0;
    break;
    case(3):
    slider2dMove.setValue(0, 0);
    cp5.getController("zMove").setValue(0);
    slider2dRotate.setValue(0, 0);
    cp5.getController("zRotate").setValue(0);
    controlRobot.TwistBody(0, 0, 0, 0, 0, 0);
    xMoveLast = 0;
    yMoveLast = 0;
    zMoveLast = 0;
    xRotateLast = 0;
    yRotateLast = 0;
    zRotateLast = 0;
    break;
    case(4):
    controlRobot.ChangeBodyHeight(0);
    controlRobot.SleepMode();
    controlRobot.CalibrateState();
    cp5.getController("confirm").unlock();
    cp5.getController("confirm").setColorLabel(255);
    break;
    case(5):
    controlRobot.InstallState();
    break;

    // tab Control
    // move robot
    case(201):
    controlRobot.CrawlForward();
    break;
    case(202):
    controlRobot.CrawlBackward();
    break;
    case(203):
    controlRobot.CrawlLeft();
    break;
    case(204):
    controlRobot.CrawlRight();
    break;
    case(205):
    controlRobot.TurnLeft();
    break;
    case(206):
    controlRobot.TurnRight();
    break;
    case(207):
    controlRobot.ActiveMode();
    break;
    case(208):
    controlRobot.SwitchMode();
    break;
    case(209):
    controlRobot.SleepMode();
    break;
    case(210):
    int zBody = (int)cp5.getController("zBody").getValue();
    if(zBodyLast != zBody)
      controlRobot.ChangeBodyHeight(zBody);
    zBodyLast = zBody;
    break;
    // change IO
    case(211):
    controlRobot.ChangeIO(0, cp5.getController("20").getValue() == 1 ? true : false);
    break;
    case(212):
    controlRobot.ChangeIO(1, cp5.getController("21").getValue() == 1 ? true : false);
    break;
    case(213):
    controlRobot.ChangeIO(2, cp5.getController("a0").getValue() == 1 ? true : false);
    break;
    case(214):
    controlRobot.ChangeIO(3, cp5.getController("a1").getValue() == 1 ? true : false);
    break;
    case(215):
    controlRobot.ChangeIO(4, cp5.getController("15").getValue() == 1 ? true : false);
    break;
    case(216):
    controlRobot.ChangeIO(5, cp5.getController("14").getValue() == 1 ? true : false);
    break;
    case(217):
    controlRobot.ChangeIO(6, cp5.getController("2").getValue() == 1 ? true : false);
    break;
    case(218):
    controlRobot.ChangeIO(7, cp5.getController("3").getValue() == 1 ? true : false);
    break;

    // tab Twist body
    // twist body
    case(301):
    case(302):
    case(303):
    case(304):
    value = cp5.getController("move").getArrayValue();
    int xMove = (int)value[0];
    int yMove = (int)value[1];
    int zMove = (int)cp5.getController("zMove").getValue();
    value = cp5.getController("rotate").getArrayValue();
    int xRotate = (int)value[1];
    int yRotate = (int)value[0];
    int zRotate = (int)cp5.getController("zRotate").getValue();
    if(xMoveLast != xMove || yMoveLast != yMove || zMoveLast != zMove || xRotateLast != xRotate || yRotateLast != yRotate || zRotateLast != zRotate)
      controlRobot.TwistBody(xMove, yMove, zMove, xRotate, yRotate, zRotate);
    xMoveLast = xMove;
    yMoveLast = yMove;
    zMoveLast = zMove;
    xRotateLast = xRotate;
    yRotateLast = yRotate;
    zRotateLast = zRotate;
    break;
    
    //HERE 
    case(400): 
    //delay can be varied currently delay(400)
 while (true){
    if (iDistance > 20) {
        controlRobot.CrawlForward(); // Move forward continuously
        delay(400); // Adjust delay as needed
    }
    else {
        // Check left and right to choose direction with more space
        if (iAngle >= 60 && iAngle <= 120) {
            if (iAngle < 90) {
                controlRobot.TurnLeft(); // Turn left if more space on the left side
            }
            else {
                controlRobot.TurnRight(); // Turn right if more space on the right side
            }
            delay(400); // Adjust delay as needed
        }
    }
}
    case(401):
      delay(2000); 
    case(402):
    controlRobot.MoveLeg((int)(cp5.getGroup("radioButton2").getValue()), 0, dL, 0);
    break;
    case(403):
    controlRobot.MoveLeg((int)(cp5.getGroup("radioButton2").getValue()), 0, -dL, 0);
    break;
    case(404):
    controlRobot.MoveLeg((int)(cp5.getGroup("radioButton2").getValue()), dL, 0, 0);
    break;
    case(405):
    controlRobot.MoveLeg((int)(cp5.getGroup("radioButton2").getValue()), -dL, 0, 0);
    break;
    case(406):
    controlRobot.MoveLeg((int)(cp5.getGroup("radioButton2").getValue()), 0, 0, dL);
    break;
    case(407):
    controlRobot.MoveLeg((int)(cp5.getGroup("radioButton2").getValue()), 0, 0, -dL);
    break;
    // calibrate
    case(408):
    controlRobot.Calibrate();
    break;
    case(409):
    controlRobot.CalibrateState();
    cp5.getController("confirm").unlock();
    cp5.getController("confirm").setColorLabel(255);
    break;
    case(410):
    controlRobot.CalibrateVerify();
    cp5.getController("confirm").lock();
    cp5.getController("confirm").setColorLabel(160);
    break;
  }
}
