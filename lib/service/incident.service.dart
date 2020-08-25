// import 'dart:convert';

// import 'package:nowyoucan/model/incident_details.model.dart';
// import 'package:nowyoucan/model/incident_details.model.dart';
import 'package:nowyoucan/model/incidentComment.model.dart';
import 'package:nowyoucan/utils/ApiConstants.dart';
import 'package:nowyoucan/utils/requestHandler.dart';
import 'package:nowyoucan/model/incident.model.dart';

class IncidentService {
    static list(type) async {
      var response = await RequestHandler.GET(ApiConstants.INCIDENT, {
        "deleted": true,
        "limit": 50,
        "offset": 0,
        "status": type
        // "status": "inProgress" // Resolved
      });
      List<IncidentList> incidentList = IncidentList.fromJSONList(response["data"]["docs"]);
      // incidentList.forEach((element) { 
      //   print(element.status);
      // });
      return incidentList;
    }

    static getDetails(String id) async {
      var response = await RequestHandler.GET(ApiConstants.INCIDENT + "/" + id);
      IncidentList incident = new IncidentList(response["data"]);
      return incident;
    }

    static updateIncident(incidentId, memberId) async {
      var response = await RequestHandler.PUT(ApiConstants.INCIDENT + "/" + incidentId, {
        "status": "Trade Expert Assigned",
        "tradeExpert": memberId
      });
      return response;
    }

    static markResolved(String incidentId) async {
      var response = await RequestHandler.PUT(ApiConstants.INCIDENT + "/" + incidentId, {
        "status": "Resolved"
      });
      return response;
    }

    static progressGraph() async {
      var response = await RequestHandler.GET(ApiConstants.INCIDENT_GRAPH_V2);
      print(response["data"]);
      return response["data"];
    }

    static incidentComments(incidentId) async
    {
      var response = await RequestHandler.GET(ApiConstants.INCIDENT_COMMENT_V2 , {
        "incident" : incidentId,
        "type" : "Newest"
      });

      print(response.toString());


      List<IncidentComment> commentList =  IncidentComment.fromJSONList(response["data"]);

      return commentList;

    }

    static createIncidentComment(body) async
    {
      var response = await RequestHandler.POST(ApiConstants.INCIDENT_COMMENT_V1 , body);

      return response;

    }

}