class FloorInfo {
  int floorNumber;
  String floorAlias; 
  String floorName;

  FloorInfo(createObj) {
    this.floorNumber = createObj["number"];
    this.floorAlias = createObj["alias"];
    this.floorName = createObj["name"];
  }

  static fromJSONList(list) {
    List<FloorInfo> newList = [];
    for(var item in list) {
      newList.add(FloorInfo(item));
    }
    return newList;
  }
}