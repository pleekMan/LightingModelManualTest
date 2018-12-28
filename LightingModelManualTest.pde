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

// OBJECT
float[][] v; // VERTICES 
float[][] n; // NORMALS
int[][] f; // FACES

//color[] faceColors = {color(0, 255, 0), color(0, 255, 0)};

color objectDiffuseColor = color(255, 255, 255);
  
// LIGHTS 
color lightColor = color(255, 0, 0);
color lightColor2 = color(0, 0, 255);

PVector lightPos = new PVector(-100, 0, 100);
PVector lightPos2 = new PVector(-100, 0, 100);

PVector[] lightsPos;
color[] lightsColor;

void setup() {
  size(500, 500, P3D);
  stroke(255, 100, 0);
  fill(255, 0, 0);
  sphereDetail(3);

  cam = new PeasyCam(this, 400);
  tools = new Tools();

  lightsPos = new PVector[2];
  lightsColor = new color[lightsPos.length];

  lightsPos[0] = lightPos;
  lightsPos[1] = lightPos2;
  lightsColor[0] = lightColor;
  lightsColor[1] = lightColor2;

  constructSphere(30);
}

void draw() {
  background(0);
  stroke(255, 100, 0);

  lightPos.x = 100 * (cos(frameCount * 0.01)*1.8); // ELIPSOIDAL
  lightPos.z = 100 * sin(frameCount * 0.01);

  lightPos2.x = 100 * (sin(frameCount * 0.01)*1.8); // ELIPSOIDAL
  lightPos2.z = 100 * cos(frameCount * 0.01);


  tools.drawAxisGizmo(200);

  // FACES (only 1 object)
  //float[] tempL = new float[2];
  for (int i=0; i < f.length; i++) {
    //for (int i=0; i < 1; i++) {

    PVector n = getFaceNormal(i);
    //println("---|| FINISHED: GETTING FACE NORMALS\n");
    
    // FOR EACH LIGHT...
    color[] colorForLight = new color[2];
    for (int j=0; j < lightsPos.length; j++) {
      
      float l = normalToLightIncidence(i, n, j); // face, faceNormal, light
      //println("---|| FINISHED: CALCULATING INCIDENCE\n");

      //tempL[i] = l; 

      //println("-|| ObjectColor => \tR:" + red(objectDiffuseColor) + "\tG:" + green(objectDiffuseColor)  + "\tB:" + blue(objectDiffuseColor));
      color faceDiffuse = shadeDiffuse(objectDiffuseColor, 1, lightsColor[j], 1, l);
      colorForLight[j]  = faceDiffuse;
    }
    
    //color finalColor = lerpColor(colorForLight[0], colorForLight[1],0.5);
    //color finalColor = mix(colorForLight[0], colorForLight[1],0.5); // COMO EL lerpColor. No suma las luces,  sino que las balancea
    color finalColor = mixSumado(colorForLight[0], colorForLight[1]); // sumar y clampear colores. Seria lo correcto para no perder intensidad luminica general.


    beginShape();
    fill(finalColor);
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
  fill(lightColor);
  pushMatrix();
  translate(lightPos.x, lightPos.y, lightPos.z);
  sphere(10);
  popMatrix();

  // LIGHT 2
  noStroke();
  fill(lightColor2);
  pushMatrix();
  translate(lightPos2.x, lightPos2.y, lightPos2.z);
  sphere(10);
  popMatrix();

  //-------------
  cam.beginHUD();
  fill(0, 255, 127);
  //text("FACE 0 NORMAL: \t\t" + n, 10, 20);
  text("LIGHT POS: \t\t" + lightPos, 10, 20);
  //text("LIGHT INCIDENCE ON FACE 0: " + tempL[0], 10, 40);
  //text("LIGHT INCIDENCE ON FACE 1: " + tempL[1], 10, 60);
  //text("FACE LIGHT INCIDENCE: \t\t" + l, 10, 60);
  cam.endHUD();

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

float normalToLightIncidence(int face, PVector faceNormal, int light) {
  float incidence = 0;

  // CALCULATE LIGHT VECTOR FROM CENTROID OF FACE
  // CENTROID (BY VERTEX AVERAGE):
  float cX = (v[f[face][0]][0] + v[f[face][1]][0] + v[f[face][2]][0]) / 3;
  float cY = (v[f[face][0]][1] + v[f[face][1]][1] + v[f[face][2]][1])  / 3;
  float cZ = (v[f[face][0]][2] + v[f[face][1]][2] + v[f[face][2]][2])  / 3;

  // CREATE AND VIZ CENTROID
  PVector centroid = new PVector(cX, cY, cZ);
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

color shadeDiffuse(color surfaceColor, float rho, color lightColor, float lightMultiplier, float incidence) {
  // ALBEDO/DIFFUSE ALGORITHM = R*L*(N dot L) 
  // R = rho = Surface Absorbtion Rate (reflectedLight /incidentLight). Here, a constant.
  // L = lightColor = Incident Light Energy = color * multiplier (lightMultiplier)
  // (N dot L) = incidence = (cosine law) 

  // FIRST, NORMALIZE INCOMING rgb255 COLORS. EASIER TO WORK WITH.
  PVector surfaceColorNorm = normalizeColor(surfaceColor);
  //println("-|| SurfaceColorNorm: " + surfaceColorNorm);
  PVector lightColorNorm = normalizeColor(lightColor);
  //println("-|| lightColorNorm: " + lightColorNorm);

  // MULTIPLY ELEMENTS OF ALGORYTHM
  PVector lightEnergy = PVector.mult(lightColorNorm, lightMultiplier); // L
  PVector lightAbsorbtion = PVector.mult(lightEnergy, rho); // L * R
  PVector incidenceOnSurface = PVector.mult(lightAbsorbtion, incidence); // L * R * (N dot L)

  // FINALLY, MULTIPLY by surfaceColor 
  PVector finalColorNorm = multiplyVectorByComponent(surfaceColorNorm, incidenceOnSurface);
  //PVector finalColorNorm = PVector.add(surfaceColorNorm,incidenceOnSurface);
  //println("-|| Incidence =>\t\t" + incidenceOnSurface);
  //println("-|| SurfaceColorNorm =>\t" + surfaceColorNorm);
  //println("-|| finalColorNorm =>\t" + finalColorNorm);
  //println("---------------------------------------------------\n");


  return color(finalColorNorm.x * 255, finalColorNorm.y * 255, finalColorNorm.z * 255);
}

PVector normalizeColor (color c) {
  return new PVector((c >> 16 & 0xFF) / 255.0, (c >> 8 & 0xFF) / 255.0, (c & 0xFF) / 255.0);
}

PVector multiplyVectorByComponent(PVector a, PVector b) {
  return new PVector(a.x * b.x, a.y * b.y, a.z * b.z);
}

color mix(color a, color b, float pct){
    
  float r = (red(a) * (1-pct)) + (red(b) * pct);
  float g = (green(a) * (1-pct)) + (green(b) * pct);
  float bl = (blue(a) * (1-pct)) + (blue(b) * pct);
  
  return color(r,g,bl);
}

color mixSumado(color a, color b){
    
  float r = constrain((a >> 16 & 0xFF) + (b >> 16 & 0xFF),0,255);
  float g = constrain((a >> 8 & 0xFF) + (b >> 8 & 0xFF),0,255);
  float bl = constrain((a & 0xFF) + (b & 0xFF),0,255);
  
  return color(r,g,bl);
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
}
