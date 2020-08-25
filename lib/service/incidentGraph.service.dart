import 'package:nowyoucan/utils/ApiConstants.dart';
import 'package:nowyoucan/utils/requestHandler.dart';
import 'package:nowyoucan/model/incident.model.dart';
class IncidentGraphService {
    static count() async {
      var response = await RequestHandler.GET(ApiConstants.INCIDENT_GRAPH + "/incidentCount", {
        "deleted": false
      });
      IncidentCount count = response["data"].length > 0 ? new IncidentCount( response["data"][0] ) : null ;
      print(response);
      return count;
    }
}