import peasy.PeasyCam; //<>//

PeasyCam cam;
Tools tools;

/*
float[][] v = {
 {0, 0, -50}, {100, 0, 0}, {0, 100, 0}, {100, 100, 0}
 };
 
 int[][] f = {
 {0, 2, 1}, {1, 2, 3}
 };
 */

boolean drawNormals = false;
boolean controlAmbient = true;

// OBJECT
float[][] v; // VERTICES 
float[][] n; // NORMALS
int[][] f; // FACES

// SCENE PROPERTIES
//PVector sceneAmbientColor = new PVector(0, 0, 1);

// OBJECT PROPERTIES
PVector objectAmbientColor = new PVector(0,0.2,0.5);
float objectAmbientConstant = 1;
PVector objectDiffuseColor = new PVector(0, 0.8, 0);
PVector objectSpecularColor = new PVector(1, 1, 1);
float objectSpecularConstant = 0.5; // 
float objectSpecularWidth = 8;



// LIGHTS 
PVector lightColor = new PVector(1, 1, 1);
PVector lightColor2 = new PVector(1, 0, 0);

PVector lightPos = new PVector(-100, 0, 100);
PVector lightPos2 = new PVector(-100, 0, 100);


PVector[] lightsPos;
PVector[] lightsColor;

void setup() {
  size(800, 800, P3D);
  stroke(255, 100, 0);
  fill(255, 0, 0);
  sphereDetail(3);

  cam = new PeasyCam(this, 400);
  tools = new Tools();

  lightsPos = new PVector[2];
  lightsColor = new PVector[lightsPos.length];

  lightsPos[0] = lightPos;
  lightsPos[1] = lightPos2;
  lightsColor[0] = lightColor;
  lightsColor[1] = lightColor2;

  constructSphere(50);
}

void draw() {
  background(0);
  stroke(255, 100, 0);

  lightPos.x = 100 * (cos(frameCount * 0.005)*1.8); // ELIPSOIDAL
  lightPos.z = 100 * sin(frameCount * 0.005);

  lightPos2.x = 100 * (sin(frameCount * 0.005)*1.8); // ELIPSOIDAL
  lightPos2.z = 100 * cos(frameCount * 0.005);

  float[] camPos = cam.getPosition();
  PVector camPosVector = new PVector(camPos[0], camPos[1], camPos[2]);

  //objectSpecularWidth = floor(((float)mouseX / width) * 10) + 1;
  //objectSpecularConstant = (float)mouseY / height;
  if(controlAmbient)objectAmbientConstant = (float)mouseY / height;

  tools.drawAxisGizmo(200);

  // FOR EACH FACE (only 1 object)
  //float[] tempL = new float[2];
  for (int i=0; i < f.length; i++) {
    //for (int i=0; i < 1; i++) {

    PVector n = getFaceNormal(i);

    // FOR EACH LIGHT...
    PVector[] diffuseForLight = new PVector[2];
    PVector[] specularForLight = new PVector[2];

    for (int j=0; j < lightsPos.length; j++) {

      // DIFFUSE
      float l = normalToLightIncidence(i, n, j); // face, faceNormal, light
      //tempL[i] = l; 
      PVector faceDiffuse = shadeDiffuse(objectDiffuseColor, 1, lightsColor[j], 1, l);
      diffuseForLight[j]  = faceDiffuse;

      // SPECULAR
      PVector halfAngle = viewerToLightHalfAngle(i, camPosVector, lightsPos[j]);
      PVector faceSpecular = shadeSpecular(objectSpecularConstant, n, halfAngle, objectSpecularWidth, lightsColor[j], objectSpecularColor);
      specularForLight[j] = faceSpecular;
    }

    PVector finalDiffuseColor = PVector.add(diffuseForLight[0], diffuseForLight[1]);
    PVector finalSpecularColor = PVector.add(specularForLight[0], specularForLight[1]);
    PVector finalAmbientColor = shadeAmbient(objectAmbientConstant, objectAmbientColor);

    PVector diffusePlusSpecular = PVector.add(finalDiffuseColor, finalSpecularColor);
    PVector finalFaceColor = PVector.add(finalAmbientColor, diffusePlusSpecular);

    beginShape();
    fill(vectorToColor(finalFaceColor));
    noStroke();

    // FACES VERTICES
    for (int j=0; j < 3; j++) {
      vertex(v[f[i][j]][0], v[f[i][j]][1], v[f[i][j]][2] );
    }
    endShape(CLOSE);
  }

  // DRAW GIZMOS

  // LIGHT
  noStroke();
  fill(vectorToColor(lightColor));
  pushMatrix();
  translate(lightPos.x, lightPos.y, lightPos.z);
  sphere(10);
  popMatrix();

  // LIGHT 2
  noStroke();
  fill(vectorToColor(lightColor2));
  pushMatrix();
  translate(lightPos2.x, lightPos2.y, lightPos2.z);
  scale(0.5);
  sphere(10);
  popMatrix();

  //-------------
  //cam.beginHUD();
  //fill(0, 255, 127);
  //text("FACE 0 NORMAL: \t\t" + n, 10, 20);
  //text("LIGHT POS: \t\t" + lightPos, 10, 20);
  //text("LIGHT INCIDENCE ON FACE 0: " + tempL[0], 10, 40);
  //text("LIGHT INCIDENCE ON FACE 1: " + tempL[1], 10, 60);
  //text("FACE LIGHT INCIDENCE: \t\t" + l, 10, 60);
  //cam.endHUD();

  //noLoop();
  //println("noLoop()ing");
}

PVector getFaceNormal(int face) {
  PVector n = new PVector();

  // CONVERT POINTS TO VECTORS
  PVector vertexA = new PVector(v[f[face][0]][0], v[f[face][0]][1], v[f[face][0]][2]);
  PVector vertexB = new PVector(v[f[face][1]][0], v[f[face][1]][1], v[f[face][1]][2]);
  PVector vertexC = new PVector(v[f[face][2]][0], v[f[face][2]][1], v[f[face][2]][2]);

  // VECTORS OF 2 NON-PARALLEL SIDES
  // NEGATIVE IF TRIANGLE IS FACING BACKWARDS (FRONT = RIGHT HAND RULE)
  // SWAPPING THE PARAMETERS For sideA INVERTS THE NORMALS
  PVector sideA = PVector.sub(vertexA, vertexB);
  PVector sideB = PVector.sub(vertexB, vertexC);

  // TRIANGLE NORMAL => CROSS PRODUCT: VECTOR PERPENDICULAR TO 2 OF ITS SIDE (NON-PARALLEL)
  n.set(sideA.cross(sideB));
  // CROSS PRODUCT (A cross B) = |A| * |B| * sin(theta) * n 
  // theta = angle between vectors = A dot B
  // n = unit vector perpendicular to A and B (it would be: 1 or (0,0,1). It´s kind of the orientation template of the normal to be calculated
  n.normalize();
  //println(n);
  return n;
}

PVector getFaceCentroid(int face) {
  // FACE POSITION IN WORLD SPACE
  // CENTROID (BY VERTEX AVERAGE):
  PVector faceCentroid = new PVector();
  faceCentroid.x = (v[f[face][0]][0] + v[f[face][1]][0] + v[f[face][2]][0]) / 3;
  faceCentroid.y = (v[f[face][0]][1] + v[f[face][1]][1] + v[f[face][2]][1]) / 3;
  faceCentroid.z = (v[f[face][0]][2] + v[f[face][1]][2] + v[f[face][2]][2]) / 3;
  return faceCentroid;
}

float normalToLightIncidence(int face, PVector faceNormal, int light) {
  float incidence = 0;

  // CALCULATE LIGHT VECTOR FROM CENTROID OF FACE
  // CENTROID (BY VERTEX AVERAGE):
  //float cX = (v[f[face][0]][0] + v[f[face][1]][0] + v[f[face][2]][0]) / 3;
  //float cY = (v[f[face][0]][1] + v[f[face][1]][1] + v[f[face][2]][1])  / 3;
  //float cZ = (v[f[face][0]][2] + v[f[face][1]][2] + v[f[face][2]][2])  / 3;

  // CREATE AND VIZ CENTROID
  PVector centroid = getFaceCentroid(face);
  if (drawNormals) {
    int nMult = 20;
    pushMatrix();
    fill(255, 0, 0);
    translate(centroid.x, centroid.y, centroid.z);
    sphere(1);
    stroke(0, 255, 255);
    noFill();
    line(0, 0, 0, faceNormal.x * nMult, faceNormal.y * nMult, faceNormal.z * nMult);
    popMatrix();
  }

  // LIGHT VECTOR FROM CENTROID
  PVector lightVector = PVector.sub(lightsPos[light], centroid);
  //println("Light Vector => " + lightVector);

  // DOT PRODUCT, TO FIND THE "ANGLE INCIDENCE" ==> A dot B = cos(angle) 
  lightVector.normalize();
  incidence = faceNormal.dot(lightVector);

  return incidence;
}

PVector shadeAmbient(float objectAmbientConst, PVector sceneAmbientLighting) {
  //AMBIENT COLOR MODEL
  // O*S
  // O = Object Ambient Reflection Constant
  // S = Scene Ambient Lighting (sometimes conputed as the sum of all lights sources)

  return PVector.mult(sceneAmbientLighting, objectAmbientConst);
}

PVector shadeDiffuse(PVector objectColor, float rho, PVector lightColor, float lightMultiplier, float incidence) {
  // ALBEDO/DIFFUSE ALGORITHM = R*L*(N dot L) 
  // R = rho = Surface Absorbtion Rate (reflectedLight /incidentLight). Here, a constant.
  // L = lightColor = Incident Light Energy = color * multiplier (lightMultiplier)
  // (N dot L) = incidence = (cosine law) 

  // MULTIPLY ELEMENTS OF ALGORYTHM
  PVector lightEnergy = PVector.mult(lightColor, lightMultiplier); // L
  PVector lightAbsorbtion = PVector.mult(lightEnergy, rho); // L * R
  PVector incidenceOnSurface = PVector.mult(lightAbsorbtion, incidence); // L * R * (N dot L)

  // FINALLY, MULTIPLY by surfaceColor 
  PVector finalColorNorm = multiplyVectorByComponent(objectColor, incidenceOnSurface);
  //PVector finalColorNorm = PVector.add(surfaceColorNorm,incidenceOnSurface);
  //println("-|| Incidence =>\t\t" + incidenceOnSurface);
  //println("-|| SurfaceColorNorm =>\t" + surfaceColorNorm);
  //println("-|| finalColorNorm =>\t" + finalColorNorm);
  //println("---------------------------------------------------\n");


  return finalColorNorm;
}

PVector shadeSpecular(float specConstant, PVector faceNormal, PVector halfAngle, float specularWidth, PVector lightColor, PVector objectSpecColor) {
  // BLINN-PHONG REFLECTION MODEL
  // K * (MAX(0, N dot H)^S) * L * M
  // K = Specular Constant
  // N = Face Normal
  // H = Viewer <=> Light Half-Angle
  // S = Specular Width (exponential falloff)
  // L = Light Specular Color
  // M = Object Specular Color

  float normalToHalfAngleIncidence = max(faceNormal.normalize().dot(halfAngle), 0);

  float withSpecConstant = pow(specConstant * normalToHalfAngleIncidence, specularWidth);
  PVector lightWithObjectSpecColor = multiplyVectorByComponent(lightColor, objectSpecColor);
  PVector finalSpecular = multiplyVectorByComponent(new PVector(withSpecConstant, withSpecConstant, withSpecConstant), lightWithObjectSpecColor);

  return finalSpecular;
}

PVector viewerToLightHalfAngle(int face, PVector viewerPos, PVector lightPos) {
  // FOR SPECULAR REFLECTION

  PVector faceCentroid = getFaceCentroid(face);
  PVector faceToViewer = PVector.sub(viewerPos, faceCentroid);
  PVector faceToLight = PVector.sub(lightPos, faceCentroid);

  PVector halfAngle = faceToViewer.normalize().add(faceToLight.normalize());

  return halfAngle;
}


PVector multiplyVectorByComponent(PVector a, PVector b) {
  return new PVector(a.x * b.x, a.y * b.y, a.z * b.z);
}

color mixLerp(color a, color b, float pct) {

  float r = (red(a) * (1-pct)) + (red(b) * pct);
  float g = (green(a) * (1-pct)) + (green(b) * pct);
  float bl = (blue(a) * (1-pct)) + (blue(b) * pct);

  return color(r, g, bl);
}

PVector mixConstrained(PVector a, PVector b) {

  float r = constrain(a.x + b.x, 0, 1);
  float g = constrain(a.y + b.y, 0, 1);
  float bl = constrain(a.z + b.z, 0, 1);

  return new PVector(r, g, bl);
}

color vectorToColor(PVector v) {
  return color(v.x * 255, v.y * 255, v.z * 255);
}

PVector colorToVector(color c) {
  return new PVector((c >> 16 & 0xFF) / 255.0, (c >> 8 & 0xFF) / 255.0, (c & 0xFF) / 255.0);
}


void constructSphere(int resolution) {
  // THE SPHERE IS GENERATED FACING TOWARDS THE FRONT (ON X/Y PLANE, AXIS on Z)
  // BUT Y AND Z VALUES ARE SWAPPED AT THE END TO ALIGN AXIS ON Y.
  // NOT FINISHED..!!! I THINK IT IS NOT THE BEST WAY TO CONSTRUCT IT,
  // MIGHT BE BETTTER TO CALCULATE PER 4 VERTICES AT A TIME

  //int resolution = 20;
  float anguloUnidad = TWO_PI / resolution;
  float escala = 50;
  float r = 1 * escala; // RADIO

  v = new float[resolution * resolution][3];
  n = new float[resolution * resolution][3];
  //f = new int[((resolution - 1) * (resolution - 1)) * 2][3];
  f = new int[((resolution * resolution)-2)*2][3];

  int faceCount = 0;

  for (int plano=0; plano < resolution; plano++) { // Sphere X/Y SLICE

    float phi = (PI / resolution) * plano;
    float z = r * cos(phi);

    for (int vert=0; vert < resolution; vert++) {

      float theta = anguloUnidad * vert;
      float x = r * sin(phi) * cos(theta);
      float y = r * sin(phi) * sin(theta);

      // Vertex Position
      PVector vertPos = new PVector(x, z, y); // SWAPPEAR Y <-> Z para iniciarla mirando hacia arriba (mas intuitivo)

      // Vertex Normal as Euler Angles
      //float angleY = -theta;
      //float angleZ = -phi + HALF_PI;

      PVector normal = vertPos.copy();
      normal.normalize();

      int id = vert + (plano * resolution);

      v[id][0] = vertPos.x;
      v[id][1] = vertPos.y;      
      v[id][2] = vertPos.z;

      n[id][0] = normal.x;
      n[id][1] = normal.y;      
      n[id][2] = normal.z;

      // FACE/TRIANGLE ASSEMBLY
      if (id >= (resolution * 2) + 1) { // START AT THE SECOND LOOP
        if (id % resolution != 0) { // BYPASS ASSEMBLY FOR START OF LOOP (HANDLE AT THE else)
          //println("\nAtVert: " + id);

          // TRIANGLE 1 OF 2 (FOR RECTANGLE)      
          //println("-|| FaceCount: " + faceCount);
          f[faceCount][0] = id - 1; 
          f[faceCount][1] = (id - 1) - resolution;
          f[faceCount][2] = id - resolution;
          faceCount++;

          // TRIANGLE 2 OF 2
          //println("-|| FaceCount: " + faceCount);
          f[faceCount][0] = id; 
          f[faceCount][1] = id - 1;
          f[faceCount][2] = id - resolution;
          faceCount++;
        } else {
          // HANDLE TRIANGLES BETWEEN FIRST AND LAST VERTEX OF LOOP
          // TRIANGLE 1 OF 2 (FOR RECTANGLE)      
          //println("-|| FaceCount: " + faceCount);
          f[faceCount][0] = id - 1; 
          f[faceCount][1] = (id - resolution) - 1;
          f[faceCount][2] = id - (resolution * 2);
          faceCount++;

          //println("-|| FaceCount: " + faceCount);
          f[faceCount][0] = id - resolution; 
          f[faceCount][1] = id - 1;
          f[faceCount][2] = id - (resolution * 2);
          faceCount++;
        }
      }
    }
  }

  println("---|| FINISHED: CALCULATING SPHERE\n");
}

void keyPressed() {
  if (key == 'n') {
    drawNormals = !drawNormals;
  }
    if (key == 'a') {
    controlAmbient = !controlAmbient;
  }
}
