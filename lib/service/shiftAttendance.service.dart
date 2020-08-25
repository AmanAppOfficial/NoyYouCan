import 'package:nowyoucan/utils/ApiConstants.dart';
import 'package:nowyoucan/utils/requestHandler.dart';

class ShiftAttendanceService {
    static markAttendance(date, startTime, endTime, shiftRotationId, allocatedShiftId, workUnits , selectedBuildingId) async {
  //       date: "2020-06-01"
  // endTime: "2020-04-17T10:00:00.840Z"
  // shift: "5e98e3b079469573dfe18990"
  // startTime: "2020-04-17T09:30:00.828Z"
  // workUnits: 0.5
      var response = await RequestHandler.POST(ApiConstants.SHIFT_ATTENDANCE, {
        "date": date,
        "endTime": endTime,
        "shift": allocatedShiftId,
        "startTime": startTime,
        "workUnits": workUnits,
        "building" : selectedBuildingId
      });
       print(response);
      return response;
    }

    static getMarkedShifts(date , shiftId) async
    {
      var response = await RequestHandler.GET(ApiConstants.SHIFT_ATTENDANCE , {
        "shift" : shiftId ,
        "date" : date
      });

      print(response.toString());

      return response["data"];

    }

}