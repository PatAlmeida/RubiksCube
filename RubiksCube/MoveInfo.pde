class MoveInfo {
  
  String baseMove;
  String mod;
  
  public MoveInfo(String bm, String m) {
    baseMove = bm;
    mod = m;
  }
  
  int getTurns() {
    if (mod.equals("")) return 1;
    else if (mod.equals("'")) return -1;
    else if (mod.equals("2")) return 2;
    else return int("ERROR"); // Shouldn't get here
  }
  
  String toString() {
    return baseMove + " - " + mod;
  }
  
}
