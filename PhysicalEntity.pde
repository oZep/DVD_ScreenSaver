class PhysicalEntity {
  PVector position;
  PVector velocity;
  PVector acceleration;
  float r;
  float maxforce;    // Maximum steering force
  float maxspeed;    // Maximum speed
  int countCorner;
  
  PhysicalEntity(float x, float y) {
    // basic physics entity
    acceleration = new PVector(0,0); // set acceleration
    float angle = random(TWO_PI);
    velocity = new PVector(cos(angle), sin(angle));
    
    position = new PVector(x, y);
    r = 100.0;
    maxspeed = 2;
    maxforce = 2.0;
    countCorner = 0;
  }
  
  void run(ArrayList<PhysicalEntity> entity) {
    flock(entity);
    update();
    borders();
    render();
  }
  
  void applyForce(PVector force) {
    // We could add mass here if we want A = F / M
    acceleration.add(force);
  }
  
  void render() {
    // heading2D() above is now heading() but leaving old syntax until Processing.js catches up
    fill(0, 0, 255); // Set color to blue
    noStroke(); // Remove border
    
    // Define dimensions
    float boxWidth = r * 0.9;
    float boxHeight = r * 0.7;
    
    // Draw the outer box
    rectMode(CENTER);
    rect(position.x, position.y, boxWidth, boxHeight);
    
    
    // Draw the "DVD" text
    fill(255);
    textSize(r * 0.3);
    textAlign(CENTER, CENTER);
    text("DVD", position.x, position.y);
    text(countCorner, width / 2, 20.0f);
    }

  // Wraparound
  void borders() {
    if (position.x < -r) position.x = width+r;
    if (position.y < -r) position.y = height+r;
    if (position.x > width+r) position.x = -r;
    if (position.y > height+r) position.y = -r;
  }
  
  
  // Method to update position
  void update() {
    // Update velocity
    velocity.add(acceleration);
    // Limit speed
    velocity.limit(maxspeed);
    position.add(velocity);
    // Reset acceleration to 0 each cycle
    acceleration.mult(0);
    
    boundary();
  }
  
  void boundary() {
    // I want them to check if they're past a boundary
    if ((position.x + (r * 0.9)/2 > width  || position.x + (r * 0.9)/2 <  0.0) || (position.x - (r * 0.9)/2 > width  || position.x - (r * 0.9)/2 <  0.0)){
      // change this to cause the velocity to point the other way
      // swapping
      PVector temp = new PVector(-velocity.x, velocity.y, velocity.z);
      velocity.set(temp);
    }
    if ((position.y + (r * 0.7)/2 > height || position.y + (r * 0.7)/2 < 0.0) || (position.y - (r * 0.7)/2 > height || position.y - (r * 0.7)/2 < 0.0)) {
      // same with horizontal but fix different values
      PVector temp = new PVector(velocity.x, -velocity.y, velocity.z);
      velocity.set(temp);
    }
    if ((position.y + (r * 0.7)/2 == 0.0 && (position.x + (r * 0.9)/2 ==  0.0 || position.x + (r * 0.9)/2 ==  width)) || (position.x + (r * 0.9)/2 == 0.0 && 
    (position.y + (r * 0.7)/2 ==  0.0 || position.y + (r * 0.7)/2 ==  height)) || (position.y - (r * 0.7)/2 == 0.0 && (position.x - (r * 0.9)/2 ==  0.0 || position.x - (r * 0.9)/2 ==  width))
    || (position.x - (r * 0.9)/2 == 0.0 && (position.y - (r * 0.7)/2 ==  0.0 || position.y - (r * 0.7)/2 ==  height))) {
      countCorner += 1;
    }
  }
  
   // We accumulate a new acceleration each time based on three rules
  void flock(ArrayList<PhysicalEntity> entity) {
    PVector sep = separate(entity);   // Separation
    PVector ali = align(entity);      // Alignment
    PVector coh = cohesion(entity);   // Cohesion
    // Arbitrarily weight these forces
    sep.mult(1.5);
    ali.mult(1.0);
    coh.mult(1.0);
    // Add the force vectors to acceleration
    applyForce(sep);
    applyForce(ali);
    applyForce(coh);
  }
  
  PVector align(ArrayList<PhysicalEntity> entity) {
    PVector separate = separate(entity);
    float neighbordist = 50;
    PVector sum = new PVector(0, 0);
    int count = 0;
    for (PhysicalEntity other : entity) {
      float d = PVector.dist(position, other.position);
      if ((d > 0) && (d < neighbordist)) {
        sum.add(other.velocity);
        count++;
      }
    }
    if (count > 0) {
      sum.div((float)count);
      sum.normalize();
      sum.mult(maxspeed);
      PVector steer = PVector.sub(sum, velocity);
      steer.limit(maxforce);
      return steer;
    } 
    else {
      return new PVector(0, 0);
    }
  }
  
  PVector separate(ArrayList<PhysicalEntity> entity) {
    // desired separation between entities
    float desiredSeparation = 20.0;
    PVector steer = new PVector(0, 0, 0);
    int count = 0;
    for (PhysicalEntity other : entity) {
      // get the distance between the entity and the other entity 
      float dis = PVector.dist(position, other.position);
      if ((dis > 0) && (dis < desiredSeparation)) {
        PVector difference = PVector.sub(position, other.position);
        difference.normalize(); // get the weight
        difference.div(dis);   // weight in terms of distance
        steer.add(difference);
        count++;
        // do something with this
      }
    }
    if (count > 0) {
      steer.div((float)count);
    }
    if (steer.mag() > 0) {
      steer.normalize();
      steer.mult(maxspeed);
      steer.sub(velocity);
      steer.limit(maxforce);
    }
    return steer;
  }
  
  PVector cohesion(ArrayList<PhysicalEntity> entity) {
    float neighbordist = 50;
    PVector sum = new PVector(0, 0);
    int count = 0;
    for (PhysicalEntity other : entity) {
      float d = PVector.dist(position, other.position);
      if ((d > 0) && (d < neighbordist)) {
        sum.add(other.position);
        count++;
      }
    }
    if (count > 0) {
      sum.div(count);
      PVector desired = PVector.sub(sum, position);
      desired.normalize();
      desired.mult(maxspeed);
      PVector steer = PVector.sub(desired, velocity);
      steer.limit(maxforce);
      return steer;
    } 
    else {
      return new PVector(0, 0);
    }
  }
}
