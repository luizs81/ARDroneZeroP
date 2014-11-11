/*
  ARDroneZeroP - Processing game for Parrot ARDrone 2.0 - https://github.com/lgmsampaio/ARDroneZeroP
  Collaborators: 
  Luiz Gustavo Moreira Sampaio - lgmsampaio@gmail.com 
  Kazuki Sakai
  Shinichi Tamura
  Koudai Fujii
  With the kind consultancy of Christopher Michael Yap and the supervision of professor Shigeru Kashihara.
  
  Strongly based in the [ODC - Open Drone Control] http://www.opendronecontrol.org/
*/

import java.awt.image.BufferedImage;
import org.opendronecontrol.platforms.ardrone.ARDrone;
import org.opendronecontrol.spatial.Vec3;
import scala.collection.immutable.List;

final int gMAX_NUM_OF_ENEMY = 100;
final int gMAX_TIME = 20;

ARDrone drone;  // this creates our drone class
BufferedImage bimg;  // a 2D image from JAVA returns current video frame
 
PImage img;
DroneState state;
float droneX;
float droneY;
float droneZ;
float droneYaw;


//for game component
ArrayList<Object> objs;
TargetCircle tCircle;
ScoreManager score;
Timer time;

void setup(){
  size(640,480, OPENGL);
  
  //setup drone
  drone = new ARDrone("192.168.1.1"); // default IP is 192.168.1.1
  drone.connect();
  state = new DroneState();
  
  //setup game component
  background(255, 255, 255);
  framerate(60);
  reset();
}

void draw(){
  ///////////////////
  //input
  ///////////////////
  state.update(drone);

  ///////////////////
  //draw
  ///////////////////
  
  if( drone.hasVideo()){
    bimg = drone.video().getFrame(); // on each draw call get the current video frame
    if( bimg != null ){
      img = new PImage(bimg.getWidth(),bimg.getHeight(),PConstants.ARGB); // create a new processing image to hold the current video frame
      bimg.getRGB(0, 0, img.width, img.height, img.pixels, 0, img.width); // fill the img with buffered frame data from drone
      img.updatePixels();
      img.resize(640,480);
      image(img,0,0); // display the video frame
     }
  }
  tCircle.drawCircle();
  textAlign(LEFT);
  score.drawScore(0, 40);
  textAlign(RIGHT);
  time.drawTime(width, 60);
  textAlign(RIGHT);
  
  /*
   ARMarkerClassObject : amo
   for(int i = 0 ; i < amo.size() ; ++i){
     draw3DObject( amo[i].id );
   }
   
  */
  state.displayBattery(width, 40);
    
  
  if(state.flying){
     //if(mouseX < width/2){
     if(key == 'a'){  
      droneX = 0.1;
     }
     if(key == 'd'){
      droneX = -0.1; 
     }
     
     //if(mouseY < height/2){
    if(key == 'w'){   
      droneZ = 0.1;
    // } else {
    }
    if(key == 's')  {
      droneZ = -0.1; 
     }
   }
    
   
   if( time.mTime <= 0){
     gameover();
     return;//return to startpoint of draw()
   }
   
   //AR Marker detection
   /*
   ARMarkerClassObject : amo
   amo = ARMargerDetection();
   */
   
   /*
   //shoot!
   if(key == 's'){//shoot!
     drawShootEffect();
   }
   */
   
 
   

  ///////////////////
  //update
  ///////////////////
  drone.move(droneX,droneY,droneZ,droneYaw);
    
  //supplement enemy
  supplementEnemy( gMAX_NUM_OF_ENEMY - objs.size() );
  
  //object move
  for(int i = 0 ; i < objs.size() ; ++i){
    //Object tmp = objs.get(i);
    objs.get(i).recovery(0.05);//recover enemy's HP   
  }
  

  //hit detection
  /*
  for(int i = 0 ; i < amo.size() ; ++i){//for all object which the marker is detected
    if(amo[i] is shooted){
      object got damages.
      if(object hp is under 0){
        object is removed;
        score.add(10);
      }
    }
  }
  */
    
}

void reset(){
  score = new ScoreManager(0);
  time = new Timer(20);
  tCircle = new TargetCircle(width / 2.0, height / 2.0, 100);//center of image
  objs = new Arraylist<Object>();
  for(int i = 0 ; i < gMAX_NUM_OF_ENEMY ; ++i){
    obj.add( new Object() );
  }
}

void gameover(){
  textAlign(LEFT);
  score.drawScore(0, 40);
  for(int i = 0 ; i < objs.size()  ; ++i){
    objs.remove(i);//all object removed
  }  
  textAlign(CENTER);
  text("GAME OVER", width /2, height / 2);
  text("Press 'q' to restart", width /2, height / 2 +50);
  if( keyPressed  ){
    if(key == 'q'){
      reset();
    }
  }
}

void keyPressed(){
  //takeoff anf release
  if (key =='u'){
    if(!state.flying){
      drone.takeOff(); 
    } else{
     drone.land(); 
    }
  }
  

}

void supplementEnemy(final int numOfSupplemnt){
  for(int i = 0 ; i < numOfSupplement ; ++i){
    objs.add( new Object() );
  }
}
