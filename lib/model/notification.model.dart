class NotificationList
{
  String message;
  String date;

  NotificationList(createObj)
  {
    this.message = createObj["message"];
    this.date = createObj["createdAt"];
  }

  static List<NotificationList> fromJSONList(list) {
    List<NotificationList> newList = [];
    list.forEach((element) {
      newList.add(
          new NotificationList(element)
      );
    });
    return newList;
  }
}