import 'package:nowyoucan/utils/ApiConstants.dart';
import 'package:nowyoucan/utils/requestHandler.dart';
import 'package:nowyoucan/model/shiftRotation.dart';
class ShiftRotationService {
    static get() async {
      var response = await RequestHandler.GET(ApiConstants.SHIFT_ROTATION);
      List<ShiftRotation> shiftRotationList = ShiftRotation.fromJSONList(response["data"]);
      List<ShiftRotation> reversedList = new List.from(shiftRotationList.reversed);
      return reversedList;
    }
}