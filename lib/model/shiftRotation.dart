class ShiftRotation {

  String id;
  String name;
  String startDate;
  String endDate;
  String createdBy;

  ShiftRotation(shiftRotationObj) {
    this.id = shiftRotationObj["shiftRotation"]["_id"];
    this.name = shiftRotationObj["shiftRotation"]["name"];
    this.startDate = shiftRotationObj["shiftRotation"]["startDate"];
    this.endDate = shiftRotationObj["shiftRotation"]["endDate"];
    this.createdBy = shiftRotationObj["shiftRotation"]["createdBy"];
  }

  static fromJSONList(list) {
    print(list);
    List<ShiftRotation> newShiftRotationList = [];
    list.forEach((element) {
      newShiftRotationList.add(new ShiftRotation(element));
    });
    return newShiftRotationList;
  }

}
