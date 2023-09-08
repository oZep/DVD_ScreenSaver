class Exist {
  ArrayList<PhysicalEntity> entity;
  
  Exist() {
    entity = new ArrayList<PhysicalEntity>();
  }
  
  void run() {
    for (PhysicalEntity life : entity) {
      life.run(entity);
    }
  }
  
  void addPeople(PhysicalEntity people) {
    entity.add(people);
  }
}
