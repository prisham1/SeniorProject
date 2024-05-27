int fieldWidth, fieldHeight;
int startX, startY;
int pointerX, pointerY;
boolean settingDimensions = true;
boolean settingStart = false;
boolean movingPointer = false;
float scaleFactor;
float stepSize;

PFont font;
String widthBuffer = "";
String heightBuffer = "";
boolean enterWidth = true;

void setup() {
  size(800, 800);
  font = createFont("Arial", 20);
  textFont(font);
  background(255);
  fill(0);
  textAlign(CENTER, CENTER);
  text("Enter field width and height (in feet):", width / 2, height / 2 - 50);
  text("Width:", width / 2 - 100, height / 2);
  text("Height:", width / 2 - 100, height / 2 + 40);
}

void draw() {
  if (movingPointer) {
    background(0);
    drawField();
    drawPointer();
  } else if (settingDimensions) {
    background(255);
    fill(0);
    text("Enter field width and height (in feet):", width / 2, height / 2 - 50);
    text("Width:", width / 2 - 100, height / 2);
    text("Height:", width / 2 - 100, height / 2 + 40);
    fill(255);
    rect(width / 2, height / 2 - 10, 100, 30);
    rect(width / 2, height / 2 + 30, 100, 30);
    fill(0);
    textAlign(LEFT, CENTER);
    text(widthBuffer, width / 2 + 10, height / 2 + 5);
    text(heightBuffer, width / 2 + 10, height / 2 + 45);
  } else if (settingStart) {
    background(0);
    fill(255);
    text("Click to set starting position", width / 2, height / 2);
  }
}

void keyPressed() {
  if (settingDimensions) {
    if (key == ENTER) {
      if (enterWidth) {
        enterWidth = false;
      } else {
        fieldWidth = int(widthBuffer) * 12; // Convert feet to inches
        fieldHeight = int(heightBuffer) * 12; // Convert feet to inches
        settingDimensions = false;
        settingStart = true;
        background(0);
        fill(255);
        text("Click to set starting position", width / 2, height / 2);
      }
    } else if (key == BACKSPACE) {
      if (enterWidth && widthBuffer.length() > 0) {
        widthBuffer = widthBuffer.substring(0, widthBuffer.length() - 1);
      } else if (!enterWidth && heightBuffer.length() > 0) {
        heightBuffer = heightBuffer.substring(0, heightBuffer.length() - 1);
      }
    } else if (key >= '0' && key <= '9') {
      if (enterWidth) {
        widthBuffer += key;
      } else {
        heightBuffer += key;
      }
    }
  } else if (movingPointer) {
    if (key == 'w') {
      pointerY -= stepSize;
    } else if (key == 's') {
      pointerY += stepSize;
    } else if (key == 'a') {
      pointerX -= stepSize;
    } else if (key == 'd') {
      pointerX += stepSize;
    }
  }
}

void mouseClicked() {
  if (settingStart) {
    startX = mouseX;
    startY = mouseY;
    pointerX = startX;
    pointerY = startY;
    settingStart = false;
    movingPointer = true;
    scaleFactor = min((width - 40) / (float)fieldWidth, (height - 40) / (float)fieldHeight); // Add padding of 20 pixels on each side
    stepSize = 2 * scaleFactor; // 2 inches in real life
    background(0);
  }
}

void drawField() {
  stroke(255);
  noFill();
  float fieldX = (width - fieldWidth * scaleFactor) / 2;
  float fieldY = (height - fieldHeight * scaleFactor) / 2;
  rect(fieldX, fieldY, fieldWidth * scaleFactor, fieldHeight * scaleFactor);
}

void drawPointer() {
  fill(255, 0, 0);
  ellipse(pointerX, pointerY, 10, 10);
}
