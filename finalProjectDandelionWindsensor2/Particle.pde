class Particle{
  PVector pos;
  PVector vel;
  PVector acc;
  float rad;
  
  PVector targetPos;
  float lerpSpeed ;

  float chance;
  float life ;
  boolean transform;
  
  PVector offset;
  float offsetFreq;
  float offsetFreqInc;

  float origialSize;
  float size;

  
  Particle (PVector l){
    pos=l.copy();
    vel = new PVector(random(-10, 10), random(-10, 10));
    acc = new PVector(0, 0);
    rad = 2; //random(2, 3.5);

    targetPos = new PVector(width / 5, height * 2 / 3);
    lerpSpeed = random(0.05, 0.1);

    chance = random(0, 1);
    life = random(50, 80);
    transform = false;

    offset = new PVector();
    offsetFreq = 0;
    offsetFreqInc = random(0.2, 0.4);

    origialSize = random(0.7, 1.3);
    size = 1.0;
  }
  
  void moveWithLerp() {
    vel.mult(0.1);
    pos = PVector.lerp(pos, targetPos, lerpSpeed);
  }
  void applyForce(PVector f) {
    acc.add(f);
  }

  void update() {
    vel.add( acc);
    pos.add( vel);
    acc.mult(0);
  }

void stopUpdate(boolean stopValue){
  // make the velocity of particle zero
  if (stopValue){
   vel.y=0;
   vel.x=0;
    pos.add( vel);
    acc.mult(0);
  }
  
}

  void wind() {
    float x = sin(frameCount * 0.02) * 0.005 + 0.008;
    float y = cos(frameCount * 0.1) * -0.01 - 0.001;
    PVector windForce = new PVector(x, y);
    applyForce(windForce);
    update();
  }

  void display() {
    push();
    PVector center = new PVector(width / 5, height * 2 / 3);
    PVector vector = PVector.sub(center, pos);
    float angle = vector.heading();
    float vel_angle = vel.heading();
    translate(pos.x + offset.x, pos.y + offset.y);

    scale(origialSize);
    scale(size);

    noStroke();
    fill(255, 200);

    if (displayMode) {
      rotate(angle - PI / 2);
      seedShape();
    } else if (windMode) {
      if (pos.x > width*0.8 ) {
        if (life > 0) {
           life -= random(0.9,1.4);
        } else {
           life = 0;
        }
      }
//println("life:" + life);
      if ( life == 0 &&  transform == false) {
         size -= 0.04;
        if ( size < 0) {
           transform = true;
           size = 0.0;
        }
      }

      if ( transform) {
         size = lerp( size, 1.0, 0.03);
        rotate(vel_angle + noise(-PI / 3, PI / 3));
        //if ( chance < 0.8) {
        // //  musicShape();
        //} else {
        //   offset.x = 0;
        //   offset.y = sin( offsetFreq) * 3;
        //   offsetFreq +=  offsetFreqInc;
        //  //acc
        //  PVector force = new PVector(-0.001, -0.005);
        //   applyForce(force);
        //  // birdShape();
        //}
      } else {
        rotate(angle - PI / 2);
         seedShape();
      }
    }
    pop();
  }
    void seedShape() {
    strokeWeight(1);
    stroke(255, 100);
    line(0, 0, 0, -15);
    line(0, -15, -10, -20);
    line(0, -15, -5, -20);
    line(0, -15, 10, -20);
    line(0, -15, 5, -20);
  }

}
