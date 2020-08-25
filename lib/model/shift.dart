class Shift {
  String id;
  String name;
  String startTime;
  String endTime;

  Shift(createObj) {
    this.id = createObj["_id"];
    this.name = createObj["name"];
    this.startTime = createObj["startTime"];
    this.endTime = createObj["endTime"];
  }

  static fromJSONList(list) {
    print(list);
    List<Shift> newShiftList = [];
    list.forEach((element) {
      newShiftList.add(new Shift(element));
    });
    return newShiftList;
  }

}