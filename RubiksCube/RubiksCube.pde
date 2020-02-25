import peasy.PeasyCam;
import java.util.Scanner;

PeasyCam camera;

int ORDER = 3;
float PIECE_SIZE = 50;

String screenText;
int screenX;

boolean scrambling = true;
ArrayList<String> scrambleList;
String scramble = "L F2 R2 F2 B R' U B L' U F' L2 R2 D' L' R' B L' B2 R2";

boolean animating = false;
boolean animFirstTime = true;
boolean animScrambling = true;
boolean animDelay = false;
boolean animSolving = false;
int animIndex = 0;

int waitCount = 75;

boolean solving = false;
ArrayList<ArrayList<String>> stepLists;
String cross = "R U D' L' U F U R F' R' U2";
String pair1 = "D' L D' L' D2 L D' L'";
String pair2 = "R' D R D' R' D' R";
String pair3 = "B D B'";
String pair4 = "R' D2 R D' B' D B";
String mistake = "R' D2 R D' R' D R";
String oll1 = "F L D L' D' F'";
String oll2 = "R D2 R' D' R D' R'";
String pll1 = "B' L B' R2 B L' B' R2 B2";
String pll2 = "R D' R D R D R D' R' D' R2";

Cube cube;

void setup() {
  
  size(512, 512, P3D);
  
  float center = (ORDER - 3) * PIECE_SIZE/2 + PIECE_SIZE;
  camera = new PeasyCam(this, center, center, center, 300);
  resetCam();
  
  screenText = "Scrambling...";
  screenX = -65;
  
  cube = new Cube(ORDER, PIECE_SIZE);
  cube.scramble();
  
  scrambleList = initMoveString(scramble);
  
  stepLists = new ArrayList<ArrayList<String>>();
  stepLists.add(initMoveString(cross));
  stepLists.add(initMoveString(pair1));
  stepLists.add(initMoveString(pair2));
  stepLists.add(initMoveString(pair3));
  stepLists.add(initMoveString(pair4));
  stepLists.add(initMoveString(mistake));
  stepLists.add(initMoveString(oll1));
  stepLists.add(initMoveString(oll2));
  stepLists.add(initMoveString(pll1));
  stepLists.add(initMoveString(pll2));
  
}

void draw() {
  
  background(100);
  
  cube.show();
  drawAxis();
  
  if (animating) animateSolve();
  
}

void keyPressed() {
       if (key == 'q') resetCam();
  else if (key == 'p') cube.scramble();
  else if (key == 'w') cube.solve();
  else if (key == 'o') cube.solveState = SolveState.L1E;
  else if (key == 'm') printCamInfo();
  else if (key == 'n') println(cube.latestScramble);
  else if (key == 'a') println(cube.solveMoveList);
  else if (key == 't') animating = true;
  else cube.move(Character.toString(key).toUpperCase());
}

void printCamInfo() {
  println("Camera distance: " + camera.getDistance());
  print("Camera rotations: ");
  for (float rot : camera.getRotations()) print(rot + " ");
  println("");
}

void resetCam() {
  camera.setDistance(384.6);
  camera.setRotations(0.751, 0.458, -0.255);
}

ArrayList<String> initMoveString(String scram) {
  Scanner scan = new Scanner(scram);
  scan.useDelimiter(" ");
  ArrayList<String> list = new ArrayList<String>();
  while (scan.hasNext()) list.add(scan.next());
  scan.close();
  return list;
}

void animateSolve() {
  
  if (animFirstTime) {
    while (cube.pieces[10].colors[0] != cube.initUpCol) cube.move("X");
    while (cube.pieces[14].colors[1] != cube.initFrontCol) cube.move("Y");
    animFirstTime = false;
  }
  
  if (animScrambling) {
    if (frameCount % 10 == 0) {
      cube.move(cube.latestScramble.get(animIndex));
      animIndex++;
      if (animIndex == cube.latestScramble.size()) {
        animIndex = 0;
        animScrambling = false;
        animDelay = true;
      }
    }
  } else if (animDelay) {
    animIndex++;
    if (animIndex == 240) {
      animIndex = 0;
      animDelay = false;
      animSolving = true;
    }
  } else if (animSolving) {
    if (frameCount % 5 == 0) {
      cube.move(cube.solveMoveList.get(animIndex));
      animIndex++;
      if (animIndex == cube.solveMoveList.size()) {
        animIndex = 0;
        animSolving = false;
        animScrambling = true;
        animating = false;
      }
    }
  }
  
}

void doTestSolve() {
  
  stroke(0);
  fill(255);
  textSize(40);
  text(screenText, screenX, -70, 50);
  
  if (scrambling && frameCount % 10 == 0) {
    cube.move(scrambleList.remove(0));
    scrambling = !scrambleList.isEmpty();
  }
  
  // Delay after scramble finishes
  if (!scrambling && !solving && waitCount > 0) {
    screenText = "";
    waitCount--;
    solving = waitCount == 0;
  }
  
  if (solving && frameCount % 5 == 0 && !stepLists.isEmpty()) {
    screenText = "Solving...";
    screenX = -30;
    if (stepLists.get(0).isEmpty()) {
      stepLists.remove(0);
    } else {
      cube.move(stepLists.get(0).remove(0));
    }
  }
  
  if (stepLists.isEmpty()) {
    screenText = "";
  }
  
}

void drawAxis() {
  strokeWeight(1);
  stroke(255, 0, 0); // Positive x
  line(0, 0, 0, 10000, 0, 0);
  stroke(0, 255, 0); // Positive y
  line(0, 0, 0, 0, 10000, 0);
  stroke(0, 0, 255); // Positive z
  line(0, 0, 0, 0, 0, 10000);
}
