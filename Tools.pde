

public class Tools {
  
  public Tools(){
  }

   public float distanceBetween(PVector pos1, PVector pos2) {
    return dist(pos1.x, pos1.y, pos1.z, pos2.x, pos2.y, pos2.z);
  }

   public void drawAxisGizmo(){
    drawGizmo(0f,0f,0f,50f);
  }

   public void drawAxisGizmo(float size){
    drawGizmo(0f,0f,0f,size);
  }
   public void drawGizmo(float xPos, float yPos, float zPos, float gizmoSize) {

   pushMatrix();
    translate(xPos, yPos, zPos);

    noFill();
    box(gizmoSize * 0.05f);

    // X
    fill(255, 0, 0);
    stroke(255, 0, 0);
    line(0, 0, 0, gizmoSize, 0, 0);
    // box(100);

    // Y
    fill(0, 255, 0);
    stroke(0, 255, 0);
    line(0, 0, 0, 0, gizmoSize, 0);

    // Z
    fill(0, 0, 255);
    stroke(0, 0, 255);
    line(0, 0, 0, 0, 0, gizmoSize);

    popMatrix();
  }

   public void drawMouseCoordinates() {
    // MOUSE POSITION
    fill(255, 0, 0);
    text("FR: " + frameRate, 20, 20);
    text("X: " + mouseX + " / Y: " + mouseY, mouseX, mouseY);
  }
  
  public  void translateVector(PVector p){
    translate(p.x, p.y, p.z);
  }
  
  public  PVector lerpPVector(PVector a, PVector b, float amount){
    return new PVector(lerp(a.x, b.x, amount),lerp(a.y, b.y, amount),lerp(a.z, b.z, amount));
  }
  
  public PVector multiplyVectorByComponent(PVector a, PVector b) {
  return new PVector(a.x * b.x, a.y * b.y, a.z * b.z);
}



}
