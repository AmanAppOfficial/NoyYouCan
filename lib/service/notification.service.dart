import 'package:nowyoucan/model/notification.model.dart';
import 'package:nowyoucan/utils/ApiConstants.dart';
import 'package:nowyoucan/utils/requestHandler.dart';

class NotificationService
{
  static getNotifications() async
  {
    var query = {
      "deleted": false,
      "limit": 100,
      "offset": 0,
    };
    var response = await RequestHandler.GET(ApiConstants.NOTIFICATIONS, query);

    List<NotificationList> notificationList = NotificationList.fromJSONList(response["data"]["docs"]);
    return notificationList;


  }
}