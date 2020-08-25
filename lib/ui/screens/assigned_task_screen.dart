/**
 * @descrption Assigned task screen
 * @author Aman Srivastava
 */

import 'package:configurable_expansion_tile/configurable_expansion_tile.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nowyoucan/service/shiftRotation.dart';
import 'package:nowyoucan/service/user.dart';
import 'package:nowyoucan/ui/popUps/assignedSheduled.dart';
import 'package:nowyoucan/ui/widgets/app_bar.dart';
import 'package:nowyoucan/ui/widgets/navigation_drawer_elements.dart';
import 'package:nowyoucan/ui/widgets/loader.dart';
import 'package:nowyoucan/service/scheduledTasks.dart';
import 'package:nowyoucan/model/shiftRotation.dart';
import 'package:nowyoucan/model/scheduledTask.dart';
import 'package:nowyoucan/service/commentCategory.dart';
import 'package:nowyoucan/model/commentCategory.model.dart';

class AssignedScheduledTask extends StatefulWidget {
  String userRole;
  var mainCtx;
  var currentUser;

  AssignedScheduledTask(this.userRole, this.mainCtx, this.currentUser);

  @override
  _AssignedScheduledTaskState createState() => _AssignedScheduledTaskState();
}

class _AssignedScheduledTaskState extends State<AssignedScheduledTask> {
  bool isLoading = true;
  bool isListLoading = true;
  var currentUser;
  List<dynamic> buildingList = [];
  var selectedBuilding;
  var cardLoad = {};
  bool isSwitched = false;

  int selectedIndex = 1;

  List<ShiftRotation> shiftRotationList;

  List<ScheduledTaskCount> scheduledTaskCountList = [];
  List<ScheduledTaskList> scheduledTaskList = [];
  List<CommentCategory> commentCategoryList = [];
  DateTime todaysDate = new DateTime.now();
  var dateChangeCount = 0;
  DateTime displayedDate;

  ShiftRotation selectedShiftRotation;

  @override
  void initState() => {
        (() async {
          widget.currentUser = await User.me();
          await getShiftRotation();
          setState(() {
          });
        })()
      };

  selectBuilding(building, index) {
    // print("clicked ${index + 1}");
    selectedBuilding = building;
    selectedIndex = index + 1;
    getScheduledTaskCountList();
    setState(() {});
  }

  getBuildingList() async {
    try {
      buildingList = await ScheduledTaskService.getBuildings();
      if (buildingList.length > 0) {
        selectedBuilding = buildingList[0];
        selectBuilding(buildingList[0], 0);
      }
      isLoading = false;
      setState(() {});
    } catch (error) {
      print("@getBuildingList Error " + error.toString());
    }
  }

  getShiftRotation() async {
    try {
      shiftRotationList = await ShiftRotationService.get();
      if(shiftRotationList.length > 0)
      {
        selectPeriod(shiftRotationList[0]);

        // print(selectedShiftRotation.startDate);
        // To set the date to start date of the shift rotation
        dateChangeCount = 0;
      }
      else
      {
        isLoading = false;
        isListLoading = false;
      }
//      print(shiftRotationList);

    } catch (error) {
      print("@getShiftRotation Error " + error.toString());
    }
  }

  selectPeriod(period) async {
    selectedShiftRotation = period;
    // print(selectedShiftRotation.startDate);
    // To set the date to start date of the shift rotation
    if (todaysDate.isBefore(
                DateTime.parse(selectedShiftRotation.endDate.toString())) &&
            todaysDate.isAfter(
                DateTime.parse(selectedShiftRotation.startDate.toString())) ||
        todaysDate
                .difference(
                    DateTime.parse(selectedShiftRotation.startDate.toString()))
                .inDays ==
            0 ||
        todaysDate
                .difference(
                    DateTime.parse(selectedShiftRotation.endDate.toString()))
                .inDays ==
            0) {
      todaysDate = todaysDate;
    } else {
      todaysDate =
          DateTime.parse(selectedShiftRotation.startDate.toString()).toLocal();
    }

    dateChangeCount = 0;
    startLoader();
    await getBuildingList();
  }

  getScheduledTaskCountList() async {
    try {
      startLoader();
      DateTime date1 = new DateTime(todaysDate.year, todaysDate.month, todaysDate.day + dateChangeCount);
      var formatter = new DateFormat('yyyy-MM-dd');
      String formattedDate = formatter.format(date1);
      scheduledTaskCountList = await ScheduledTaskService.getScheduledTaskCount(
          selectedShiftRotation.id, selectedBuilding["_id"], formattedDate);
      closeLoader();
      int i = 0;
      scheduledTaskCountList.forEach((element) {
        cardLoad[i] = {"isLoading": false, "data": scheduledTaskList};
        i++;
      });
    } catch (error) {
      print("@getScheduledTaskCountList" + error.toString());
    }
  }

  getScheduledTaskList(floorNumber, index) async {
    try {
      DateTime displayedDate = new DateTime(todaysDate.year, todaysDate.month, todaysDate.day + dateChangeCount);
      var formatter = new DateFormat('yyyy-MM-dd');
      String formattedDate = formatter.format(displayedDate);
      cardLoad[index]["isLoading"] = true;
      setState(() {});
      cardLoad[index]["data"] = await ScheduledTaskService.getScheduledTaskList(
          selectedShiftRotation.id,
          selectedBuilding["_id"],
          formattedDate,
          floorNumber);
      cardLoad[index]["isLoading"] = false;
      setState(() {});
    } catch (error) {
      print("@getScheduledTaskList" + error.toString());
    }
  }

  getCommentCategory() async {
    try {
      commentCategoryList = await CommentCategoryService.get();
    } catch (error) {
      print("@ErrorgetCommentCategory" + error.toString());
    }
  }

//  completetask() async {
//    try {
//      ScheduledTaskService.completeTask("5eafa43eec975640adfdaeac",
//          {"comment": "test", "commentCategory": "5e74b1cf3c1b4c09f1b2adac"});
//    } catch (error) {}
//  }

  startLoader() {
    isListLoading = true;
    setState(() {});
  }

  closeLoader() {
    isListLoading = false;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
     displayedDate = new DateTime(todaysDate.year, todaysDate.month, todaysDate.day + dateChangeCount);
    var formatter = new DateFormat('MMM d, yyyy');
    String formattedDate = formatter.format(displayedDate);


    var diff;
    Future _selectDate(BuildContext context) async
    {
      final DateTime picked = await showDatePicker(
          context: context,
//          initialDate: (displayedDate!=null) ? displayedDate : DateTime.now(),
          initialDate: DateTime.parse(selectedShiftRotation.startDate.toString()).toLocal(),
          firstDate: DateTime.parse(selectedShiftRotation.startDate.toString()).toLocal(),
          lastDate: DateTime.parse(selectedShiftRotation.endDate.toString()).toLocal());

      if (picked != null && picked != displayedDate)
      {
        diff = picked.difference(displayedDate).inDays;
        dateChangeCount= dateChangeCount + diff;
      }
      getScheduledTaskCountList();
      setState(() {
      });
    }

// View Functions
    periodBtn(period, title) {
      var opacity = 0.2, txtColor = Colors.white;
      if (selectedShiftRotation != null &&
          selectedShiftRotation.id == period.id) {
        opacity = 1;
        txtColor = Color(0xffec828c);
      } else {
        opacity = 0.2;
        txtColor = Colors.white;
      }

      return InkWell(
        onTap: () {
          todaysDate = DateTime.now();
          selectPeriod(period);
          // selectedShiftRotation = period;
//          todaysDate = DateTime.parse(selectedShiftRotation.startDate.toString()).toLocal();
//          dateChangeCount = 0;


          setState(() {});
        },
        child: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            Opacity(
              opacity: opacity,
              child: Container(
                margin: EdgeInsets.only(left: 10.0, right: 10.0),
                height: 50,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10.0)),
              ),
            ),
            Text(title, style: TextStyle(color: txtColor, fontSize: 16.5))
          ],
        ),
      );
    }

    periodRow() {
      int i = 1;
      List<Widget> rowList = [];
      shiftRotationList.forEach((shiftRotation) {
        rowList.add(Expanded(
            child: periodBtn(shiftRotation, formatter.format(DateTime.parse(shiftRotation.startDate).toLocal()))));
        i++;
      });

      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: rowList,
      );
    }

    header() {
      return Stack(
        alignment: Alignment.topCenter,
        children: <Widget>[
          Container(
              width: MediaQuery.of(context).size.width,
              // height: MediaQuery.of(context).size.height * (1/5),
              height: 200,
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                      begin: Alignment(0.0, 1.3),
                      end: Alignment(0.9, 0.7),
                      colors: [
                    const Color(0xffec828c),
                    const Color(0xfff6a04f)
                  ]))),
          Container(
              margin: EdgeInsets.only(top: 30.0),
              width: MediaQuery.of(context).size.width,
              child: Column(
                children: <Widget>[
                  Text("Schedule Tasks",
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w400,
                          fontFamily: "Gotham",
                          fontStyle: FontStyle.normal,
                          fontSize: 30.0),
                      textAlign: TextAlign.center),
                  SizedBox(height: 30),
                  (shiftRotationList.length > 0) ? periodRow() :
                  Container(
                    padding: EdgeInsets.all(13),
                    child: Text("No Shifts Allocated" ,
                      style: TextStyle(
                          fontWeight: FontWeight.bold ,fontSize: 16 ,
                          color:  Color(0xffec828c)),) ,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10)
                    ),),
                ],
              ))
        ],
      );
    }

    onDateChange(val) {
      dateChangeCount += val;
      getScheduledTaskCountList();
    }

    dateRow() {
      boxStyle(check) {
        return BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(15)),
          boxShadow: [
            BoxShadow(
              color: Colors.grey[300],
              blurRadius: 15,
            )
          ],
          color: (check) ? Colors.white : Colors.grey[300],
        );
      }
      // var boxStyle =

      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            child: InkWell(
              onTap: () {
                if (!displayedDate.isBefore(DateTime.parse(
                    selectedShiftRotation.startDate.toString()))) {
                  onDateChange(-1);
                }
              },
              child: Container(
                width: MediaQuery.of(context).size.width * (1 / 5),
                height: 50,
                decoration: boxStyle(!displayedDate.isBefore(DateTime.parse(
                    selectedShiftRotation.startDate.toString()))),
                child: Icon(Icons.chevron_left),
              ),
            ),
          ),
          SizedBox(width: 20.0),
          GestureDetector(
            onTap: (){_selectDate(context);},
            child: Container(
                width: MediaQuery.of(context).size.width * (1 / 2.5),
                height: 50,
                decoration: boxStyle(true),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Icon(Icons.calendar_today,
                        color: const Color(0xfff6a04f), size: 17),
                    SizedBox(width: 10),
                    Text(formattedDate)
                  ],
                )),
          ),
          SizedBox(width: 20.0),
          Container(
            child: InkWell(
              onTap: () {
                if (displayedDate
                        .difference(DateTime.parse(
                            selectedShiftRotation.endDate.toString()))
                        .inDays <
                    0) {
                  onDateChange(1);
                }
              },
              child: Container(
                width: MediaQuery.of(context).size.width * (1 / 5),
                height: 50,
                decoration: boxStyle(displayedDate
                        .difference(DateTime.parse(
                            selectedShiftRotation.endDate.toString()))
                        .inDays <
                    0),
                child: Icon(Icons.chevron_right),
              ),
            ),
          )
        ],
      );
    }

    buildingLists() {
      return Container(
        margin: const EdgeInsets.only(top: 175, left: 0, right: 0),
        child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: buildingList.length,
            itemBuilder: (BuildContext ctx, int index) {
              return GestureDetector(
                onTap: () {
                  selectBuilding(buildingList[index], index);
                },
                child: Card(
                  elevation: 6,
                  shadowColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.25)),
                  child: Center(
                    child: Container(
                      height: (selectedIndex == (index + 1)) ? 70 : 30,
                      width: MediaQuery.of(context).size.width * (1 / 3.1),
                      child: Center(
                        child: Text(
                          buildingList[index]["name"],
                          style: TextStyle(
                              fontSize:
                                  (selectedIndex == (index + 1)) ? 22 : 17,
                              color: (selectedIndex == (index + 1))
                                  ? const Color(0xfff6a04f)
                                  : const Color(0xffb3b3b3),
                              fontWeight: (selectedIndex == (index + 1))
                                  ? FontWeight.bold
                                  : null),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),
        height: 50.0,
      );
    }

    taskCard(ScheduledTask task, mainCardIndex) {
      var cardBoxStyle = BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(10)),
          border: Border.all(color: const Color(0xffffffff), width: 0.4),
          boxShadow: [
            BoxShadow(
                color: const Color(0x52b7b8ba),
                offset: Offset(0, 0),
                blurRadius: 8,
                spreadRadius: 0)
          ],
          color: const Color(0xfff9f9f9));

      var textStyle = const TextStyle(
        color: const Color(0xff343233),
        fontWeight: FontWeight.w400,
        fontFamily: "Gotham",
        fontStyle: FontStyle.normal,
        fontSize: 14.5,
      );

      timeFormat(timeString) {
        DateTime shiftStartTime = DateTime.parse(timeString).toLocal();
        var formatter = new DateFormat('HH:mm');
        return formatter.format(shiftStartTime);
      }

      return Container(
        margin: EdgeInsets.only(top: 10),
//        height: 180,
        child: Container(
          margin:
              const EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 10),
          width: MediaQuery.of(context).size.width,
          decoration: cardBoxStyle,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                margin: EdgeInsets.all(12),
                child: Text(task.config.name,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: textStyle,
                    textAlign: TextAlign.left),
              ),
              SizedBox(
                height: 15,
              ),
              Row(
                children: <Widget>[
                  Expanded(
                    child: Container(
                      margin: EdgeInsets.only(left: 12),
                      child: Column(
                        children: <Widget>[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Icon(
                                Icons.calendar_today,
                                color: Colors.orangeAccent,
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Text(timeFormat(task.shift.startTime),
                                  style: textStyle,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.center)
                            ],
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Icon(
                                Icons.wb_sunny,
                                color: Colors.orangeAccent,
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Container(
                                width: 40,
                                child: Text(task.shift.name,
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                    style: textStyle,
                                    textAlign: TextAlign.center),
                              )
                            ],
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Icon(
                                Icons.hourglass_empty,
                                color: Colors.orangeAccent,
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Container(
                                width: 40,
                                child: Text(task.occCount.toString(),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                    style: textStyle,
                                    textAlign: TextAlign.center),
                              ),

                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {

                        if ((displayedDate.difference(DateTime.now())).inDays == 0) {
                          print("taskCard");
                          showSchedulePopup(
                              task, formattedDate, selectedShiftRotation, mainCardIndex);
                        }


                      },
                      child: Container(
                          alignment: Alignment.center,
                          margin: const EdgeInsets.only(left: 12, right: 12),
                          height: 48,
                          child: Text(
                              (task.status == "Pending")
                                  ? "Take Action"
                                  : "Completed",
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w300,
                                  fontFamily: "Gotham",
                                  fontStyle: FontStyle.normal,
                                  fontSize: 16.0),
                              textAlign: TextAlign.center),
                          decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(20)),
                              color:
                                  (displayedDate.difference(DateTime.now())).inDays == 0
                                      ? (task.status == "Pending")
                                          ? Color(0xfff6a050)
                                          : Color(0xff90c217)
                                      : Colors.grey)),
                    ),
                  )
                ],
              ),
              SizedBox(
                height: 10,
              ),
              (task.status == "Pending")? Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.all(10),
                    child: Text("Mark Complete",
                        style: TextStyle(fontSize: 20),
                        textAlign: TextAlign.center),
                  ),
                  Switch(
                    value: isSwitched,
                    onChanged: (value) async {
                      setState(() {
                        isSwitched = false;
                      });
                      getScheduledTaskList(scheduledTaskCountList[mainCardIndex].floorNumber ,mainCardIndex);
                      var result = await ScheduledTaskService.completeTask(task.id , {});
                      scheduledTaskCountList[mainCardIndex].completed = scheduledTaskCountList[mainCardIndex].completed + 1;
                      scheduledTaskCountList[mainCardIndex].remaining = scheduledTaskCountList[mainCardIndex].remaining - 1;
                      setState(() {

                      });
















                       },
                    activeTrackColor: Colors.orange,
                    activeColor: Colors.red,
                  ),
                ],
              ) : Container(),
            ],
          ),
        ),
      );
    }

    taskListRecord(mainCardIndex) {
      // var  = index;
      // print("---------- main card index" + index.toString());
      List<ScheduledTaskList> taskList = cardLoad[mainCardIndex]["data"];
      return Container(
          color: Colors.white,
          // height: 300,
          child: ListView.builder(
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              physics: ClampingScrollPhysics(),
              itemCount: taskList.length,
              itemBuilder: (BuildContext ctx, int index) {
                return (taskList[index].suite == null)
                    ? Column(
                        children: <Widget>[
                          Container(
                              child: Center(
                                child: Text(taskList[index].facilityAlias,
                                    style: TextStyle(fontSize: 25)),
                              ),
                              margin: EdgeInsets.only(
                                  top: 10, bottom: 10, left: 10, right: 10),
                              height: 40,
                              width: MediaQuery.of(context).size.width,
                              decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(15)),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey[300],
                                    blurRadius: 3,
                                  )
                                ],
                                color: Colors.grey[300],
                              )),
                          ListView.builder(
                              scrollDirection: Axis.vertical,
                              shrinkWrap: true,
                              physics: ClampingScrollPhysics(),
                              itemCount: taskList[index].task.length,
                              itemBuilder: (BuildContext ctx, int index1) {
                                return taskCard(taskList[index].task[index1], mainCardIndex);
                              })
                        ],
                      )
                    : Container(
                        margin: EdgeInsets.all(10),
                        child: buildInnerExpansionTile(
                            taskList[index], displayedDate, formattedDate, index),
                      );
              }));
    }

    shiftCards() {
      return (scheduledTaskCountList.length == 0)
          ? Container(
              child: Text("No Record!"),
            )
          : ListView.builder(
              shrinkWrap: true,
              physics: ClampingScrollPhysics(),
              itemCount: scheduledTaskCountList.length,
              itemBuilder: (BuildContext ctx, int index) {
                return Container(
                  margin: EdgeInsets.only(bottom: 20, left: 18, right: 18),
                  child: Card(
                    elevation: 4.0,
                    shadowColor: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 10.0, bottom: 10.0),
                      child: ListTileTheme(
                          contentPadding: EdgeInsets.all(0),
                          dense: true,
                          child: ConfigurableExpansionTile(
                            borderColorStart: Colors.white,
                            borderColorEnd: Colors.white,
                            onExpansionChanged: ((newState) {
                              if (newState) {
                                onCardClick(
                                    scheduledTaskCountList[index].floorNumber,
                                    index);
                              }
                            }),
                            header: countHeader(index),
                            children: [
                              (cardLoad[index]["isLoading"])
                                  ? Loader.getListLoader(context)
                                  : taskListRecord(index)
                            ],
                          )),
                    ),
                  ),
                );
              });
    }

    return Scaffold(
        backgroundColor: Colors.white,
        resizeToAvoidBottomPadding: true,
        appBar: BaseAppBar.getAppBar("Assigned \nScheduled Tasks"),
        endDrawer: Drawer(
          child: DrawerElements.getDrawer(
              'assigned task', context, widget.userRole, widget.mainCtx , widget.currentUser),
        ),
        body: (isLoading)
            ? Loader.getLoader()
            : SafeArea(
                child: ListView(
                  children: <Widget>[
                    Stack(
                      children: <Widget>[
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            header(),
                            SizedBox(height: 50.0),
                            (shiftRotationList.length > 0) ? dateRow() : Container(),
                            SizedBox(height: 30.0),
                            (isListLoading)
                                ? Loader.getListLoader(context)
                                : shiftCards()
                          ],
                        ),
                        buildingLists(),
                      ],
                    ),
                  ],
                ),
              ));
  }

  onCardClick(int floorNumber, index) {
    getScheduledTaskList(floorNumber, index);
//    headerList = assignedTaskDataList;
//    assignedCardData = headerList[0].data;
//    // cardLoad[s] = {"isLoading": true, "data": []};
    cardLoad[index]["isLoading"] = true;
  }

  countHeader(int index) {
    return Flexible(
      child: Align(
        alignment: Alignment(-1.0, 0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Container(
                alignment: Alignment.center,
                child: Text(
                  "Floor " + scheduledTaskCountList[index].floor,
                  style: const TextStyle(
                      color: const Color(0xffffffff),
                      fontWeight: FontWeight.w400,
                      fontFamily: "Gotham",
                      fontStyle: FontStyle.normal,
                      fontSize: 12.5),
                ),
                width: 120,
                height: 51,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                        topRight: Radius.circular(25),
                        bottomRight: Radius.circular(25)),
                    gradient: LinearGradient(
                        begin: Alignment(0, 1.9),
                        end: Alignment(0.6, 0.2),
                        colors: [
                          const Color(0xffec828c),
                          const Color(0xfff6a04f)
                        ]))),
            Expanded(
                child: Container(
              margin: const EdgeInsets.all(13),
                  child: Column(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.all(0.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            Expanded(
                                child: Text("Total Tasks",
                                style: const TextStyle(
                                    color: const Color(0xffc6c5c6),
                                    fontWeight: FontWeight.w400,
                                    fontFamily: "Gotham",
                                    fontStyle: FontStyle.normal,
                                    fontSize: 9.5),
                                textAlign: TextAlign.center)),
                            Expanded(
                                child: Text("Remaining",
                                style: const TextStyle(
                                    color: const Color(0xfff49d13),
                                    fontWeight: FontWeight.w400,
                                    fontFamily: "Gotham",
                                    fontStyle: FontStyle.normal,
                                    fontSize: 11.5),
                                textAlign: TextAlign.center)),
                            Expanded(
                                child: Text("Completed",
                                style: const TextStyle(
                                    color: const Color(0xff90c217),
                                    fontWeight: FontWeight.w400,
                                    fontFamily: "Gotham",
                                    fontStyle: FontStyle.normal,
                                    fontSize: 9.5),
                                textAlign: TextAlign.center)),
                      ],
                    ),
                  ),
                      SizedBox(
                        height: 3,
                  ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          countCard(scheduledTaskCountList[index].total.toString() , const Color(0xffa2a2a2)),
                          countCard(scheduledTaskCountList[index].remaining.toString(), const Color(0xfff47f20)),
                          countCard( scheduledTaskCountList[index].completed.toString(), const Color(0xff90c217)),
                    ],
                  ),
                ],
              ),
            )),
            Image.asset(
              'images/bottomicon.webp',
              scale: 4,
            ),
          ],
        ),
      ),
    );
  }

  void showSchedulePopup(
    ScheduledTask task, 
    String date,
    ShiftRotation selectedShiftRotation, 
    int mainCardIndex) async {
    
    // print("--- ------------ accordion" + scheduledTaskCountList[mainCardIndex].floorNumber.toString()  + " =>  "+ mainCardIndex.toString());
    var res = await showDialog(
        context: context,
        builder: (BuildContext context) {
          return ScheduledTaskPopup(task, date, selectedShiftRotation);
        });
    print(res);
    if (res == "Completed") {
      scheduledTaskCountList[mainCardIndex].completed = scheduledTaskCountList[mainCardIndex].completed + 1; 
      scheduledTaskCountList[mainCardIndex].remaining = scheduledTaskCountList[mainCardIndex].remaining - 1;
      setState(() {

      });
      print(scheduledTaskCountList[mainCardIndex].toString());
    }
        //viki

    // getScheduledTaskCountList();
    getScheduledTaskList(scheduledTaskCountList[mainCardIndex].floorNumber ,mainCardIndex);
  }

  buildInnerExpansionTile(ScheduledTaskList taskList1, displayedDate, formattedDate, mainCardIndex) {

    return ListTileTheme(
        contentPadding: EdgeInsets.all(0),
        dense: true,
        child: ConfigurableExpansionTile(
          borderColorStart: Colors.white,
          borderColorEnd: Colors.white,
          onExpansionChanged: ((newState) {
            if (newState) {
//              onCardClick(
//                  scheduledTaskCountList[index].floorNumber,
//                  index
//              );
            }
          }),
          header: innerExpansionTileHeader(taskList1),
          children: [
            ListView.builder(
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                physics: ClampingScrollPhysics(),
                itemCount: taskList1.suiteList.length,
                itemBuilder: (BuildContext ctx, int index1) {
                  return Column(
                        children: <Widget>[
                          Container(
                              child: Center(
                                child: Text(taskList1.suiteList[index1].facilityAlias,
                                    style: TextStyle(fontSize: 25)),
                              ),
                              margin: EdgeInsets.only(
                                  top: 10, bottom: 10, left: 10, right: 10),
                              height: 40,
                              width: MediaQuery.of(context).size.width,
                              decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(15)),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey[300],
                                    blurRadius: 3,
                                  )
                                ],
                                color: Colors.grey[300],
                              )),
                          ListView.builder(
                              scrollDirection: Axis.vertical,
                              shrinkWrap: true,
                              physics: ClampingScrollPhysics(),
                              itemCount: taskList1.suiteList[index1].task.length,
                              itemBuilder: (BuildContext ctx, int cardIndex) {
                                // return taskCard(taskList[index].task[index1], mainCardIndex);
                                return buildInnerCardData(
                                  taskList1.suiteList[index1].task[cardIndex], displayedDate, formattedDate, mainCardIndex);
                              })
                        ],
                      );
                  // return buildInnerCardData(
                  //     taskList1.suiteList[index1].task[0], displayedDate, formattedDate, mainCardIndex);
                      //viki1
                })
          ],
        ));
  }

  innerExpansionTileHeader(ScheduledTaskList taskListv1) {
    return Flexible(
      child: Align(
        alignment: Alignment(-1.0, 0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Container(
                alignment: Alignment.center,
                child: Text(
                  "Suite " 
                      +
                      taskListv1.suite.suiteNo 
                      ,

                  // taskList.facilityName + "-" + taskList.suite.floorName,
                  // "test",
                  style: const TextStyle(
                      color: const Color(0xffffffff),
                      fontWeight: FontWeight.w400,
                      fontFamily: "Gotham",
                      fontStyle: FontStyle.normal,
                      fontSize: 16.5),
                ),
                width: 200,
                height: 41,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                        topRight: Radius.circular(25),
                        bottomRight: Radius.circular(25)),
                    gradient: LinearGradient(
                        begin: Alignment(0, 1.9),
                        end: Alignment(0.6, 0.2),
                        colors: [
                          const Color(0xffec828c),
                          const Color(0xfff6a04f)
                        ]))),
            Image.asset(
              'images/bottomicon.webp',
              scale: 4,
            ),
          ],
        ),
      ),
    );
  }

  buildInnerCardData(ScheduledTask task, displayedDate, formattedDate, mainCardIndex) {
    var cardBoxStyle = BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(10)),
        border: Border.all(color: const Color(0xffffffff), width: 0.4),
        boxShadow: [
          BoxShadow(
              color: const Color(0x52b7b8ba),
              offset: Offset(0, 0),
              blurRadius: 8,
              spreadRadius: 0)
        ],
        color: const Color(0xfff9f9f9));

    var textStyle = const TextStyle(
      color: const Color(0xff343233),
      fontWeight: FontWeight.w400,
      fontFamily: "Gotham",
      fontStyle: FontStyle.normal,
      fontSize: 14.5,
    );

    timeFormat(timeString) {
      DateTime shiftStartTime = DateTime.parse(timeString).toLocal();
      var formatter = new DateFormat('HH:mm');
      return formatter.format(shiftStartTime);
    }

    return Container(
      margin: EdgeInsets.only(top: 10),
      height: 180,
      child: Container(
        margin: const EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 10),
        width: MediaQuery.of(context).size.width,
        decoration: cardBoxStyle,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              margin: EdgeInsets.all(12),
              child: Text(task.config.name,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: textStyle,
                  textAlign: TextAlign.left),
            ),
            SizedBox(
              height: 15,
            ),
            Row(
              children: <Widget>[
                Expanded(
                  child: Container(
                    margin: EdgeInsets.only(left: 12),
                    child: Column(
                      children: <Widget>[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Icon(
                              Icons.calendar_today,
                              color: Colors.orangeAccent,
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Text(timeFormat(task.shift.startTime),
                                style: textStyle,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center)
                          ],
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Icon(
                              Icons.wb_sunny,
                              color: Colors.orangeAccent,
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Container(
                              width: 40,
                              child: Text(task.shift.name,
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                  style: textStyle,
                                  textAlign: TextAlign.center),
                            )
                          ],
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Icon(
                              Icons.hourglass_empty,
                              color: Colors.orangeAccent,
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Container(
                              width: 40,
                              child: Text(task.occCount.toString(),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                  style: textStyle,
                                  textAlign: TextAlign.center),
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      if (task.status == "Pending") {
                        if ((displayedDate.difference(DateTime.now())).inDays == 0) {
                          print("buildInnerCardData");
                          showSchedulePopup(
                              task, formattedDate, selectedShiftRotation, mainCardIndex);
                        }
                      }
                    },
                    child: Container(
                        alignment: Alignment.center,
                        margin: const EdgeInsets.only(left: 12, right: 12),
                        height: 48,
                        child: Text(
                            (task.status == "Pending")
                                ? "Take Action"
                                : "Completed",
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w300,
                                fontFamily: "Gotham",
                                fontStyle: FontStyle.normal,
                                fontSize: 16.0),
                            textAlign: TextAlign.center),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(20)),
                            color:
                                (displayedDate.difference(DateTime.now())).inDays == 0
                                    ? (task.status == "Pending")
                                        ? Color(0xfff6a050)
                                        : Color(0xff90c217)
                                    : Colors.grey)),
                  ),
                )
              ],
            ),
            SizedBox(
              height: 10,
            ),
            (task.status == "Pending")? Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  margin: EdgeInsets.all(10),
                  child: Text("Mark Complete",
                      style: TextStyle(fontSize: 20),
                      textAlign: TextAlign.center),
                ),
                Switch(
                  value: isSwitched,
                  onChanged: (value) async {
                    setState(() {
                      isSwitched = false;
                    });
                    getScheduledTaskList(scheduledTaskCountList[mainCardIndex].floorNumber ,mainCardIndex);
                    var result = await ScheduledTaskService.completeTask(task.id , {});
                    scheduledTaskCountList[mainCardIndex].completed = scheduledTaskCountList[mainCardIndex].completed + 1;
                    scheduledTaskCountList[mainCardIndex].remaining = scheduledTaskCountList[mainCardIndex].remaining - 1;
                    setState(() {

                    });
















                  },
                  activeTrackColor: Colors.orange,
                  activeColor: Colors.red,
                ),
              ],
            ) : Container(),
          ],
        ),
      ),
    );
  }

  countCard(String count, Color color )
  {
    return  Expanded(
      child: Container(
          alignment: Alignment.center,
          margin: EdgeInsets.only(
              left: 5.0, right: 5.0, top: 2.0),
          height: 30,
          child: Text(
            // "${pantryFloorList[index].taskTotal}",
              count,
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w300,
                  fontFamily: "Gotham",
                  fontStyle: FontStyle.normal,
                  fontSize: 18.0),
              textAlign: TextAlign.center),
          decoration: BoxDecoration(
              borderRadius:
              BorderRadius.all(Radius.circular(16.4576)),
              color: color
          )
      ),
    );
  }
}
