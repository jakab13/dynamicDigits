import processing.opengl.*;

import processing.video.*;
MovieMaker mm;

import blobDetection.*;

int numLines = 70;

BlobDetection theBlobDetection;
PImage img;
Blob b;
EdgeVertex[][][] eA = new EdgeVertex[1800][3][10];
EdgeVertex[][][] eB = new EdgeVertex[1800][3][10];
int[][] edgeSize = new int[3][10];
int[] blobNum = new int[10];

float[][][] beginX = new float[2][numLines][6];  // Initial x-coordinate
float[][][] beginY = new float[2][numLines][6];  // Initial y-coordinate
float[][][] endX = new float[2][numLines][6];   // Final x-coordinate
float[][][] endY = new float[2][numLines][6];   // Final y-coordinate
float[][][] distX = new float[2][numLines][6];          // X-axis distance to move
float[][][] distY = new float[2][numLines][6];          // Y-axis distance to move
float exponent = 0.35;   // Determines the curve
float[][][] x = new float[2][numLines][6];        // Current x-coordinate
float[][][] y = new float[2][numLines][6];        // Current y-coordinate
float step = 1/(4.5*frameRate);    // Size of each step along the path
float pct = 0.0;      // Percentage traveled (0.0 to 1.0)

int sec1, sec10, min1, min10, hour1, hour10;
boolean tick;
int frameNum = 0;
Digit[] digit = new Digit[6];

void setup() 
{
  // --------- Setup blobdetection -------- //
  for (int i = 0; i<10; i++) {
    img = loadImage(i+"gill.jpeg");

    theBlobDetection = new BlobDetection(img.width, img.height);
    theBlobDetection.setPosDiscrimination(false);
    theBlobDetection.setThreshold(0.38f);
    theBlobDetection.computeBlobs(img.pixels);

    blobNum[i] = theBlobDetection.getBlobNb();

    for (int n=0 ; n<blobNum[i] ; n++)
    {
      b=theBlobDetection.getBlob(n);
      edgeSize[n][i] = b.getEdgeNb();
      if (b!=null)
      {  
        strokeWeight(2);
        stroke(0, 255, 0);

        for (int m=0;m<b.getEdgeNb();m++)
        {
          eA[m][n][i] = b.getEdgeVertexA(m);
          eB[m][n][i] = b.getEdgeVertexB(m);
        }
      }
    }
  }

  size(1280, 800, OPENGL);
  mm = new MovieMaker(this, width, height, "test.mov", 60, MovieMaker.JPEG, MovieMaker.HIGH);

  // ------------- Setup points ------------ //
  smooth();
  for (int k=0; k<6; k++) {
    for (int j=0; j<numLines; j++) {
      for (int i=0; i<2; i++) {
        distX[i][j][k] = endX[i][j][k] - beginX[i][j][k];
        distY[i][j][k] = endY[i][j][k] - beginY[i][j][k];
        beginX[i][j][k] = random(width);  // Initial x-coordinate
        beginY[i][j][k] = random(height);  // Initial y-coordinate
        endX[i][j][k] = random(width);   // Final x-coordinate
        endY[i][j][k] = random(height);   // Final y-coordinate
        x[i][j][k] = random(width);        // Current x-coordinate
        y[i][j][k] = random(height);        // Current y-coordinate
      }
    }
  }
}


void draw() 
{
  sec1 = second()%10;
  sec10 = second()/10;
  min1 = minute()%10;
  min10 = minute()/10;
  hour1 = hour()%10;
  hour10 = hour()/10;

  frameNum ++;
  int frameNumModulo = frameNum%60;
  println(frameNumModulo);

  if (frameNumModulo == 0) {
    tick = true;
  }
  else { 
    tick = false;
  }

  digit[0] = new Digit(0, tick, hour10, -105);
  digit[1] = new Digit(1,tick, hour1, 45);
  digit[2] = new Digit(2,tick, min10, 322);
  digit[3] = new Digit(3,tick, min1, 472);
  digit[4] = new Digit(4,tick, sec10, 749);
  digit[5] = new Digit(5,tick, sec1, 899);

  for (int k = 0; k<6; k++) {
    digit[k].generate();
  }

  background(0);
  stroke(255, 50);
  line(427,280,427,500);
  line(854,280,854,500);
  fill(255);

  pct += step;
  if (pct < 0.99999 + step) {
    for (int k = 0; k<6; k++) {
      for (int j=0; j<numLines; j++) {
        for (int i=0; i<2; i++) { 
          x[i][j][k] = beginX[i][j][k] + pow((sin(PI*pct-HALF_PI)+1)/2,exponent) * distX[i][j][k];
          y[i][j][k] = beginY[i][j][k] + (sin(PI/2*pct) * distY[i][j][k]);
        }
      }
    }
  }
  fill(255);
  for (int k = 0; k<6; k++) {
    for (int j=0; j<numLines; j++) {
      for (int i=0; i<2; i++) {
        ellipse(x[i][j][k], y[i][j][k], 3, 3);
      }
      stroke(255, 35);
      line(x[0][j][k], y[0][j][k], x[1][j][k], y[1][j][k]);
    }
  }
  
   mm.addFrame();
}

class Digit {

  boolean tick;
  int number;
  float pos;
  int digitPos;

  Digit(int tempdigitPos, boolean temptick, int tempnumber, float temppos)  
  {
    digitPos = tempdigitPos;
    tick = temptick;
    number = tempnumber;
    pos = temppos;
  }

  void generate() {

    if (tick)
    {
      pct = 0.0;
      for (int j=0; j<numLines; j++) {
        for (int i=0; i<2; i++) {
          int rand1 = int(random(blobNum[number]));
          int rand2 = int(random(edgeSize[rand1][number]));
          beginX[i][j][digitPos] = x[i][j][digitPos];
          beginY[i][j][digitPos] = y[i][j][digitPos];
          endX[0][j][digitPos] = eA[rand2][rand1][number].x*500 + pos;
          endY[0][j][digitPos] = eA[rand2][rand1][number].y*375 + 200;
          endX[1][j][digitPos] = eB[rand2][rand1][number].x*500 + pos;
          endY[1][j][digitPos] = eB[rand2][rand1][number].y*375 + 200;
          distX[i][j][digitPos] = endX[i][j][digitPos] - beginX[i][j][digitPos];
          distY[i][j][digitPos] = endY[i][j][digitPos] - beginY[i][j][digitPos];
        }
      }
    }
  }
}

void keyPressed() {
  // Finish the movie if space bar is pressed!
  if (key == ' ' ) {
    println( "finishing movie" );
    // Do not forget to finish the movie! Otherwise, it will not play properly.
    mm.finish();
  }
}

