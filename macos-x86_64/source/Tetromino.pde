class Tetromino{
  Mino[] pieces = new Mino[4];
  boolean isLocked = false;
  int countdown = 2;
  char[] allStates = {'0', 'R', '2', 'L'};
  int currState = 0;
  int[][] startPos = new int[4][2];
  
  //Makes 4 minos connected to each other
  Tetromino(int[][] xyCoords){
    for(int i = 0; i < xyCoords.length; i++){
      pieces[i] = new Mino(xyCoords[i][0], xyCoords[i][1]);
      pieces[i].isSolid = true;
      startPos[i][0] = xyCoords[i][0];
      startPos[i][1] = xyCoords[i][1];
    }
  }
  
  void show(){
    for(Mino p: pieces){
      p.show();
    }
  }
  
  void resetPosition(){
    for(int i = 0; i < startPos.length; i++){
      pieces[i].x = startPos[i][0];
      pieces[i].y = startPos[i][1];
    }
  }
  
  void showOutsideGrid(int xPos, int yPos){
    for(Mino p: pieces){
      p.showOutsideGrid(xPos + p.x*cellSize, yPos + p.y*cellSize);
    }
  }
  
  //Checks if the current piece is on solid ground
  boolean isValidYState(){
    boolean isNotOnSolidGround = true;
    for(Mino p: pieces){
      if(p.y < rows - 1){
        if (grid[p.x][p.y + 1].isSolid){
          isNotOnSolidGround = false;
          break;
        }
      } else{
        isNotOnSolidGround = false;
        break;
      }
    }
    return isNotOnSolidGround;
  }
  
  //updates the y position of the piece
  void update(){
    if(!isLocked && isValidYState() && countdown > 0){
      for(Mino p: pieces){
        p.move(0, 1);
      }
      if (countdown < 2){
        countdown++;
      }
    } else if(countdown > 0){
      countdown--;
    } else{
      hardDrop();
    }
  }
  
  //drops the piece faster
  void softDrop(){
    if(!isLocked && isValidYState() && countdown > 0){
      for (Mino p: pieces){
        p.move(0, 1);
      }
      pieceDropRate += softDropRate;
      if (countdown < 2){
        countdown++;
      }
    } else if (countdown > 0){
      countdown--;
    } else{
      isLocked = true;
    }
  }
  
  //drops the piece to the current highest point directly below the piece
  void hardDrop(){
    pieceDropRate = pieceDropLimit;
    int yDist = rows - 1;
    
    if(!isLocked && isValidYState()){ //checks if there is enough space below the piece to hard drop
      for(Mino p: pieces){ //finds the smallest distance between the piece and the "floor" (not only the floor)
        int currLowestNonSolidY = p.y;
        //checks each row if the current cell is not solid (starts from the cell directly below it)
        for(int i = p.y + 1; i < rows; i++){  
          if (!grid[p.x][i].isSolid){
            currLowestNonSolidY++;
          } else{
            break;
          }
        }
        yDist = min(yDist, currLowestNonSolidY - p.y); //takes the smallest distance available
      }
      for(Mino p: pieces){
          p.move(0, yDist);
      }
    }
    isLocked = true;
  }
  
  //moves piece to the right
  void moveRight(){
    if(!isLocked){
      int rightMostX = 0;
      int rightMostY = 0;
      for(Mino p: pieces){
        if(rightMostX < p.x){
          rightMostX = p.x;
          rightMostY = p.y;
        }
      }
      if(rightMostX < cols - 1){
        for(Mino p: pieces){ //checks if there are any solid minos to the right of the piece
          if (grid[p.x + 1][p.y].isSolid){
            return;
          }
        }
        if(!grid[rightMostX + 1][rightMostY].isSolid){
          for(Mino p: pieces){
            p.move(1, 0);
          }
        }
      }
    }
  }
  
  //moves piece to the left
  void moveLeft(){
    if(!isLocked){
      int leftMostX = 20;
      int leftMostY = 0;
      for(Mino p: pieces){
        if (leftMostX > p.x){
          leftMostX = p.x;
          leftMostY = p.y;
        }
      }
      if (leftMostX > 0){
        for(Mino p: pieces){ //checks if there are any solid minos to the left of the piece
          if (grid[p.x - 1][p.y].isSolid){
            return;
          }
        }
        if(!grid[leftMostX - 1][leftMostY].isSolid){
          for (Mino p: pieces){
            p.move(-1, 0);
          }
        }
      }
    }
  }
  
  void rotateCW(){
    //This is only here as a placeholder to prevent superclass errors, each piece has this actually filled out
  }
  
  void rotateCCW(){
    //This is only here as a placeholder to prevent superclass errors, each piece has this actually filled out
  }
}
