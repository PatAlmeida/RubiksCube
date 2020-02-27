class Cube {
  
  int SCR_LEN = 40;
  
  // Color-Order-With-Yellow-Up
  CubeColor[] COYU = {CubeColor.BLUE, CubeColor.RED, CubeColor.GREEN, CubeColor.ORANGE};
  
  HashMap<Integer, String> sides;
  HashMap<Integer, String> mods;
  
  ArrayList<String> latestScramble;
  ArrayList<String> solveMoveList;
  
  CubeColor initUpCol = CubeColor.WHITE;
  CubeColor initFrontCol = CubeColor.GREEN;
  
  SolveState solveState;
  
  boolean doneSolving;
  
  int order;
  float pieceSize;
  
  Piece[] pieces;
 
  public Cube(int o, float pSize) {
    
    makeMaps();
    
    latestScramble = new ArrayList<String>();
    solveMoveList = new ArrayList<String>();
    
    solveState = SolveState.L1E;
    
    order = o;
    pieceSize = pSize;
    
    doneSolving = false;
    
    pieces = new Piece[int(pow(order, 3))];
    
    CubeColor N = CubeColor.NONE;
    
    for (int i = 0; i < order; i++) {
      for (int j = 0; j < order; j++) {
        for (int k = 0; k < order; k++) {
          
          CubeColor[] colors = {N, N, N, N, N, N};
          if (j == 0) colors[0] = CubeColor.WHITE;
          if (k == order - 1) colors[1] = CubeColor.GREEN;
          if (i == order - 1) colors[2] = CubeColor.RED;
          if (k == 0) colors[3] = CubeColor.BLUE;
          if (i == 0) colors[4] = CubeColor.ORANGE;
          if (j == order - 1) colors[5] = CubeColor.YELLOW;
          
          pieces[i*order*order + j*order + k] = new Piece(i, j, k, colors, pieceSize);
          
    }}}
    
  }
  
  void makeMaps() {
    sides = new HashMap<Integer, String>();
    sides.put(0, "U");
    sides.put(1, "F");
    sides.put(2, "R");
    sides.put(3, "B");
    sides.put(4, "L");
    sides.put(5, "D");
    mods = new HashMap<Integer, String>();
    mods.put(0, "");
    mods.put(1, "'");
    mods.put(2, "2");
  }
  
  void show() {
    for (Piece piece : pieces) piece.show();
  }
  
  void scramble() {
    latestScramble.clear();
    solveMoveList.clear();
    doneSolving = false;
    solveState = SolveState.L1E;
    for (int i = 0; i < SCR_LEN; i++) {
      String moveStr = sides.get((int)random(6)) + mods.get((int)random(3));
      latestScramble.add(moveStr);
      move(moveStr);
    }
    initUpCol = pieces[10].colors[0];
    initFrontCol = pieces[14].colors[1];
  }
  
  void solve() {
    
    switch(solveState) {
      
      case L1E:
      
        // Check if yellow is on top
        CubeColor topCol = pieces[10].colors[0];
        if (topCol != CubeColor.YELLOW) {
          addToSolve("X2"); // Assumes White Top Green Front to start
        }
                           
        // Check if the cross is complete
        int[] ptc = {14, 17, 22, 25, 12, 15, 4, 7}; // piecesToCheck
        boolean crossSolved = true;
        for (int i = 0; i < 4; i++) {
          crossSolved = (pieces[ptc[2*i]].colors[i+1] == pieces[ptc[2*i + 1]].colors[i+1])
                     && pieces[ptc[2*i + 1]].colors[5] == CubeColor.WHITE;
          if (!crossSolved) i = 4;
        }
                           
        if (crossSolved) {
          solveState = SolveState.L1C;
        } else {
        
          // Search top layer for a Cross piece
          CubeColor W = CubeColor.WHITE;
          Piece tlp = pieces[11]; // topLayerPiece
          boolean foundWhiteSticker = false;
          int[] topLayerEdges = {11, 19, 9, 1};
          for (int i = 0; i < topLayerEdges.length; i++) {
            tlp = pieces[topLayerEdges[i]];
            // Check for a white sticker
            foundWhiteSticker = (tlp.colors[0] == W || tlp.colors[i+1] == W);
            if (foundWhiteSticker) i = topLayerEdges.length;
          }
          
          // Solve the piece
          if (foundWhiteSticker) {
            
            // Move the piece to the Front
            if (tlp.x == 0) addToSolve("U'");
            else if (tlp.x == 2) addToSolve("U");
            else if (tlp.z == 0) addToSolve("U2");
            
            tlp = pieces[11];
            
            // Do Dw moves until Front center matches with non-White color
            CubeColor otherCol = CubeColor.NONE;
            if (tlp.colors[0] == W) otherCol = tlp.colors[1];
            else otherCol = tlp.colors[0];
            while (pieces[14].colors[1] != otherCol) addToSolve("Dw");
            
            // Solve the piece
            if (tlp.colors[0] == W) addToSolve("F2");
            else doAlg(Algs.CROSS_FRONT_LAYER);
            
          } 
          
          // Get a Cross piece in the top layer
          else {
            
            // Search middle layer for a cross piece
            int[] middleLayerEdges = {3, 5, 21, 23};
            Piece mlp = pieces[3]; // middleLayerPiece
            boolean foundOne = false;
            for (int i = 0; i < middleLayerEdges.length; i++) {
              mlp = pieces[middleLayerEdges[i]];
              if (i == 0) {
                if (mlp.colors[3] == W || mlp.colors[4] == W) {
                  foundOne = true; i = middleLayerEdges.length;
                }
              } else if (i == 1) {
                if (mlp.colors[1] == W || mlp.colors[4] == W) {
                  foundOne = true; i = middleLayerEdges.length;
                }
              } else if (i == 2) {
                if (mlp.colors[2] == W || mlp.colors[3] == W) {
                  foundOne = true; i = middleLayerEdges.length;
                }
              } else {
                if (mlp.colors[1] == W || mlp.colors[2] == W) {
                  foundOne = true; i = middleLayerEdges.length;
                }
              }
            }
            
            // Take the edge piece out, then solve again
            if (foundOne) {
              
              // Move piece to Front-Right
              if (mlp.x == 0 && mlp.z == 0) addToSolve("Dw2");
              else if (mlp.x == 0 && mlp.z == 2) addToSolve("Dw");
              else if (mlp.x == 2 && mlp.z == 0) addToSolve("Dw'");
              
              // Move piece to top layer
              doAlg(Algs.SEXY);
              
            }
            
            // There must be one in the bottom layer
            else {
              
              // Find the piece
              int[] stc = {14, 17, 22, 25, 12, 15, 4, 7}; // spotsToCheck
              int index = 0;
              boolean found = false;
              for (int i = 0; i < stc.length; i++) {
                Piece blp = pieces[stc[2*i + 1]]; // bottomLayerPiece
                if (blp.colors[i+1] == CubeColor.WHITE || blp.colors[i+1] != pieces[stc[2*i]].colors[i+1]) {
                  found = true; index = i; i = stc.length;
                }
              }
              
              // Move it to top layer
              if (found) {
                if (index == 0) addToSolve("F2");
                else if (index == 1) addToSolve("R2");
                else if (index == 2) addToSolve("B2");
                else if (index == 3) addToSolve("L2");
              } else {
                println("This should hopefully never get here");
              }
              
            }
            
          }
        
        }
        
        break;
        
      case L1C:
      
        // Check if corners are done
        CubeColor fc = pieces[14].colors[1]; // frontColor
        int indexOfFC = indexOfCOYU(fc);
        // Get indexes for adjacent colors
        int iolc = indexOfFC - 1; if (iolc == -1) iolc = 3;
        int iorc = indexOfFC + 1;if (iorc == 4) iorc = 0;
        int iobc = indexOfFC + 2; if (iobc > 3) iobc = iobc - 4;
        CubeColor bc = COYU[iobc];
        boolean frontSame = pieces[8].colors[1] == fc && pieces[17].colors[1] == fc && pieces[26].colors[1] == fc;
        boolean frontCors = pieces[8].colors[4] == COYU[iolc] && pieces[26].colors[2] == COYU[iorc];
        boolean backSame = pieces[6].colors[3] == bc && pieces[15].colors[3] == bc && pieces[24].colors[3] == bc;
        boolean backCors = pieces[6].colors[4] == COYU[iolc] && pieces[24].colors[2] == COYU[iorc];
        
        // Corners are done
        if (frontSame && frontCors && backSame && backCors) {
          solveState = SolveState.L2E;
        } 
        
        // Find a corner piece
        else {
          
          // Check the top layer for a White corner
          int[] topLayerCorners = {20, 18, 0, 2};
          CubeColor W = CubeColor.WHITE;
          Piece tlp = pieces[20];
          boolean foundCor = false;
          int i = 0;
          for (i = 0; i < 4; i++) {
            tlp = pieces[topLayerCorners[i]];
            int j = i+1; int k = i+2;
            if (i == 3) k = 1;
            foundCor = tlp.colors[0] == W || tlp.colors[j] == W || tlp.colors[k] == W;
            if (foundCor) break;
          }
          
          // Solve the corner
          if (foundCor) {
            
            // Move it into place
            if (i == 1) addToSolve("U");
            else if (i == 2) addToSolve("U2");
            else if (i == 3) addToSolve("U'");
            
            tlp = pieces[20];
            
            // Do the correct alg based on where the White sticker is
            CubeColor searchCol = CubeColor.NONE;
            if (tlp.colors[0] == W) searchCol = tlp.colors[2];
            else if (tlp.colors[1] == W) searchCol = tlp.colors[0];
            else if (tlp.colors[2] == W) searchCol = tlp.colors[1];
            while (pieces[14].colors[1] != searchCol) addToSolve("Dw");
            if (tlp.colors[0] == W) doAlg(Algs.CORNER_UP);
            else if (tlp.colors[1] == W) doAlg(Algs.CORNER_FRONT);
            else if (tlp.colors[2] == W) doAlg(Algs.SEXY);
            
          }
          
          // Take a piece out of the bottom layer
          else {
            
            // Find a corner
            int[] stc = {26, 17, 24, 25, 6, 15, 8, 7}; // spotsToCheck
            int index = 0;
            boolean found = false;
            for (int j = 0; j < 4; j++) {
              Piece blp = pieces[stc[2*j]]; // bottomLayerPiece
              int i1 = j+1; int i2 = j+2; if (i2 == 5) i2 = 1;
              if (blp.colors[i1] == W || blp.colors[i2] == W || blp.colors[i1] != pieces[stc[2*j + 1]].colors[i1]) {
                found = true; index = j; j = 4;
              }
            }
            
            // Bring it to the top layer
            if (found) {
              if (index == 1) addToSolve("Dw'");
              else if (index == 2) addToSolve("Dw2");
              else if (index == 3) addToSolve("Dw");
              doAlg(Algs.SEXY);
            } else {
              println("This should hopefully never get here");
            }
            
          }
          
        }
        
        break;
        
      case L2E:
      
        // Check if the middle layer is finished - trying a different approach here
        int[] stc = {5, 14, 23, 23, 22, 21, 21, 12, 3, 3, 4, 5}; // spotsToCheck
        boolean middleDone = true;
        for (int i = 0; i < 4; i++) {
          CubeColor col = pieces[stc[3*i + 1]].colors[i+1];
          middleDone = pieces[stc[3*i]].colors[i+1] == col && pieces[stc[3*i + 2]].colors[i+1] == col;
          if (!middleDone) i = 4;
        }
        
        // Move on to the next step
        if (middleDone) {
          solveState = SolveState.EOLL;
        }
        
        // Find a piece without Yellow on the top layer
        else {
          
          int[] tle = {11, 19, 9, 1}; // topLayerEdges
          boolean foundOne = false;
          Piece piece = pieces[11];
          int i = 0;
          for (i = 0; i < 4; i++) {
            piece = pieces[tle[i]];
            if (piece.colors[0] != CubeColor.YELLOW && piece.colors[i+1] != CubeColor.YELLOW) {
              foundOne = true; break;
            }
          }
          
          // Solve the piece
          if (foundOne) {
            
            if (i == 0) addToSolve("U'");
            else if (i == 2) addToSolve("U");
            else if (i == 3) addToSolve("U2");
            
            CubeColor sideCol = pieces[19].colors[2];
            while (pieces[22].colors[2] != sideCol) addToSolve("Dw");
            
            // Do correct alg based on where piece needs to go
            if (pieces[19].colors[0] == pieces[14].colors[1]) doAlg(Algs.EDGE_FRONT);
            else doAlg(Algs.EDGE_BACK);
            
          }
          
          // The only middle layer pieces are in the wrong spot in the middle layer
          else {
            
            // Pretty sure you only need to check the center and one adjacent piece on each side
            int[] mlp = {14, 23, 22, 21, 12, 3, 4, 5}; // middleLayerPieces
            for (i = 0; i < 4; i++) {
              if (pieces[mlp[2*i]].colors[i+1] != pieces[mlp[2*i + 1]].colors[i+1]) {
                if (i == 0) addToSolve("Dw");
                else if (i == 2) addToSolve("Dw'");
                else if (i == 3) addToSolve("Dw2");
                doAlg(Algs.EDGE_BACK);
                break;
              }
            }
            // The only other possible case is when all edges are rotated (I think...)
            doAlg(Algs.EDGE_BACK);
            
          }
          
        }
      
        break;
        
      case EOLL:
      
        // Check if the Yellow cross is done
        CubeColor Y = CubeColor.YELLOW;
        boolean crossDone = pieces[11].colors[0] == Y && pieces[19].colors[0] == Y
                         && pieces[9].colors[0] == Y && pieces[1].colors[0] == Y;
        
        if (crossDone) {
          solveState = SolveState.COLL;
        }
        
        else {
          
          ArrayList<Integer> pwy = new ArrayList<Integer>(); // piecesWithYellow
          int[] tlp = {11, 19, 9, 1}; // topLayerPieces
          for (int i = 0; i < 4; i++) {
            if (pieces[tlp[i]].colors[0] == Y) pwy.add(tlp[i]);
          }
          
          // The amount of piece with Yellow on top will always be 0 or 2
          if (pwy.size() == 0) {
            doAlg(Algs.EOLL);
          } else {
            
            // Determine if L or Bar
            boolean isL = true;
            if (pwy.contains(11)) {
              isL = !pwy.contains(9);
            } else {
              isL = !(pwy.contains(1) && pwy.contains(19));
            }
            
            if (isL) {
              while (!(pieces[9].colors[0] == Y && pieces[1].colors[0] == Y)) addToSolve("U");
            } else {
              while (!(pieces[1].colors[0] == Y && pieces[19].colors[0] == Y)) addToSolve("U");
            }
            
            doAlg(Algs.EOLL);
            
          }
          
        }
      
        break;
        
      case COLL:
      
        // Going to do something a little more sophisticated here
        
        // Count the Yellow sticker corners already oriented
        int[] tlc = {0, 2, 18, 20}; // topLayerCorners
        int count = 0;
        Y = CubeColor.YELLOW;
        for (int i = 0; i < 4; i++) {
          if (pieces[tlc[i]].colors[0] == Y) count++;
        }
        
        // Determine which alg to do based on the number of corners already in place
        if (count == 0) {
          while (!(pieces[18].colors[3] == Y && pieces[20].colors[1] == Y)) addToSolve("U");
          if (pieces[2].colors[1] == Y) doAlg(Algs.DOUBLE_HEAD);
          else doAlg(Algs.THAT_BAD_ONE);
        } else if (count == 1) {
          while (pieces[2].colors[0] != Y) addToSolve("U");
          if (pieces[20].colors[1] == Y) doAlg(Algs.SUNE);
          else doAlg(Algs.ANTI_SUNE);
        } else if (count == 2) {
          while (pieces[2].colors[1] != Y) addToSolve("U");
          if (pieces[0].colors[3] == Y) doAlg(Algs.OLL_TC_FB);
          else if (pieces[20].colors[1] == Y) doAlg(Algs.OLL_TC_FF);
          else if (pieces[18].colors[2] == Y) doAlg(Algs.OLL_TC_FR);
        } else if (count == 4) {
          solveState = SolveState.CPLL;
        }
      
        break;
        
      case CPLL:
      
        // Check if finished
        int[] tlp = {2, 20, 20, 18, 18, 0, 0, 2}; // topLayerPieces
        boolean cpllSolved = true;
        int cIndex = indexOfCOYU(pieces[2].colors[1]);
        for (int i = 0; i < 4; i++) {
          CubeColor col = COYU[(cIndex + i) % 4];
          cpllSolved = pieces[tlp[2*i]].colors[i+1] == col && pieces[tlp[2*i + 1]].colors[i+1] == col;
          if (!cpllSolved) break;
        }
        
        if (cpllSolved) {
          // Spin U side until it matches with center
          while (pieces[2].colors[1] != pieces[14].colors[1]) addToSolve("U");
          solveState = SolveState.EPLL;
        }
        
        else {
          
          // Find headlights
          boolean foundHeadlights = false;
          int i = 0;
          for (i = 0; i < 4; i++) {
            foundHeadlights = pieces[tlp[2*i]].colors[i+1] == pieces[tlp[2*i + 1]].colors[i+1];
            if (foundHeadlights) break;
          }
          
          if (foundHeadlights) {
            if (i == 0) addToSolve("U2");
            else if (i == 1) addToSolve("U'");
            else if (i == 3) addToSolve("U");
            doAlg(Algs.A_PERM);
            while (pieces[2].colors[1] != pieces[14].colors[1]) addToSolve("U");
          } else {
            doAlg(Algs.A_PERM);
          }
          
        }
      
        break;
        
      case EPLL:
      
        // Check if cube is solved!
        int[] fpc = {11, 14, 19, 22, 9, 12, 1, 4}; // finalPieceCheck
        boolean solved = true;
        for (int i = 0; i < 4; i++) {
          solved = pieces[fpc[2*i]].colors[i+1] == pieces[fpc[2*i + 1]].colors[i+1];
          if (!solved) break;
        }
        
        if (solved) {
          solveState = SolveState.DONE;
        }
        
        // Finish the corners to solve the cube!
        else {
          
          int[] bp = {2, 11, 20, 20, 19, 18, 18, 9, 0, 0, 1, 2}; // barPieces
          boolean foundBar = false;
          int i = 0;
          for (i = 0; i < 4; i++) {
            CubeColor col = pieces[bp[3*i + 1]].colors[i+1];
            foundBar = pieces[bp[3*i]].colors[i+1] == col && pieces[bp[3*i + 2]].colors[i+1] == col;
            if (foundBar) break;
          }
          
          if (foundBar) {
            
            // Bring the bar to the back and U Perm
            if (i == 0) addToSolve("U2");
            else if (i == 1) addToSolve("U'");
            else if (i == 3) addToSolve("U");
            doAlg(Algs.U_PERM);
            // Undo setup move
            if (i == 0) addToSolve("U2");
            else if (i == 1) addToSolve("U");
            else if (i == 3) addToSolve("U'");
            
          }
          
          // Do a U Perm from anywhere and solve again
          else {
            doAlg(Algs.U_PERM);
          }
          
        }
      
        break;
        
      case DONE:
      
        /* boolean optimizing = true;
        int i = 0;
        ArrayList<String> newSolve = new ArrayList<String>();
        while (optimizing) {
          MoveInfo moveInfo = getMoveInfo(solveMoveList.get(i));
          int turns = moveInfo.getTurns();
          i++;
          if (i < solveMoveList.size()) {
            
          }
        } */
        
        doneSolving = true;
      
        break;
      
    }
    
    if (!doneSolving) solve();
    
  }
  
  MoveInfo getMoveInfo(String str) {
    int len = str.length();
    if (len == 1) return new MoveInfo(str, "");
    else if (len == 2) {
      if (str.charAt(1) == 'w') return new MoveInfo(str, "");
      else return new MoveInfo(str.substring(0, 1), str.substring(1));
    } else return new MoveInfo(str.substring(0, 2), str.substring(2));
  }
  
  void printStartNextStepInfo() {
    println("Starting next step - " + solveMoveList.size() + " moves");
  }
  
  void addToSolve(String moveStr) {
    solveMoveList.add(moveStr);
    move(moveStr);
  }
  
  int indexOfCOYU(CubeColor col) {
    for (int i = 0; i < 4; i++) {
      if (COYU[i] == col) return i;
    }
    return 0;
  }
  
  void doAlg(String[] alg) {
    for (String str : alg) addToSolve(str);
  }
  
  void move(String str) {
    
    if (str.startsWith("X")) {
      
      int rCount = 1; int mCount = 3; int lCount = 3;
      if (str.length() > 1) {
        if (str.charAt(1) == '\'') {
          rCount = 3; mCount = 1; lCount = 1;
        } else if (str.charAt(1) == '2') {
          rCount = 2; mCount = 2; lCount = 2;
        }
      }
      
      for (int i = 0; i < rCount; i++) turn("R");
      for (int i = 0; i < mCount; i++) turn("M");
      for (int i = 0; i < lCount; i++) turn("L");
      
    } else if (str.startsWith("Y")) {
      
      int uCount = 1; int eCount = 3; int dCount = 3;
      if (str.length() > 1) {
        if (str.charAt(1) == '\'') {
          uCount = 3; eCount = 1; dCount = 1;
        } else if (str.charAt(1) == '2') {
          uCount = 2; eCount = 2; dCount = 2;
        }
      }
      
      for (int i = 0; i < uCount; i++) turn("U");
      for (int i = 0; i < eCount; i++) turn("E");
      for (int i = 0; i < dCount; i++) turn("D");
      
    } else if (str.startsWith("Z")) {
      
      int fCount = 1; int sCount = 1; int bCount = 3;
      if (str.length() > 1) {
        if (str.charAt(1) == '\'') {
          fCount = 3; sCount = 3; bCount = 1;
        } else if (str.charAt(1) == '2') {
          fCount = 2; sCount = 2; bCount = 2;
        }
      }
      
      for (int i = 0; i < fCount; i++) turn("F");
      for (int i = 0; i < sCount; i++) turn("S");
      for (int i = 0; i < bCount; i++) turn("B");
      
    } else if (str.length() == 1) {
      
      turn(str);
      
    } else if (str.contains("w")) {
      
      boolean isTwoLong = str.length() == 2;
      
      if (str.charAt(0) == 'U') {
        if (isTwoLong) { turn("E"); turn("E"); turn("E"); }
        else if (str.charAt(2) == '\'') { turn("E"); }
        else if (str.charAt(2) == '2') { turn("E"); turn("E"); }
      } else if (str.charAt(0) == 'F') {
        if (isTwoLong) { turn("S"); }
        else if (str.charAt(2) == '\'') { turn("S"); turn("S"); turn("S"); }
        else if (str.charAt(2) == '2') { turn("S"); turn("S"); }
      } else if (str.charAt(0) == 'R') {
        if (isTwoLong) { turn("M"); turn("M"); turn("M"); }
        else if (str.charAt(2) == '\'') { turn("M"); }
        else if (str.charAt(2) == '2') { turn("M"); turn("M"); }
      } else if (str.charAt(0) == 'B') {
        if (isTwoLong) { turn("S"); turn("S"); turn("S"); }
        else if (str.charAt(2) == '\'') { turn("S"); }
        else if (str.charAt(2) == '2') { turn("S"); turn("S"); }
      } else if (str.charAt(0) == 'L') {
        if (isTwoLong) { turn("M"); }
        else if (str.charAt(2) == '\'') { turn("M"); turn("M"); turn("M"); }
        else if (str.charAt(2) == '2') { turn("M"); turn("M"); }
      } else if (str.charAt(0) == 'D') {
        if (isTwoLong) { turn("E"); }
        else if (str.charAt(2) == '\'') { turn("E"); turn("E"); turn("E"); }
        else if (str.charAt(2) == '2') { turn("E"); turn("E"); }
      }
      
      if (isTwoLong) move(str.substring(0, 1));
      else move(str.substring(0, 1) + str.substring(2));
      
    } else if (str.length() == 2) {
      
      if (str.charAt(1) == '\'') {
        turn(str.substring(0, 1));
        turn(str.substring(0, 1));
        turn(str.substring(0, 1));
      } else if (str.charAt(1) == '2') {
        turn(str.substring(0, 1));
        turn(str.substring(0, 1));
      }
      
    }
    
  }
  
  // Make this work with ORDER
  // Curently only works with 3x3
  
  void turn(String str) {
    
    if (str.equals("U")) {
      
      CubeColor[] cols = colorSave(pieces[0].colors);
      pieces[0].colors[0] = pieces[2].colors[0];
      pieces[0].colors[3] = pieces[2].colors[4];
      pieces[0].colors[4] = pieces[2].colors[1];
      pieces[2].colors[0] = pieces[20].colors[0];
      pieces[2].colors[1] = pieces[20].colors[2];
      pieces[2].colors[4] = pieces[20].colors[1];
      pieces[20].colors[0] = pieces[18].colors[0];
      pieces[20].colors[1] = pieces[18].colors[2];
      pieces[20].colors[2] = pieces[18].colors[3];
      pieces[18].colors[0] = cols[0];
      pieces[18].colors[2] = cols[3];
      pieces[18].colors[3] = cols[4];
      
      cols = colorSave(pieces[9].colors);
      pieces[9].colors[0] = pieces[1].colors[0];
      pieces[9].colors[3] = pieces[1].colors[4];
      pieces[1].colors[0] = pieces[11].colors[0];
      pieces[1].colors[4] = pieces[11].colors[1];
      pieces[11].colors[0] = pieces[19].colors[0];
      pieces[11].colors[1] = pieces[19].colors[2];
      pieces[19].colors[0] = cols[0];
      pieces[19].colors[2] = cols[3];
      
    } else if (str.equals("F")) {
      
      CubeColor[] cols = colorSave(pieces[2].colors);
      pieces[2].colors[0] = pieces[8].colors[4];
      pieces[2].colors[1] = pieces[8].colors[1];
      pieces[2].colors[4] = pieces[8].colors[5];
      pieces[8].colors[1] = pieces[26].colors[1];
      pieces[8].colors[4] = pieces[26].colors[5];
      pieces[8].colors[5] = pieces[26].colors[2];
      pieces[26].colors[1] = pieces[20].colors[1];
      pieces[26].colors[2] = pieces[20].colors[0];
      pieces[26].colors[5] = pieces[20].colors[2];
      pieces[20].colors[0] = cols[4];
      pieces[20].colors[1] = cols[1];
      pieces[20].colors[2] = cols[0];
      
      cols = colorSave(pieces[11].colors);
      pieces[11].colors[0] = pieces[5].colors[4];
      pieces[11].colors[1] = pieces[5].colors[1];
      pieces[5].colors[1] = pieces[17].colors[1];
      pieces[5].colors[4] = pieces[17].colors[5];
      pieces[17].colors[1] = pieces[23].colors[1];
      pieces[17].colors[5] = pieces[23].colors[2];
      pieces[23].colors[1] = cols[1];
      pieces[23].colors[2] = cols[0];
      
    } else if (str.equals("R")) {
      
      CubeColor[] cols = colorSave(pieces[18].colors);
      pieces[18].colors[0] = pieces[20].colors[1];
      pieces[18].colors[2] = pieces[20].colors[2];
      pieces[18].colors[3] = pieces[20].colors[0];
      pieces[20].colors[0] = pieces[26].colors[1];
      pieces[20].colors[1] = pieces[26].colors[5];
      pieces[20].colors[2] = pieces[26].colors[2];
      pieces[26].colors[1] = pieces[24].colors[5];
      pieces[26].colors[2] = pieces[24].colors[2];
      pieces[26].colors[5] = pieces[24].colors[3];
      pieces[24].colors[2] = cols[2];
      pieces[24].colors[3] = cols[0];
      pieces[24].colors[5] = cols[3];
      
      cols = colorSave(pieces[19].colors);
      pieces[19].colors[0] = pieces[23].colors[1];
      pieces[19].colors[2] = pieces[23].colors[2];
      pieces[23].colors[1] = pieces[25].colors[5];
      pieces[23].colors[2] = pieces[25].colors[2];
      pieces[25].colors[2] = pieces[21].colors[2];
      pieces[25].colors[5] = pieces[21].colors[3];
      pieces[21].colors[2] = cols[2];
      pieces[21].colors[3] = cols[0];
      
    } else if (str.equals("B")) {
      
      CubeColor[] cols = colorSave(pieces[18].colors);
      pieces[18].colors[0] = pieces[24].colors[2];
      pieces[18].colors[2] = pieces[24].colors[5];
      pieces[18].colors[3] = pieces[24].colors[3];
      pieces[24].colors[2] = pieces[6].colors[5];
      pieces[24].colors[3] = pieces[6].colors[3];
      pieces[24].colors[5] = pieces[6].colors[4];
      pieces[6].colors[3] = pieces[0].colors[3];
      pieces[6].colors[4] = pieces[0].colors[0];
      pieces[6].colors[5] = pieces[0].colors[4];
      pieces[0].colors[0] = cols[2];
      pieces[0].colors[3] = cols[3];
      pieces[0].colors[4] = cols[0];
      
      cols = colorSave(pieces[9].colors);
      pieces[9].colors[0] = pieces[21].colors[2];
      pieces[9].colors[3] = pieces[21].colors[3];
      pieces[21].colors[2] = pieces[15].colors[5];
      pieces[21].colors[3] = pieces[15].colors[3];
      pieces[15].colors[3] = pieces[3].colors[3];
      pieces[15].colors[5] = pieces[3].colors[4];
      pieces[3].colors[3] = cols[3];
      pieces[3].colors[4] = cols[0];
      
    } else if (str.equals("L")) {
      
      CubeColor[] cols = colorSave(pieces[0].colors);
      pieces[0].colors[0] = pieces[6].colors[3];
      pieces[0].colors[3] = pieces[6].colors[5];
      pieces[0].colors[4] = pieces[6].colors[4];
      pieces[6].colors[3] = pieces[8].colors[5];
      pieces[6].colors[4] = pieces[8].colors[4];
      pieces[6].colors[5] = pieces[8].colors[1];
      pieces[8].colors[1] = pieces[2].colors[0];
      pieces[8].colors[4] = pieces[2].colors[4];
      pieces[8].colors[5] = pieces[2].colors[1];
      pieces[2].colors[0] = cols[3];
      pieces[2].colors[1] = cols[0];
      pieces[2].colors[4] = cols[4];
      
      cols = colorSave(pieces[1].colors);
      pieces[1].colors[0] = pieces[3].colors[3];
      pieces[1].colors[4] = pieces[3].colors[4];
      pieces[3].colors[4] = pieces[7].colors[4];
      pieces[3].colors[3] = pieces[7].colors[5];
      pieces[7].colors[5] = pieces[5].colors[1];
      pieces[7].colors[4] = pieces[5].colors[4];
      pieces[5].colors[1] = cols[0];
      pieces[5].colors[4] = cols[4];
      
    } else if (str.equals("D")) {
      
      CubeColor[] cols = colorSave(pieces[8].colors);
      pieces[8].colors[1] = pieces[6].colors[4];
      pieces[8].colors[4] = pieces[6].colors[3];
      pieces[8].colors[5] = pieces[6].colors[5];
      pieces[6].colors[3] = pieces[24].colors[2];
      pieces[6].colors[4] = pieces[24].colors[3];
      pieces[6].colors[5] = pieces[24].colors[5];
      pieces[24].colors[2] = pieces[26].colors[1];
      pieces[24].colors[3] = pieces[26].colors[2];
      pieces[24].colors[5] = pieces[26].colors[5];
      pieces[26].colors[1] = cols[4];
      pieces[26].colors[2] = cols[1];
      pieces[26].colors[5] = cols[5];
      
      cols = colorSave(pieces[17].colors);
      pieces[17].colors[1] = pieces[7].colors[4];
      pieces[17].colors[5] = pieces[7].colors[5];
      pieces[7].colors[4] = pieces[15].colors[3];
      pieces[7].colors[5] = pieces[15].colors[5];
      pieces[15].colors[3] = pieces[25].colors[2];
      pieces[15].colors[5] = pieces[25].colors[5];
      pieces[25].colors[2] = cols[1];
      pieces[25].colors[5] = cols[5];
      
    } else if (str.equals("M")) {
      
      CubeColor[] cols = colorSave(pieces[11].colors);
      pieces[11].colors[0] = pieces[9].colors[3];
      pieces[11].colors[1] = pieces[9].colors[0];
      pieces[9].colors[0] = pieces[15].colors[3];
      pieces[9].colors[3] = pieces[15].colors[5];
      pieces[15].colors[3] = pieces[17].colors[5];
      pieces[15].colors[5] = pieces[17].colors[1];
      pieces[17].colors[1] = cols[0];
      pieces[17].colors[5] = cols[1];
      
      cols = colorSave(pieces[10].colors);
      pieces[10].colors[0] = pieces[12].colors[3];
      pieces[12].colors[3] = pieces[16].colors[5];
      pieces[16].colors[5] = pieces[14].colors[1];
      pieces[14].colors[1] = cols[0];
      
    } else if (str.equals("E")) {
      
      CubeColor[] cols = colorSave(pieces[3].colors);
      pieces[3].colors[3] = pieces[21].colors[2];
      pieces[3].colors[4] = pieces[21].colors[3];
      pieces[21].colors[2] = pieces[23].colors[1];
      pieces[21].colors[3] = pieces[23].colors[2];
      pieces[23].colors[1] = pieces[5].colors[4];
      pieces[23].colors[2] = pieces[5].colors[1];
      pieces[5].colors[1] = cols[4];
      pieces[5].colors[4] = cols[3];
      
      cols = colorSave(pieces[4].colors);
      pieces[4].colors[4] = pieces[12].colors[3];
      pieces[12].colors[3] = pieces[22].colors[2];
      pieces[22].colors[2] = pieces[14].colors[1];
      pieces[14].colors[1] = cols[4];
      
    } else if (str.equals("S")) {
      
      CubeColor[] cols = colorSave(pieces[1].colors);
      pieces[1].colors[0] = pieces[7].colors[4];
      pieces[1].colors[4] = pieces[7].colors[5];
      pieces[7].colors[4] = pieces[25].colors[5];
      pieces[7].colors[5] = pieces[25].colors[2];
      pieces[25].colors[2] = pieces[19].colors[0];
      pieces[25].colors[5] = pieces[19].colors[2];
      pieces[19].colors[0] = cols[4];
      pieces[19].colors[2] = cols[0];
      
      cols = colorSave(pieces[10].colors);
      pieces[10].colors[0] = pieces[4].colors[4];
      pieces[4].colors[4] = pieces[16].colors[5];
      pieces[16].colors[5] = pieces[22].colors[2];
      pieces[22].colors[2] = cols[0];
      
    } else {
      
      println("Invalid turn string: " + str);
      
    }
    
  }
  
  CubeColor[] colorSave(CubeColor[] cols) {
    CubeColor[] colors = new CubeColor[6];
    for (int i = 0; i < 6; i++) colors[i] = cols[i];
    return colors;
  }
  
}
