//操作方法
//キーボード入力で開始
//sで時計回り、aで反時計回り、dでhold
//←→で横移動↓でソフトドロップ、↑でハードドロップ
//ゲーム終了後restartをクリックしてやり直せる

class TetrisGame{
  int score = 0;//消したラインの数
  int goal = 150;//この数字分ラインを消すとクリア
  int level = 0;//レベルが高いほどミノが落ちるスピードが上がる
  int levelInterval = 30;//この数字分ラインを消すごとにレベルアップ
  int[] speedModels = {60,20,15,12,10};//ミノの落ちる速さ(frameRateをspeedで割って表現)
  int speed = speedModels[0];
  int sortDropSpeed = 3;
  boolean gameStart = false;
  boolean gameClear = false;
  boolean gameOver = false;
  void levelUp(){//レベルを上げてミノが落ちるスピードを上げる
    if(score < goal){
      level = score / levelInterval;
      speed = speedModels[level];
    }
  }
  void changeSpeed(int value){
    speed = value;
  }
  boolean play(){//ゲームをプレイ中かの判定
    if(gameStart && !gameClear && !gameOver){
      return true;
    } else {
      return false;
    }
  }
  void startGame(){
    if(!game.gameStart){
      game.gameStart = true;
    }
  }
  void judgeGame(boolean canPlaceBlock){//ゲームクリアとゲームオーバーの判定
    if(score >= goal){
      gameClear = true;
    }
    if(!gameClear && !canPlaceBlock){
      gameOver = true;
    }
  }
  boolean judgeInside(int x,int y,int side){//マウスが範囲内にあるか判定
    if(mouseX >= x && mouseX <= x + side && mouseY >= y && mouseY <= y + side){
      return true;
    } else {
      return false;
    }
  }
  void reset(){//変数の初期化
    score = 0;
    level = 0;
    gameStart = false;
    gameClear = false;
    gameOver = false;
  }
}

class TetrisBoard{
  int boardWidth = 10;
  int boardHeight = 20;//boardの縦横それぞれの升目
  int[][] board = new int[boardHeight][boardWidth];//0は空白1はミノ
  void placeBlock(int a,int b,int blockSize,int[][] shape,int currentType){//ミノを置く処理
    for(int i = 0;i < blockSize;i++){
      for(int j = 0;j < blockSize;j++){
        if(shape[i][j] == 1){
          board[b + j][a + i] = currentType + 1;
        }
      }
    }
  }
  int clearLines(){//ミノを消す処理と消したライン数を返す
    int clearCount = 0;
    boolean fullLine;
    for(int i = 0;i < boardHeight;i++){
      fullLine = true;
      for(int j = 0;j < boardWidth;j++){
        if(board[i][j] == 0){
          fullLine = false;
          break;
        }
      }
      if(fullLine){
        clearCount++;
        for(int row = 0;row < boardWidth;row++){
          for(int line = i;line > 0;line--){ 
            board[line][row] = board[line - 1][row];
          }
          board[0][row] = 0;
        }
      }
    }
    return clearCount;
  }
  void reset(){//変数の初期化
    for(int i = 0;i < boardHeight;i++){
      for(int j = 0;j < boardWidth;j++){
        board[i][j] = 0;
      }
    }
  }
}
class TetrisBlock{
  int x;
  int y;//xは縦軸、yは横軸
  int startX = 3;
  int startY = 0;//ミノの初期位置
  int blockKind = 7;//ミノの種類
  int blockSize = 4;//ミノは4×4の行列で管理する
  int currentBlock = -1;//currentBlocksの現在の位置を表す
  int currentType;//現在のミノの種類
  int direction;//現在のミノの向き
  int holdType = -1; //holdしているミノの種類
  int[] currentBlocks = new int[7]; //現在のミノの塊の配列
  int[] nextBlocks = new int[7];//次のミノの塊の配列
  int[][] shape = new int[blockSize][blockSize];//現在のミノの形  
  int[][] holdShape = new int[blockSize][blockSize];//holdのミノの形
  //1.形2.回転3.height4.widthの4次元配列
  int[][][][] models = {{{{0,1,0,0},{0,1,0,0},{0,1,0,0},{0,1,0,0}},
    {{0,0,0,0},{0,0,0,0},{1,1,1,1},{0,0,0,0}},
    {{0,0,1,0},{0,0,1,0},{0,0,1,0},{0,0,1,0}},
    {{0,0,0,0},{1,1,1,1},{0,0,0,0},{0,0,0,0}}},//I
    {{{0,0,0,0},{0,1,1,0},{0,1,1,0},{0,0,0,0}},
    {{0,0,0,0},{0,1,1,0},{0,1,1,0},{0,0,0,0}},
    {{0,0,0,0},{0,1,1,0},{0,1,1,0},{0,0,0,0}},
    {{0,0,0,0},{0,1,1,0},{0,1,1,0},{0,0,0,0}}},//O
    {{{1,0,0,0},{1,1,0,0},{0,1,0,0},{0,0,0,0}},
    {{0,1,1,0},{1,1,0,0},{0,0,0,0},{0,0,0,0}},
    {{0,1,0,0},{0,1,1,0},{0,0,1,0},{0,0,0,0}},
    {{0,0,0,0},{0,1,1,0},{1,1,0,0},{0,0,0,0}}},//S
    {{{0,1,0,0},{1,1,0,0},{1,0,0,0},{0,0,0,0}},
    {{1,1,0,0},{0,1,1,0},{0,0,0,0},{0,0,0,0}},
    {{0,0,1,0},{0,1,1,0},{0,1,0,0},{0,0,0,0}},
    {{0,0,0,0},{1,1,0,0},{0,1,1,0},{0,0,0,0}}},//Z
    {{{1,1,0,0},{0,1,0,0},{0,1,0,0},{0,0,0,0}},
    {{0,0,1,0},{1,1,1,0},{0,0,0,0},{0,0,0,0}},
    {{0,1,0,0},{0,1,0,0},{0,1,1,0},{0,0,0,0}},
    {{0,0,0,0},{1,1,1,0},{1,0,0,0},{0,0,0,0}},},//L
    {{{0,1,0,0},{0,1,0,0},{1,1,0,0},{0,0,0,0}},
    {{1,0,0,0},{1,1,1,0},{0,0,0,0},{0,0,0,0}},
    {{0,1,1,0},{0,1,0,0},{0,1,0,0},{0,0,0,0}},
    {{0,0,0,0},{1,1,1,0},{0,0,1,0},{0,0,0,0}}},//J
    {{{0,1,0,0},{0,1,1,0},{0,1,0,0},{0,0,0,0}},
    {{0,0,0,0},{1,1,1,0},{0,1,0,0},{0,0,0,0}},
    {{0,1,0,0},{1,1,0,0},{0,1,0,0},{0,0,0,0}},
    {{0,1,0,0},{1,1,1,0},{0,0,0,0},{0,0,0,0}}}};//T
    boolean holdDone = false;
  boolean canPlaceBlock(int a,int b,int boardWidth,int boardHeight,int[][] board,int[][] model){//ミノを置けるかの判定
    for(int i = 0;i < blockSize;i++){
      for(int j = 0;j < blockSize;j++){
        if(model[i][j] != 0 && (a + i < 0 || a + i >= boardWidth || b + j < 0 || b + j >= boardHeight || board[b + j][a + i] != 0)){
            return false;
        }
      }
    }
    return true;
  }
  int[] createBlocks(){//重複のない配列の生成
    int[] newBlocks = new int[blockKind];
    for(int i = 0;i < blockKind;i++){
      newBlocks[i] = int(random(blockKind));
      int j = 0;
      while(j < i){
        if(newBlocks[i] == newBlocks[j]){
          newBlocks[i] = int(random(blockKind));
          j = 0;
        } else {
          j++;
        }
      }
    }
    return newBlocks;
  }
  int getGhost(int boardWidth,int boardHeight,int[][] board){//ゴーストの位置をgraphicsに渡す
    int count = 0;
    while(canPlaceBlock(x,y + count + 1,boardWidth,boardHeight,board,shape)){
      count++;
    }
    return count;
  }
    
  int[] getNextType(){//nextの種類をgraphicsに渡す
    int a = currentBlock + 1;
    int count = 0;
    int[] nextType = new int[blockKind];
    while(a < blockKind){
      nextType[count] = currentBlocks[a];
      a++;
      count++;
    }
    a = 0;
    while(count < blockKind){
      nextType[count] = nextBlocks[a];
      a++;
      count++;
    }
    return nextType;
  }
  int[][][] getNextModels(){//以降のミノの形をgraphicsに渡す
    int a = currentBlock + 1;
    int count = 0;
    int[][][] nextModels = new int[blockKind][blockSize][blockSize];
    while(a < blockKind){
      for(int i = 0;i < blockSize;i++){
        for(int j = 0;j < blockSize;j++){
          nextModels[count][i][j] = models[currentBlocks[a]][0][i][j];
        }
      }
      a++;
      count++;
    }
    a = 0;
    while(count < blockKind){
      for(int i  = 0;i < blockSize;i++){
        for(int j = 0;j < blockSize;j++){
          nextModels[count][i][j] = models[nextBlocks[a]][0][i][j];
        }
      }
      a++;
      count++;
    }
    return nextModels;
  }
  void setShape(){//shapeに使うmodelを代入
    for(int i = 0;i < blockSize;i++){
      for(int j = 0;j < blockSize;j++){
        shape[i][j] = models[currentType][direction][i][j];
      }
    }
  }
  void initialization(){//ブロックの位置の初期化
    direction = 0;
    setShape();
    x = startX;
    y = startY;
    if(currentType == 0 || currentType == 1 || currentType == 6){//I,O,Tはmodelsの1行目が空白なので一行分詰める
      y--;
    }
  }
  void setBlock(){//ミノを置き終わって次のミノに更新する処理
    currentBlock++;
    if(currentBlock == blockKind){
      for(int i = 0;i < blockKind;i++){
        currentBlocks[i] = nextBlocks[i];
      }
      nextBlocks = createBlocks();
      currentBlock = 0;
    }
    currentType = currentBlocks[currentBlock];
    holdDone = false;
    initialization();
  }
  boolean drop(int boardWidth,int boardHeight,int[][] board){//ミノが落ちる処理
    if(canPlaceBlock(x,y + 1,boardWidth,boardHeight,board,shape)){
      y++;
      return true;
    } else {
      return false;
    }
  }
  void hold(){//hold処理
    int buffer;
    if(!holdDone){
      if(holdType == -1){
        holdType= currentType;
        setBlock();
      } else {
        buffer = currentType;
        currentType = holdType;
        holdType = buffer;
        initialization();
      }
      for(int i = 0;i < blockSize;i++){
        for(int j = 0;j < blockSize;j++){
          holdShape[i][j] = models[holdType][0][i][j];
        }
      }
      holdDone = true;
    }
  }
  void moveLeft(int boardWidth,int boardHeight,int[][] board){//左移動
    if(canPlaceBlock(x - 1,y,boardWidth,boardHeight,board,shape)){
      x--;
    }
  }
  void moveRight(int boardWidth,int boardHeight,int[][] board){//右移動
    if(canPlaceBlock(x + 1,y,boardWidth,boardHeight,board,shape)){
      x++;
    }
  }
  void hardDrop(int boardWidth,int boardHeight,int[][] board){//ハードドロップ処理
    while(canPlaceBlock(x,y + 1,boardWidth,boardHeight,board,shape)){
      y++;
    }
  }
  void rotateClockwise(int boardWidth,int boardHeight,int[][] board){//反時計回り回転処理
    int prodir;
    int[][] model = new int[blockSize][blockSize];
    if(direction == 0){
      prodir = 3;
    } else {
      prodir = direction - 1;
    }
    for(int i = 0;i < blockSize;i++){
      for(int j = 0;j < blockSize;j++){
        model[i][j] = models[currentType][prodir][i][j];
      }
    }
    if(canPlaceBlock(x,y,boardWidth,boardHeight,board,model)){
      direction = prodir;
      setShape();
    }
  }
  void rotateAntiClockwise(int boardWidth,int boardHeight,int[][] board){//時計回り回転処理
  int prodir;
  int[][] model = new int[blockSize][blockSize];
    if(direction == 3){
      prodir = 0;
    } else {
      prodir = direction + 1;
    }
    for(int i = 0;i < blockSize;i++){
      for(int j = 0;j < blockSize;j++){
        model[i][j] = models[currentType][prodir][i][j];
      }
    }
    if(canPlaceBlock(x,y,boardWidth,boardHeight,board,model)){
      direction = prodir;
      setShape();
    }
  }
  void reset(){//変数の初期化
    currentBlock = -1;
    currentBlocks = createBlocks();
    nextBlocks = createBlocks();
    setBlock();
  }
}

class TetrisGraphics{//描画関係
  int boardX = 200;
  int boardY = 50;//boardの座標
  int blockSide = 40;//ミノの一辺の長さ
  int nextX = 600;
  int nextY = 60;//next表示の座標
  int holdX = 100;
  int holdY = 60;//hold表示の座標
  int infoX = 700;
  int infoY = 500;//infoの座標
  int resetX = 700;
  int resetY = 600;//resetの座標
  int textX = 300;
  int textY = 300;//textの座標
  int textWidth = 250;
  int textHeight = 250;//textの幅
  int textSize = 40;//textの大きさ
  int boxTextWidth = 80;
  int boxTextHeight = 30;//holdとnextの文字の幅
  int boxTextSize = 20;//holdとnextの文字の大きさ
  int boxSide = 100;//nextとhold表示の一辺の長さ
  int boxBlockSide = 20;//nextとholdに表示するミノの一辺の長さ
  int nextNum = 5;//nextに表示する数
  int space = 20;//間隔
  color black = color(0,0,0);
  color white = color(255,255,255);
  color skyBlue = color(135,206,235);
  color yellow = color(255,255,0);
  color lightgreen = color(144,238,144);
  color red = color(255,0,0);
  color orange = color(255,165,0);
  color blue = color(0,0,255);
  color purple = color(128,0,128);
  color[] minoColor = {white,skyBlue,yellow,lightgreen,red,orange,blue,purple};//ミノの種類の配列の添え字と対応させるための配列
  void drawBoard(int x,int y,int boardWidth,int boardHeight,int currentType,int blockSize,int ghost,int[][] board,int[][] shape){//boardの描画
    for(int i = 0;i < boardWidth;i++){//boardの描画
      for(int j = 0;j < boardHeight;j++){
        fill(minoColor[board[j][i]]);
        rect(i * blockSide + boardX,j * blockSide + boardY,blockSide,blockSide);
      }
    }
    for(int i = 0;i < blockSize;i++){//現在のミノとゴーストの描画
      for(int j = 0;j < blockSize;j++){
        if(shape[i][j] == 1){
          fill(minoColor[currentType + 1]);
          rect((x + i) * blockSide + boardX,(y + j + ghost) * blockSide + boardY,blockSide,blockSide);
          fill(white);
          rect((x + i) * blockSide + space / 2 + boardX,(y + j + ghost) * blockSide + space / 2+ boardY,blockSide - space,blockSide - space);
          fill(minoColor[currentType + 1]);
          rect((x + i) * blockSide + boardX,(y + j) * blockSide + boardY,blockSide,blockSide);
        }
      }
    }
  }
  void drawHold(int blockSize,int holdType,int[][] models){//holdの描画
    fill(white);
    rect(holdX,holdY - boxTextHeight,boxTextWidth,boxTextHeight);//holdText枠の描画
    rect(holdX,holdY,boxSide,boxSide);//hold枠の描画
    textSize(boxTextSize);
    textAlign(TOP,TOP);
    fill(black);
    text("hold",holdX + space,holdY - boxTextHeight,boxTextWidth,boxTextHeight);
    if(holdType != -1){
      fill(minoColor[holdType + 1]);
      for(int i = 0;i < blockSize;i++){
        for(int j = 0;j < blockSize;j++){
          if(models[i][j] == 1){
            rect(holdX + space / 2 + boxBlockSide * i,holdY + space / 2 + boxBlockSide * j,boxBlockSide,boxBlockSide);
          }
        }
      }
    }
  }
  void drawNext(int blockSize,int[] nextType,int[][][] models){//nextの描画
    fill(white);
    for(int i = 0;i < nextNum;i++){//Nextの枠の描画
      rect(nextX,nextY + i * boxSide,boxSide,boxSide);
    }
    rect(nextX,nextY - boxTextHeight,boxTextWidth,boxTextHeight);//nextText枠の描画
    textSize(boxTextSize);
    textAlign(TOP,TOP);
    fill(black);
    text("next",nextX + space,nextY - boxTextHeight,boxTextWidth,boxTextHeight);
    for(int count = 0;count < nextNum;count++){
      fill(minoColor[nextType[count] + 1]);
      for(int i = 0;i < blockSize;i++){
        for(int j = 0;j < blockSize;j++){
          if(models[count][i][j] == 1){
            rect(nextX + space / 2 + boxBlockSide * i,nextY + space / 2 + boxBlockSide * j + boxSide * count,boxBlockSide,boxBlockSide);
          }
        }
      }
    }
  }
  void drawInfo(int score,int goal,int level){//score,goal,levelの描画
    textSize(textSize);
    textAlign(CENTER,CENTER);
    fill(black);
    text("score " + score,infoX,infoY,textWidth,textHeight);
    text("goal " + goal,infoX,infoY + textSize + space,textWidth,textHeight);
    text("level " + (level + 1),infoX,infoY + (textSize + space) * 2,textWidth,textHeight);
  }
  void drawGameStart(){//ゲーム開始前の描画
    textSize(textSize);
    textAlign(CENTER,CENTER);
    fill(black);
    text("Please press the key to start",textX,textY,textWidth,textHeight);
  }
  void drawGameClear(){//ゲームクリア時の描画
    textSize(textSize);
    textAlign(CENTER,CENTER);
    fill(black);
    text("GameClear!",textX,textY,textWidth,textHeight);
  }
  void drawGameOver(int score){//ゲームオーバー時の描画
    textSize(textSize);
    textAlign(CENTER,CENTER);
    fill(black);
    text("GameOver",textX,textY,textWidth,textHeight);
    text("result " + score,textX,textY + textSize + space,textWidth,textHeight);
  }
  void drawReset(){//リセットボタンの描画
    fill(white);
    rect(resetX,resetY,textWidth,textHeight);
    textSize(textSize);
    textAlign(CENTER,CENTER);
    fill(black);
    text("restart",resetX,resetY,textWidth,textHeight);
  }
}

TetrisGame game;
TetrisBoard board;
TetrisBlock block;
TetrisGraphics graphics;

void setup(){
  size(1000,1000);
  game = new TetrisGame();
  board = new TetrisBoard();
  block = new TetrisBlock();
  graphics = new TetrisGraphics();
  frameRate(60);
  for(int i = 0;i < board.boardHeight;i++){
    for(int j = 0;j < board.boardWidth;j++){
      board.board[i][j] = 0;
    }
  }
  block.currentBlocks = block.createBlocks();
  block.nextBlocks = block.createBlocks();
  block.setBlock();
}

void draw(){
  background(255);
  graphics.drawBoard(block.x,block.y,board.boardWidth,board.boardHeight,block.currentType,block.blockSize,block.getGhost(board.boardWidth,board.boardHeight,board.board),board.board,block.shape);
  graphics.drawNext(block.blockSize,block.getNextType(),block.getNextModels());
  graphics.drawHold(block.blockSize,block.holdType,block.holdShape);
  if(!game.gameStart){
    graphics.drawGameStart();
  } else if(game.play()){
    graphics.drawInfo(game.score,game.goal,game.level);
    if(frameCount % game.speed == 0){
      if(!block.drop(board.boardWidth,board.boardHeight,board.board)){
        board.placeBlock(block.x,block.y,block.blockSize,block.shape,block.currentType);
        game.score += board.clearLines();
        game.levelUp();
        block.setBlock();
        game.judgeGame(block.canPlaceBlock(block.x,block.y,board.boardWidth,board.boardHeight,board.board,block.shape));
      }
    }
  } else {
    if(game.gameClear){
      graphics.drawGameClear();
    } else {
      graphics.drawGameOver(game.score);
    }
    graphics.drawReset();
  }
}

void keyPressed(){
  game.startGame();
  if(game.play()){
    if(key == 's'){
      block.rotateClockwise(board.boardWidth,board.boardHeight,board.board);
    }
    if(key == 'a'){
      block.rotateAntiClockwise(board.boardWidth,board.boardHeight,board.board);
    }
    if(key == 'd'){
      block.hold();
    }
    if(keyCode == LEFT){
      block.moveLeft(board.boardWidth,board.boardHeight,board.board);
    }
    if(keyCode == RIGHT){
      block.moveRight(board.boardWidth,board.boardHeight,board.board);
    }
    if(keyCode == DOWN){
      game.changeSpeed(game.sortDropSpeed);
    }
    if(keyCode == UP){
      block.hardDrop(board.boardWidth,board.boardHeight,board.board);
      board.placeBlock(block.x,block.y,block.blockSize,block.shape,block.currentType);
      game.score += board.clearLines();
      game.levelUp();
      block.setBlock();
      game.judgeGame(block.canPlaceBlock(block.x,block.y,board.boardWidth,board.boardHeight,board.board,block.shape));
    }
  }
}

void keyReleased(){
  if(keyCode == DOWN && game.play()){
    game.changeSpeed(game.speedModels[game.level]);
  }
}

void mouseClicked(){
  if(game.gameStart && !game.play() && game.judgeInside(graphics.resetX,graphics.resetY,graphics.textWidth)){
    game.reset();
    board.reset();
    block.reset();
  }
}
