class QualiltyReviewComment {
  String id;
  String comment;
  bool memberShare;

  QualiltyReviewComment(createObj) {
    this.id = createObj["_id"];
    this.comment = createObj["comment"];
    this.memberShare = createObj["memberShare"];
  }

  static fromJSONList(list) {
    List<QualiltyReviewComment> newShiftList = [];

    if(list != null)
      {
        list.forEach((element) {
          newShiftList.add(new QualiltyReviewComment(element));
        });
      }

    return newShiftList;
  }
}