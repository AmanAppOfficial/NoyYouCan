class CommentCategory {
  String id;
  String name;
  String icon;

  CommentCategory(createObj) {
    this.id = createObj["_id"];
    this.name = createObj["name"];
    this.icon = createObj["icon"];
  }

  static fromJSONList(list) {
    List<CommentCategory> newList = []; 
    list.forEach((element) {
      newList.add(
        new CommentCategory(element)
      );
    });
    return newList;
  }
}