class I_Piece extends Tetromino{
  /*For I piece: 
      State '0' and State '2':      State 'R' and State 'L':
      pieces[0] = Far left          pieces[0] = Top
      pieces[1] = Center left       pieces[1] = Middle top
      pieces[2] = Center Right      pieces[2] = Middle bottom
      pieces[3] = Far right         pieces[3] = Bottom
  */
  
  I_Piece(int[][] xyCoords){
    super(xyCoords);
    for(Mino p: pieces){
      p.setColor(0, 255, 255);
    }
  }
  
  boolean isValidFutureState(int[][] futureState){
    for(int i = 0; i < futureState.length; i++){ //testing the current position
        if (futureState[i][0] < 0 || futureState[i][0] >= cols || futureState[i][1] < 0 || futureState[i][1] >= rows){
          return false;
        }
        if (grid[futureState[i][0]][futureState[i][1]].isSolid){
          return false;
        }
      }
    return true;
  }
  
  void updateFutureStates(int[][] futureState){
    for(int i = 0; i < futureState.length; i++){ //updates state of all pieces
          pieces[i].x = futureState[i][0];
          pieces[i].y = futureState[i][1];
    }
  }
  
  void switchStateToBeChecked(int[][] futureState, int xDisplacement, int yDisplacement){
    for(int i = 0; i < futureState.length; i++){ //switches future state position
        futureState[i][0] += xDisplacement;
        futureState[i][1] += yDisplacement;
    }
  }
  
  boolean checkCurrentPosition(int[][] futureState, int xDisplacement, int yDisplacement){
    switchStateToBeChecked(futureState, xDisplacement, yDisplacement); //changes to the current position

    if (isValidFutureState(futureState)){ //checks if current position is valid
      updateFutureStates(futureState);
      return true;
    } else{
      return false;
    }
  } 

  int[][] getState(String direction, char position){
    //(Note: I'm too lazy to code this in but I found this neat quirk);
    //CWSR = CCWS2 flipped
    //CWS2 = CCWSR flipped
    //CWSL = CCWS0 flipped
    //CWS0 = CCWSL flipped
    int[][] CWStateR = {{pieces[2].x, pieces[2].y - 1}, {pieces[2].x, pieces[2].y}, {pieces[2].x, pieces[2].y + 1}, {pieces[2].x, pieces[2].y + 2}};
    int[][] CWState2 = {{pieces[2].x - 2, pieces[2].y}, {pieces[2].x - 1, pieces[2].y}, {pieces[2].x, pieces[2].y}, {pieces[2].x + 1, pieces[2].y}};
    int[][] CWStateL = {{pieces[2].x - 1, pieces[2].y - 2}, {pieces[2].x - 1, pieces[2].y - 1}, {pieces[2].x - 1, pieces[2].y}, {pieces[2].x - 1, pieces[2].y + 1}};
    int[][] CWState0 = {{pieces[2].x - 1, pieces[2].y - 1}, {pieces[2].x, pieces[2].y - 1}, {pieces[2].x + 1, pieces[2].y - 1}, {pieces[2].x + 2, pieces[2].y - 1}};
    int[][] CCWStateL = {{pieces[2].x - 1, pieces[2].y - 1}, {pieces[2].x - 1, pieces[2].y}, {pieces[2].x - 1, pieces[2].y + 1}, {pieces[2].x - 1, pieces[2].y + 2}};
    int[][] CCWState2 = {{pieces[2].x - 1, pieces[2].y}, {pieces[2].x, pieces[2].y}, {pieces[2].x + 1, pieces[2].y}, {pieces[2].x + 2, pieces[2].y}};
    int[][] CCWStateR = {{pieces[2].x, pieces[2].y - 2}, {pieces[2].x, pieces[2].y - 1}, {pieces[2].x, pieces[2].y}, {pieces[2].x, pieces[2].y + 1}};
    int[][] CCWState0 = {{pieces[2].x - 2, pieces[2].y - 1}, {pieces[2].x - 1, pieces[2].y - 1}, {pieces[2].x, pieces[2].y - 1}, {pieces[2].x + 1, pieces[2].y - 1}};

    if(direction == "CW"){
      if(position == 'R'){
        return CWStateR;
      } else if(position == '2'){
        return CWState2;
      } else if(position == 'L'){
        return CWStateL;
      } else{
        return CWState0;
      }
    } else{
      if(position == 'L'){
        return CCWStateL;
      } else if(position == '2'){
        return CCWState2;
      } else if(position == 'R'){
        return CCWStateR;
      } else{
        return CCWState0;
      }
    }
  }
  
  int[][] getDisplacement(String direction, char futurePosition){
    int[][] option1 = {{0, 0}, {-2, 0}, {3, 0}, {-3, 1}, {3, -3}};    //CWR = CCW2
    int[][] option2 = {{0, 0}, {-1, 0}, {3, 0}, {-3, -2}, {3, 3}};    //CW2 = CCWL
    int[][] option3 = {{0, 0}, {2, 0}, {-3, 0}, {3, -1}, {-3, 3}};    //CWL = CCW0
    int[][] option4 = {{0, 0}, {1, 0}, {-3, 0}, {3, 2}, {-3, -3}};    //CW0 = CCWR

    if((direction == "CW" && futurePosition == 'R') || (direction == "CCW" && futurePosition == '2')){
      return option1;
    } else if((direction == "CW" && futurePosition == '2') || (direction == "CCW" && futurePosition == 'L')){
      return option2;
    } else if((direction == "CW" && futurePosition == 'L') || (direction == "CCW" && futurePosition == '0')){
      return option3;
    } else{
      return option4;
    }
  }
  
  void rotatePiece(String direction){
    int[][] futureState = getState(direction, allStates[currState]); //gets the future state of all of the pieces
    int[][] xyTests = getDisplacement(direction, allStates[currState]); //gets the displacements to test all positions of the future state
    
    for(int i = 0; i < xyTests.length; i++){
      if(checkCurrentPosition(futureState, xyTests[i][0], xyTests[i][1])){  //checks if any of the 5 test positions are valid
        return;
      }
    }
  }
  
  void rotateCW(){
    currState = (currState + 1) % allStates.length;  //updates the current state of the piece
    rotatePiece("CW");
  }
    
  void rotateCCW(){
    currState = (currState - 1 + allStates.length) % allStates.length;  //updates the current state of the piece
    rotatePiece("CCW");
  }
}
