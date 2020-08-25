class FacilityCategory {
  String id;
  String name;

  FacilityCategory(createObj) {
    this.id = createObj["_id"];
    this.name = createObj["name"];
  }

  static fromJSONList(list) {
    print(list);
    List<FacilityCategory> newShiftList = [];
    list.forEach((element) {
      newShiftList.add(new FacilityCategory(element));
    });
    return newShiftList;
  }

}