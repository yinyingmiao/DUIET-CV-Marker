//trigger your events here

void tagPresent3D(int id, float tx, float ty, float tz, float rx, float ry, float rz) {
}

void tagAbsent3D(int id, float tx, float ty, float tz, float rx, float ry, float rz) {
    //println("- Tag:", id, "loc = (", tx, ",", ty, ",", tz,"), angle = (", degrees(rx),",",degrees(ry),",",degrees(rz),")");
}

void tagUpdate3D(int id, float tx, float ty, float tz, float rx, float ry, float rz) {
  //if(serialDebug && !isCorner(id)) println("% Tag:", id, "loc = (", tx, ",", ty, ",", tz,"), angle = (", degrees(rx),",",degrees(ry),",",degrees(rz),")");
}

void tagPresent2D(int id, float x, float y, float z, float rz) {
  if (serialDebug && homographyMatrixCalculated && !isCorner(id)) {
    PVector t = img2screen(transformPoint(new PVector(x, y, z), homography));
    //println("+ Tag:", id, "loc = (", t.x, ",", t.y, "), angle = ", degrees(rz));
  }
}

void tagAbsent2D(int id, float x, float y, float z, float rz) {
  if (serialDebug && homographyMatrixCalculated && !isCorner(id)) {
    PVector t = img2screen(transformPoint(new PVector(x, y, z), homography));
    //println("- Tag:", id, "loc = (", t.x, ",", t.y, "), angle = ", degrees(rz));
  }
}

void tagUpdate2D(int id, float x, float y, float z, float rz) {
  if (serialDebug && homographyMatrixCalculated && !isCorner(id)) {
    PVector t = img2screen(transformPoint(new PVector(x, y, z), homography));
    float distance = distancePointToPlane(new PVector(x, y, z), planePoints);
    //println("% Tag:", id, "loc = (", t.x, ",", t.y, "), angle = ", degrees(rz),", d= ",distance);
  }
}

void bundlePresent2D(int id, float x, float y, float z, float rz) {
  if (serialDebug && homographyMatrixCalculated && !isCorner(id)) {
    PVector t = img2screen(transformPoint(new PVector(x, y, z), homography));
    //println("+ Bundle:", id, "loc = (", t.x, ",", t.y, "), angle = ", degrees(rz));
  }
  if (homographyMatrixCalculated && !isCorner(id)) {
    PVector t = img2screen(transformPoint(new PVector(x, y, z), homography));
    for (DataObject obj : DOlist) {
      if (obj.checkHit(t.x, t.y, tm.BUNDLE_D/2)) {
        if (!obj.hasCtrlID(id)) {
          obj.addCtrlID(id, new PVector(t.x,t.y), rz);
        }
      }
    }
  }
}

void bundleAbsent2D(int id, float x, float y, float z, float rz) {
  if (serialDebug && homographyMatrixCalculated && !isCorner(id)) {
    PVector t = img2screen(transformPoint(new PVector(x, y, z), homography));
    //println("- Bundle:", id, "loc = (", t.x, ",", t.y, "), angle = ", degrees(rz));
  }
  if (homographyMatrixCalculated && !isCorner(id)) {
    PVector t = img2screen(transformPoint(new PVector(x, y, z), homography));
    for (DataObject obj : DOlist) {
      if (obj.hasCtrlID(id)) {
        obj.removeCtrlID(id);
      }
    }
  }
}

void bundleUpdate2D(int id, float x, float y, float z, float rz) {
  if (serialDebug && homographyMatrixCalculated && !isCorner(id)) {
    PVector t = img2screen(transformPoint(new PVector(x, y, z), homography));
    //println("% Tag:", id, "loc = (", t.x, ",", t.y, "), angle = ", degrees(rz));
  }
  if (homographyMatrixCalculated && !isCorner(id)) {
    PVector t = img2screen(transformPoint(new PVector(x, y, z), homography));
    for (DataObject obj : DOlist) {
      if (obj.hasCtrlID(id)) {
        if (obj.getCtrlCounts()==1) {
          //obj.update(obj.val, t.x-obj.ref2D.x, t.y-obj.ref2D.x, rz-obj.ref_r);
        }
      }
    }
  }
}
