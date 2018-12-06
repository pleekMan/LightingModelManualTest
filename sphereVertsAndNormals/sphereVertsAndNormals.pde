import peasy.PeasyCam;

PeasyCam cam;

float[][] v; // VERTICES
float[][] n; // NORMALS
int[][] f; // FACES

void setup() {
  size(500, 500, P3D);
  stroke(255);
  fill(255, 0, 0);

  cam = new PeasyCam(this, 400);


  calcularPuntosEnEsfera();

  // PRINT OUT FACE VERTEX ASSIGNMENT
  for (int i=0; i < f.length; i++) {
    //println(j + (i * f.length) + "\t: " + v[f[i][j]][0] + "\t" + v[f[i][j]][1] + "\t" +v[f[i][j]][2]);
    println(i + ": " + f[i][0] + "\t" + f[i][1] + "\t" + f[i][2]);
  }
}

void draw() {
  background(0);

  float nMult = 20;
  for (int i=0; i < v.length; i++) {
    point(v[i][0], v[i][1], v[i][2]);

    line(v[i][0], v[i][1], v[i][2], v[i][0] + (n[i][0] * nMult), v[i][1] + (n[i][1] * nMult), v[i][2] + (n[i][2]* nMult));
  }

  // FACES
  for (int i=0; i < f.length; i++) {

    beginShape();
    fill(0, 255, 127);
    // FACES VERTICES
    for (int j=0; j < 3; j++) {
      vertex(v[f[i][j]][0], v[f[i][j]][1], v[f[i][j]][2] );
    }
    endShape(CLOSE);
  }
}


void calcularPuntosEnEsfera() {
  // THE SPHERE IS GENERATED FACING TOWARDS THE FRONT (ON X/Y PLANE)
  // BUT Y AND Z VALUES ARE SWAPPED AT THE END TO ALIGN AXIS ON Y.
  // NOT FINISHED..!!! I THINK IT IS NOT THE BEST WAY TO CONSTRUCT IT,
  // MIGHT BE BETTTER TO CALCULATE PER 4 VERTICES AT A TIME

  int resolution = 7;
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
          println("\nAtVert: " + id);

          // TRIANGLE 1 OF 2 (FOR RECTANGLE)      
          println("-|| FaceCount: " + faceCount);
          f[faceCount][0] = id - 1; 
          f[faceCount][1] = (id - 1) - resolution;
          f[faceCount][2] = id - resolution;
          faceCount++;

          // TRIANGLE 2 OF 2
          println("-|| FaceCount: " + faceCount);
          f[faceCount][0] = id; 
          f[faceCount][1] = id - 1;
          f[faceCount][2] = id - resolution;
          faceCount++;
        } else {

          // TRIANGLE 1 OF 2 (FOR RECTANGLE)      
          println("-|| FaceCount: " + faceCount);
          f[faceCount][0] = id - 1; 
          f[faceCount][1] = (id - resolution) - 1;
          f[faceCount][2] = id - (resolution * 2);
          faceCount++;

          println("-|| FaceCount: " + faceCount);
          f[faceCount][0] = id - resolution; 
          f[faceCount][1] = id - 1;
          f[faceCount][2] = id - (resolution * 2);
          faceCount++;
        }
      }
    }
  }
}
