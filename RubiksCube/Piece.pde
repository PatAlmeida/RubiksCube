class Piece {
  
  int x, y, z;
  float size;
  CubeColor[] colors;
  
  public Piece(int i, int j, int k, CubeColor[] cols, float s) {
    x = i; y = j; z = k;
    size = s;
    colors = cols;
  }
  
  void show() {
    
    pushMatrix();
    
    translate(x * size, y * size, z * size);
    stroke(0);
    strokeWeight(2);
    noFill();
    box(size);
    
    for (int i = 0; i < 6; i++) {
      if (colors[i] != CubeColor.NONE) {
      
        switch(colors[i]) {
          case WHITE: fill(255, 245, 245); break;
          case GREEN: fill(0, 180, 0); break;
          case RED: fill(255, 44, 180); break;
          case BLUE: fill(0, 160, 255); break;
          case ORANGE: fill(255, 140, 0); break;
          case YELLOW: fill(255, 255, 0); break;
          case NONE: fill(0, 0, 0); break;
        }
        
        float xPos = (i == 2 || i == 3) ? size/2 : -size/2;
        float yPos = (i == 5) ? size/2 : -size/2;
        float zPos = (i == 1 || i == 2 || i == 5) ? size/2 : -size/2;
        float xRot = (i == 0) ? PI/2 : 0; if (i == 5) xRot = -PI/2;
        float yRot = (i == 2) ? PI/2 : 0; if (i == 4) yRot = -PI/2;
        float zRot = (i == 3) ? PI/2 : 0;
        
        pushMatrix();
        translate(xPos, yPos, zPos);
        rotateX(xRot); rotateY(yRot); rotateZ(zRot);
        rect(0, 0, size, size);
        popMatrix();
      
      }
    }
    
    popMatrix();
    
  }
  
  String getColorPrint() {
    String str = "";
    for (CubeColor col : colors) str += col + " ";
    return str;
  }
  
}
