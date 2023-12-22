class DataObject {
  int OBJ_WIDTH = 300;
  int dataID;
  int lastCtrlID=-1;
  boolean multiControl;
  float x, y, r, h, w;
  float val;
  float tempVal = 0;
  ArrayList<Integer> ctrlIDList;
  ArrayList<PVector> ref2DList;
  ArrayList<Float> ref_rList;
  color fg_m = color(250, 177, 160);
  color fg_s = color(162, 155, 254);
  color bg = color(52);
  PVector ref2D; //reference 2D point for the MT gestures
  float ref_r; //reference angle for the MT gestures
  boolean bEngaged = false;
  float d0, theta0;
  PVector m0;
  int textSizeL=24;
  int textSizeM=20;
  int gestureType = 0;
  int numTouches = 0;
  boolean gesturePerformed = false;
  final float TH_S = 30; // unit: px
  final float TH_R = 10; // unit: degree
  final float TH_T = 30; // unit: px
  final int UNDEFINED = 0;
  final int SCALING = 1;
  final int ROTATION = 2;
  final int TRANSLATION = 3;
  float scale = 1;
  float rotation = 0;
  PVector translation = new PVector(0, 0);
  String lastGestureInfo = "";

  DataObject(int did, boolean multi, float val, float x, float y, float r, float h, float w) {
    this.dataID = did;
    this.set(val, x, y, r, h, w);
    this.ref2D = new PVector(0, 0);
    this.ref_r = 0;
    this.ctrlIDList = new ArrayList<Integer>();
    this.ref2DList = new ArrayList<PVector>();
    this.ref_rList = new ArrayList<Float>();
    this.multiControl = multi;
  }
  
  DataObject(int did, boolean multi, float val, float x, float y, float w) {
    this.dataID = did;
    this.set(val, x, y, 0, w, w);
    this.ref2D = new PVector(0, 0);
    this.ref_r = 0;
    this.ctrlIDList = new ArrayList<Integer>();
    this.ref2DList = new ArrayList<PVector>();
    this.ref_rList = new ArrayList<Float>();
    this.multiControl = multi;
  }

  DataObject(int did, boolean multi, float val, float x, float y) {
    this.dataID = did;
    this.set(val, x, y, 0, OBJ_WIDTH, OBJ_WIDTH);
    this.ref2D = new PVector(0, 0);
    this.ref_r = 0;
    this.ctrlIDList = new ArrayList<Integer>();
    this.ref2DList = new ArrayList<PVector>();
    this.ref_rList = new ArrayList<Float>();
    this.multiControl = multi;
  }

  void set(float val, float x, float y, float r, float h, float w) {
    this.update(val, x, y, r, h, w);
  }
  
  void setValue(float val){
    this.val = val;
  }
  void setTempVal(float val){
    this.tempVal = val;
  }

  void addCtrlID(int cid, PVector ref2d, float ref_r) {
    this.ctrlIDList.add(cid);
    this.ref2DList.add(ref2d);
    this.ref_rList.add(ref_r);
  }

  boolean hasCtrlID(int cid) {
    boolean found = false;
    for (int i : ctrlIDList) {
      if (i == cid) found=true;
    }
    return found;
  }

  void removeCtrlID(int cid) {
    for (int i = ctrlIDList.size()-1; i>=0; i--) {
      if (this.ctrlIDList.get(i) == cid) {
        this.ctrlIDList.remove(i);
        this.ref2DList.remove(i);
        this.ref_rList.remove(i);
      }
    }
  }

  int getCtrlCounts() {
    return this.ctrlIDList.size();
  }

  void setRef2D(PVector l, float r) {
    this.ref2D = new PVector (l.x, l.y);//new PVector (l.x-this.x, l.y-this.y);
    this.ref_r = r;
    println(ref2D.x, ref2D.y, ref_r);
  }

  void update(float val, float x, float y, float r, float h, float w) {
    this.val = val;
    this.x = x;
    this.y = y;
    this.r = r;
    this.h = h;
    this.w = w;
  }

  void update(float val, float x, float y, float r) {
    this.val = val;
    this.x = x;
    this.y = y;
    this.r = r;
  }

  void update(float val, float x, float y) {
    this.val = val;
    this.x = x;
    this.y = y;
  }

  void update(float x, float y) {
    this.x = x;
    this.y = y;
  }

  void update(float val) {
    this.val = val;
  }

  boolean checkHit(float cx, float cy, float d) {
    boolean hit = false;
    return abs(this.x-cx)<(this.w/2+d) && abs(this.y-cy)<(this.h/2+d);
  }

  void display() {
    String ctrlIDstr = "";
    for (int i : ctrlIDList) ctrlIDstr += ("["+i+"]");
    String label = dataID+":"+ctrlIDstr+"\n"+nf((val+tempVal),0,2);
    pushMatrix();
    pushStyle();
    if(multiControl) fill(fg_m);
    else fill(fg_s);
    noStroke();
    rectMode(CENTER);
    rect(x, y, w, w);
    //line(x, y, x + w/2 * cos(r), y + w/2 * sin(r));
    fill(bg);
    noStroke();
    textSize(w/6);
    textAlign(CENTER, CENTER);
    text(label, x, y);
    popStyle();
    popMatrix();
  }
  
  void drawSTGestureInfo() {
    String info = "[Thresholds > Movement]\n" + 
      "\n rotation =" + nf(degrees(rotation), 1, 2) +
      "\n translation = (X: " + nf(translation.x, 1, 1) + ", Y:" + nf(translation.y, 1, 1) + ")";
    if (gestureType!=UNDEFINED) {
      info ="[Movement > Thresholds]\n rotation = " + nf(degrees(rotation), 1, 2) + " degrees \n" +
        "translation = (X: " + nf(translation.x, 1, 1) + ", Y:" + nf(translation.y, 1, 1) + ") pixels";
    }
    pushStyle();
    fill(0, 255, 0);
    textSize(textSizeM);
    text(info, this.x, this.y);
    rectMode(CENTER);
    noFill();
    popStyle();
  }
  
  void getSTGestureType() {
    if (degrees(rotation)>TH_R) {
      dataObjectIsSingleTurnedLeft(dataID, lastCtrlID);
    }
    if (degrees(rotation)<-TH_R) {
      dataObjectIsSingleTurnedRight(dataID, lastCtrlID);
    }
    if (gestureType==UNDEFINED) {
      dataObjectIsSingleTapped(dataID, lastCtrlID);
    }
  }
  
  void drawSTGestureType() {
    pushMatrix();
    pushStyle();
    fill(0, 255, 0);
    textSize(textSizeM);
    translate(this.x,this.y);
    String lastGestureInfo =" rotated " + nf(degrees(this.rotation), 1, 2) + " degrees" +
      "\n translated (X: " + nf(this.translation.x, 1, 1) + ", Y:" + nf(this.translation.y, 1, 1) + ") pxs";
    text("last gesture:\n"+ lastGestureInfo, 0, 0);
    text("Can be recognized as:", 0, 3*textSizeL);
    if (degrees(rotation)>TH_R) {
      text(dataID+":[turned left]", 0, 4*textSizeL);
    }
    if (degrees(rotation)<-TH_R) {
      text(dataID+":[turned right]", 0, 4*textSizeL);
    }
    if (gestureType==UNDEFINED && numTouches>0) {
      text(dataID+":[tapped]", 0, 5*textSizeL);
    }
    popStyle();
    popMatrix();
  }
  
  void drawMTGestureInfo() {
    String info = "[Thresholds > Movement]\n" + 
      "\n scale =" + nf(scale, 1, 1) +
      "\n rotation =" + nf(degrees(rotation), 1, 2) +
      "\n translation = (X: " + nf(translation.x, 1, 1) + ", Y:" + nf(translation.y, 1, 1) + ")";
    if (gestureType!=UNDEFINED) {
      info ="[Movement > Thresholds]\n scale = " + nf(scale, 1, 1) + " pixels \n"+ 
        "rotation = " + nf(degrees(rotation), 1, 2) + " degrees \n" +
        "translation = (X: " + nf(translation.x, 1, 1) + ", Y:" + nf(translation.y, 1, 1) + ") pixels";
    }
    pushStyle();
    fill(0, 255, 0);
    textSize(textSizeM);
    text(info, this.x, this.y);
    rectMode(CENTER);
    noFill();
    popStyle();
  }
  
  void getMTGestureType() {
    if (scale>TH_S) {
      dataObjectIsPinched(dataID, lastCtrlID);
    }
    if (scale<-TH_S) {
      dataObjectIsSpreaded(dataID, lastCtrlID);
    }
    if (degrees(rotation)>TH_R) {
      dataObjectIsTurnedLeft(dataID, lastCtrlID);
    }
    if (degrees(rotation)<-TH_R) {
      dataObjectIsTurnedRight(dataID, lastCtrlID);
    }
    if (translation.x>TH_T) {
      dataObjectIsSwipedRight(dataID, lastCtrlID);
    }
    if (translation.x<-TH_T) {
      dataObjectIsSwipedLeft(dataID, lastCtrlID);
    }
    if (translation.y>TH_T) {
      dataObjectIsSwipedDown(dataID, lastCtrlID);
    }
    if (translation.y<-TH_T) {
      dataObjectIsSwipedUp(dataID, lastCtrlID);
    }
    if (gestureType==UNDEFINED) {
      dataObjectIsMultiTapped(dataID, lastCtrlID, numTouches);
    }
  }

  void drawMTGestureType() {
    pushMatrix();
    pushStyle();
    fill(0, 255, 0);
    textSize(textSizeM);
    translate(this.x,this.y);
    String lastGestureInfo =" scaled " + nf(this.scale, 1, 1) + " pxs" +
      "\n rotated " + nf(degrees(this.rotation), 1, 2) + " degrees" +
      "\n translated (X: " + nf(this.translation.x, 1, 1) + ", Y:" + nf(this.translation.y, 1, 1) + ") pxs";
    text("last gesture:\n"+ lastGestureInfo, 0, 0);
    text("Can be recognized as:", 0, 4*textSizeL);
    if (scale>TH_S) {
      text(dataID+":[pinched]", 0, 5*textSizeL);
      //myPort.write('a');
    }
    if (scale<-TH_S) {
      text(dataID+":[spreaded]", 0, 5*textSizeL);
      //myPort.write('b');
    }
    if (degrees(rotation)>TH_R) {
      text(dataID+":[turned left]", 0, 6*textSizeL);
    }
    if (degrees(rotation)<-TH_R) {
      text(dataID+":[turned right]", 0, 6*textSizeL);
    }
    if (translation.x>TH_T) {
      text(dataID+":[swiped right]", 0, 7*textSizeL);
    }
    if (translation.x<-TH_T) {
      text(dataID+":[swiped left]", 0, 7*textSizeL);
    }
    if (translation.y>TH_T) {
      text(dataID+":[swiped down]", 0, 8*textSizeL);
    }
    if (translation.y<-TH_T) {
      text(dataID+":[swiped up]", 0, 8*textSizeL);
    }
    if (gestureType==UNDEFINED && numTouches>0) {
      text(dataID+":[tapped with "+numTouches+" fingers]", 0, 9*textSizeL);
    }
    popStyle();
    popMatrix();
  }
  
  
}
