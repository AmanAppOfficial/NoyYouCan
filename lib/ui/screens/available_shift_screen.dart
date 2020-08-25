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

class AvailableShifts extends StatefulWidget {

  String userRole;
  var mainCtx;
  var currentUser;



  AvailableShifts(this.userRole, this.mainCtx, this.currentUser);

  @override
  _AvailableShiftsState createState() => _AvailableShiftsState();
}

class _AvailableShiftsState extends State<AvailableShifts> {





  List<String> availableShiftsList = ["Morning" , "Evening" , "Night"];
  bool isLoading = true;



  List<String> buildingList = [
    "1",
    "2",
    "3",
    "4",
    "5",
    "6",
    "7",
    "8",
    "9",
    "10",
    "11",
    "12",
    "13",
    "14",
    "15",
    "16",
    "17",
    "18"
  ];
  int selectedIndex = 1;


   DateTime now = new DateTime.now();
   var x=0;


  List<ShiftRotation> shiftRotationLists;
  ShiftRotation selectedShiftRotation;

  bool isOpenedFloorB1 = false;

  List<ShiftRotation> shiftRotationList;

  DateTime date1;
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
      selectPeriod(shiftRotationList[0]);

    } catch(error) {
      print(error);
    }
  }




  selectPeriod(period) async {


    selectedShiftRotation = period;
    print(period);

    if(shiftRotationList.length > 0)
    {

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
      x = 0;
    }


    isLoading = false;
    setState(() {
    });

  }



  @override
  Widget build(BuildContext context) {



    date1 = new DateTime(now.year, now.month, now.day+x);
    formatter = new DateFormat('MMM d, yyyy');
    formattedDate = formatter.format(date1);


    var diff;
    Future _selectDate(BuildContext context) async
    {
      final DateTime picked = await showDatePicker(
          context: context,
//          initialDate: (date1!=null) ? date1 : DateTime.now(),
          initialDate:DateTime.now(),
          firstDate: DateTime.now(),
          lastDate: DateTime(2022)
      );

      if (picked != null && picked != date1)
        {
          diff = picked.difference(date1).inDays;
          x= x + diff;
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
//          // selectedShiftRotation = period;
//
//          now = DateTime.parse(selectedShiftRotation.startDate.toString()).toLocal();
//          x = 0;


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
      x += val;
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
                if (!date1.isBefore(DateTime.parse(
                    selectedShiftRotation.startDate.toString()))) {
                  onDateChange(-1);
                  print("-1");
                }
              },
              child: Container(
                width: MediaQuery.of(context).size.width * (1 / 5),
                height: 50,
                decoration: boxStyle(!date1.isBefore(DateTime.parse(
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
                if (date1
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
                decoration: boxStyle(date1
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

          return Container(
            margin: EdgeInsets.only(bottom: 20 , left: 10 , right: 10),
            child: Card(
              elevation: 4.0,
              shadowColor: Colors.white,
              child: Padding(
                padding: const EdgeInsets.only(top : 10.0 , bottom: 10.0),
                child: ExpansionTile(
                  backgroundColor:Colors.white,
                  trailing: Image.asset('images/bottomicon.webp' , scale: 4,),
                  title: Container(
                      margin: EdgeInsets.only(right: 130 , left: 0),
                                  alignment: Alignment.center,
                                  child: Text(
                                      "${availableShiftsList[index]}",
                                      style: const TextStyle(
                                          color:  const Color(0xffffffff),
                                          fontWeight: FontWeight.w400,
                                          fontFamily: "Gotham",
                                          fontStyle:  FontStyle.normal,
                                          fontSize: 20.5
                                      ),
                                      textAlign: TextAlign.center
                                  ),
                                  width: 160,
                                  height: 51,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.only(topRight :  Radius.circular(25) , bottomRight:  Radius.circular(25)),
                                      gradient: LinearGradient(
                                          begin: Alignment(0, 1.9),
                                          end: Alignment(0.6, 0.2),

                                          colors: [const Color(0xffec828c), const Color(0xfff6a04f)])
                                  )
                              ),
                  children: <Widget>[
                    Container(
                            margin: EdgeInsets.only(top: 10),
                            height:110,
                            child: childContainer(index),
                          )
                ],
              ),
            ),
          ),
        );
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

  childContainer(int index) {
    return Container(
      margin: const EdgeInsets.only(left: 20 , right: 20 , top: 10 , bottom: 10),
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.all(
              Radius.circular(10)
          ),
          border: Border.all(
              color: const Color(0xffffffff),
              width: 0.4
          ),
          boxShadow: [BoxShadow(
              color: const Color(0x52b7b8ba),
              offset: Offset(0,0),
              blurRadius: 8,
              spreadRadius: 0
          )] ,
          color: const Color(0xfff9f9f9)
      ),
      child: GestureDetector(
        onTap: (){
          print("${index}");
        },
        child: Container(
          margin: const EdgeInsets.only(left: 40 , right: 40 , top: 25 , bottom: 25),
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.all(
                  Radius.circular(10)
              ),
              color: const Color(0xffec838a)
          ),
          child: Center(
              child : GestureDetector(
                onTap: (){
                  print("${index}");
                },
                child:  Text(
                    "Available",
                    style: const TextStyle(
                        color:  Colors.white,
                        fontWeight: FontWeight.w300,
                        fontFamily: "Gotham",
                        fontStyle:  FontStyle.normal,
                        fontSize: 20.0
                    ),
                    textAlign: TextAlign.center
                ),
              )
          ),
        ),
      ),
    );
  }


}
