import 'dart:math';

/**
 * @descrption Available shift screen
 * @author Aman Srivastava
 */



import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nowyoucan/service/shiftRotation.dart';
import 'package:nowyoucan/service/user.dart';
import 'package:nowyoucan/ui/widgets/app_bar.dart';
import 'package:nowyoucan/ui/widgets/navigation_drawer_elements.dart';
import 'package:nowyoucan/model/shiftRotation.dart';
import 'package:nowyoucan/ui/widgets/loader.dart';

class AvailableShiftsV2 extends StatefulWidget {

  String userRole;
  var mainCtx;
  var currentUser;



  AvailableShiftsV2(this.userRole, this.mainCtx, this.currentUser);

  @override
  _AvailableShiftsState createState() => _AvailableShiftsState();
}

class _AvailableShiftsState extends State<AvailableShiftsV2> {





  var availableShiftsList = [
    {
      "date": "2020-07-22T06:34:00.082Z",
      "data": [
        {
          "shift": "Morning",
          "available": true
        },
        {
          "shift": "Morning",
          "available": true
        },
        {
          "shift": "Morning",
          "available": true
        },
        {
          "shift": "Morning",
          "available": true
        }
      ]
    },
    {
      "date": "2020-07-22T06:34:00.082Z",
      "data": [
        {
          "shift": "Morning",
          "available": true
        },
        {
          "shift": "Morning",
          "available": true
        },
        {
          "shift": "Morning",
          "available": true
        },
        {
          "shift": "Morning",
          "available": true
        }
      ]
    }
  ];
  bool isLoading = true;



  List<String> buildingList = [];

  int selectedIndex = 1;


  DateTime now = new DateTime.now();
  var dateChangeCount=0;


  List<ShiftRotation> shiftRotationLists;
  ShiftRotation selectedShiftRotation;

  bool isOpenedFloorB1 = false;

  List<ShiftRotation> shiftRotationList;

  DateTime displayedDate;
  var formatter ;
  String formattedDate ;




  @override
  void initState() => {
    (() async {


      widget.currentUser = await User.me();
      await getShiftRotation();
      // print("----------------------------------");
      setState(() {

      });

    })()
  };


  getShiftRotation() async {
    try {
      shiftRotationList = await ShiftRotationService.get();
      if(shiftRotationList.length > 0)
      {
        selectPeriod(shiftRotationList[0]);
        print(selectedShiftRotation.startDate);
        // To set the date to start date of the shift rotation
        if(now.isBefore(DateTime.parse(selectedShiftRotation.endDate.toString())) && now.isAfter(DateTime.parse(selectedShiftRotation.startDate.toString())) || now.difference(DateTime.parse(selectedShiftRotation.startDate.toString())).inDays == 0 || now.difference(DateTime.parse(selectedShiftRotation.endDate.toString())).inDays == 0)
        {
          now = now;
        }
        else
        {
          now = DateTime.parse(selectedShiftRotation.startDate.toString()).toLocal();
        }
      }
      dateChangeCount = 0;
      isLoading = false;
      setState(() {
      });
    } catch(error) {
      print(error);
    }
  }




  selectPeriod(period) async {
    selectedShiftRotation = period;
    print(period);
  }



  @override
  Widget build(BuildContext context) {



    displayedDate = new DateTime(now.year, now.month, now.day + dateChangeCount);
    formatter = new DateFormat('MMM d, yyyy');
    formattedDate = formatter.format(displayedDate);


    var diff;
    Future _selectDate(BuildContext context) async
    {
      final DateTime picked = await showDatePicker(
          context: context,
          initialDate:DateTime.parse(selectedShiftRotation.startDate.toString()).toLocal(),
          firstDate: DateTime.parse(selectedShiftRotation.startDate.toString()).toLocal(),
          lastDate: DateTime.parse(selectedShiftRotation.endDate.toString()).toLocal());

      if (picked != null && picked != displayedDate)
      {
        diff = picked.difference(displayedDate).inDays;
        dateChangeCount = dateChangeCount + diff;
      }


      setState(() {
      });
    }


// View Functions
    // View Functions
    periodBtn(period, title) {
      var opacity = 0.2, txtColor = Colors.white;
      if(selectedShiftRotation != null && selectedShiftRotation.id == period.id) {
        opacity = 1;
        txtColor = Color(0xffec828c);
      } else {
        opacity = 0.2;
        txtColor = Colors.white;
      }

      return InkWell(
        onTap: () async {


          now = DateTime.now();
          selectPeriod(period);
//
//          selectPeriod(period);
//
//          now = DateTime.parse(selectedShiftRotation.startDate.toString()).toLocal();
//          dateChangeCount = 0;

        setState(() {

        });
//        selectedShiftRotation = period;




        },
        child: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            Opacity(
              opacity: opacity,
              child: Container(
                margin: EdgeInsets.only(left: 20.0, right: 10.0),
                height: 50,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10.0)
                ),
              ),
            ),
            Text(title, style: TextStyle(
                color: txtColor,
                fontSize: 16.5
            ))
          ],
        ),
      );
    }


    periodRow() {

      List<Widget> rowList = [];
      shiftRotationList.forEach((shiftRotation) {
        rowList.add(
            Expanded(child: periodBtn(shiftRotation, formatter.format(DateTime.parse(shiftRotation.startDate).toLocal())))
        );
      });

      return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: rowList
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




    buildingLists() {
      return Container(
        margin: const EdgeInsets.only(top: 175, left: 0, right: 0),
        child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: buildingList.length,
            itemBuilder: (BuildContext ctx, int index) {
              return GestureDetector(
                onTap: () {
                  print("clicked ${index + 1}");
                  selectedIndex = index + 1;
                  setState(() {});
                },
                child: Card(
                  elevation: 6,
                  shadowColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.25)),
                  child: Center(
                    child: Container(
                      height: (selectedIndex == (index + 1)) ? 50 : 30,
                      width: MediaQuery.of(context).size.width * (1 / 3.1),
                      child: Center(
                        child: Text(
                          "Cyber ${index + 1}",
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


    onDateChange(val) {
      dateChangeCount += val;
      setState(() {
      });
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
                  print("-1");
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
            onTap: () {
              _selectDate(context);

            },
            child: Container(
                width: MediaQuery.of(context).size.width * (1 / 2.5),
                height: 50,
                decoration: boxStyle(true),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Icon(
                        Icons.calendar_today,
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


    floorCards()
    {

      return ListView.builder(
          shrinkWrap: true,
          physics: ClampingScrollPhysics(),
          itemCount: availableShiftsList.length,
          itemBuilder: (BuildContext ctx, int index) {

            return shiftCard(availableShiftsList[index]["data"]);
          }
      );
    }


    return  Scaffold(
        backgroundColor: Colors.white,
        resizeToAvoidBottomPadding: true,
        appBar: BaseAppBar.getAppBar("Available \nShifts"),
        endDrawer: Drawer(
          child: DrawerElements.getDrawer('available shift', context, widget.userRole , widget.mainCtx , widget.currentUser),
        ),
        body : (isLoading) ? Loader.getLoader() :SafeArea(
          child: ListView(
            children: <Widget>[
              Stack(
                children: <Widget>[
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      header(),
                      SizedBox(height: 40.0),
                      (shiftRotationList.length>0) ? dateRow() : Container(),
                      SizedBox(height: 30.0),
                      floorCards(),
                    ],
                  ),
//                    buildingLists(),
                ],
              ),
            ],
          ),
        )
    );
  }

  shiftCard(shiftData) {
    return Container(
      child: Stack(
        children: <Widget>[
          Container(
            margin: EdgeInsets.all(20),
            padding: const EdgeInsets.all(18),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                headingRow(),
                SizedBox(height: 10,),
                shiftElements(shiftData),
              ],
            ),
            decoration: BoxDecoration(
                color: Colors.grey[200],
                boxShadow: [BoxShadow(
                  color: Colors.grey,
                  offset: Offset(0.2 , 0.3),
                  blurRadius: 0.2,
                  spreadRadius: 0.3
                )],
                borderRadius: BorderRadius.circular(8),
            ),
          ),
          Container(
            margin: EdgeInsets.only(left: 50),
            alignment: Alignment.center,
            height: 50,
            width: 120,
            child: Text('22 Jan, 2020' , style: TextStyle(color: Colors.white , fontWeight: FontWeight.bold),),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment(0.0, 1.3),
                  end: Alignment(0.9, 0.7),
                  colors: [
                    const Color(0xffec828c),
                    const Color(0xfff6a04f)
                  ]),
              borderRadius: BorderRadius.circular(8),),
          )
        ],
      ),
    );
  }

  headingRow()
  {

    TextStyle headingStyle = TextStyle(fontSize: 22 , fontWeight: FontWeight.bold);
    return Container(
      margin: EdgeInsets.only(left: 17 , top: 20),
      padding: EdgeInsets.all(8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Text("Name" , style: headingStyle ,),
          SizedBox(width: 10,),
          Text("Availability" , style: headingStyle,)
        ],
      ),
    );
  }

  shiftElements(shiftData)
  {
    return ListView.builder(
      shrinkWrap: true,
        physics: ClampingScrollPhysics(),
        itemCount: shiftData.length,
        itemBuilder: (BuildContext context , int index)
        {
          return Container(
            margin: EdgeInsets.only(right: 5),
            padding: EdgeInsets.all(5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Text(shiftData[index]["shift"] , style: TextStyle(fontSize: 17),),
                SizedBox(width: 20,),
                Icon(Icons.done)
              ],
            ),
          );
        }
    );
  }

}
