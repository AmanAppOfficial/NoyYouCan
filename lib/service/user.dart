import 'package:nowyoucan/service/auth.dart';
import 'package:nowyoucan/utils/ApiConstants.dart';
import 'package:nowyoucan/utils/requestHandler.dart';

class User {

  static updateProfile(body) async
  {
    var response = await RequestHandler.PUT(ApiConstants.USERS, body);
    print("update res------${response.toString()}");
    return response;
  }

    static me() async {
      var response = await RequestHandler.GET(ApiConstants.USERS + "/me");
      // print(response);
      return response["data"];
    }

    static getTadeExpertCategories() async
    {
      var response = await RequestHandler.GET(ApiConstants.TRADE_EXPERT_CATEGORIES , {
        "deleted" : false,
        "searchFields" : "name"
      });

      return response["data"]["docs"];

    }

    static getFacilityItem() async
    {
      var response = await RequestHandler.GET(ApiConstants.FACILITY_ITEM , {
        "deleted" : false,
        "searchFields" : "name"
      });

      return response["data"];
    }


    static changePassword(oldpass , newpass) async
    {
      var response = await RequestHandler.PUT(ApiConstants.USERS + "/password",
        {"newPassword": newpass,
          "oldPassword": oldpass}
      );

      if(response!=null)
        return response["data"];
      return null;


    }

}