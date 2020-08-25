// import 'package:nowyoucan/service/shiftRotation.dart';
import 'package:nowyoucan/model/shift.dart';
import 'package:nowyoucan/utils/ApiConstants.dart';
import 'package:nowyoucan/utils/requestHandler.dart';
import 'package:nowyoucan/model/shiftAllocation.model.dart';

class ShiftAllocationService {
    static memberShifts(
      shiftRotationId,
      date
    ) async {
       print("aaa" + shiftRotationId.toString());
       print("aaa" + date.toString());
      var response = await RequestHandler.GET(ApiConstants.SHIFT_ALLOCATION + "/member-shifts", {
        "shiftRotation": shiftRotationId.toString(),
        "date": date.toString() 
      });
      List<ShiftAllocation> shiftAllocation = ShiftAllocation.fromJSONList(response["data"]);
       print("------------" + response.toString());
      return shiftAllocation;
    }
    
    
    static markUnavailable(body) async
    {
      var response = await RequestHandler.POST(ApiConstants.MARK_UNAVAILABLE , body);
      return response;
    }

    static getShifts() async
    {
      var response = await RequestHandler.GET(ApiConstants.SHIFTS);
      List<Shift> shiftList = Shift.fromJSONList(response["data"]);
      print(shiftList[0]);
      return shiftList;

    }

    static requestSwap(body) async
    {
      var response = await RequestHandler.POST(ApiConstants.REQUEST_SWAP , body);
      return response;
    }
    
}