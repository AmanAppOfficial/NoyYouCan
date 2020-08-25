import 'package:nowyoucan/model/shift.dart';

class ShiftAllocation {

  Shift shift;
  List<String> tasks;
  String startTime;
  String endTime;
  double allocated;
  List<Building> buildings;
  List<Building> buildingsTimeStamp;


  ShiftAllocation(createObj) {

    this.shift = new Shift(createObj["shift"]);
    this.startTime = createObj["startTime"];
    this.endTime = createObj["endTime"];
    this.allocated = createObj["allocated"].toDouble();
    this.buildingsTimeStamp = Building.fromJSONList(createObj["buildingsTimeStamp"]);
    List<String> _tasks = [];
    for (String item in createObj["tasks"]) {
      _tasks.add(item);
    }

    this.tasks = _tasks;

    List<Building> _building = [];

    for (var itemObj in createObj["buildings"]) {
      _building.add(Building(itemObj));
    }

    this.buildings = _building;
  }

  static fromJSONList(list) {
    List<ShiftAllocation> newList = [];
    for(var item in list) {
      newList.add(ShiftAllocation(item));
    }
    return newList;
  }

}

class Building {
  String id;
  String name;
  String startTime;
  String endTime;

  Building(createObj) {
    this.id = createObj["_id"];
    this.name = createObj["name"];
    this.startTime = createObj["startTime"];
    this.endTime = createObj["endTime"];
  }

  static fromJSONList(list) {
    List<Building> newList = [];
    for(var item in list) {
      newList.add(Building(item));
    }
    return newList;
  }
}


/*

    {
      "_id": {
        "shift": "5e98e3b079469573dfe18990"
      },
      "tasks": [
        "5ed5d3a07359a884b553427b"
      ],
      "startTime": "2020-04-17T04:30:00.828Z",
      "endTime": "2020-04-17T10:00:00.840Z",
      "allocated": 1,
      "shift": {
        "_id": "5e98e3b079469573dfe18990",
        "name": "A"
      },
      "buildings": [
        {
          "_id": "5c63cb0aa5f5b405a730e830",
          "name": "cyber"
        }
      ]
    }

*/