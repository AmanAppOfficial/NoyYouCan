import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/services.dart';
import 'package:nowyoucan/service/auth.dart';
import 'package:nowyoucan/service/incident.service.dart';
import 'package:nowyoucan/service/quality_service.dart';
import 'package:nowyoucan/service/requestSwap.service.dart';
import 'package:nowyoucan/service/user.dart';
import 'package:nowyoucan/ui/screens/allocated_shift_screen.dart';
import 'package:nowyoucan/ui/screens/assigned_task_screen.dart';
import 'package:nowyoucan/ui/screens/available_shift_screen.dart';
import 'package:nowyoucan/ui/screens/concave_dep.dart';
import 'package:nowyoucan/ui/screens/missing_task_screen.dart';
import 'package:nowyoucan/ui/screens/quality_check_data_screen.dart';
import 'package:nowyoucan/ui/screens/recent_comment_screen.dart';
import 'package:nowyoucan/ui/screens/requested_swaps_screen.dart';
import 'package:nowyoucan/ui/widgets/app_bar.dart';
import 'package:nowyoucan/ui/widgets/navigation_drawer_elements.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:nowyoucan/service/scheduledTasks.dart';
import 'dart:async';
import 'package:intl/intl.dart';


class PendingTasksSeries
{
  String buildingName;
  int numbers;

  PendingTasksSeries({this.buildingName , this.numbers});
}

class DashboardScreen extends StatefulWidget {
 var userRole;
 var ctx;
 var currentUser;
  DashboardScreen(this.ctx , this.userRole, this.currentUser);
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<PendingTasksSeries> data = [];
  var qrInProgressCount=0;
  var todayTaskCount = {
    "total": 0,
    "completed": 0,
    "remaining": 0
  };
  var missedTaskCount = {
    "yesterday": 0,
    "lastWeek": 0
  };

  var recentCommentCount = {
    "today": 0,
    "yesterday": 0,
    "lastWeek": 0
  };

  var requestSwapCount = {
    "today": 0,
    "yesterday": 0,
    "lastWeek": 0
  };

  bool isAvailableTrue = false , isAllocatedTrue = false;

  Timer timer;

  @override
  void initState() {
    super.initState();


    (() async {
      widget.currentUser = await User.me();

      if(widget.currentUser["tradeExpert"]["userControl"]["availableShift"] != null)
      {
        if(widget.currentUser["tradeExpert"]["userControl"]["availableShift"] == true)
        {
          isAvailableTrue = true;
        }
      }

      if(widget.currentUser["tradeExpert"]["userControl"]["allocatedShift"] != null)
      {
        if(widget.currentUser["tradeExpert"]["userControl"]["allocatedShift"] == true)
        {
          isAllocatedTrue = true;
        }

      }

      refresh();
      setState(() {
      });

    })();

  }

  refreshLater() {
    timer = new Timer(new Duration(seconds: 30), () {
      refresh();
    });
  }

  @override
  void dispose() {
    print("disposed");
    timer.cancel();
    // WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  refresh() {
  
    debugPrint("refreshing DH");
    getIncidentGraph();
    if(widget.userRole == "Trade Expert Company") {
      getMissedTaskCount();
      getQrInprogressCount();
      getRecentCommentCount();
    } else {
      getTaskCount();
      getRequestSwapCount();
    }
    refreshLater();

  }

  getQrInprogressCount() async
  {
    try
        {
          var res = await QualityService.getReviewInprogressCount();
          qrInProgressCount = res["Inprogress"];
        }
        catch(e)
    {}
  }

  getTaskCount() async {
    try {
      DateTime now = new DateTime.now().toUtc();
      var formatter = new DateFormat('yyyy-MM-dd');
      String formattedDate = formatter.format(now);
      var res = await  ScheduledTaskService.getTaskCount(formattedDate);
      if(res != null) {
        todayTaskCount["total"] = int.parse(res[0]["total"].toString());
        todayTaskCount["completed"] = int.parse(res[0]["completed"].toString());
        todayTaskCount["remaining"] = int.parse(res[0]["total"].toString()) - int.parse(res[0]["completed"].toString());
      }
      setState(() {
      });
    } catch(error) {
      print("@getTaskCount");
      print(error);
    }
  }

  getRequestSwapCount() async {
    try {
      var res = await  RequestSwapService.getSwapCount();
      if(res != null) {
        requestSwapCount["today"] = int.parse(res[0]["today"].toString());
        requestSwapCount["yesterday"] = int.parse(res[0]["yesterday"].toString());
        requestSwapCount["lastWeek"] = int.parse(res[0]["lastWeek"].toString());
      }
      setState(() {
      });
    } catch(error) {
      print("@getTaskCount");
      print(error);
    }
  }

  getMissedTaskCount() async {
    try {
      var res = await ScheduledTaskService.getMissedTaskCount();
      if(res.length > 0) {
        missedTaskCount["yesterday"] = res[0]["yesterday"];
        missedTaskCount["lastWeek"] = res[0]["lastWeek"];
      }
      setState(() {
      });
    } catch(error) {
      print("@getMissedTaskCount");
      print(error);
    }
  }

  Future<bool> _onWillPop() async {
    SystemNavigator.pop();
    return false;
  }

  getIncidentGraph() async {
    try {
      var response = await IncidentService.progressGraph();
      data = [];
      response.forEach((element) { 
        print(int.parse(element["inProgressCount"].toString()));
        // print(element["building"]["name"] + " " + element["inProgressCount"]);
        data.add(
          PendingTasksSeries(
            buildingName: element["building"]["name"], 
            numbers: int.parse(element["inProgressCount"].toString()
            )
          )
        );
      });      
      // print(data);
      setState(() {
      });
    } catch(error) {
      print(error);
    }
  }


  getRecentCommentCount() async {
    try {
      var res = await ScheduledTaskService.getRecentTaskCount();
      if(res.length > 0) {
        recentCommentCount["today"] = res[0]["today"];
        recentCommentCount["yesterday"] = res[0]["yesterday"];
        recentCommentCount["lastWeek"] = res[0]["lastWeek"];
        // print(recentCommentCount);
      }
      setState(() {
      });
    } catch(error) {
      print("@getRecentCommentCount");
      print(error);
    }
  }
 

  @override
  Widget build(BuildContext context) {
    var style = TextStyle(fontSize: 17 , fontWeight: FontWeight.bold , color: Colors.black);

    List<charts.Series<PendingTasksSeries , String>> series = [
      charts.Series(
        id: "Pending Tasks",
        data:  data,
        domainFn: (PendingTasksSeries series , _) => series.buildingName,
        measureFn: (PendingTasksSeries series , _) => series.numbers,
        colorFn: (PendingTasksSeries series , _) {
          if(_ & 1 == 1) {
            return charts.ColorUtil.fromDartColor(Color(0xffec828c));
          } else {
            return charts.ColorUtil.fromDartColor(Color(0xfff6a04f));
          }
        },

      )
    ];


    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: Colors.white,
        resizeToAvoidBottomPadding: true,
        appBar: BaseAppBar.getAppBar("Dashboard"),
        endDrawer: Drawer(
          child: DrawerElements.getDrawer('dashboard' , context, widget.userRole , widget.ctx , widget.currentUser),
        ),
        // bottomNavigationBar: ,
        body: SafeArea(
          child: ListView(
            children: <Widget>[
              buildChart(style , series),
                (widget.userRole  == "Trade Expert Company")
                      ? companyDashboard(style): memberDashboard(style)
            ],
          ),
        ),
      ),
    );
  }

  buildChart(TextStyle style ,   List<charts.Series<PendingTasksSeries , String>> series)
  {
    return Column(
      children: <Widget>[
        SizedBox(height: MediaQuery.of(context).size.height * 0.05),
        buildText('In Progress Incidents' , style),
        Container(
          margin: EdgeInsets.only(top: 20 , bottom: 20.0, left: 20, right: 20),
          padding: EdgeInsets.all(10.0),
          height:320,
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(10.0)),
            boxShadow: [BoxShadow(
              color: Colors.grey[300],
              blurRadius: 15,
            )],
          ),
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: <Widget>[
//                      SizedBox(height: 10,),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Container(
                  width: MediaQuery.of(context).size.width - 75,
                  child: charts.BarChart(
                    series ,
                    animate: true,
                    barGroupingType: charts.BarGroupingType.grouped,
                    defaultRenderer: new charts.BarRendererConfig(
                        cornerStrategy: const charts.ConstCornerStrategy(10)
                    ),
                    domainAxis: charts.OrdinalAxisSpec(
                      renderSpec: charts.SmallTickRendererSpec(labelRotation: 50),
                    ),),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: MediaQuery.of(context).size.height * 0.05)
      ],
    );
  }



  missedTasks(TextStyle style)
  {
    return Container(
      margin: EdgeInsets.only(left: 20 , right: 20),
      child: Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            buildText('Scheduled Tasks', style),
            SizedBox(height: 20,),
            missedTasksCard(),
          ],
        ),
      ),
    );
  }

  buildText(String s , TextStyle style)
  {
    return Container(
        margin: EdgeInsets.only(left: 30 , top: 0),
        alignment: Alignment.centerLeft,
        child: Text(s, style:  style));
  }

  missedTasksCard()
  {
    return GestureDetector(
      onTap: (){
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => MissingTaskScreen(widget.ctx , widget.userRole , widget.currentUser)),
        );
      },
      child: Container(
        child: Row(
          children: <Widget>[
            SizedBox(width: 15,),
            Text("Missed Tasks" , style: TextStyle(color: Colors.white , fontSize: 16),),
            SizedBox(width: 10,),
            // buildElement('Today' , 7),
            buildElement('Yesterday' , missedTaskCount["yesterday"]),
            buildElement('Last Week' , missedTaskCount["lastWeek"]),
          ],
        ),
        height: 100,
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
            boxShadow: [BoxShadow(
              color: Color(0xffec828c),
              blurRadius: 10,
            )],
            borderRadius:BorderRadius.circular(10),
            gradient: LinearGradient(
                begin: Alignment(0.0, 1.3),
                end: Alignment(0.5, 0.7),
                colors: [
                  const Color(0xffec828c),
                  const Color(0xfff6a04f)
                ])
        ),
      ),
    );
  }

  recentCommentsCard()
  {
    return GestureDetector(
      onTap: (){
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => RecentCommentsScreen(widget.ctx, widget.userRole , widget.currentUser)),
        );
      },
      child: Container(
        child: Row(
          children: <Widget>[
            SizedBox(width: 15,),
            Text("Recent Comments" , style: TextStyle(color: Colors.white , fontSize: 12),),
            SizedBox(width: 10,),
            buildElement('Today' , recentCommentCount["today"]),
            buildElement('Yesterday' , recentCommentCount["yesterday"]),
            buildElement('Last Week' , recentCommentCount["lastWeek"]),
          ],
        ),
        height: 100,
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
            boxShadow: [BoxShadow(
              color: Color(0xffec828c),
              blurRadius: 10,
            )],
            borderRadius:BorderRadius.circular(10),
            gradient: LinearGradient(
                begin: Alignment(0.0, 1.3),
                end: Alignment(0.5, 0.7),
                colors: [
                  const Color(0xffec828c),
                  const Color(0xfff6a04f)
                ])
        ),
      ),
    );
  }

  buildElement(String text , int count)
  {
    return  Expanded(child: 
      Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(text  , style: TextStyle(
            color: Colors.white , 
            fontSize: 12),
          ),
          Container(
            
            decoration: BoxDecoration(
              // boxShadow: ,
              color: Colors.white,
              borderRadius:BorderRadius.circular(7),),
            alignment: Alignment.center,
            // child: Text("$count" , style: TextStyle(fontSize: 20),),
            child: Container(
              width: MediaQuery.of(context).size.width,
              alignment: Alignment.center,
              decoration: ConcaveDecoration(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(7)
                ), 
                colors: [Colors.grey[700], Colors.grey[300]],
                depth: 5),
              child: Text("$count" , style: TextStyle(fontSize: 20),)
            ),
            margin: EdgeInsets.all(8),
            height: 50, ),
        ],
    ));
  }

//  buildRecentComments(TextStyle style)
//  {
//    return Container(
//      margin: EdgeInsets.all(10),
//      child: Card(
//        color: const Color.fromRGBO(12, 40, 120, 1),
//        elevation: 10,
//        child: Container(
//          child: Column(
//            mainAxisAlignment: MainAxisAlignment.start,
//            crossAxisAlignment: CrossAxisAlignment.start,
//            children: <Widget>[
//              Row(
//                mainAxisAlignment: MainAxisAlignment.start,
//                children: <Widget>[
//                  Container(
//                      margin: EdgeInsets.only(left: 30 , top: 20 , bottom: 10),
//                      alignment: Alignment.centerLeft,
//                      child: Text('Recent Comments' , style:  TextStyle(fontSize: 12  , color: Colors.greenAccent),)),
//                  Expanded(
//                    child: Container(
//                      alignment: Alignment.center,
//                      child: Text(
//                        '8', style: TextStyle(fontSize: 20 , fontWeight: FontWeight.bold),
//                      ),
//                      margin: EdgeInsets.all(20),
//                      width: 50,
//                      height: 50,
//                      color: Colors.white,
//                    ),
//                  ),
//                  Expanded(
//                    child: Container(
//                      alignment: Alignment.center,
//                      child: Text(
//                        '8', style: TextStyle(fontSize: 20 , fontWeight: FontWeight.bold),
//                      ),
//                      margin: EdgeInsets.all(20),
//                      width: 50,
//                      height: 50,
//                      color: Colors.white,
//                    ),
//                  ),
//                  Expanded(
//                    child: Container(
//                      alignment: Alignment.center,
//                      child: Text(
//                        '8', style: TextStyle(fontSize: 20 , fontWeight: FontWeight.bold),
//                      ),
//                      margin: EdgeInsets.all(20),
//                      width: 50,
//                      height: 50,
//                      color: Colors.white,
//                    ),
//                  )
//                ],
//              )
//            ],
//          ),
//        ),
//      ),
//    );
//  }


  companyDashboard(TextStyle style)
  {
    return Column(
      children: <Widget>[
        missedTasks(style),
        SizedBox(height: 20,),
        qualityReviewCard(),
        SizedBox(height: 20,),
        Container(
          margin: EdgeInsets.only(left: 20 , right: 20),
          child: recentCommentsCard(),
        )
      ],
    );
  }

  memberDashboard(TextStyle style)
  {
    return Column(
      children: <Widget>[
        buildTodayTasks(style),
        SizedBox(height: 20,),
        Container(
          margin: EdgeInsets.only(left: 20 , right: 20),
          child: Column(
            children: <Widget>[
              (isAllocatedTrue)  ? buildRequestedSwapsCard() : Container(),
              SizedBox(height: 15,),
              buildManageAndCheckAvailableCards()
            ],
          ),
        )
      ],
    );
  }

  buildTodayTasks(TextStyle style)
  {
    return Container(
      margin: EdgeInsets.only(left: 20 , right: 20),
      child: Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            buildText('Scheduled Tasks', style),
            SizedBox(height: 20,),
            buildTodayTasksCard(),
          ],
        ),
      ),
    );
  }

  buildTodayTasksCard()
  {
    return GestureDetector(
      onTap: (){
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => AssignedScheduledTask(widget.userRole , widget.ctx , widget.currentUser)),
        );
      },
      child: Container(
        child: Row(
          children: <Widget>[
            SizedBox(width: 15,),
            Text("Todays Tasks" , style: TextStyle(color: Colors.white , fontSize: 16),),
            SizedBox(width: 10,),
            buildElement('Total' , todayTaskCount["total"]),
            buildElement('Remaining' , todayTaskCount["remaining"]),
            buildElement('Completed' , todayTaskCount["completed"]),
          ],
        ),
        height: 100,
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
            boxShadow: [BoxShadow(
              color: Color(0xffec828c),
              blurRadius: 10,
            )],
            borderRadius:BorderRadius.circular(10),
            gradient: LinearGradient(
                begin: Alignment(0.0, 1.3),
                end: Alignment(0.5, 0.7),
                colors: [
                  const Color(0xffec828c),
                  const Color(0xfff6a04f)
                ])
        ),
      ),
    );
  }

  buildRequestedSwapsCard()
  {
    return GestureDetector(
      onTap: (){
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => RequestedSwapScreen(widget.userRole , widget.ctx , widget.currentUser)),
        );
      },
      child: Container(
        child: Row(
          children: <Widget>[
            SizedBox(width: 15,),
            Text("Requested Swaps" , style: TextStyle(color: Colors.white , fontSize: 12)),
            SizedBox(width: 10,),
            buildElement('Today' , requestSwapCount["today"]),
//            buildElement('Yesterday' , requestSwapCount["yesterday"]),
            buildElement('Future Week' , requestSwapCount["lastWeek"]),
          ],
        ),
        height: 100,
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
            boxShadow: [BoxShadow(
              color: Color(0xffec828c),
              blurRadius: 10,
            )],
            borderRadius:BorderRadius.circular(10),
            gradient: LinearGradient(
                begin: Alignment(0.0, 1.3),
                end: Alignment(0.5, 0.7),
                colors: [
                  const Color(0xffec828c),
                  const Color(0xfff6a04f)
                ])
        ),
      ),
    );
  }

  buildManageAndCheckAvailableCards()
  {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        (isAllocatedTrue) ? dataCard('Manage Shifts') : Container(),
        SizedBox(
          width: 20.0
        ),
        (isAvailableTrue) ?  dataCard('Check Availability') : Container()
      ],
    );
  }

  dataCard(String text)
  {
    return  Expanded(
      child: GestureDetector(
        onTap: (){
         if(text == "Check Availability")
           {
             Navigator.push(
               context,
               MaterialPageRoute(builder: (context) => AvailableShifts(widget.userRole , widget.ctx , widget.currentUser)),
             );
           }
         else  if(text == "Manage Shifts")
         {
           Navigator.push(
             context,
             MaterialPageRoute(builder: (context) => AllocatedShifts(widget.userRole , widget.ctx , widget.currentUser)),
           );
         }
        },
        child: Container(
          alignment: Alignment.center,
          height: 60,
          margin: EdgeInsets.only(top: 10.0),
          child: Text(text , style: TextStyle(color: Colors.white),),
          decoration: BoxDecoration(
              boxShadow: [BoxShadow(
                color: Color(0xffec828c),
                blurRadius: 10,
              )],
              borderRadius:BorderRadius.circular(8),
              gradient: LinearGradient(
                  begin: Alignment(0.0, 1.3),
                  end: Alignment(0.5, 0.7),
                  colors: [
                    const Color(0xffec828c),
                    const Color(0xfff6a04f)
                  ])
          ),),
      ),);
  }

  qualityReviewCard()
  {
    return GestureDetector(
      onTap: (){
        Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => QualityCheckDataScreen(widget.userRole , widget.ctx , widget.currentUser)));
      },
      child: Container(
        margin: EdgeInsets.only(left: 20 , right: 20),
        height: 100,
        decoration: BoxDecoration(
            boxShadow: [BoxShadow(
              color: Color(0xffec828c),
              blurRadius: 10,
            )],
            borderRadius:BorderRadius.circular(10),
            gradient: LinearGradient(
                begin: Alignment(0.0, 1.3),
                end: Alignment(0.5, 0.7),
                colors: [
                  const Color(0xffec828c),
                  const Color(0xfff6a04f)
                ])
        ),
        child: Row(
          children: <Widget>[
            SizedBox(width: 15,),
            Text("Quality Review" , style: TextStyle(color: Colors.white , fontSize: 16),),
            SizedBox(width: 10,),
            // buildElement('Today' , 7),
            buildElement('In Progress' , qrInProgressCount),
          ],
        ),
      ),
    );
  }

}
