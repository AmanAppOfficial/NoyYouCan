/**
 * @descrption Mark attendance pop up
 * @author Aman Srivastava
 */


import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nowyoucan/model/shiftAllocation.model.dart';
import 'package:nowyoucan/service/shiftAttendance.service.dart';
import 'package:nowyoucan/ui/widgets/loader.dart';

class MarkAttendance extends StatefulWidget {


  String date;
  String shiftRotationId;
  ShiftAllocation allocatedShift;

  MarkAttendance(this.date, this.shiftRotationId, this.allocatedShift);

  @override
  _MarkAttendanceState createState() => _MarkAttendanceState();
}

class _MarkAttendanceState extends State<MarkAttendance> {


  bool isLoading = false;

  bool showMarkTextLayout = false;
  bool showActionMarkButtons = false;
  TextEditingController reasonController = new TextEditingController();
//  TextEditingController timeUnitController = new TextEditingController();
  double timeUnitController=0;

  List<Building> buildingsList = [];
  var _selectedBuildingId;


  TimeOfDay _timeStart = TimeOfDay.now();
  TimeOfDay _timeEnd = TimeOfDay.now();
  TimeOfDay pickedStartTime = TimeOfDay.now() , pickedEndTime = TimeOfDay.now();
  DateTime selectedDate = DateTime.now();


  Future<Null> _selectStartTime(BuildContext context) async
  {
    _timeStart = TimeOfDay.now();
    var a = await showTimePicker(context: context, initialTime: _timeStart);
    if(a != null) pickedStartTime = a;

    setState(() {
      _timeStart = pickedStartTime;
      computeWorkUnit();
    });

  }

  getMarkedShift() async{
    var formattedDate = DateFormat("yyyy-MM-dd").format(DateTime.parse(widget.date));
    var res = await ShiftAttendanceService.getMarkedShifts(formattedDate, widget.allocatedShift.shift.id);

    buildingsList = widget.allocatedShift.buildings;


    for(var obj in res)
      {
        if(obj["building"]!= null)
          {
            for(int i=0 ; i<buildingsList.length ; i++)
              {
                if(buildingsList[i].id == obj["building"])
                  {
                    buildingsList.removeAt(i);
                  }
              }
          }
      }

    isLoading = false;
    setState(() {

    });

  }


//  computeWorkUnit() {
//    // print("+++++++++");
//    // print(pickedStartTime);
//    final now = new DateTime.now();
//    var st = DateTime(now.year, now.month, now.day, pickedStartTime.hour, pickedStartTime.minute);
//    var et = DateTime(now.year, now.month, now.day, pickedEndTime.hour, pickedEndTime.minute);
//    var diff = et.difference(st).inMinutes;
//    // timeUnitController = diff.toString();
//    print( "--------------" + diff.toString());
//    timeUnitController = diff/60;
//  }

  computeWorkUnit()
  {
    if(_timeStart.hour<_timeEnd.hour)
    timeUnitController = (_timeEnd.hour - _timeStart.hour)/1;
    else
      timeUnitController = (_timeStart.hour - _timeEnd.hour)/1;
  }


  Future<Null> _selectEndTime(BuildContext context) async
  {
    _timeEnd = TimeOfDay.now();
    var a = await showTimePicker(context: context, initialTime: _timeEnd);
    if(a != null) pickedEndTime = a;

    setState(() {
      _timeEnd = pickedEndTime;
      computeWorkUnit();
    });

  }


    /*
  https://dev.nowyoucan.io/api/v1/shift-attendance

  date: "2020-06-01"
  endTime: "2020-04-17T10:00:00.840Z"
  shift: "5e98e3b079469573dfe18990"
  startTime: "2020-04-17T09:30:00.828Z"
  workUnits: 0.5
  */


  markAttendance() async {

    isLoading = true;
    setState(() {

    });

    print("------------");
    final now = new DateTime.now();
    var dt = DateTime(now.year, now.month, now.day, _timeStart.hour, _timeStart.minute);
    // print(" ---" + dt.toUtc().toIso8601String());
    var startTime = dt.toUtc().toIso8601String();
    dt = DateTime(now.year, now.month, now.day, _timeEnd.hour, _timeEnd.minute);
    var endTime = dt.toUtc().toIso8601String();

//     print(" __" + startTime + "\n" + endTime);
////     print(" __" + shiftRotationId);
////     print(" __" + allocatedShiftId);
////     print(" __" + date);
//     print(" __" + timeUnitController.toString());


    var res = await ShiftAttendanceService.markAttendance(widget.date, startTime, endTime, widget.shiftRotationId, widget.allocatedShift.shift.id, timeUnitController , _selectedBuildingId);
    Navigator.pop(context);
  }


  @override
  void initState() => {
    (() async {

      isLoading = true;
      setState(() {

      });
      await getMarkedShift();




      if(widget.allocatedShift.buildingsTimeStamp.length > 0)
      {


        // Start sorting
        widget.allocatedShift.buildingsTimeStamp.sort((b, a) {
          // return DateTime.parse(a.startTime).toUtc().isBefore(DateTime.parse(b.startTime).toUtc());
          // return DateTime.parse(a.startTime).toLocal() > DateTime.parse(b.startTime).toLocal();
          return DateTime.parse(b.startTime).toUtc().difference(DateTime.parse(a.startTime).toUtc()).inSeconds;
        });
        // End sorting


        _selectedBuildingId = widget.allocatedShift.buildingsTimeStamp[0].id;
        _timeStart = TimeOfDay.fromDateTime(DateTime.parse(widget.allocatedShift.buildingsTimeStamp[0].startTime).toLocal());
        _timeEnd = TimeOfDay.fromDateTime(DateTime.parse(widget.allocatedShift.buildingsTimeStamp[0].endTime).toLocal());
        computeWorkUnit();
      }

      timeUnitController = double.parse(_timeEnd.hour.toString()) - double.parse(_timeStart.hour.toString());
    })()
  };



  @override
  Widget build(BuildContext context) {
    return ListView(
      children: <Widget>[
        Container(
          margin: ( MediaQuery.of(context).orientation == Orientation.portrait) ? EdgeInsets.only(top: 100 , bottom: 30) : EdgeInsets.only(top: 30 , bottom: 30),
          child: Stack(
            children: <Widget>[
              Container(
                child: Dialog(
                    shape: RoundedRectangleBorder(
                        borderRadius:
                        BorderRadius.circular(15.0)), //this right here
                    child: StatefulBuilder(
                        builder: (BuildContext context, StateSetter setState) {

                          return Stack(
                            children: <Widget>[
                              Container(
                                  child: Column(
                                    children: <Widget>[
                                      Container(
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: <Widget>[
                                            Container(
                                                child :  Text(
                                                    "Mark Attendance",
                                                    style: const TextStyle(
                                                        color:  Colors.white,
                                                        fontWeight: FontWeight.bold,
                                                        fontFamily: "Gotham",
                                                        fontStyle:  FontStyle.normal,
                                                        fontSize: 17.5),
                                                    textAlign: TextAlign.center)
                                            ),
                                            GestureDetector(
                                              onTap: (){
                                                Navigator.pop(context);
                                              },
                                              child: Container(
                                                child: Image.asset(('images/whitecancelicon.png') , scale: 1.8,),
                                              ),
                                            )
                                          ],
                                        ),
                                        margin: EdgeInsets.only(left: 25 , right: 19 , top: 30),
                                      ),
                                      Container(
                                          child: details(),
                                          margin: EdgeInsets.only(top: 40 , bottom: 40),
                                          decoration: BoxDecoration(
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(15)
                                              ),
                                              color: Colors.white
                                          )
                                      ),
                                    ],
                                  ),
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(15)
                                      ),
                                      boxShadow: [BoxShadow(
                                          color: const Color(0xff4f4f4f),
                                          offset: Offset(7.347880794884119e-16, 12),
                                          blurRadius: 32,
                                          spreadRadius: 0
                                      )
                                      ],
                                      color: const Color(0xfff6a04f)
                                  )
                              )
                            ],
                          );
                        }
                    )
                ),

              )
            ],
          ),
        )
      ],
    );
  }

  details() {
    return (!isLoading) ? Container(
      alignment: Alignment.center,
      margin: EdgeInsets.all(30),
      child: Column(
        children: <Widget>[
          Center(
            child: Column(
              children: <Widget>[
                buildingListView(),
                SizedBox(height: 20,),
                selectStartTiming(),
                SizedBox(height: 20,),
                selectEndTiming(),
                SizedBox(height: 20,),
                selectTotalTimeUnits(),

              ],
            ),
          ),
          actionButtons()
        ],
      ),
    ) : Container(
      height: 400,
      child: Loader.getLoader(),
    );
  }

  selectStartTiming()
  {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          alignment: Alignment.centerLeft,
          child: Text(
              "Start Time",
              style: const TextStyle(
                  color:  const Color(0xff343233),
                  fontWeight: FontWeight.w400,
                  fontFamily: "Gotham",
                  fontStyle:  FontStyle.normal,
                  fontSize: 15.0
              ),
              textAlign: TextAlign.center
          ),
        ),
        SizedBox(height: 10,),
        Container(
            width: MediaQuery.of(context).size.width,
            alignment: Alignment.centerRight,
            padding: EdgeInsets.all(7),
            child:  Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Container(
                  child:  Text(
                      "${(_timeStart != null) ? _timeStart.hour :  TimeOfDay.now().hour}:${(_timeStart != null) ? _timeStart.minute :  TimeOfDay.now().minute}"
                  ),
                ),
                GestureDetector
                  (
                    onTap: () async {
                      await _selectStartTime(context);
                      setState(() {

                      });
                    },
                    child: Icon(Icons.access_time)),
              ],
            ) ,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.all(
                    Radius.circular(9.4576)
                ),
                boxShadow: [BoxShadow(
                    color: Colors.grey,
                    offset: Offset(0,0),
                    blurRadius: 2,
                    spreadRadius: 0
                )] ,
                color: Colors.white
            )
        )
      ],
    );
  }

  selectEndTiming()
  {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          alignment: Alignment.centerLeft,
          child: Text(
              "End Time",
              style: const TextStyle(
                  color:  const Color(0xff343233),
                  fontWeight: FontWeight.w400,
                  fontFamily: "Gotham",
                  fontStyle:  FontStyle.normal,
                  fontSize: 15.0
              ),
              textAlign: TextAlign.center
          ),
        ),
        SizedBox(height: 10,),
        Container(
            width: MediaQuery.of(context).size.width,
            alignment: Alignment.centerRight,
            padding: EdgeInsets.all(7),
            child:  Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Container(
                  child:  Text(
                      "${(_timeEnd != null) ? _timeEnd.hour :  TimeOfDay.now().hour}:${(_timeEnd != null) ? _timeEnd.minute :  TimeOfDay.now().minute}"
                  ),
                ),
                GestureDetector
                  (
                    onTap: () async {
                      await _selectEndTime(context);
                      setState(() {
                      });
                    },
                    child: Icon(Icons.access_time)),
              ],
            ) ,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.all(
                    Radius.circular(9.4576)
                ),
                boxShadow: [BoxShadow(
                    color: Colors.grey,
                    offset: Offset(0,0),
                    blurRadius: 2,
                    spreadRadius: 0
                )] ,
                color: Colors.white
            )
        )
      ],
    );
  }

  selectTotalTimeUnits()
  {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          alignment: Alignment.centerLeft,
          child: Text(
              "Total Time Units",
              style: const TextStyle(
                  color:  const Color(0xff343233),
                  fontWeight: FontWeight.w400,
                  fontFamily: "Gotham",
                  fontStyle:  FontStyle.normal,
                  fontSize: 15.0
              ),
              textAlign: TextAlign.center
          ),
        ),
        SizedBox(height: 10,),
        Container(
            width: MediaQuery.of(context).size.width,
            alignment: Alignment.centerRight,
            padding: EdgeInsets.all(7),
            child:
            Container(

              alignment: Alignment.center,
              child : Row(
                children: <Widget>[
                  Expanded(
                    child: Container(
                      child: Text(
                      "${timeUnitController.toString()}"
                      ),
                      margin: EdgeInsets.only(top: 9),
                    ),
                  ),

                ],
              ),
            ),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.all(
                    Radius.circular(9.4576)
                ),
                boxShadow: [BoxShadow(
                    color: Colors.grey,
                    offset: Offset(0,0),
                    blurRadius: 2,
                    spreadRadius: 0
                )] ,
                color: Colors.white
            )
        )
      ],
    );
  }

  buildingListView() {

   return Column(
     children: <Widget>[
       Container(
         alignment: Alignment.centerLeft,
         child: Text(
             "Buildings",
             style: const TextStyle(
                 color:  const Color(0xff343233),
                 fontWeight: FontWeight.w400,
                 fontFamily: "Gotham",
                 fontStyle:  FontStyle.normal,
                 fontSize: 15.0
             ),
             textAlign: TextAlign.center
         ),
       ),
       SizedBox(height: 10,),
       Wrap(
         children: buildingsList.map((item) => GestureDetector(
           onTap: (){
             _selectedBuildingId = item.id;

               for(final element in widget.allocatedShift.buildingsTimeStamp)
                 {
                   if(element.id == _selectedBuildingId)
                   {
                     _timeStart = TimeOfDay.fromDateTime(DateTime.parse(element.startTime).toLocal());
                     _timeEnd = TimeOfDay.fromDateTime(DateTime.parse(element.endTime).toLocal());
                     computeWorkUnit();
                     break;
                   }
                 }

             setState(() {

             });
           },
           child: Container(
             alignment: Alignment.center,
             width: 100,
             margin: EdgeInsets.all(8),
             padding: EdgeInsets.all(8),
               decoration: BoxDecoration(
                 color: (_selectedBuildingId == item.id) ? Colors.deepOrange : Colors.orange,
                 borderRadius: BorderRadius.circular(5),
               ),
               child : Text(item.name , style: TextStyle(fontSize: 20 , color: Colors.white),)
           ),
         )).toList().cast<Widget>(),
       ),
     ],
   );
  }


  actionButtons()
  {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        Expanded(
          child: GestureDetector(
            onTap: (){
              markAttendance();
//              print(timeUnitController.);
            // Navigator.pop(context);
            },
            child: Container(
                padding: EdgeInsets.all(12),
                margin: const EdgeInsets.only(top : 25 , left: 10 , right: 10),
                alignment: Alignment.center,
                child: Text(
                    "Mark",
                    style: const TextStyle(
                        color:  Colors.white,
                        fontWeight: FontWeight.w300,
                        fontFamily: "Gotham",
                        fontStyle:  FontStyle.normal,
                        fontSize: 20.0
                    ),
                    textAlign: TextAlign.center
                ),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(
                        Radius.circular(10.4576)
                    ),
                    color: const Color(0xffd74545)
                )
            ),
          ),
        ),
        Expanded(
          child:  GestureDetector(
            onTap: (){Navigator.pop(context);},
            child: Container(
                padding: EdgeInsets.all(12),
                margin: const EdgeInsets.only(top : 25 , left: 10 , right: 10),
                alignment: Alignment.center,
                child: Text(
                    "Cancel",
                    style: const TextStyle(
                        color:  Colors.white,
                        fontWeight: FontWeight.w300,
                        fontFamily: "Gotham",
                        fontStyle:  FontStyle.normal,
                        fontSize: 20.0
                    ),
                    textAlign: TextAlign.center
                ),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(
                        Radius.circular(10.4576)
                    ),
                    color: const Color(0xff0fe68e)
                )
            ),
          ),

        )
      ],
    );
  }
}
