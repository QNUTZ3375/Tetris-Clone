class Mino{
  int x, y;
  int r = 0;
  int g = 0;
  int b = 0;
  boolean isSolid = false;
  
  Mino(int _x, int _y){
    x = _x;
    y = _y;
  }
  
  void setColor(int _r, int _g, int _b){
    r = _r;
    g = _g;
    b = _b;
  }
  
  void show(){
    fill(r, g, b, 205);
    strokeWeight(2);
    square(xStartPos + x*cellSize, yStartPos + y*cellSize, cellSize);
  }
  
  void showOutsideGrid(int xPos, int yPos){
    fill(r, g, b);
    strokeWeight(2);
    square(xPos, yPos, cellSize);
  }
  
  void move(int xDist, int yDist){
    x += xDist;
    y += yDist;
  }
  
  void copyMinoValues(Mino toCopy){
    r = toCopy.r;
    g = toCopy.g;
    b = toCopy.b;
    isSolid = toCopy.isSolid;
  }
  
  void resetValues(){
    isSolid = false;
    setColor(0, 0, 0);
  }
}
