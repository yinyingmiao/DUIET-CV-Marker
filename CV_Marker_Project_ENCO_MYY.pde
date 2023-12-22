//*********************************************
// Example Code: ArUCo Fiducial Marker Detection in OpenCV Python and then send to Processing via OSC
// Rong-Hao Liang: r.liang@tue.nl

// Integrated by Yinying Miao for the CV Marker detection, tracking, and processing. 
// Supported by Olaf Adan with suggestions and small sample codes.
//*********************************************

import org.ejml.simple.SimpleMatrix;
import oscP5.*;
import netP5.*;
import processing.net.*;

//Serial data
import processing.serial.*;
Serial port; 

TagManager tm;
OscP5 oscP5;
boolean serialDebug = true;

int[] cornersID = {1, 3, 2, 0};
int[][] bundlesIDs = {{57}, {49}, {55}, {27}};
PVector[][] bundlesOffsets = { {new PVector(0, 0, 0)}, {new PVector(0, 0, 0)}, {new PVector(0, 0, 0)}, {new PVector(0, 0, 0)}};
int camWidth = 1280;
int camHeight = 720;

float touchThreshold = 0.025; //unit: m

float paperWidthOnScreen = 490; //unit: mm
float markerWidth = 20; //unit: mm
float calibgridWidth = 199; //unit:mm
float calibgridHeight = 197; //unit:mm

PImage calibImg;

ArrayList<DataObject> DOlist = new ArrayList<DataObject>();

ArrayList<Tag> activeTagList = new ArrayList<Tag>();

int tagsAmountSec2; //section 2 amount of tags

float PreviousLoc52;
float CurrentLoc52;
float PreviousLoc53;
float CurrentLoc53;
float PreviousLoc67;
float CurrentLoc67;


void setup() {
  size(1280, 720);
  oscP5 = new OscP5(this, 9000);
  initTagManager();
  
  String[] portList = Serial.list();
  
  if (portList.length > 0) {

    // Use the last available port in the list (modify this logic if needed)
    //for (int i = 0; i < Serial.list().length; i++) println("[", i, "]:", Serial.list()[i]);

    String portName = portList[3];
    
    // Print the selected port to the console for verification
    println("Using serial port:", portName);
    
    port = new Serial(this, portName, 9600);
    port.bufferUntil('\n'); // Arduino ends each data packet with a carriage return
    port.clear();
 
  
 }
}

void draw() {
  tm.update();
  background(200);
  tm.displayRaw();  
  showInfo("Unit: cm",0,height);
  
  //int tagsAmount = 0;
  
    //add this to your 'void draw' -> aka main loop
  for (Tag t : tm.tags) {                                     // look into the tags seen by TagManager
      if (t.active) {                                     // if a tag is active then
         //println("tag with id " + t.id +  " is active");      // print the id of this tag
         
           if (t.id >= 27 & t.id <= 46) {        //do something with these tags only
              tagsAmountSec2 ++;
           }
           
           if (t.id == 52) { //temperature bar
              print ("Tag 52 - temperature bar locates on the y-axis at: ");
              println (t.ty);   
              CurrentLoc52 = t.ty;
              if (CurrentLoc52 > PreviousLoc52) {
                char tempup = 'T';
                println ("Tag 52, temperature perception increases");
                port.write (tempup);
                PreviousLoc52 = CurrentLoc52;
              }
              if (CurrentLoc52 < PreviousLoc52) {
                char tempdown = 't';
                println ("Tag 52, temperature perception decreases");
                port.write (tempdown);
                PreviousLoc52 = CurrentLoc52;
              }             
           }
           
           if (t.id == 53) { //humidity bar 
              print ("Tag 53 - humidity bar locates on the y-axis at: ");
              println (t.ty);
              CurrentLoc53 = t.ty;
              if (CurrentLoc53 > PreviousLoc53) {
                char humup = 'H';
                println ("Tag 53, humidity perception increases");
                port.write (humup);
                PreviousLoc53 = CurrentLoc53;
              }
              if (CurrentLoc53 < PreviousLoc53) {
                char humdown = 'h';                
                println ("Tag 53, humidity perception decreases");
                port.write (humdown);
                PreviousLoc53 = CurrentLoc53;
              }              
           }   
           
           if (t.id == 67) { // IRIS turning for noise 
              print ("Tag 67 is at the angle of: ");
              println (t.tx);
              if (CurrentLoc67 > PreviousLoc67) {
               char noup = 'N';
               println ("Tag 67, noise, increases");
               port.write (noup);
               PreviousLoc67 = CurrentLoc67;
              }
              if (CurrentLoc67 > PreviousLoc67) {
               char nodo = 'n';
               println ("Tag 67, noise, decreases");
               port.write (nodo);
               PreviousLoc67 = CurrentLoc67;
              }                 
            }
            
            if (t.id == 60) { // air quality ball
              char airb = 'A';
              print ("Tag 60 is detected, air quality bad");
              port.write (airb);
            }
            else { 
              char airg = 'a';
              port.write (airg);
            }
            
         }
       }
  print ("the number of tags being detected in section 02: ");
  println (tagsAmountSec2);
  
  if (tagsAmountSec2 <= 12) {
    char lightb = 'L';
    port.write (lightb);
    
  }
  
  if (tagsAmountSec2 > 12) {
    char lightg = 'l';
    port.write (lightg);
  }   
    
  delay (2000);
  
  if (tagsAmountSec2 > 0) {
    tagsAmountSec2 = 0;
  }
}

void drawCalibImage(){
  pushStyle();
  imageMode(CENTER);
  image(calibImg,width/2,height/2,(float)calibImg.width*tag2screenRatio,(float)calibImg.height*tag2screenRatio);
  popStyle();
}

void drawCanvas() {
  pushStyle();
  noStroke();
  fill(255);
  rectMode(CENTER);
  rect(width/2, height/2, (float)calibImg.width*tag2screenRatio, (float)calibImg.height*tag2screenRatio);
  popStyle();
}

void showInfo(String s, int x, int y) {
  pushStyle();
  fill(52);
  textAlign(LEFT, BOTTOM);
  textSize(48);
  text(s, x, y);
  popStyle();
}
