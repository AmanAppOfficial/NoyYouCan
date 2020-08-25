import 'package:nowyoucan/model/scheduledTaskConfig.dart';
import 'package:nowyoucan/model/shift.dart';
import 'package:nowyoucan/model/floor.model.dart';
import 'package:nowyoucan/model/suite.model.dart';

class ScheduledTask {
  
  String id;
  bool isQRrequired;
  String status;
  int occCount;
  ScheduledTaskConfig config;
  Shift shift;
  String name;
  TEMember member;
  String comment;
  List<String> images;
  String commentCategory;
  

  ScheduledTask(scheduledTaskObj){
    this.id = scheduledTaskObj["_id"];
    this.isQRrequired = scheduledTaskObj["isQRrequired"];
    this.status = scheduledTaskObj["status"];
    this.occCount = scheduledTaskObj["occCount"];
    this.commentCategory = scheduledTaskObj["commentCategory"];
    this.config = ScheduledTaskConfig(scheduledTaskObj["scheduledTaskConfig"]);
    if (scheduledTaskObj["occurence"] != null) {
      this.shift = Shift(scheduledTaskObj["occurence"]);
    }
    this.name = scheduledTaskObj["name"];

    if (scheduledTaskObj["TEMemberAssigned"] != null) {
      this.member = TEMember(scheduledTaskObj["TEMemberAssigned"]);
    }

    if (scheduledTaskObj["comment"] != null) {
      this.comment = scheduledTaskObj["comment"];
    }

    if (scheduledTaskObj["images"] != null) {
      this.images = [];
      for(String url in scheduledTaskObj["images"]) {
        this.images.add(url);
      } 
    }
  }

  static fromJSONList(list) {
    List<ScheduledTask> newList = []; 
    list.forEach((element) {
      newList.add(
        new ScheduledTask(element)
      );
    });
    return newList;
  }
}

class TEMember {
  String id;
  String firstName;
  String lastName;
  String email;
  TEMember(createObj) {
    this.id = createObj["_id"];
    this.firstName = createObj["user"]["firstName"];
    this.lastName = createObj["user"]["lastName"];
    this.email = createObj["user"]["email"];
  }

}

class ScheduledTaskCount {

  String floor;
  int floorNumber;
  int total;
  int completed;
  int remaining;

  ScheduledTaskCount(countObj) {
    this.floor = countObj["floorNo"].toString();
    this.floorNumber = countObj["floor"];
    this.total = countObj["val"]["total"];
    this.completed = countObj["val"]["completed"];
    this.remaining = this.total - this.completed;
  }

  static List<ScheduledTaskCount> fromJSONList(list) {
    List<ScheduledTaskCount> newList = [];
    list.forEach((element) {
      newList.add(
        new ScheduledTaskCount(element)
      );
    });
    return newList;
  }

}



/**
     "facilityPerFloor": {
          "_id": "5c78d045c32d5750b1bb7b81",
          "floor": {
              "alias": "2",
              "number": 2,
              "name": "2"
          }
      }
 */

class ScheduledTaskList {
  
  String facilityId;
  String facilityName;
  String facilityAlias;
  String type;
  FloorInfo floor;
  SuiteInfo suite;
  List<ScheduledTask> task;
  List<ScheduledTaskList> suiteList;
  String buildingId;
  String buildingName;

  ScheduledTaskList(scheduledTaskObj) {
    if (scheduledTaskObj["facilityPerFloor"] != null ) {
      this.facilityId = scheduledTaskObj["facilityPerFloor"]["_id"] ;
      this.facilityName = scheduledTaskObj["facilityPerFloor"]["name"];
      this.type = "facilityPerFloor";
      this.facilityAlias = scheduledTaskObj["facilityPerFloor"]["alias"]; 
      this.floor = new FloorInfo(scheduledTaskObj["facilityPerFloor"]["floor"]);
    } else if (scheduledTaskObj["facilityPerSuite"] != null) {
      this.facilityId = scheduledTaskObj["facilityPerSuite"]["_id"] ;
      this.facilityName = scheduledTaskObj["facilityPerSuite"]["name"];
      this.type = "facilityPerSuite";
      this.facilityAlias = scheduledTaskObj["facilityPerSuite"]["alias"];
      this.suite = new SuiteInfo(scheduledTaskObj["facilityPerSuite"]["suiteInfo"]);
    }
    if(scheduledTaskObj["suiteInfo"] != null) {
      this.suite = new SuiteInfo(scheduledTaskObj["suiteInfo"]);
      this.suiteList = ScheduledTaskList.fromJSONList(scheduledTaskObj["suiteList"]);
    }
    if (scheduledTaskObj["list"] != null) {
      this.task = ScheduledTask.fromJSONList(scheduledTaskObj["list"]);
    }

    if (scheduledTaskObj["building"] != null) {
      this.buildingId = scheduledTaskObj["building"]["_id"];
      this.buildingName = scheduledTaskObj["building"]["name"];
    }

    if(scheduledTaskObj["tasks"] != null) {
      this.task = ScheduledTask.fromJSONList(scheduledTaskObj["tasks"]);
    }

  }

  static fromJSONList(list) {
    List<ScheduledTaskList> newList = []; 
    list.forEach((element) {
      newList.add(
        new ScheduledTaskList(element)
      );
    });
    return newList;
  }
}

// class FloorInfo {
//   int floorNumber;
//   String floorAlias; 
//   String floorName;

//   FloorInfo(createObj) {
//     this.floorNumber = createObj["number"];
//     this.floorAlias = createObj["alias"];
//     this.floorName = createObj["name"];
//   }
// }

// class SuiteInfo {

//   int floorNumber;
//   String floorAlias; 
//   String floorName;
//   String suiteNo;

//   SuiteInfo(createObj) {
//     this.floorNumber = createObj["floorNumber"];
//     this.floorAlias = createObj["floorNo"]; 
//     this.floorName = createObj["name"];
//     this.suiteNo = createObj["suiteNo"];
//   }
// }
