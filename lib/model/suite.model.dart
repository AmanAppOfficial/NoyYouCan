class SuiteInfo {

  int floorNumber;
  String floorAlias; 
  String floorName;
  String suiteNo;

  SuiteInfo(createObj) {
    this.floorNumber = createObj["floorNumber"];
    this.floorAlias = createObj["floorNo"]; 
    this.floorName = createObj["name"];
    this.suiteNo = createObj["suiteNo"];
  }

  static fromJSONList(list) {
    List<SuiteInfo> newList = [];
    for(var item in list) {
      newList.add(SuiteInfo(item));
    }
    return newList;
  }
}