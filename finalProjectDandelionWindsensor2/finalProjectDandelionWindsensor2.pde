// NOC-Dandelion-Kathy Wang
//https://gist.github.com/kathykwang/5154a2246651037357fdd864ba182653

import processing.sound.*;

// declare a SoundFile object
SoundFile sound;

import processing.serial.*;
boolean arduinoSetup = false;
String myString = null;
Serial myPort;

int NUM_OF_VALUES = 1;   /** YOU MUST CHANGE THIS ACCORDING TO YOUR PROJECT **/
int[] sensorValues;      /** this array stores values from Arduino **/
float blow;



//JSON
boolean displayMode= true;
boolean debugMode = false;
boolean windMode = false;
float n = 4.5;
float d = 12.3;
int t = 80;
int s = 105;
int c = 0;
int angle = 0;
int step = 2;
int p = 20;
int test = 1;



// for particles
ArrayList <Particle> particles;
float alpha_value = 0;
PVector centerBranch;
float blowArea = 0;
float blowStrength = 0;

void init() {
  // init variables
  displayMode= true;
  debugMode = false;
  windMode = false;
  n = 4.5;
  d = 12.3;
  t = 80;
  s = 105;
  c = 0;
  angle = 0;
  step = 2;
  p = 20;
  test = 1; 

  alpha_value = 0;
  blowArea = 0;
  blowStrength = 0;
  //init setup
  sound.loop();

  textSize(12);
  particles =new ArrayList <Particle>();
  for (int i = 0; i < 200; i++) {
    particles.add(new Particle(new PVector(random(width), random(height))));
  }
  println("particles: "+particles.size());
  centerBranch = new PVector(width / 5, height * 2 / 3);
}

void setup() {
  fullScreen();
  //size(1000, 600);
  sound = new SoundFile(this, "windTrees.wav");
  // only setupSerial once, otherwise it shows "port busy";
  if(!arduinoSetup){
   setupSerial(); 
   arduinoSetup = true;
 }
  init();
}

//wind start
void mouseClicked() {
  windMode=true;
  displayMode=false;
}
void detectWind() {
  if (sensorValues[0]>1) {
    windMode=true;
    displayMode=false;
  }
}
//press key to reset
void keyPressed() {
  frameCount=-1; //back to setup and call init again;
}
void draw() {
  background(0);

  updateSerial();
  printArray(sensorValues);
  detectWind();
  float windSensor=map(sensorValues[0], 1, 8, 0, 4);
  blow=windSensor;

  float amplitude=map(sensorValues[0], 0, 10, 0, 1);
  sound.amp(amplitude);

  
  //main branch display
  if (displayMode || windMode) {
    push();
    strokeWeight(3);
    stroke(255, 100);
    line(centerBranch.x, height, centerBranch.x, centerBranch.y);
    pop();
  }

  // particle display
  for (int i = 0; i < particles.size(); i++) {
    Particle q=particles.get(i);
    float distance =  q.pos.dist(centerBranch);
    
      // particle within this distance stop moving
      if (distance<20*(4-blow)) {
        q.stopUpdate(true);
        println("blow1:"+blow);
      }
      // }
      //else{
      // q.stopUpdate(false); 
      // println("blow2:"+blow);
      //}
    
    if (displayMode) {
      q.moveWithLerp();
      println("displayMode");
    } else if (windMode) {
      // println("windMode");

      if (blowArea < s + 20 / test) {
        blowArea += 0.001;
      }

      if (distance > s - blowArea + 20) {
        q.wind();
      }
    } else {
      // particles[i].checkBoundaries();
    }

    q.update();
    q.display();
  }

  push();
  translate(centerBranch.x, centerBranch.y);
  int count = 0;
  for (float a = 0; a < TWO_PI * t; a += step) {
    //clock shape
    noStroke();
    // if (params.debugMode) {
    //   alpha_value = 0;
    // } else {
    //   alpha_value = 0;
    // }
    fill(255, alpha_value);
    float k =  n /  d;
    float r =  s * cos(k * a) +  c;
    float x = r * cos(a) + (r /  p) * cos( angle);
    float y = r * sin(a) + (r /  p) * sin( angle);
    ellipse(x, y, 3, 3);
    //match
    if (count < particles.size()) {
      particles.get(count).targetPos = new PVector(x + centerBranch.x, y + centerBranch.y);
    }
    count++;
  }
  //count adjustment
  if (count < particles.size()) {
    particles.remove(count);
  } else if (count > particles.size()) {
    particles.add(new Particle (new PVector (centerBranch.x, centerBranch.y)));
  }
  pop();
  if (debugMode) {
    // text display
    fill(255);
    //text("frameRate:" + round(frameRate()), 15, 30);
    text("count:" + count, 15, 50);
    text("# of particles:" + particles.size(), 15, 70);
    text("blowArea:" + blowArea, width-100, 50); 
    println("windMode:"+windMode);
    //text("r = s * cos(n / d * theta) + c", 15, 90);
    //text("x = r * cos(theta) + r / p * cos(angle)", 15, 110);
    //text("y = r * sin(theta) + r / p * sin(angle)", 15, 130);
    stroke(255);
    noFill();
    //ellipse(centerBranch.x, centerBranch.y, 2 * params.s + params.c, 2 * params.s + params.c);
    ellipse(centerBranch.x, centerBranch.y, blowArea, blowArea);
  }
}


void setupSerial() {
  printArray(Serial.list());
  myPort = new Serial(this, Serial.list()[ 2], 9600);
  // WARNING!
  // You will definitely get an error here.
  // Change the PORT_INDEX to 0 and try running it again.
  // And then, check the list of the ports,
  // find the port "/dev/cu.usbmodem----" or "/dev/tty.usbmodem----" 
  // and replace PORT_INDEX above with the index number of the port.

  myPort.clear();
  // Throw out the first reading,
  // in case we started reading in the middle of a string from the sender.
  myString = myPort.readStringUntil( 10 );  // 10 = '\n'  Linefeed in ASCII
  myString = null;

  sensorValues = new int[NUM_OF_VALUES];
}



void updateSerial() {
  while (myPort.available() > 0) {
    myString = myPort.readStringUntil( 10 ); // 10 = '\n'  Linefeed in ASCII
    if (myString != null) {
      String[] serialInArray = split(trim(myString), ",");
      if (serialInArray.length == NUM_OF_VALUES) {
        for (int i=0; i<serialInArray.length; i++) {
          sensorValues[i] = int(serialInArray[i]);
        }
      }
    }
  }
}
