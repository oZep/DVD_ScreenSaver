
Exist exist;
void setup() {
  size(640, 360);
  exist = new Exist();
  
  for (int i = 0; i < 50; i++) {
    exist.addPeople(new PhysicalEntity(width/2, height/2));
  }
}

void draw() {
  background(50);
  exist.run();
}

// Add a new boid into the System
void mousePressed() {
  exist.addPeople(new Boid(mouseX,mouseY));
}
