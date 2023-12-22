PVector[] srcPoints = new PVector[4];
PVector[] dstPoints = new PVector[4];
PVector[] planePoints = new PVector[4];

PVector globalR = new PVector();

boolean homographyMatrixCalculated = false;
SimpleMatrix homography;

ArrayList idBundles;
ArrayList offsetBundles;

float tag2screenRatio = 297. / paperWidthOnScreen; //1
PVector cCen = new PVector (842./2., 595./2.);
float mW = (markerWidth/25.4*72.)*tag2screenRatio;
float mDC1 = (calibgridWidth/2)*(72/25.4)*tag2screenRatio;
float mDC2 = (calibgridHeight/2)*(72/25.4)*tag2screenRatio;
float[] markerX = {(cCen.x-mDC1+mW/2), (cCen.x-mDC1+mW/2), (cCen.x+mDC2-mW/2), (cCen.x+mDC2-mW/2)};
float[] markerY = {(cCen.y-mDC1+mW/2), (cCen.y+mDC1+mW/2), (cCen.y-mDC2-mW/2), (cCen.y+mDC2-mW/2)};
float markerGridWidth = markerX[2]-markerX[0];
PVector markerOffset = new PVector(markerX[0], markerY[0]);
PVector windowOffset = new PVector(0, 0);
PVector imageOffset = new PVector(0, 0);
float alpha = 0;

void initTagManager() {
  idBundles = new ArrayList();
  offsetBundles = new ArrayList();
  for (int i = 0; i < bundlesIDs.length; i++) {
    ArrayList ids = new ArrayList();
    ArrayList offsets = new ArrayList();
    for (int j = 0; j < bundlesIDs[i].length; j++) {
      ids.add(bundlesIDs[i][j]);
      offsets.add(bundlesOffsets[i][j]);
    }
    idBundles.add(ids);
    offsetBundles.add(offsets);
  }
  tm = new TagManager(600, idBundles, offsetBundles);
}

void calculateHomographyMatrix() {
  srcPoints[0] = new PVector(tm.tags[cornersID[0]].tx, tm.tags[cornersID[0]].ty, tm.tags[cornersID[0]].tz);
  srcPoints[1] = new PVector(tm.tags[cornersID[1]].tx, tm.tags[cornersID[1]].ty, tm.tags[cornersID[1]].tz);
  srcPoints[2] = new PVector(tm.tags[cornersID[2]].tx, tm.tags[cornersID[2]].ty, tm.tags[cornersID[2]].tz);
  srcPoints[3] = new PVector(tm.tags[cornersID[3]].tx, tm.tags[cornersID[3]].ty, tm.tags[cornersID[3]].tz);

  dstPoints[0] = new PVector(0, 0);
  dstPoints[1] = new PVector(1, 0);
  dstPoints[2] = new PVector(1, 1);
  dstPoints[3] = new PVector(0, 1);

  homography = calculateHomography(srcPoints, dstPoints);
}

void registerPlanePoints() {
  planePoints[0] = new PVector(srcPoints[0].x, srcPoints[0].y, srcPoints[0].z);
  planePoints[1] = new PVector(srcPoints[1].x, srcPoints[1].y, srcPoints[1].z);
  planePoints[2] = new PVector(srcPoints[2].x, srcPoints[2].y, srcPoints[2].z);
  planePoints[3] = new PVector(srcPoints[3].x, srcPoints[3].y, srcPoints[3].z);
}

boolean cornersDetected() {
  if (tm.tags[cornersID[0]].active &&
    tm.tags[cornersID[1]].active &&
    tm.tags[cornersID[2]].active &&
    tm.tags[cornersID[3]].active) {
    return true;
  } else {
    return false;
  }
}

boolean isCorner(int id) {
  if (id == cornersID[0] || id == cornersID[1] || id == cornersID[2] || id == cornersID[3]) {
    return true;
  } else {
    return false;
  }
}

SimpleMatrix calculateHomography(PVector[] srcPoints, PVector[] dstPoints) {
  SimpleMatrix srcMatrix = new SimpleMatrix(3, 4);
  SimpleMatrix dstMatrix = new SimpleMatrix(3, 4);

  for (int i = 0; i < 4; i++) {
    srcMatrix.set(0, i, srcPoints[i].x);
    srcMatrix.set(1, i, srcPoints[i].y);
    srcMatrix.set(2, i, srcPoints[i].z);

    dstMatrix.set(0, i, dstPoints[i].x);
    dstMatrix.set(1, i, dstPoints[i].y);
    dstMatrix.set(2, i, 1.0);
  }

  return dstMatrix.mult(srcMatrix.pseudoInverse());
}

PVector transformPoint(PVector point, SimpleMatrix homography) {
  float x = point.x;
  float y = point.y;
  float z = point.z;

  SimpleMatrix result = homography.mult(new SimpleMatrix(new double[][] {{x}, {y}, {z}}));

  float w = (float) result.get(2, 0);
  float transformedX = (float) (result.get(0, 0) / w);
  float transformedY = (float) (result.get(1, 0) / w);

  return new PVector(transformedX, transformedY);
}

PVector img2screen(PVector p) {
  PVector wo = windowOffset;
  PVector io = imageOffset;
  PVector mo = markerOffset;
  float mgw = markerGridWidth;
  return new PVector (p.x*mgw + wo.x + io.x + mo.x, p.y*mgw + wo.y + io.y + mo.y);
}

float distancePointToPlane(PVector point, PVector[] planePoints) {
  PVector normal = cross(subtract(planePoints[1], planePoints[0]), subtract(planePoints[2], planePoints[0])); // Calculate the normal vector to the plane
  float d = -dot(normal, planePoints[0]); // Calculate the d coefficient of the plane equation

  // Use the plane equation to find the distance
  float numerator = abs(dot(normal, point) + d);
  float denominator = sqrt(pow(normal.x, 2) + pow(normal.y, 2) + pow(normal.z, 2));

  return numerator / denominator;
}

PVector cross(PVector v1, PVector v2) {
  return new PVector(
    v1.y * v2.z - v1.z * v2.y,
    v1.z * v2.x - v1.x * v2.z,
    v1.x * v2.y - v1.y * v2.x
    );
}

float dot(PVector v1, PVector v2) {
  return v1.x * v2.x + v1.y * v2.y + v1.z * v2.z;
}

PVector subtract(PVector v1, PVector v2) {
  return new PVector(v1.x - v2.x, v1.y - v2.y, v1.z - v2.z);
}

float getDistanceBetween(PVector p0, PVector p1) {
  return dist(p0.x, p0.y, p1.x, p1.y);
}

float getAngleBetween(PVector p0, PVector p1) {
  return atan2(p1.y-p0.y, p1.x-p0.x);
}

PVector getCentroidBetween(PVector p0, PVector p1) {
  return PVector.add(p0, p1).div(2);
}
