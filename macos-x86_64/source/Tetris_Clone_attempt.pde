import java.util.Arrays;
boolean left, right, down;
int cellSize = 40;
int xStartPos = 250;
int yStartPos = -100;
int heightLimit = 4;
int cols = 10;
int rows = 20 + heightLimit;
int softDropRate = 30; //out of 60, 0 being slow, 60 being fast
int pieceDropRate = 0;
int pieceDropLimit = 120; //Default is 60, decrease for harder difiiculty
int playerScore = 0;
int playerLines = 0;
int playerLevel = 1;
int[] pointsTable = {40, 100, 300, 1200};
boolean hasSwitched = false;
boolean isGameOver = false;
int[] sevenBagRandomizer = {0, 1, 2, 3, 4, 5, 6};
Mino[][] grid = new Mino[cols][rows];
int[][] TCoords = {{4, 3}, {3, 4}, {4, 4}, {5, 4}};
int[][] ICoords = {{3, 4}, {4, 4}, {5, 4}, {6, 4}};
int[][] OCoords = {{4, 3}, {5, 3}, {4, 4}, {5, 4}};
int[][] JCoords = {{3, 3}, {3, 4}, {4, 4}, {5, 4}};
int[][] LCoords = {{5, 3}, {5, 4}, {4, 4}, {3, 4}};
int[][] SCoords = {{5, 3}, {4, 3}, {4, 4}, {3, 4}};
int[][] ZCoords = {{3, 3}, {4, 3}, {4, 4}, {5, 4}};
Tetromino[] piecesInPlay = new Tetromino[5]; //Index 0 is the current piece falling, 1 is the held piece, 2 and onwards are next pieces
PFont f;
PFont r;
int arrLimit = 3;
int arrCounter = 0;
int dasLimit = 5;
int dasCounter = 0;

//Draws the grid
void drawGrid(){
  for(int i = 0; i < cols; i++){
    for(int j = heightLimit; j < rows; j++){
      grid[i][j].show();
    }
  }
}

//Checks if the next piece spawned is in a valid position
boolean checkSpawnState(int startCol, int endCol){
  for(int i = startCol; i < endCol; i++){
    if (grid[i][heightLimit - 1].isSolid){
      return true;
    }
  }
  return false;
}

//Spews out a random number from 0 - 6 with 7-bag constraints (helps with generation of the next piece)
int randomizerFunction(){
  int returnVal;
  if(sevenBagRandomizer.length > 1){
    int r = int(random(0, sevenBagRandomizer.length));
    returnVal = sevenBagRandomizer[r];
    for(int i = r; i < sevenBagRandomizer.length - 1; i++){
      sevenBagRandomizer[i] = sevenBagRandomizer[i + 1];
    }
    sevenBagRandomizer = Arrays.copyOf(sevenBagRandomizer, sevenBagRandomizer.length - 1);
  } else{
    returnVal = sevenBagRandomizer[0];
    sevenBagRandomizer = Arrays.copyOf(sevenBagRandomizer, 7);
    for(int i = 0; i < sevenBagRandomizer.length; i++){
      sevenBagRandomizer[i] = i;
    }
  }
  return returnVal;
}

void updateMetrics(int[] linesCleared){
  //adds up the score and lines cleared after clearing the lines
  playerScore += pointsTable[linesCleared.length - 1] * playerLevel;
  playerLines += linesCleared.length;
  playerLevel = (playerLines / 10) + 1;
  //Difficulty calculation
  if (playerLevel < 12){
    pieceDropLimit = 60 - 5*(playerLevel - 1);
  } else{
    if(playerLevel < 15){
      pieceDropLimit = 10 - (playerLevel % 10);
    } else if(playerLevel < 18 ){
      pieceDropLimit = 4;
    } else if(playerLevel < 19){
      pieceDropLimit = 3;
    } else if(playerLevel < 29){
      pieceDropLimit = 2;
    } else{
      pieceDropLimit = 1;
    }
  }
}

//Scans the board for full lines
void checkLineClears(){
  int[] linesCleared = {};
  int initialFullLine = -1;
  //Goes through all the playable rows
  for(int i = rows - 1; i >= heightLimit; i--){
    //Goes through each column in a row
    for(int j = 0; j < cols; j++){
      if(!grid[j][i].isSolid){    //Case where a cell in a column is not filled
        break;
      } else if(j == cols - 1){    //Case where all the columns are filled
        initialFullLine = i;
        //appends initialFullLine's value into linesCleared, making it contain 1 line to be cleared
        linesCleared = Arrays.copyOf(linesCleared, linesCleared.length + 1);
        linesCleared[0] = i;
      }
    }
    //Checks if there is a full row filled
    if(initialFullLine != -1){
      break;
    }
  }
  
  //checks if there is at least one row fully filled
  if(initialFullLine != -1){
    //Goes through all the rows starting directly above initialFullLine (only checks 3 lines above it as the first one is already found)
    for(int i = initialFullLine - 1; i > initialFullLine - 4; i--){
      //Goes through each column in a row
      for(int j = 0; j < cols; j++){
        if(!grid[j][i].isSolid){    //Case where a cell in a column is not filled
          break;
        } else if(j == cols - 1){    //Case where all the columns are filled
          //Appends the current row to linesCleared
          linesCleared = Arrays.copyOf(linesCleared, linesCleared.length + 1);
          linesCleared[linesCleared.length - 1] = i;
        }
      }
    }
    updateMetrics(linesCleared);
  }
  
  //Goes through each row in linesCleared
  for(int j = linesCleared.length - 1; j > -1; j--){
    //Goes through all columns
    for(int i = 0; i < cols; i++){
      //Resets the Minos of the cleared line to their default state
      grid[i][linesCleared[j]].resetValues();
      
      //Goes through all the rows above the line just cleared (at column i) except for row 0
      for(int k = linesCleared[j]; k > 1; k--){
        grid[i][k].copyMinoValues(grid[i][k - 1]);
      }
      //Resets the Mino at column i and row 0 back to default state
      grid[i][0].resetValues();
    }
  }
}

//The code for the "NEXT" section
void showNextPiece(){
  fill(200);
  stroke(0);
  strokeWeight(1);
  rect(675, 150, 200, 600);
  fill(0);
  textFont(f, 40);
  text("NEXT", 720, 140);
  for(int i = 2; i < piecesInPlay.length; i++){
    if(piecesInPlay[i] instanceof Tetromino){
      if(piecesInPlay[i] instanceof I_Piece){
        piecesInPlay[i].showOutsideGrid(575, 68 + (i - 2)*200);
      }
      else if(piecesInPlay[i] instanceof O_Piece){
        piecesInPlay[i].showOutsideGrid(575, 88 + (i - 2)*200);
      } else{
        piecesInPlay[i].showOutsideGrid(593, 90 + (i - 2)*200);
      }
    }
  }
}

//The code for the "HOLD" section
void showHeldPiece(){
  fill(200);
  stroke(0);
  strokeWeight(1);
  square(25, 150, 200);
  fill(0);
  textFont(f, 40);
  text("HOLD", 70, 140);
  if(piecesInPlay[1] instanceof Tetromino){
    if(piecesInPlay[1] instanceof I_Piece){
      piecesInPlay[1].showOutsideGrid(-75, 68);
    }
    else if(piecesInPlay[1] instanceof O_Piece){
      piecesInPlay[1].showOutsideGrid(-75, 88);
    } else{
      piecesInPlay[1].showOutsideGrid(-57, 90);
    }
  }
}

void showPlayerScoreAndLinesAndDifficulty(){
  fill(0);
  textFont(f, 40);
  text("SCORE: \n" + playerScore, 45, 450);
  text("LINES: \n" + playerLines, 45, 600);
  text("LEVEL: \n" + playerLevel, 45, 750);
}

void getNewPiece(){
  piecesInPlay[0] = piecesInPlay[2];
  for(int i = 2; i < piecesInPlay.length - 1; i++){
    piecesInPlay[i] = piecesInPlay[i + 1];
  }
  //Generates a new piece
  switch(randomizerFunction()){
    case 0:
      piecesInPlay[piecesInPlay.length - 1] = new T_Piece(TCoords);
      break;
    case 1:
      piecesInPlay[piecesInPlay.length - 1] = new O_Piece(OCoords);
      break;
    case 2:
      piecesInPlay[piecesInPlay.length - 1] = new I_Piece(ICoords);
      break;
    case 3:
      piecesInPlay[piecesInPlay.length - 1] = new J_Piece(JCoords);
      break;
    case 4:
      piecesInPlay[piecesInPlay.length - 1] = new L_Piece(LCoords);
      break;
    case 5:
      piecesInPlay[piecesInPlay.length - 1] = new S_Piece(SCoords);
      break;
    case 6:
      piecesInPlay[piecesInPlay.length - 1] = new Z_Piece(ZCoords);
      break;
    default:
      piecesInPlay[piecesInPlay.length - 1] = null;
  }
  //Checks if the piece can spawn into the grid
  if(piecesInPlay[0] instanceof I_Piece){
    isGameOver = checkSpawnState(3, 7);
  } else if (piecesInPlay[0] instanceof O_Piece){
    isGameOver = checkSpawnState(4, 6);
  } else{
    isGameOver = checkSpawnState(3, 6);
  }
}

void removeCurrentPiece(){
  //Converts current piece into the grid and removes the piece from the board
  for(Mino p: piecesInPlay[0].pieces){
    grid[p.x][p.y].isSolid = true;
    grid[p.x][p.y].r = p.r;
    grid[p.x][p.y].g = p.g;
    grid[p.x][p.y].b = p.b;
  }
  //Derefereces the current piece to prevent movement
  piecesInPlay[0] = null;
  hasSwitched = false;
}

void switchWithHeldPiece(){
  if(!hasSwitched){
    hasSwitched = true;
    piecesInPlay[0].resetPosition();
    if(piecesInPlay[1] instanceof Tetromino){
      Tetromino tempRef = piecesInPlay[1];
      piecesInPlay[1] = piecesInPlay[0];
      piecesInPlay[0] = tempRef;
      piecesInPlay[0].resetPosition();
    } else{
      piecesInPlay[1] = piecesInPlay[0];
      getNewPiece();
    }
  }
}

void showGhostPiece(Tetromino currPiece){
  int yDist = rows - 1;
  //Finds the Mino on the piece with the lowest Y value
  for(Mino p: currPiece.pieces){ //finds the smallest distance between the piece and the "floor" (not only the floor)
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
  
  for(Mino p: currPiece.pieces){
    fill(p.r - 55, p.g - 55, p.b - 55, 125);
    square(xStartPos + p.x*cellSize, yStartPos + (p.y + yDist)*cellSize, cellSize);
  }
}

void setup(){
  size(900, 900);
  //Initializes grid
  for(int i = 0; i < cols; i++){
    for(int j = 0; j < rows; j++){
      grid[i][j] = new Mino(i, j);
    }
  }
  f = createFont("Helvetica", 40, true);
  r = createFont("Zapfino", 12, true);
}

void draw(){
  background(125);
  drawGrid();
  showNextPiece();
  showHeldPiece();
  showPlayerScoreAndLinesAndDifficulty();
  textFont(r, 12);
  fill(255);
  text("Made By: Jozka N.T. \n       (in 3 Days)", 685, 800);
  //Checks if current piece is tetromino and is not game over
  if(!isGameOver){
    if (piecesInPlay[0] instanceof Tetromino){
      showGhostPiece(piecesInPlay[0]);
      piecesInPlay[0].show();
      if(left){
        if(arrCounter >= arrLimit && dasCounter >= dasLimit){
          arrCounter = 0;
          right = false;
          piecesInPlay[0].moveLeft();
        }else if(dasCounter >= dasLimit){
          arrCounter++;
        }else{
          dasCounter++;
        }
      }
      if(right){
        if(arrCounter >= arrLimit && dasCounter >= dasLimit){
          arrCounter = 0;
          left = false;
          piecesInPlay[0].moveRight();
        }else if(dasCounter >= dasLimit){
          arrCounter++;
        }else{
          dasCounter++;
        }
      }
      if(down){
        if(arrCounter >= arrLimit){
          arrCounter = 0;
          piecesInPlay[0].softDrop();
        }else{
          arrCounter++;
        }
      }
      //Checks if countdown for moving piece has expired
      if(pieceDropRate >= pieceDropLimit){
        piecesInPlay[0].update();
        pieceDropRate = 0;
        //Checks if current piece has locked in place
        if (piecesInPlay[0].isLocked){
          removeCurrentPiece();
        }
      } else{
        pieceDropRate++;
      }
    } else{
      checkLineClears();
      getNewPiece();
    }
  } else{
    for(int i = 0; i < cols; i++){
      for(int j = 0; j < rows; j++){
        if(!(grid[i][j].r == 0 && grid[i][j].g == 0 && grid[i][j].b == 0)){
          grid[i][j].setColor(55, 55, 55);
        }
      }
    }
    fill(255);
    rect(270, 400, 360, 120);
    textFont(f, 40);
    fill(0);
    text("Press any key\n   to restart!", 320, 450);
  }
}

void keyPressed(){
  if (piecesInPlay[0] instanceof Tetromino && !isGameOver){
    if(keyCode == RIGHT){
      piecesInPlay[0].moveRight();
      right = true;
    }
    if (keyCode == LEFT){
      piecesInPlay[0].moveLeft();
      left = true;
    }
    if (keyCode == DOWN){
      down = true;
    }
    if (keyCode == UP){
      switchWithHeldPiece();
    }
    if (key == ' '){
      piecesInPlay[0].hardDrop();
    }
    if (key == 'c'){
      piecesInPlay[0].rotateCW();
    }
    if (key == 'x'){
      piecesInPlay[0].rotateCCW();
    }
  } else if(isGameOver){
    piecesInPlay = new Tetromino[5];
    pieceDropLimit = 60;
    playerScore = 0;
    playerLines = 0;
    playerLevel = 1;
    sevenBagRandomizer = Arrays.copyOf(sevenBagRandomizer, 7);
    for(int i = 0; i < sevenBagRandomizer.length; i++){
      sevenBagRandomizer[i] = i;
    }  
    for(int i = 0; i < cols; i++){
      for(int j = 0; j < rows; j++){
        grid[i][j].resetValues();
      }
    }
    isGameOver = false;
  }
}

void keyReleased(){
  if(keyCode == RIGHT){
    dasCounter = 0;
    arrCounter = 0;
    right = false;
  }
  if(keyCode == LEFT){
    dasCounter = 0;
    arrCounter = 0;
    left = false;
  }
  if(keyCode == DOWN){
    arrCounter = 0;
    down = false;
  }
}

/*
Notes:
- 20 Dec: Started this project, made Mino class, Tetromino class, T Piece class
- 20 Dec: added softdrop, harddrop, moveleft, moveright, and a bunch of helper functions
- 20 Dec: fixed a bug where harddropping caused an indexOutOfBounds error (recounted the same cell twice, off by one issue)
- 20 Dec: fixed collision detection so now it checks every piece instead of the lowest y piece
- 20 Dec: added clockwise and counterclockwise rotation to T piece, fixed a bug where pieces can move left or right into other pieces
- 20 Dec: extended the rows to 24 (only 20 are still playable) to prevent indexOutOfBounds errors when moving the piece at the top
- 20 Dec: Created the O Piece and I Piece, fixed a bug where a piece can lock in mid-air due to frantic spinning
- 20 Dec: improved an existing function which detects if a new piece can spawn in the board so now it checks the columns along with the rows

- 21 Dec: refactored code in the T piece from 200+ to 100+ lines, made the J, L, S, and Z piece using the T piece code as a template
- 21 Dec: refactored code in the I piece from around 220 to under 130 lines, added 7-bag randomization
- 21 Dec: added a line clear function, fixed over a dozen bugs that came with it
          (this function took the longest and was the most annoying to implement QAQ)

- 22 Dec: added Next box and Hold box, added scoring system, extended the next box to show next 3 pieces, added line cleared metric
- 22 Dec: added difficulty scaling, added ghost piece, added a restart mechanic, changes all pieces to gray when game over is triggered

THIS PROJECT IS NOW FINISHED: 1320 Lines of code in total (May modify it in the future if I feel like it);

Extras:
- 25 Jan: added DAS and ARR support (now pieces can move faster yay)
*/
