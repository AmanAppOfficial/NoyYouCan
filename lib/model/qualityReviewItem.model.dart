class QualiltyReviewItem {
  String id;
  String name;
  int rating;

  QualiltyReviewItem(createObj) {
    this.id = createObj["_id"];
    this.name = createObj["name"];
    this.rating = createObj["rating"];
  }

  static fromJSONList(list) {
    List<QualiltyReviewItem> newShiftList = [];
    if(list != null)
      {

        list.forEach((element) {
          newShiftList.add(new QualiltyReviewItem(element));

        });
      }
    return newShiftList;

  }
}