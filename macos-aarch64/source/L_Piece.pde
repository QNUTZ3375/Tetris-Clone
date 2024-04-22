class L_Piece extends Tetromino{ 
  /*For L piece: 
      pieces[2] = Center
      
      State '0':                State 'R':                 State '2':                    State 'L':
      pieces[0] = Top right     pieces[0] = Bottom right   pieces[0] = Bottom left       pieces[0] = Top left
      pieces[1] = Right         pieces[1] = Bottom         pieces[1] = Left              pieces[1] = Top
      pieces[3] = Left          pieces[3] = Top            pieces[3] = Right             pieces[3] = Bottom
  */ 
  L_Piece(int[][] xyCoords){
    super(xyCoords);
    for(Mino p: pieces){
      p.setColor(255, 125, 0);
    }
  }
  
  boolean isValidFutureState(int[][] tempStates){
    for(int i = 0; i < tempStates.length; i++){ //testing the current position
        if (tempStates[i][0] < 0 || tempStates[i][0] >= cols || tempStates[i][1] < 0 || tempStates[i][1] >= rows){
          return false;
        }
        if (grid[tempStates[i][0]][tempStates[i][1]].isSolid){
          return false;
        }
      }
    return true;
  }
  
  void updateFutureStates(int[][] tempStates){
    for(int i = 0; i < tempStates.length; i++){ //updates state of all pieces
          pieces[i].x = tempStates[i][0];
          pieces[i].y = tempStates[i][1];
    }
  }
  
  void switchStateToBeChecked(int[][] tempStates, int xDisplacement, int yDisplacement){
    for(int i = 0; i < tempStates.length; i++){ //switches future state position
        tempStates[i][0] += xDisplacement;
        tempStates[i][1] += yDisplacement;
    }
  }
  
  boolean checkCurrentPosition(int[][] tempStates, int xDisplacement, int yDisplacement){
    switchStateToBeChecked(tempStates, xDisplacement, yDisplacement); //changes to the current position

    if (isValidFutureState(tempStates)){ //checks if current position is valid
      updateFutureStates(tempStates);
      return true;
    } else{
      return false;
    }
  }
  
  int[][] getState(char position){
    int[][] stateR = {{pieces[2].x + 1, pieces[2].y + 1}, {pieces[2].x, pieces[2].y + 1}, {pieces[2].x, pieces[2].y}, {pieces[2].x, pieces[2].y - 1}};
    int[][] state2 = {{pieces[2].x - 1, pieces[2].y + 1}, {pieces[2].x - 1, pieces[2].y}, {pieces[2].x, pieces[2].y}, {pieces[2].x + 1, pieces[2].y}};
    int[][] stateL = {{pieces[2].x - 1, pieces[2].y - 1}, {pieces[2].x, pieces[2].y - 1}, {pieces[2].x, pieces[2].y}, {pieces[2].x, pieces[2].y + 1}};
    int[][] state0 = {{pieces[2].x + 1, pieces[2].y - 1}, {pieces[2].x + 1, pieces[2].y}, {pieces[2].x, pieces[2].y}, {pieces[2].x - 1, pieces[2].y}};
    
    if(position == 'R'){
      return stateR;
    } else if (position == '2'){
      return state2;
    } else if (position == 'L'){
      return stateL;
    } else{ //Case for getting position 0 (default case)
      return state0;
    }
  }
  
  int[][] getDisplacement(String direction, char futurePosition){
    int[][] fromAnyToR = {{0, 0}, {-1, 0}, {0, -1}, {1, 3}, {-1, 0}};
    int[][] fromRToAny = {{0, 0}, {1, 0}, {0, 1}, {-1, -3}, {1, 0}};
    int[][] fromAnyToL = {{0, 0}, {1, 0}, {0, -1}, {-1, 3}, {1, 0}};
    int[][] fromLToAny = {{0, 0}, {-1, 0}, {0, 1}, {1, -3}, {-1, 0}};
    
    if(futurePosition == 'R'){
      return fromAnyToR;
    } else if(futurePosition == 'L'){
      return fromAnyToL;
    } else if((direction == "CW" && futurePosition == '2') || (direction == "CCW" && futurePosition == '0')){
      return fromRToAny;
    } else{ //Case for CW and 0, or CCW and 2 (default case)
      return fromLToAny;
    }
  }
  
  void rotatePiece(String direction){
    int[][] futureState = getState(allStates[currState]); //gets the future state of all of the pieces
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
