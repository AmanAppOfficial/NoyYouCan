import 'package:nowyoucan/utils/ApiConstants.dart';
import 'package:nowyoucan/utils/requestHandler.dart';

class MessageService
{

  static getMessages() async
  {
    var response = await RequestHandler.GET(ApiConstants.MESSAGES);

    return response["data"]["docs"];

  }

  static postMessages(body) async
  {
    print(ApiConstants.URL + ApiConstants.MESSAGES);
    print(body.toString());

    var response = await RequestHandler.POST(ApiConstants.MESSAGES , body);
    print("POst messages-----------${response.toString()}");
    return response;
  }

  static getFloorSuite(buildingId) async
  {

    var response = await RequestHandler.GET(ApiConstants.MESSAGES + "/getFloorSuite" ,
    {
      "building" :  buildingId.toString()
    }
    );

    print("------------------------------------");
    print("find : ${response.toString()}");

    return response["data"];

  }
  
  
  static getFloorMembers(body) async
  {

    var response = await RequestHandler.POST(ApiConstants.MESSAGES + "/getFloorMembers" , body);

    return response["data"];

  }

}