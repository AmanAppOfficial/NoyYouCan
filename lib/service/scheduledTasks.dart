import 'package:nowyoucan/utils/ApiConstants.dart';
import 'package:nowyoucan/utils/requestHandler.dart';
import 'package:nowyoucan/model/scheduledTask.dart';
class ScheduledTaskService {
    static getBuildings() async {
      // print("-------------------------------------------");
      var response = await RequestHandler.GET(ApiConstants.SCHEDULED_TASK + "/buildings");
      return response["data"];
    }

    static get() async {
      // print("-------------------------------------------");
      var response = await RequestHandler.GET(ApiConstants.SCHEDULED_TASK + "/5eafa43eec9756f32efdaeaf");
      print(response["data"][0]);
      ScheduledTask task = new ScheduledTask(response["data"][0]);
    }



    static getScheduledTaskCount(shiftRotationId, buildingId, date) async {
      var query = {
        "shiftRotation": shiftRotationId,
        "building": buildingId,
        "date": date,
        "type": "Count"
      };
      // print("query---$query");
      var response = await RequestHandler.GET(ApiConstants.SCHEDULED_TASK_V2, query);
      List<ScheduledTaskCount> scheduledTaskCount = ScheduledTaskCount.fromJSONList((response["data"]));  
      // print(scheduledTaskCount);
      return scheduledTaskCount;
    }

    static getScheduledTaskList(shiftRotationId, buildingId, date, floorNumber) async {
      var query = {
        "shiftRotation": shiftRotationId,
        "building": buildingId,
        "date": date,
        "type": "List",
        "floorNo": floorNumber
      };
      var response = await RequestHandler.GET(ApiConstants.SCHEDULED_TASK_V3, query);
      // print("--------------------------------" + response["data"].toString());
      List<ScheduledTaskList> scheduledTaskList = ScheduledTaskList.fromJSONList((response["data"]));  
      // print("-------------" + scheduledTaskList[0].suiteList[0].facilityName);
      return scheduledTaskList;
    }    

    static completeTask(id, body) async {
      var response = await RequestHandler.POST(ApiConstants.SCHEDULED_TASK + "/$id/complete", body);
      // print("------------");
      // print(response);
      return response;
    }

    static getTaskCount(date) async {
      print(date);
      var response = await RequestHandler.GET(ApiConstants.SCHEDULED_TASK_V2 + "/count", {
        "date": date 
      });
      // print("------------");
      // print(response);
      return response["data"];
    }

    static getMissedTaskCount() async {
      var response = await RequestHandler.GET(ApiConstants.SCHEDULED_TASK_V2 + "/missingTaskCount", {
        "type": "Count"
      });
      // print("------------");
      // print(response);
      return response["data"];
    }

    static getMissedTaskList(date) async {
      var response = await RequestHandler.GET(ApiConstants.SCHEDULED_TASK_V2 + "/missingTaskCount", {
        "type": "List",
        "date": date
      });
      List<ScheduledTaskList> scheduledTaskList = response["data"] != null ? ScheduledTaskList.fromJSONList(response["data"]) : [];
      if(scheduledTaskList.length >0 ){
        // print(scheduledTaskList[0].buildingName);
        // print(scheduledTaskList[0].task[0].member.email);
      }
      return scheduledTaskList;
    }

    static getRecentTaskCount() async {
      var response = await RequestHandler.GET(ApiConstants.SCHEDULED_TASK_V2 + "/recentCommentCount", {
        "type": "Count"
      });
      // print("------------");
      // print(response);
      return response["data"];
    }

    static getRecentCommentsDates() async
    {
      var response = await RequestHandler.GET(ApiConstants.SCHEDULED_TASK_V2 + "/recentCommentCount", {
        "type" : "Dates"
      });

      return response["data"];

    }

    static getRecentTaskList(date) async {
      var response = await RequestHandler.GET(ApiConstants.SCHEDULED_TASK_V2 + "/recentCommentCount", {
        "type": "List",
        "date": date
      });


      List<ScheduledTaskList> scheduledTaskList = response["data"] != null ? ScheduledTaskList.fromJSONList(response["data"]) : [];
      // print(scheduledTaskList[0].task[1].images);
      // print("------------");
      // print(response);
      return scheduledTaskList;
    }

    static getScheduledTask(id) async {
      var response = await RequestHandler.GET(ApiConstants.SCHEDULED_TASK + "/$id");
      // print("------------");
      // print(response["data"][0]);

      return response["data"][0];
    }

}