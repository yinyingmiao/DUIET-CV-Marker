void dataObjectBeingMultiSwipedX(int dataID, int ctrlID){
  println("DataObject", dataID,"is being multi-swiped (X-axis): Bundle", ctrlID);
  DataObject obj = DOlist.get(dataID);
  if(dataID==4) DOlist.get(dataID).setTempVal(map(degrees(obj.translation.x),0,100,0,10));
}

void dataObjectBeingMultiSwipedY(int dataID, int ctrlID){
  println("DataObject", dataID,"is being multi-swiped (Y-axis): Bundle", ctrlID);
  DataObject obj = DOlist.get(dataID);
  if(dataID==5) DOlist.get(dataID).setTempVal(map(degrees(-obj.translation.y),0,100,0,10));
}

void dataObjectBeingMultiScaled(int dataID, int ctrlID){
  println("DataObject", dataID,"is being Pinched: Bundle", ctrlID);
  DataObject obj = DOlist.get(dataID);
  if(dataID==6) DOlist.get(dataID).setTempVal(map(degrees(-obj.scale),0,100,0,10));
}

void dataObjectBeingMultiRotated(int dataID, int ctrlID){
  println("DataObject", dataID,"is being multi-turned: Bundle", ctrlID);
  DataObject obj = DOlist.get(dataID);
  if(dataID==7) DOlist.get(dataID).setTempVal(map(degrees(-obj.rotation),0,100,0,10));
}

void dataObjectBeingSingleRotated(int dataID, int ctrlID){
  println("DataObject", dataID,"is being single Turned: Bundle", ctrlID);
  DataObject obj = DOlist.get(dataID);
  if(ctrlID == 57 && dataID == 9) obj.setTempVal(map(degrees(obj.rotation),0,100,0,10));
  if(ctrlID == 49 && dataID == 9) obj.setTempVal(map(degrees(obj.rotation),0,100,0,10));
}
