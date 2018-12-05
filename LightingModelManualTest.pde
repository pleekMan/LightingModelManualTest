import peasy.PeasyCam;

PeasyCam cam;

float[][] v = {
  {0, 0, 0}, {100, 0, 0}, {0, 100, 0}, {100, 100, 0}
};

int[][] faces = {
  {0, 1, 2}, {1, 2, 3}
};

color[] faceColors = {color(0,255,0), color(0)};

color objectDiffuseColor = color(0, 255, 0);

PVector lightPos = new PVector(-100, 50, 100);
color lightColor = color(255);

void setup() {
  size(500, 500, P3D);
  stroke(255, 100, 0);
  fill(255, 0, 0);

  cam = new PeasyCam(this, 400);
}

void draw() {
  background(0);
  stroke(255, 100, 0);

  lightPos.x = map(mouseX, 0, width, -200,200);
  
  PVector n = getFaceNormal(0);
  float l = normalToLightIncidence(0, n);
  
  color faceDiffuse = shadeDiffuse(faceColors[0],l);

  // FACES
  for (int i=0; i < faces.length; i++) {

    //PVector n = getFaceNormal(i);
    //float theta =  normalToLightAngle();

    beginShape();
    fill(faceDiffuse);

    // FACES VERTICES
    for (int j=0; j < 3; j++) {
      vertex(v[faces[i][j]][0], v[faces[i][j]][1], v[faces[i][j]][2] );
    }
    endShape(CLOSE);
  }

  // DRAW GIZMOS

  // LIGHT
  noStroke();
  fill(lightColor);
  pushMatrix();
  translate(lightPos.x, lightPos.y, lightPos.z);
  sphere(10);
  popMatrix();
  
  //-------------
  cam.beginHUD();
  fill(0,255,127);
  text("FACE 0 NORMAL: \t\t" + n, 10,20);
  text("LIGHT POS: \t\t" + lightPos, 10,40);
  text("FACE 0 LIGHT INCIDENCE: \t\t" + l, 10,60);
  cam.endHUD();
}

PVector getFaceNormal(int face) {
  PVector n = new PVector();

  // CONVERT POINTS TO VECTORS
  PVector vertexA = new PVector(v[faces[face][0]][0], v[faces[face][0]][1], v[faces[face][0]][2]);
  PVector vertexB = new PVector(v[faces[face][1]][0], v[faces[face][1]][1], v[faces[face][1]][2]);
  PVector vertexC = new PVector(v[faces[face][2]][0], v[faces[face][2]][1], v[faces[face][2]][2]);

  // VECTORS OF 2 NON-PARALLEL SIDES
  PVector sideA = PVector.sub(vertexA, vertexB);
  PVector sideB = PVector.sub(vertexB, vertexC);

  // TRIANGLE NORMAL => CROSS PRODUCT: VECTOR PERPENDICULAR TO 2 OF ITS SIDE (NON-PARALLEL)
  n.set(sideA.cross(sideB));
  // CROSS PRODUCT (A cross B) = |A| x |B| x sin(theta) x n 
  // theta = angle between vectors = A dot B
  // n = unit vector perpendicular to A and B (it would be: 1 or (0,0,1). It´s kind of the orientation template of the normal to be calculated
  n.normalize();
  //println(n);

  return n;
}

float normalToLightIncidence(int face, PVector faceNormal) {
  float incidence = 0;

  // CALCULATE LIGHT VECTOR FROM CENTROID OF FACE
  // CENTROID (BY VERTEX AVERAGE):
  float cX = (v[faces[face][0]][0] + v[faces[face][1]][0] + v[faces[face][2]][0]) / 3;
  float cY = (v[faces[face][0]][1] + v[faces[face][1]][1] + v[faces[face][2]][1])  / 3;
  float cZ = (v[faces[face][0]][2] + v[faces[face][1]][2] + v[faces[face][2]][2])  / 3;
  
  // CREATE AND VIZ CENTROID
  PVector centroid = new PVector(cX, cY, cZ);
  pushMatrix();
  fill(255,0,0);
  translate(centroid.x, centroid.y,centroid.z);
  sphere(2);
  stroke(255,200,0);
  noFill();
  line(0,0,0,faceNormal.x * 50,faceNormal.y * 50,faceNormal.z * 50);
  popMatrix();

  // LIGHT VECTOR FROM CENTROID
  PVector lightVector = PVector.sub(lightPos, centroid);
  //println("Light Vector => " + lightVector);

  // DOT PRODUCT, TO FIND THE "ANGLE INCIDENCE" ==> A dot B = cos(angle) 
  lightVector.normalize();
  incidence = faceNormal.dot(lightVector);

  return incidence;
}

color shadeDiffuse(color c, float incidence){
  return color((c >> 16 & 0xFF) * incidence, (c >> 8 & 0xFF) * incidence, (c & 0xFF) * incidence);
}
