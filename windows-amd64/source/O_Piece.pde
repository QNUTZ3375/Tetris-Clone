class O_Piece extends Tetromino{
  /*For O Piece:
    pieces[0] = Top left
    pieces[1] = Top right
    pieces[2] = Bottom left
    pieces[3] = Bottom right
    No rotations to do here (I don't want to code in that mess of an O spin)
  */
  O_Piece(int[][] xyCoords){
    super(xyCoords);
    for(Mino p: pieces){
      p.setColor(255, 255, 0);
    }
  }
}
