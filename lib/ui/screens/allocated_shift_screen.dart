import 'package:flutter/material.dart';
import 'package:nowyoucan/model/shiftAllocation.model.dart';
import 'package:nowyoucan/ui/popUps/checkRequestSwap.dart';
import 'package:nowyoucan/ui/popUps/markAttendance.dart';
import 'package:nowyoucan/ui/popUps/markUnavailable.dart';
import 'package:nowyoucan/ui/popUps/requestSwap.dart';
import 'package:nowyoucan/ui/widgets/app_bar.dart';
import 'package:nowyoucan/ui/widgets/navigation_drawer_elements.dart';
import 'package:intl/intl.dart';
import 'package:nowyoucan/service/user.dart';
import 'package:nowyoucan/service/shiftRotation.dart';
import 'package:nowyoucan/service/shiftAllocation.dart';
import 'package:nowyoucan/ui/widgets/loader.dart';
import 'package:nowyoucan/model/shiftRotation.dart';

class AllocatedShifts extends StatefulWidget {

  String userRole;
  var mainCtx;
  var currentUser;

  AllocatedShifts(this.userRole, this.mainCtx, this.currentUser);

  @override
  _AllocatedShiftsState createState() => _AllocatedShiftsState();
}

class _AllocatedShiftsState extends State<AllocatedShifts> {

  List<String> _shiftsList = ['Sick Leave', 'Annual Leave', 'Career Leave', 'Other'];
  String _selectedLocation; // Option 2
  bool showMarkTextLayout = false;
  bool showActionMarkButtons = false;
  bool isLoading =  true;
  bool isListLoading = true;

  bool isToday = false;
  bool isAvailableSwap = false;
  TextEditingController reasonController = new TextEditingController();
  TextEditingController timeUnitController = new TextEditingController();

  List<ShiftRotation> shiftRotationList;

  List<ShiftAllocation> allocatedShiftList = [] ;

  DateTime todaysDate = new DateTime.now();
  var dateChangeCount=0;


  ShiftRotation selectedShiftRotation;

  @override
  void initState() => {
     (() async {
      widget.currentUser = await User.me();
      await getShiftRotation();
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
          dateChangeCount = 0;
        }
      else
        {
          isListLoading = false;
        }

      isLoading = false;
      setState(() {
      });

    } catch(error) {
      print(error);
    }
  }

  selectPeriod(period) async {
    selectedShiftRotation = period;
    if(todaysDate.isBefore(DateTime.parse(selectedShiftRotation.endDate.toString())) && todaysDate.isAfter(DateTime.parse(selectedShiftRotation.startDate.toString())) || todaysDate.difference(DateTime.parse(selectedShiftRotation.startDate.toString())).inDays == 0 || todaysDate.difference(DateTime.parse(selectedShiftRotation.endDate.toString())).inDays == 0)
    {
    }
    else
    {
      todaysDate = DateTime.parse(selectedShiftRotation.startDate.toString()).toLocal();
    }

    checkToday();
    checkAvailableSwap();
    getShiftAllocation();
    isLoading = false;
    setState(() {
    });
  }

  getShiftAllocation() async {
    isListLoading = true;
    setState(() {
    });    
    
    DateTime displayedDate = new DateTime(todaysDate.year, todaysDate.month, todaysDate.day + dateChangeCount);
    var formatter = new DateFormat('yyyy-MM-dd');
    String formattedDate = formatter.format(displayedDate);
    allocatedShiftList = await ShiftAllocationService.memberShifts(
      selectedShiftRotation.id,
      formattedDate
    );

    if (allocatedShiftList == null) {
      allocatedShiftList = [];
    }

    isListLoading = false;
    setState(() {
    });
  }

  checkToday() {
    DateTime dNow = new DateTime.now();
    DateTime selectedDate = new DateTime(todaysDate.year, todaysDate.month, todaysDate.day + dateChangeCount);
    var diff = dNow.difference(selectedDate).inHours;
    if(diff <= 24 && diff >=0) {
      isToday = true;
    } else {
      isToday = false;
    }
  }

  checkAvailableSwap() {
    DateTime dNow = new DateTime.now();
    DateTime selectedDate = new DateTime(todaysDate.year, todaysDate.month, todaysDate.day + dateChangeCount);
    var diff = selectedDate.difference(dNow).inHours;
    if( diff >= 48  ) {
      isAvailableSwap = true;
    } else {
      isAvailableSwap = false;
    }

//  isAvailableSwap = true;

  }

  onDateChange(val) {
    dateChangeCount += val;
    checkToday();
    checkAvailableSwap();
    getShiftAllocation();
    setState(() {

    });
  } 

  @override
  Widget build(BuildContext context) {
    DateTime displayedDate = new DateTime(todaysDate.year, todaysDate.month, todaysDate.day + dateChangeCount);
    var formatter = new DateFormat('MMM d, yyyy');
    String formattedDate = formatter.format(displayedDate);


    var diff;
    Future _selectDate(BuildContext context) async
    {
      final DateTime picked = await showDatePicker(
          context: context,
//          initialDate: (displayedDate!=null) ? displayedDate : DateTime.now(),
          initialDate:DateTime.parse(selectedShiftRotation.startDate.toString()).toLocal(),
          firstDate: DateTime.parse(selectedShiftRotation.startDate.toString()).toLocal(),
          lastDate: DateTime.parse(selectedShiftRotation.endDate.toString()).toLocal());

      if (picked != null && picked != displayedDate)
      {
        diff = picked.difference(displayedDate).inDays;
        dateChangeCount= dateChangeCount + diff;
      }
      checkToday();
      checkAvailableSwap();
      getShiftAllocation();
      setState(() {
      });
    }

    var boxStyle = BoxDecoration(
      borderRadius: BorderRadius.all(
      Radius.circular(15) 
    ),
    boxShadow: [BoxShadow(
          color: Colors.grey[300],
          blurRadius: 15,
      )],
    color: Colors.white,
    );


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
        onTap: () {
          todaysDate = DateTime.now();
          selectPeriod(period);
//          selectPeriod(period);

//            todaysDate = DateTime.parse(selectedShiftRotation.startDate.toString()).toLocal();
//          dateChangeCount = 0;

          setState((){
          });
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
            height: 200,
            decoration: BoxDecoration(
              gradient: LinearGradient(
              begin: Alignment(0.0, 1.3),
              end: Alignment(0.9, 0.7),
              colors: [const Color(0xffec828c), const Color(0xfff6a04f)])
            ) 
          ),
          Container(
            margin: EdgeInsets.only(top: 30.0),
            width: MediaQuery.of(context).size.width,
            child: Column(
              children: <Widget>[
                Text(
                  "Allocated Shifts",
                  style: const TextStyle(
                      color:  Colors.white,
                      fontWeight: FontWeight.w400,
                      fontFamily: "Gotham",
                      fontStyle:  FontStyle.normal,
                      fontSize: 30.0
                  ),
                  textAlign: TextAlign.center                
                ),
                SizedBox(height: 30),
                (shiftRotationList.length>0) ?  periodRow() :
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
            )
          )
        ],
      );
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

    headingTag(title) {
      return Container(
          margin: EdgeInsets.only(right: 130 , left: 0, top: 10.0),
          alignment: Alignment.center,
          child: Text(
              title,
              style: const TextStyle(
                  color:  const Color(0xffffffff),
                  fontWeight: FontWeight.w400,
                  fontFamily: "Gotham",
                  fontStyle:  FontStyle.normal,
                  fontSize: 20.5
              ),
              textAlign: TextAlign.left
          ),
          width: 160,
          height: 45,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.only(topRight :  Radius.circular(25) , bottomRight:  Radius.circular(25)),
              gradient: LinearGradient(
                  begin: Alignment(0, 1.9),
                  end: Alignment(0.6, 0.2),
                  colors: [const Color(0xffec828c), const Color(0xfff6a04f)])
          )
      );
    }

    tileIcon(type) {
      switch(type) {
        case "Building": 
          return Image.asset("images/building.png");
        case "Start Time":
        case "End Time":
          return Image.asset("images/clock.png", color: Color(0xfff6a04f), scale: 1.5);
        default: 
          return Icon(Icons.image); 
      }
    }

    var cardBoxStyle = BoxDecoration(
      borderRadius: BorderRadius.all(
          Radius.circular(12) 
      ),
      border: Border.all(
        color: Colors.white,
        width: 2
      ),
      boxShadow: [BoxShadow(
          color: Colors.grey[200],
          blurRadius: 6,
      )],
    );

    textCard(title, text) {
      return Container(
        margin: EdgeInsets.only(top: 6.0, left: 6.0, right: 6.0),
        height: 100,
        // width: 40,
        decoration: cardBoxStyle,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Container(
                  width: 60.0,
                  height: 70.0,
                  child: tileIcon(title)
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(title),
                    SizedBox(height: 15.0),
                    Text(text, style: TextStyle(
                      fontSize: 20.0,
                      fontFamily: "Gotham",
                    ),)
                  ],
                )
              ],
            )
          ],
        ),
      );
    }

    buttonCard(type , allocatedShift) {
      var child;
      switch(type) {
        case "Mark Attendance": 
            child = GestureDetector(
              onTap: (){markAttendanceDialog(displayedDate , selectedShiftRotation.id ,  allocatedShift);},
              child: Container(
                margin: EdgeInsets.only(right: 20.0, left: 20.0),
                alignment: Alignment.center,
                child: FittedBox(
                  child: Text(
                      type,
                      style: const TextStyle(
                          color:  const Color(0xffffffff),
                          fontWeight: FontWeight.w400,
                          fontFamily: "Gotham",
                          fontStyle:  FontStyle.normal,
                          fontSize: 17.5
                      ),
                      textAlign: TextAlign.left
                  ),
                ),
                height: 45,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Color(0xfff6a050)
                )
          ),
            );
          break;
        case "Check Request Swap":
          child = Center(
            child: GestureDetector(
              onTap: (){checkRequestSwap(displayedDate , allocatedShift);},
              child: Text("Check Request\nSwap", style: TextStyle(
                fontSize: 18.0,
                ),
                textAlign: TextAlign.center,
              ),
            )
          );
          break;
        case "Request Swap": 
          child = Column(
            children: <Widget>[
              GestureDetector(
                onTap: (){requestSwapDialog(displayedDate , allocatedShift , selectedShiftRotation.id);},
                child: Container(
                    margin: EdgeInsets.only(right: 20.0, left: 20.0, top: 10.0),
                    alignment: Alignment.center,
                    child: FittedBox(
                      child: Text(
                          "Request Swap",
                          style: const TextStyle(
                              color:  const Color(0xffffffff),
                              fontWeight: FontWeight.w400,
                              fontFamily: "Gotham",
                              fontStyle:  FontStyle.normal,
                              fontSize: 12
                          ),
                          textAlign: TextAlign.left
                      )
                    ),
                    height: 30,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Color(0xffec838a)
                    )
                ),
              ),
              GestureDetector(
                onTap: (){
                  showMarkUnAvailableDialog(displayedDate , selectedShiftRotation.id ,  allocatedShift.shift.id);
                },
                child: Container(
                    margin: EdgeInsets.only(right: 20.0, left: 20.0, top: 10.0),
                    alignment: Alignment.center,
                    child: FittedBox(
                      child: Text(
                          "Mark Unavailable",
                          style: const TextStyle(
                              color:  const Color(0xffffffff),
                              fontWeight: FontWeight.w400,
                              fontFamily: "Gotham",
                              fontStyle:  FontStyle.normal,
                              fontSize: 11
                          ),
                          textAlign: TextAlign.left
                      ),
                    ),
                    height: 30,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Color(0xffec838a)
                    )
                ),
              )
            ],
          );
          break;
      }

      return Container(
        margin: EdgeInsets.only(top: 6.0, left: 6.0, right: 6.0),
        height: 100,
        decoration: cardBoxStyle,
        child: Row(
          children: <Widget>[
            Expanded(child: child)
          ],
        )
      );
    }

    cardContent(ShiftAllocation allocatedShift) {

      var nameList = [];
      for(var build in allocatedShift.buildings) {
        nameList.add(build.name);
      }
      var startTime = DateTime.parse(allocatedShift.startTime).toLocal();
      var endTime = DateTime.parse(allocatedShift.endTime).toLocal();
      var hourFormat = new DateFormat('HH:mm');

      return Container(
        padding: EdgeInsets.all(15.0),
        child: Column(
        children: <Widget>[
            Row(
              children: <Widget>[
                Expanded( child: textCard("Building", nameList.join(","))),
              ],
            ),
            Row(
              children: <Widget>[
                Expanded( child: textCard("Start Time", hourFormat.format(startTime))),
                Expanded( child: textCard("End Time", hourFormat.format(endTime))),
              ],
            ),
            (isAvailableSwap) ?
            Row(
              children: <Widget>[
                Expanded( child: buttonCard("Request Swap" , allocatedShift)),
                Expanded( child: buttonCard("Check Request Swap" , allocatedShift)),
              ],
            )
                : Container(),
            (isToday) ?
            Row(
              children: <Widget>[
                Expanded(child: buttonCard("Mark Attendance" , allocatedShift))
              ],
            )
                : Container()
          ],
        ),
      );
    }

    listCard(ShiftAllocation allocatedShift) {
      return Container(
          // margin: EdgeInsets.only(bottom: 20 , left: 10 , right: 10),
          child: Card(
            elevation: 4.0,
            shadowColor: Colors.white,
            child: Padding(
              padding: const EdgeInsets.only(top : 10.0 , bottom: 10.0),
              child: ListTileTheme(
                contentPadding: EdgeInsets.all(0),
                child: ExpansionTile(
                  backgroundColor:Colors.white,
                  trailing: Image.asset('images/bottomicon.webp' , scale: 4,),
                  title: headingTag(allocatedShift.shift.name), // To  pass title
                  children: <Widget>[
                    cardContent(allocatedShift)
                  ],
                ),
              ),
            ),
          ),
        );
    }

    return Scaffold(
        backgroundColor: Colors.white,
        resizeToAvoidBottomPadding: true,
        appBar: BaseAppBar.getAppBar("Allocated \nShifts"),
        endDrawer: Drawer(
          child: DrawerElements.getDrawer('allocated shift', context, widget.userRole , widget.mainCtx , widget.currentUser),
        ),
        body : (isLoading) ? Loader.getLoader() : SafeArea(
          child: ListView(
            children: <Widget>[
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  header(),
                  SizedBox(height: 20.0),
                  (shiftRotationList.length > 0) ? dateRow() : Container(),
                  SizedBox(height: 20.0),
                  (isListLoading) ? 
                  Loader.getListLoader(context) : 
                    (allocatedShiftList.length > 0) ?
                    Container(
                      padding: EdgeInsets.all(25.0),
                      child: ListView.builder(
                        shrinkWrap:  true,
                        physics: ClampingScrollPhysics(),
                        itemCount: allocatedShiftList.length,
                        itemBuilder: (BuildContext context, int index) {
                          return listCard(allocatedShiftList[index]);
                        }
                      ),
                    ) : Container(
                      padding: EdgeInsets.only(top: 30.0),
                      child: Text("No Records!"),
                    )
                ],
              ),
            ],
          ),
        )
    );
  }



  openShiftSwapDropDown()
  {
    DropdownButtonHideUnderline(
      child: Container(
        margin: EdgeInsets.only(left: 5 , right: 5),
        child: DropdownButton(
          hint: Text('Select'),
          value: _selectedLocation,
          onChanged: (newValue) {
            setState(() {
              _selectedLocation = newValue;
              if(_selectedLocation != null)
                   showActionMarkButtons = true;
              if(newValue == "Other")
                   showMarkTextLayout = true;
              else
                   showMarkTextLayout = false;
            });
          },
          items: _shiftsList.map((location) {
            return DropdownMenuItem(
              child: new Text(location),
              value: location,
            );
          }).toList(),
        ),
      ),
    );
  }


  void markAttendanceDialog(DateTime formattedDate , String rotationId , ShiftAllocation allocatedShift)
  {
    var formatter = new DateFormat('yyyy-MM-dd');
    String displayedDate = formatter.format(formattedDate);
       showDialog(
        context: context,
        builder: (BuildContext context)
        {
          return MarkAttendance(displayedDate , rotationId ,  allocatedShift);
        });

       getShiftAllocation();

  }


  void checkRequestSwap(DateTime displayedDate , ShiftAllocation allocatedShift) async
  {
    var res = await showDialog(
        context: context,
        builder: (BuildContext context)
        {
          return CheckRequestSwapPopup(displayedDate , allocatedShift);

        });


    getShiftAllocation();

  }



  void requestSwapDialog(DateTime formattedDate , ShiftAllocation allocatedShift, String shiftRotationId)
  {
    showDialog(
        context: context,
        builder: (BuildContext context)
    {
      return RequestSwap(formattedDate , allocatedShift , shiftRotationId);
    });
  }


  void showMarkUnAvailableDialog(DateTime formattedDate , String rotationId , String shiftId)
  {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return (MediaQuery.of(context).orientation == Orientation.portrait) ?
          MarkUnavailable(formattedDate , rotationId ,  shiftId) :
          ListView(
            children: <Widget>[
              MarkUnavailable(formattedDate , rotationId ,  shiftId)
            ],
          );
        });
  }
}


