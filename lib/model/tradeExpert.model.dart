class TradeExpert {

  String id;
  String userId;
  String firstName;
  String lastName;
  bool isPrimary;
  String companyId;
  String email;

  TradeExpert(createObj) {
    this.id = createObj["_id"];
    this.userId = createObj["user"]["_id"];
    this.firstName = createObj["user"]["firstName"];
    this.lastName = createObj["user"]["lastName"];
    this.isPrimary = createObj["isPrimary"];
    this.companyId = createObj["company"];
    this.email = createObj["user"]["email"];
  }

  static fromJSONList(list) {
    List<TradeExpert> newList = [];
    for(var item in list) {
      newList.add(TradeExpert(item));
    }
    return newList;
  }
}