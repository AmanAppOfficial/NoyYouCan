import 'package:nowyoucan/model/requestSwap.model.dart';
import 'package:nowyoucan/utils/ApiConstants.dart';
import 'package:nowyoucan/utils/requestHandler.dart';

class RequestSwapService
{
  static getSwapCount() async {
    var response = await RequestHandler.GET(ApiConstants.REQUEST_SWAP_V2 + "/count");
    return response["data"];
  }

  static acceptRequest(taskId) async
  {
    var response = await RequestHandler.PUT(ApiConstants.REQUEST_SWAP + "/" + taskId + "/" + "approve" , {});
    return response;
  }

  static getSwapList(date) async
  {
    var query = {
      "type": "Applicable Requests",
      "date": date,
    };
    var response = await RequestHandler.GET(ApiConstants.REQUEST_SWAP_V2 , query);
    List<RequestSwapList> swapList =  RequestSwapList.fromJSONList(response["data"]);
    print((response["data"]));
    return swapList;
  }

}