import 'package:flutter/material.dart';
import 'package:nowyoucan/service/user.dart';
import 'package:nowyoucan/ui/screens/incident_edit_screen.dart';
import 'package:nowyoucan/ui/widgets/app_bar.dart';
import 'package:nowyoucan/ui/widgets/navigation_drawer_elements.dart';
import 'package:nowyoucan/service/incidentGraph.service.dart';
import 'package:nowyoucan/model/incident.model.dart';
import 'package:nowyoucan/ui/widgets/loader.dart';
import 'package:nowyoucan/service/incident.service.dart';
// import 'package:nowyoucan/model/incident.model.dart';
import 'package:intl/intl.dart';

class IncidentScreen extends StatefulWidget {
  String userRole;
  var mainCtx;
  var currentUser;
  
  IncidentScreen(this.userRole, this.mainCtx, this.currentUser);

  @override
  _IncidentScreenState createState() => _IncidentScreenState();
}

class _IncidentScreenState extends State<IncidentScreen> {

  IncidentCount count = new IncidentCount({
    "InProgress": 0,
    "Resolved": 0
  });
  bool isLoading = true;
  bool inProgressLoading = true;
  bool resolvedLoading = true;


  List<IncidentList> inProgressTask = [];
  //   {"severity": "LOW"}
  // ];

  List<IncidentList> resolvedTask = [];
  //   {
  //     "severity": "HIGH",
  //   },
  //   {
  //     "severity": "LOW",
  //   }
  // ];

  @override
  void initState() {
    (() async {
      widget.currentUser = await User.me();

      await getIncidentCount();
      getIncidentList("inProgress");
      getIncidentList("Resolved");

      setState(() {
      });



    })();
  }

  getIncidentCount() async {
    try {
      isLoading = true;
      setState(() {
      });
      var res = await IncidentGraphService.count();
      if(res != null) {
        count = res;
      }
      isLoading = false;
      setState(() {
      });
    } catch(error) {
      print("@getIncidentCount");
      print(error);
    }
  }

  getIncidentList(type) async {
    try {
      if (type == "inProgress") {
        inProgressLoading = true;
      }
      if (type == "Resolved") {
        resolvedLoading = true;
      }
      setState(() {
      });

      List<IncidentList> temp = await IncidentService.list(type);

      if (type == "inProgress") {
        inProgressTask = temp;
        inProgressLoading = false;
      }
      if (type == "Resolved") {
        resolvedTask = temp;
        resolvedLoading = false;
      }
      setState(() {
      });
    } catch(error) {
      print("@getIncidentCount");
      print(error);
    }
  }

  openDetails(incident) async {
    var result = await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => IncidentEditScreen(incident, widget.userRole , widget.mainCtx , widget.currentUser)),
    );
    if(result != null) {
      await getIncidentCount();
      getIncidentList("inProgress");
      getIncidentList("Resolved");
    }
  }


  
  @override
  Widget build(BuildContext context) {

    severityTag(severity) {
      var tagColor;
      var tagText;
      switch (severity) {
        case "Low":
          tagText = "Low Severity";
          tagColor = Colors.green;
          break;
        case "High":
          tagText = "High Severity";
          tagColor = Colors.red;
          break;
        case "Medium":
          tagText = "Medium Severity";
          tagColor = Colors.orange;
          break;
      }
      return Container(
          alignment: Alignment.center,
          child: Text(
            tagText,
            style: TextStyle(
                fontStyle: FontStyle.normal, color: Colors.grey[200], fontSize: 17),
          ),
          width: 160,
          height: 35,
          decoration: BoxDecoration(
              color: tagColor,
              boxShadow: [
                BoxShadow(
                    color: Colors.grey,
                    offset: Offset(0.0, 0.5),
                    blurRadius: 2.5)
              ],
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20.0),
                  bottomLeft: Radius.circular(20.0))));
    }

    detailBoxEle(String type, String text) {
      String image;
      switch (type) {
        case "Location":
          image = "images/Location.png";
          break;
        case "Floor":
          image = "images/obeject_alignment.png";
          break;
        case "Facility":
          image = "images/team.png";
          break;
        case "incidentType":
          image = "images/network.png";
          break;
        case "status":
          image = "images/doc.png";
          break;
        default:
      }

      return Stack(
        alignment: Alignment.topCenter,
        children: <Widget>[
          Container(
            height: 40,
            width: 0,
            decoration: BoxDecoration(
                border: Border.all(color: Colors.grey, width: 0.5)),
          ),
          Container(
              height: 100,
              // width: 60, // adjust it self
              margin: EdgeInsets.only(left: 12.0, right: 10.0, top: 40.0),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.0),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.grey,
                        offset: Offset(0.0, 0.0),
                        blurRadius: 2.5)
                  ]),
              child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.0),
                    color: Colors.white,
                  ),
                  child: Center(
                    child: Text(text,
                    overflow: TextOverflow.ellipsis,
                    // style: TextStyle(
                    //   fontSize: 15.0
                    // ),
                    ),
                  ))),
          Container(
            height: 40,
            width: 40,
            margin: EdgeInsets.only(top: 20.0),
            decoration: BoxDecoration(boxShadow: [
              BoxShadow(
                  color: Colors.grey, offset: Offset(0.0, 0.0), blurRadius: 2.5)
            ], color: Colors.white, shape: BoxShape.circle),
            child: Image.asset(image, scale: 2) 
          ),
        ],
      );
    }


    cardDetails(incident) {
      return Expanded(
          child: Container(
        decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(10.0),
                bottomRight: Radius.circular(10.0))),
        child: Center(
          child: GestureDetector(
            onTap: () {
              openDetails(incident);
            },
            child: Text(
              "View Details",
              style: TextStyle(color: Color(0xfff6a04f), fontSize: 20),
            ),
        )),
      ));
    }

    incidentDuration(IncidentList incident) {

      var timeMomentStr = '';

      DateTime createdAt = DateTime.parse(incident.createdAt);
      DateTime currentDate = DateTime.now();
      var diff = currentDate.difference(createdAt);

      if(diff.inSeconds <= 59) {
        timeMomentStr = "Few Seconds Ago";
      } else if (diff.inMinutes > 0 && diff.inMinutes <= 10) {
        timeMomentStr = "Few Minutes Ago";
      } else if(diff.inMinutes > 10 && diff.inMinutes <= 59) {
        timeMomentStr = diff.inMinutes.toString() +" Minutes Ago";
      } else if (diff.inHours > 0 && diff.inHours <= 24)  {
        timeMomentStr = "Few Hours Ago";
      } else if (diff.inHours > 24 && diff.inHours <= (24*3)){
        timeMomentStr = "Few Days Ago";
      } else if (diff.inHours >= (24*3) && diff.inHours <= (24*15)){
        timeMomentStr = diff.inDays.toString() + " Days Ago";
      } else {
        var formatter = new DateFormat('MMM dd, yyyy HH:mm');
        timeMomentStr = formatter.format(createdAt); 
      }
      
      return Container(
        padding: EdgeInsets.only(bottom: 20.0),
        width: (MediaQuery.of(context).size.width * 0.75) - 22.0,
        child: Center(
          child: Text(timeMomentStr),
        ),
        decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: Colors.grey, width: 1))),
      );
    }

    incidnetImage() {
      return Container(
          // height: 40,
          padding: EdgeInsets.only(top: 20.0, bottom: 15.0, left: 20.0),
          alignment: Alignment(-1.0, 0.0),
          child: Container(
            height: 50,
            width: 50,
            child: Image.asset("images/default_incident.png"),
            decoration: BoxDecoration(
                // image: new DecorationImage(
                //     image: new AssetImage("images/default_incident.png")),
                shape: BoxShape.circle),
          ));
    }

    listCard(IncidentList incident) {
      // print("-----");
      // print(incident.buildingName);

      String floorAlias;
      String facilityName;
      String incidentType;
      if(incident.facilityIncidentTypeId != null) {
        incidentType = incident.facilityIncidentTypeName;
      } else if(incident.facilityItemIncidentTypeId != null) {
        incidentType = incident.facilityItemIncidentTypeName;
      } else {
        incidentType = "Other";
      }
      if (incident.floor != null) {
        floorAlias = incident.floor.floorAlias; 
        facilityName = incident.facilityPerFloorAlias;
        // print(incident.floor.floorAlias);
      }
      if (incident.suite != null) {
        floorAlias = incident.suite.floorAlias;
        facilityName = incident.facilityPerSuiteAlias;
        // print(incident.suite.floorAlias);
      }
      // print("facilityName " + facilityName);
      // print("incidentType " + incidentType);
      return Container(
        padding: const EdgeInsets.only(
            top: 30.0, left: 30.0, right: 30.0, bottom: 10),
        child: Container(
            height: 325,
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.grey,
                  blurRadius: 20.0, // soften the shadow
                  offset: Offset(0.0, 0.0), // Move to bottom 10 Vertically
                )
              ],
              borderRadius: BorderRadius.circular(20.0),
            ),
            child: Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.0),
                  color: Colors.white),
              child: Column(
                children: <Widget>[
                  Stack(
                    children: <Widget>[
                      incidnetImage(),
                      Container(
                        padding: EdgeInsets.only(top: 20.0, bottom: 15.0),
                        alignment: Alignment(1.0, 0.0),
                        child: severityTag(incident.severity),
                      )
                    ],
                  ),
                  incidentDuration(incident),
                  Row(
                    children: <Widget>[
                      Expanded(child: detailBoxEle("Location", incident.buildingName)),
                      Expanded(child: detailBoxEle("Floor", floorAlias)),
                      Expanded(child: detailBoxEle("Facility", facilityName)),
                      Expanded(child: detailBoxEle("incidentType", incidentType)),
                      Expanded(child: detailBoxEle("status", incident.status))
                    ],
                  ),
                  SizedBox(height: 10.0),
                  cardDetails(
                      incident) // To add the gesture detector for the incident detail
                ],
              ),
            )),
      );
    }

    tabHeader(text, count1) {
      return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          // crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Container(
              child: Text(text),
              // height: MediaQuery.of(context).size.height,
            ),
            Container(
              margin: EdgeInsets.only(left: 4),
              alignment: Alignment.center,
              child: Text(count1.toString(), style: TextStyle(
                color: Colors.white,
                fontSize: 8.0
              ),),
              width: 20.0,
              height: 20.0,
              // color: Colors.white,
              decoration: BoxDecoration(
                color: Color(0xfff6a04f),

                borderRadius: BorderRadius.all(Radius.circular(10.0))
              ),
            )
          ],
        );
    }

    return Scaffold(
        backgroundColor: Colors.white,
        resizeToAvoidBottomPadding: true,
        appBar: BaseAppBar.getAppBar("INCIDENTS"),
        endDrawer: Drawer(
          child: DrawerElements.getDrawer('incident', context, widget.userRole , widget.mainCtx , widget.currentUser)
        ),
        body:(isLoading) ? Loader.getLoader() :  new DefaultTabController(
          length: 2,
          child: new Scaffold(
            appBar: new AppBar(
              // title: new Text("Smiple Tab Demo"),
              backgroundColor: Colors.white,
              automaticallyImplyLeading: false,
              title: new TabBar(
                indicatorColor: Color(0xfff6a04f),
                labelStyle: TextStyle(fontSize: 13.0),
                indicatorWeight: 4.0,
                onTap: (tab) {
                  print(tab);
                  if(tab == 1) {
                    getIncidentList("inProgress");
                  } else {
                    getIncidentList("Resolved");
                  }
                },
                tabs: <Widget>[
                  new Tab(
                    // text: "IN PROGRESS (" + count.inProgress.toString() + ")",
                    child: tabHeader("IN PROGRESS", count.inProgress),
                  ),
                  new Tab(
                    // text: "RESOLVED (" + count.resolved.toString() + ")"
                    child: tabHeader("RESOLVED", count.resolved),
                  ),
                ],
              ),
            ),
            body: new TabBarView(
              children: <Widget>[
                new Container(
                  alignment: Alignment.center,
                  child: (inProgressLoading) ? Loader.getListLoader(context) : 
                    (inProgressTask.length <= 0) ? Text("No Record Found!") : new Center(
                      child: ListView.builder(
                          padding: const EdgeInsets.only(top: 20.0),
                          itemCount: inProgressTask.length,
                          itemBuilder: (BuildContext context, int index) {
                            return listCard(inProgressTask[index]);
                          })),
                ),
                new Container(
                  alignment: Alignment.center,
                  child: (resolvedLoading) ? Loader.getListLoader(context) : 
                    (resolvedTask.length <= 0) ? Text("No Record Found!") : new Center(
                      child: ListView.builder(
                          padding: const EdgeInsets.only(top: 20.0),
                          itemCount: resolvedTask.length,
                          itemBuilder: (BuildContext context, int index) {
                            return listCard(resolvedTask[index]);
                          })),
                ),
              ],
            ),
          ),
        ));
  }
}
