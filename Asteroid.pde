/******************************************
 ** Asteroid! A clone by Alexandre Seite **
 ******************************************/
//last upadated on 03/02/2020

//some simple set up stuff
//creates the player's ship, lists to store the bullets and asteroids on the screen and the score
Player player1;
ArrayList<Bullet> bulletList = new ArrayList<Bullet>();
ArrayList<Asteroid> asteroidList = new ArrayList<Asteroid>();
int score = 0;
int extraLife = 3;
int savedIndex;
boolean playerCrashed = false;
boolean paused = false;
boolean newGame= true;
boolean invincible = false;
int invincibilityCount = 0;
int flipCount = 0;
int bigAsteroid;
char gameState = 's';

void setup(){
  size (800, 800);
  colorMode(HSB,360,100,100);
  background(0,0,0);
  for(int i= 0; i<15 ; i++){
    asteroidList.add(new Asteroid(random(800),random(800),(int)random(3)+1));
  }
  //noLoop();
  
}

void draw(){
  switch(gameState){
    case 'r':
      RunGame();
      break;
    case 'd':
      DeathScreen();
      break;
    case 's':
      StartScreen();
      break;
  }
}

void RunGame(){
  if(newGame){
    if (asteroidList.size()>0){
      for(int i= asteroidList.size()-1; i>-1;i--){
        asteroidList.remove(i);
      }
    }
    for(int i= bulletList.size()-1; i>-1;i--){
      bulletList.remove(i);
    }
    player1 = new Player(400,400);
    score = 0;
    extraLife = 3;
    newGame = false;
  }
  
  if(!paused){
    background(0,0,0);
  
  //Player control
    if(keyPressed){
      if (key == CODED) {
        switch(keyCode){
          case UP:
            player1.accelerate();
            break;
          case LEFT:
            player1.turnLeft();
            break;
          case RIGHT:
            player1.turnRight();
            break;
        }
      } else switch(key){
        case 'w':
          player1.accelerate();
          break;
        case 'a':
          player1.turnLeft();
          break;
        case 'd':
          player1.turnRight();
          break;
      }
    }
  
    if(invincibilityCount > 0){
      invincibilityCount -= 1;
      flipCount -= 1;
      if(flipCount == 0){
        if(player1.Fill == 0){
          player1.Fill = 100;
          flipCount += 10;
        } else {
          player1.Fill = 0;
          flipCount += 10;
        }
      }
      if(invincibilityCount == 0){
        player1.Fill = 0;
        invincible = false;
      }
    }
 
  //Update and display player's sprite
    player1.paint();
  
  //Updates and displays the player's bullets
    for(Bullet bullet : bulletList){
      bullet.paint();
    }
  
  //Updates and displays the asteroids
    for (Asteroid asteroid : asteroidList){
      asteroid.paint();
    }
    
    for(int i =1; i<=extraLife; i++){
      quad(30+(i*25),30,
           20+(i*25),56,
           30+(i*25),50,
           40+(i*25),56);
    }
    
    fill(0,0,100);
    text(score, 400, 50);
  
  //determines if any of the bullets hit an asteroid
    for(Bullet bullet : bulletList){
      bullet.hitscan();
    }
  
  //clean up bullets that left the game
    for(int i= bulletList.size()-1; i>-1;i--){
      if(bulletList.get(i).deleteMe){
        bulletList.remove(i);
      }
    }
  
  //checks is player crashes into an asteroid
    if(!invincible){
      for(int i= asteroidList.size()-1; i>-1;i--){
        asteroidList.get(i).hitscan();
        if(player1.shot && !playerCrashed){
          savedIndex = i;
          playerCrashed = true; 
          invincible = true;
          invincibilityCount += 300;
          flipCount += 10;
          player1.XVelocity =0;
          player1.YVelocity =0;
        }
      }
    }

  //splits the asteroid in which the player crashed into
    if(playerCrashed){
      asteroidList.get(savedIndex).split();
      playerCrashed = false;
    }
    
  //cleans up the asteroids that were destroyed
    for(int i= asteroidList.size()-1; i>-1;i--){
      if(asteroidList.get(i).deleteMe){
        asteroidList.remove(i);
      }
    }
    
    if(player1.shot){
      extraLife--;
      player1.x=400;
      player1.y=400;
      player1.shot = false;
    }
    
    if(extraLife<0){
      gameState='d';
    }
    
    bigAsteroid = 0;
    for (Asteroid asteroid : asteroidList){
      if(asteroid.asteroidSize == 3){
        bigAsteroid+=1;
      }
    }
    
    while(bigAsteroid < 2){
      int edge = (int)random(2);
      if (edge==0){
        asteroidList.add(new Asteroid(-50,random(800),3));
      } else {
        asteroidList.add(new Asteroid(random(800),-50,3));
      }
      bigAsteroid +=1;
    }
  }
}

void StartScreen(){
  background(0,0,0);
  for (Asteroid asteroid : asteroidList){
      asteroid.paint();
  }
  
  stroke(0,0,100);
  fill(0,0,0);
  rect(325,350,150,50);
  
  fill(0,0,100);
  textSize(40);
  text("Asteroids!", 305, 250);
  
  textSize(12);
  text("Made by Alexandre S.", 660, 780);
  
  textSize(25);
  text("Play", 375, 385);
  
}

void DeathScreen(){
  background(0,0,0);
  for (Asteroid asteroid : asteroidList){
      asteroid.paint();
  }
  
  stroke(0,0,100);
  fill(0,0,0);
  rect(325,350,150,50);
  
  fill(0,0,100);
  textSize(40);
  text("Game Over!", 285, 250);
  textSize(35);
  text("Your Score:", 300, 290);
  text(score, 400, 330);
  
  textSize(25);
  text("Continue", 346, 385);
}

class Player{
  float x,y;
  float XVelocity, YVelocity;
  float pointingAngle =PI/2;
  boolean shot = false;
  int maxSpeed = 5;
  int Fill = 0;
  
  Player(int StartX, int StartY){
    x = StartX;
    y = StartY;
  }
  
  void accelerate(){
    XVelocity += 0.1*cos(pointingAngle);
    YVelocity -= 0.1*sin(pointingAngle);
    if(sqrt(XVelocity*XVelocity + YVelocity*YVelocity) > maxSpeed){
      XVelocity *=maxSpeed/sqrt(XVelocity*XVelocity + YVelocity*YVelocity);
      YVelocity *=maxSpeed/sqrt(XVelocity*XVelocity + YVelocity*YVelocity);
    }
  }
  
  void turnLeft(){
    pointingAngle = (pointingAngle+PI/90)%(2*PI);
  }
  
  void turnRight(){
    pointingAngle = (pointingAngle-PI/90)%(2*PI);
    if(pointingAngle<=0){
      pointingAngle+= 2*PI;
    }
  }
  
  void paint(){
    stroke(0,0,100);
    fill(0,0,Fill);
    x+= XVelocity;
    if(x>813){
      x=-13;
    } else if(x<-13){
      x=813;
    }
    y+= YVelocity;
    if(y>813){
      y=-13;
    } else if(y<-13){
      y=813;
    }
    quad(x+13*cos(pointingAngle),y-13*sin(pointingAngle),
         x-13*cos(pointingAngle)-10*sin(pointingAngle),y+13*sin(pointingAngle)-10*cos(pointingAngle),
         x-7*cos(pointingAngle),y+7*sin(pointingAngle),
         x-13*cos(pointingAngle)+10*sin(pointingAngle),y+13*sin(pointingAngle)+10*cos(pointingAngle));
  }
}

class Bullet{
  float x,y,XVelocity,YVelocity,pointingAngle;
  boolean deleteMe = false;
    
  
  Bullet(float StartX, float StartY, float StartAngle){
    x=StartX;
    y=StartY;
    pointingAngle=StartAngle;
    XVelocity = 7*cos(pointingAngle);
    YVelocity = -7*sin(pointingAngle);
  }
  
  void paint(){
    x+=XVelocity;
    y+=YVelocity;
    stroke(0,0,100);
    fill(0,0,100);
    triangle(x,y,
             x-3*sin(pointingAngle)-6*cos(pointingAngle),y+6*sin(pointingAngle)-3*cos(pointingAngle),
             x+3*sin(pointingAngle)-6*cos(pointingAngle),y+6*sin(pointingAngle)+3*cos(pointingAngle));
             
    if(x >805 || x <-5){
      deleteMe = true;
    }
    if(y>805 ||y <-5){
      deleteMe = true;
    }
  }
  
  void hitscan(){
    for(int i =asteroidList.size()-1; i>-1; i--){
      float dx = x - asteroidList.get(i).x;
      float dy = y - asteroidList.get(i).y;
      float distance = sqrt(dx*dx+dy*dy);
      if(distance < 10+(asteroidList.get(i).asteroidSize-1)*20){
        asteroidList.get(i).split();
        deleteMe = true;
      }
    }
  }
}

class Asteroid {
  float x,y,XVelocity,YVelocity,pointingAngle,rotationSpeed;
  int asteroidSize, radius;
  boolean deleteMe = false;
  int Radius_adjustment1, Radius_adjustment2,Radius_adjustment3,Radius_adjustment4,Radius_adjustment5,Radius_adjustment6;
  
  Asteroid(float StartX, float StartY, int StartingSize){
    x = StartX;
    y = StartY;
    asteroidSize = StartingSize;
    pointingAngle = random(2*PI);
    rotationSpeed = random(-0.015,0.015);
    radius = (10+(asteroidSize-1)*20);
    Radius_adjustment1 = (int)random(-5-(asteroidSize-1)*9,5+(asteroidSize-1)*9) + radius;
    Radius_adjustment2 = (int)random(-5-(asteroidSize-1)*9,5+(asteroidSize-1)*9) + radius;
    Radius_adjustment3 = (int)random(-5-(asteroidSize-1)*9,5+(asteroidSize-1)*9) + radius;
    Radius_adjustment4 = (int)random(-5-(asteroidSize-1)*9,5+(asteroidSize-1)*9) + radius;
    Radius_adjustment5 = (int)random(-5-(asteroidSize-1)*9,5+(asteroidSize-1)*9) + radius;
    Radius_adjustment6 = (int)random(-5-(asteroidSize-1)*9,5+(asteroidSize-1)*9) + radius;
    XVelocity = 1*cos(pointingAngle);
    YVelocity = -1*sin(pointingAngle);
  }
  
  void paint(){ 
    pointingAngle+= rotationSpeed;
    x+=XVelocity;
    if(x>810+(asteroidSize-1)*20){
      x=-10-(asteroidSize-1)*20;
    } else if(x<-10-(asteroidSize-1)*20){
      x=810+(asteroidSize-1)*20;
    }
    
    y+=YVelocity;
    if(y>810+(asteroidSize-1)*20){
      y=-10-(asteroidSize-1)*20;
    } else if(y<-10-(asteroidSize-1)*20){
      y=810+(asteroidSize-1)*20;
    }
    
    stroke(0,0,100);
    fill(0,0,0);
    
    beginShape();
    vertex(x+Radius_adjustment1*cos(pointingAngle),        y+Radius_adjustment1*sin(pointingAngle));
    vertex(x+Radius_adjustment2*cos(pointingAngle+PI/3),   y+Radius_adjustment2*sin(pointingAngle+PI/3));
    vertex(x+Radius_adjustment3*cos(pointingAngle+2*PI/3), y+Radius_adjustment3*sin(pointingAngle+2*PI/3));
    vertex(x+Radius_adjustment4*cos(pointingAngle+PI),     y+Radius_adjustment4*sin(pointingAngle+PI));
    vertex(x+Radius_adjustment5*cos(pointingAngle+4*PI/3), y+Radius_adjustment5*sin(pointingAngle+4*PI/3));
    vertex(x+Radius_adjustment6*cos(pointingAngle+5*PI/3), y+Radius_adjustment6*sin(pointingAngle+5*PI/3));
    endShape(CLOSE);
  }
  
  void split(){
    deleteMe = true;
    score += 50;
    
    if(asteroidSize==3){
      asteroidList.add(new Asteroid(x,y,2));
      asteroidList.add(new Asteroid(x,y,2));
      score += 150;
    }
    
    if(asteroidSize==2){
      asteroidList.add(new Asteroid(x,y,1));
      asteroidList.add(new Asteroid(x,y,1));
      asteroidList.add(new Asteroid(x,y,1));
      score += 50;
    } 
  }
  
  void hitscan(){
    float dx = x - player1.x;
    float dy = y - player1.y;
    float distance = sqrt(dx*dx+dy*dy);
    
    if(distance<20+(asteroidSize-1)*20){
      player1.shot = true;
    }
  }
  
}

void keyPressed(){
  if(key == ' ' && gameState == 'r' ){
    bulletList.add(new Bullet(player1.x,player1.y,player1.pointingAngle));
  }
}

void mouseClicked() {
  switch(gameState){
    case 'r':
      paused = !paused;
      break;
    case 'd':
      if(mouseX > 325 && mouseX < 475){
        if(mouseY>350 && mouseY<450){
          gameState = 's';
        }
      }
      break;
    case 's':
      if(mouseX > 325 && mouseX < 475){
        if(mouseY>350 && mouseY<450){
          gameState = 'r';
          newGame= true;
        }
      }
      break;
  }
}
