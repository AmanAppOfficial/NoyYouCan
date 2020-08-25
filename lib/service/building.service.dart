import 'package:nowyoucan/utils/ApiConstants.dart';
import 'package:nowyoucan/utils/requestHandler.dart';

class BuildingService {

    static me() async {
      var response = await RequestHandler.GET(ApiConstants.BUILDING, {
        "deleted": false
      });
      print(response);
      return response;
    }

    static getBuilding() async
    {
      var res = await RequestHandler.GET(ApiConstants.BUILDING);
      print(res);
      return res["data"];
    }

}