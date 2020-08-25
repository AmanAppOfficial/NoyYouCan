import 'package:nowyoucan/model/floor.model.dart';
import 'package:nowyoucan/model/suite.model.dart';

class ScheduledTaskConfig {
  String id;
  String name;
  String desc;
  FloorInfo floor;
  SuiteInfo suite;

  ScheduledTaskConfig(createObj) {
    this.id = createObj["_id"];
    this.name = createObj["name"];
    this.desc = createObj["description"];
    if(createObj["facilityPerFloor"] != null) {
      this.floor = new FloorInfo(createObj["facilityPerFloor"]["floor"]);
    }
    if(createObj["facilityPerSuite"] != null) {
      this.suite = new SuiteInfo(createObj["facilityPerSuite"]["suiteInfo"]);
    }
  }

  static fromJSONList(list) {
    List<ScheduledTaskConfig> newShiftList = [];
    list.forEach((element) {
      newShiftList.add(new ScheduledTaskConfig(element));
    });
    return newShiftList;
  }
}

/**
     "_id": "5eafa43eec97560351fdaea7",
    "isQRrequired": true,
    "status": "Pending",
    "occCount": 1,
    "scheduledTaskConfig": {
        "_id": "5ea9747e1c97c8d3ec506d3f",
        "isQRrequired": true,
        "name": "female toilet_test_dev"
    },
    "date": "2020-06-01T00:00:00.000Z",
    "occurence": {
        "name": "Mo",
        "startTime": "2020-04-16T21:00:00.916Z",
        "endTime": "2020-04-17T04:00:00.929Z"
    }
 */