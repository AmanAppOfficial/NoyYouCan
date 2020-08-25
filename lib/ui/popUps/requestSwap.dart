import 'dart:convert';

/**
 * @descrption Request swap pop up
 * @author Aman Srivastava
 */


import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:nowyoucan/model/shift.dart';
import 'package:nowyoucan/model/shiftAllocation.model.dart';
import 'package:nowyoucan/service/shiftAllocation.dart';
import 'package:nowyoucan/ui/widgets/loader.dart';

class RequestSwap extends StatefulWidget {
  ShiftAllocation allocatedShift;
  DateTime currentDate;
  String shiftRotationId;
  RequestSwap(this.currentDate , this.allocatedShift , this.shiftRotationId);

  @override
  _RequestSwapState createState() => _RequestSwapState();
}

class _RequestSwapState extends State<RequestSwap> {

  bool isShiftStartDateChanged = false , isShiftEndDateChanged=false;
  List<String> _locations = [];
  var startTimedisplay= TimeOfDay.now().hour.toString() + " : " +  TimeOfDay.now().minute.toString();
  var endTimeDisplay = TimeOfDay.now().hour.toString() +  " : " +TimeOfDay.now().minute.toString();
  List<Shift> shiftList;// Option 2
  String _selectedLocation; // Option 2
  bool showMarkTextLayout = false;
  bool showActionMarkButtons = false;
  TextEditingController reasonController = new TextEditingController();
  TextEditingController timeUnitController = new TextEditingController();
  bool isLoading = true;
  bool isApiHitting = false;


  TimeOfDay _timeStart = TimeOfDay.now();
  TimeOfDay _timeEnd = TimeOfDay.now();
  TimeOfDay pickedStartTime = null , pickedEndTime = null;
  DateTime selectedDate ;


  Future _selectStartTime(BuildContext context) async
  {
    _timeStart = TimeOfDay.now();

    pickedStartTime = await showTimePicker(context: context, initialTime: _timeStart);

    setState(() {
      _timeStart = pickedStartTime;
      if(_timeStart != null)
      {
        isShiftStartDateChanged = true;
      }
      startTimedisplay = "${(_timeStart != null) ? _timeStart.hour :  TimeOfDay.now().hour} : ${(_timeStart != null) ? _timeStart.minute :  TimeOfDay.now().minute} ";
      timeUnitController.text = (_timeStart.hour - int.parse(endTimeDisplay.substring(0 , endTimeDisplay.indexOf(":"))) ).abs().toString();
    });

  }


  Future _selectEndTime(BuildContext context) async
  {
    _timeEnd = TimeOfDay.now();
    pickedEndTime = await showTimePicker(context: context, initialTime: _timeEnd);

    setState(() {
      _timeEnd = pickedEndTime;
      if(_timeEnd != null)
        {
          isShiftEndDateChanged = true;
        }
      endTimeDisplay = "${(_timeEnd != null) ? _timeEnd.hour :  TimeOfDay.now().hour} : ${(_timeEnd != null) ? _timeEnd.minute :  TimeOfDay.now().minute} ";
      timeUnitController.text = (_timeEnd.hour - int.parse(startTimedisplay.substring(0 , startTimedisplay.indexOf(":"))) ).abs().toString();

    });

  }

  Future _selectDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: (selectedDate!=null) ? selectedDate : DateTime.now(),
        firstDate: DateTime(2015, 8),
        lastDate: DateTime(2101));
    if (picked != null && picked != selectedDate)
      setState(() {
        selectedDate = picked;

      });
  }


  @override
  void initState() {
    // TODO: implement initState
    super.initState();


//    print("currrrrrrrrrr-${DateFormat("yyyy-MM-dd").format(widget.currentDate)}");
    timeUnitController.text = 0.toString();
    getShiftsList();

  }

  getShiftsList() async
  {
    shiftList =  await ShiftAllocationService.getShifts();
    shiftList.forEach((element) {
      _locations.add(element.name);
    });
    isLoading = false;
    setState(() {
    });
  }

  @override
  Widget build(BuildContext context) {

    return (isLoading) ? Loader.getLoader() : ListView(
      children: <Widget>[
        Container(
          margin: EdgeInsets.only(top: 30 , bottom: 30),
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
                                                    "Request Shift Swap",
                                                    style: const TextStyle(
                                                        color:  Colors.white,
                                                        fontWeight: FontWeight.bold,
                                                        fontFamily: "Gotham",
                                                        fontStyle:  FontStyle.normal,
                                                        fontSize: 17.5),
                                                    textAlign: TextAlign.center)
                                            ),
                                            GestureDetector(
                                              onTap: ()
                                              {
                                                if(!isApiHitting)
                                                Navigator.pop(context);},
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

  details()
  {
    return Container(
      alignment: Alignment.center,
      margin: EdgeInsets.all(30),
      child: Stack(
        children: <Widget>[
          Column(
            children: <Widget>[
              Center(
                child: Column(
                  children: <Widget>[
                    selectPreferredDate(),
                    SizedBox(height: 20,),
                    selectPreferredShift(),
                    SizedBox(height: 20,),
//                    selectStartTiming(),
//                    SizedBox(height: 20,),
//                    selectEndTiming(),
//                    SizedBox(height: 20,),
//                    totalTimeUnits(),
                  ],
                ),
              ),
              actionButtons()
            ],
          ),
          (isApiHitting) ?  Center(child: Container(
              height: 500,
              alignment: Alignment.center,
              child :createLoader())) : Container(
          )
        ],
      ),
    );
  }

  selectPreferredDate()
  {
    return
      Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            alignment: Alignment.centerLeft,
            child: Text(
                "Select Preferred Date",
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
                        "${ (selectedDate!=null) ? DateFormat("MMM dd, yyyy").format(selectedDate) : ""}"
                    ),
                  ),
                  GestureDetector
                    (
                      onTap: () async {
                        await _selectDate(context);
                        setState(() {

                        });

                      },
                      child: Icon(Icons.calendar_today)),
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

  selectPreferredShift()
  {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          alignment: Alignment.centerLeft,
          child: Text(
              "Select Preferred Shift",
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
            height: 35,
            width: MediaQuery.of(context).size.width,
//                                                             padding: EdgeInsets.all(7),
            child:
            Align(
//                                                               alignment: Alignment(-0.9 , 0.0),
              child: DropdownButtonHideUnderline(
                child: Container(
                  margin: EdgeInsets.only(left: 5 , right: 5),
                  child: DropdownButton(
                    isExpanded: true,
                    hint: Text('Select'), // Not necessary for Option 1
                    value: _selectedLocation,
                    onChanged: (newValue) {
                      setState(() {
                        _selectedLocation = newValue;
                        if(_selectedLocation != null)
                        {
                          DateTime s = DateTime.parse(shiftList[_locations.indexOf(_selectedLocation)].startTime).toUtc();
                          startTimedisplay = "${s.hour} : ${s.minute}";
                          DateTime e = DateTime.parse(shiftList[_locations.indexOf(_selectedLocation)].endTime);
                          endTimeDisplay = "${e.hour} : ${e.minute}";
                          timeUnitController.text = e.difference(s).inHours.toString();
                          showActionMarkButtons = true;
                        }
                      });
                    },
                    items: _locations.map((location) {
                      return DropdownMenuItem(
                        child: new Text(location),
                        value: location,
                      );
                    }).toList(),
                  ),
                ),
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
                      startTimedisplay
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
                    endTimeDisplay
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

  totalTimeUnits()
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
                      height: 13,
                      child: TextField(
                        maxLines: 1,
                        controller: timeUnitController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          hintText: "",
                          border: InputBorder.none,
                        ),
                      ),
                      margin: EdgeInsets.only(top: 8),
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

  actionButtons()
  {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        Expanded(
          child: GestureDetector(
            onTap: (){
              if(!isApiHitting)
                {
                  isApiHitting = true;
                  setState(() {
                  });
                  if(isShiftStartDateChanged && isShiftEndDateChanged)
                  {
                    if(_selectedLocation != null)
                      validateBothChange(widget.currentDate , context , _timeStart , _timeEnd , shiftList[_locations.indexOf(_selectedLocation)].id , selectedDate , timeUnitController , widget.allocatedShift , widget.shiftRotationId);
                    else
                    {
                      Fluttertoast.showToast(msg: "Select Shift");
                      isApiHitting = false;
                      setState(() {
                      });
                    }

                  }
                  else if(isShiftStartDateChanged)
                  {
                    if(_selectedLocation != null)
                      validateStartChange(widget.currentDate , context , _timeStart , DateTime.parse(shiftList[_locations.indexOf(_selectedLocation)].endTime).toIso8601String() , shiftList[_locations.indexOf(_selectedLocation)].id , selectedDate , timeUnitController , widget.allocatedShift , widget.shiftRotationId);
                    else
                    {
                      Fluttertoast.showToast(msg: "Select Shift");
                      isApiHitting = false;
                      setState(() {
                      });
                    }
                  }
                  else if(isShiftEndDateChanged)
                  {
                    if(_selectedLocation != null)
                      validateEndChange(widget.currentDate , context , DateTime.parse(shiftList[_locations.indexOf(_selectedLocation)].startTime).toIso8601String() , _timeEnd , shiftList[_locations.indexOf(_selectedLocation)].id , selectedDate , timeUnitController , widget.allocatedShift , widget.shiftRotationId);
                    else
                    {
                      Fluttertoast.showToast(msg: "Select Shift");
                      isApiHitting = false;
                      setState(() {
                      });
                    }
                  }
                  else if(!isShiftStartDateChanged && !isShiftEndDateChanged)
                  {
                    if(_selectedLocation != null)
                      validateNoChange(widget.currentDate , context , DateTime.parse(shiftList[_locations.indexOf(_selectedLocation)].startTime).toIso8601String() , DateTime.parse(shiftList[_locations.indexOf(_selectedLocation)].endTime).toIso8601String() , shiftList[_locations.indexOf(_selectedLocation)].id , selectedDate , timeUnitController , widget.allocatedShift , widget.shiftRotationId);
                    else
                    {
                      Fluttertoast.showToast(msg: "Select Shift");
                      isApiHitting = false;
                      setState(() {
                      });
                    }
                  }
                  else
                  {
                    isApiHitting = false;
                    setState(() {
                    });
                  }



                }

            },
            child: Container(
                padding: EdgeInsets.all(12),
                margin: const EdgeInsets.only(top : 25 , left: 10 , right: 10),
                alignment: Alignment.center,
                child: Text(
                    "Confirm",
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
            onTap: (){
              if(!isApiHitting)
              Navigator.pop(context);
              },
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

createLoader()
{

    return SpinKitCircle(
      color: Colors.orangeAccent,
      size: 170.0,
      // controller: AnimationController(vsync: this, duration: const Duration(milliseconds: 1200)),
    );

}

void validateNoChange(DateTime currDate , BuildContext context , String startTimedisplay , String endTimedisplay, String preferredShiftId, DateTime preferredDate, TextEditingController timeUnitController, ShiftAllocation allocatedShift , String shiftRotationId)
{
  completeSwap(allocatedShift.buildings , startTimedisplay , endTimedisplay , preferredShiftId , preferredDate , timeUnitController.text , currDate , allocatedShift.shift.id , shiftRotationId , context);
}

void validateBothChange(DateTime currDate , BuildContext context , TimeOfDay startTimedisplay , TimeOfDay endTimedisplay, String preferredShiftId, DateTime preferredDate, TextEditingController timeUnitController, ShiftAllocation allocatedShift , String shiftRotationId)
{
  completeSwap(allocatedShift.buildings , new DateTime(currDate.year, currDate.month, currDate.day, startTimedisplay.hour, startTimedisplay.minute).toUtc().toIso8601String().toString() , new DateTime(currDate.year, currDate.month, currDate.day, endTimedisplay.hour, endTimedisplay.minute).toUtc().toIso8601String().toString() , preferredShiftId , preferredDate , timeUnitController.text , currDate , allocatedShift.shift.id , shiftRotationId , context);
}

void validateEndChange(DateTime currDate , BuildContext context , String startTimedisplay , TimeOfDay endTimedisplay, String preferredShiftId, DateTime preferredDate, TextEditingController timeUnitController, ShiftAllocation allocatedShift , String shiftRotationId)
{
  completeSwap(allocatedShift.buildings , startTimedisplay , new DateTime(currDate.year, currDate.month, currDate.day, endTimedisplay.hour, endTimedisplay.minute).toUtc().toIso8601String().toString() , preferredShiftId , preferredDate , timeUnitController.text , currDate , allocatedShift.shift.id , shiftRotationId , context);
}

void validateStartChange(DateTime currDate , BuildContext context , TimeOfDay startTimedisplay , String endTimedisplay, String preferredShiftId, DateTime preferredDate, TextEditingController timeUnitController, ShiftAllocation allocatedShift , String shiftRotationId)
{
  completeSwap(allocatedShift.buildings , new DateTime(currDate.year, currDate.month, currDate.day, startTimedisplay.hour, startTimedisplay.minute).toUtc().toIso8601String().toString() , endTimedisplay , preferredShiftId , preferredDate , timeUnitController.text , currDate , allocatedShift.shift.id , shiftRotationId , context);
}


completeSwap(List<Building> buildings, String startTimedisplay, String endTimedisplay, String preferredShiftId, DateTime prefDate, String units, DateTime currDate, String shiftId, String shiftRotationId , BuildContext context)
async {


 if(preferredShiftId != null)
   {
     try
         {
           List buildingId=[];
           buildings.forEach((element) {
             buildingId.add(element.id);
           });

           var result = await ShiftAllocationService.requestSwap({
             "buildings" : buildingId,
             "date" : DateFormat("yyyy-MM-dd").format(currDate),
             "endTime"  : endTimedisplay,
             "preferredDate" : DateFormat("yyyy-MM-dd").format(prefDate),
             "preferredShift" : preferredShiftId,
             "shift" : shiftId,
             "shiftRotation" : shiftRotationId,
             "startTime" : startTimedisplay,
             "workUnits" : double.parse(units)
           });

           print("res---------" + result.toString());
           Fluttertoast.showToast(msg: "Completed!");
           Navigator.pop(context);
         }

         catch(e)
           {}

   }
}



