import 'package:flutter/material.dart';
import 'package:nowyoucan/model/incident.model.dart';
import 'package:nowyoucan/model/qualityInterval.dart';
import 'package:nowyoucan/service/quality_service.dart';
import 'package:nowyoucan/service/user.dart';
import 'package:nowyoucan/ui/popUps/create_quality_check.dart';
import 'package:nowyoucan/ui/widgets/app_bar.dart';
import 'package:nowyoucan/ui/widgets/loader.dart';
import 'package:nowyoucan/ui/widgets/navigation_drawer_elements.dart';
import 'package:multiselectable_dropdown/multiselectable_dropdown.dart';
import 'package:intl/intl.dart';
import 'package:nowyoucan/model/floor.model.dart';
import 'package:nowyoucan/model/suite.model.dart';

class QualityFilterScreen extends StatefulWidget {
  var mainCtx, userRole, currentUser;
  Map<String, dynamic> dataObject;

  QualityFilterScreen(
    this.dataObject,
    this.mainCtx,
    this.userRole,
    this.currentUser,
  );

  @override
  _QualityFilterScreenState createState() => _QualityFilterScreenState();
}

class _QualityFilterScreenState extends State<QualityFilterScreen> {
  var selectedFilteredData;
  var _completedReviewList = [];
  var _inProgressList = [];
  String _selectedCompletedReview ;
  var _selectedInProgressReview;
  int selectedIndex = 0;
  bool isLoading = true;
  var buildingList;
  var formatter;

  List<QualityInterval> inProgressInterval, completedInterval;
  QualityInterval selectedReviewInterval;
  List<String> categoriesList = [], floorList = [], suiteList = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    selectedFilteredData = null;
    _selectedInProgressReview = null;
    _selectedCompletedReview = null;
    selectedReviewInterval = widget.dataObject["selectedReviewInterval"];

    buildingList = widget.dataObject["buildingList"];
    selectedIndex = widget.dataObject["selectedBuildingIndex"];



    formatter = new DateFormat('MMM d, yyyy');
    completedInterval = widget.dataObject["completedList"];
    completedInterval.forEach((element) {
      _completedReviewList.add(element);
    });

    inProgressInterval = widget.dataObject["inProgressList"];

    inProgressInterval.forEach((element) {
      _inProgressList.add(element);
    });
    if (selectedReviewInterval != null) {
      if (selectedReviewInterval.floor != null)
        selectedReviewInterval.floor.forEach((element) {
          floorList.add(element.floorAlias + ' (${element.floorNumber})');
        });

      if (selectedReviewInterval.suite != null)
        selectedReviewInterval.suite.forEach((element) {
          suiteList.add(
              "Suite " + element.suiteNo + ', Floor ${element.floorAlias}');
        });
      if (selectedReviewInterval.categories != null)
        selectedReviewInterval.categories.forEach((element) {
          categoriesList.add(element.name);
        });
    }


    getData();



  }


  getData() async
  {
    InProgressAndCompleted res =
        await QualityService.getReviewIntervalList(
        buildingList[selectedIndex]["_id"]);

    setDropDownsData(res);
  }

  deleteReviewInterval(reviewIntervalId) async
  {
    isLoading = true;
    setState(() {
    });
    var res = await QualityService.discardReviewInterval(reviewIntervalId);
    return res;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomPadding: true,
      appBar: BaseAppBar.getAppBar("\nQuality Filter"),
      endDrawer: Drawer(
        child: DrawerElements.getDrawer('quality check', context,
            widget.userRole, widget.mainCtx, widget.currentUser),
      ),
      body: ListView(
        children: <Widget>[
          createBuildingHeader(),
          (!isLoading) ? createQualityCheck() : Loader.getListLoader(context)
        ],
      ),
    );
  }

  createBuildingHeader() {
    return Stack(
      children: <Widget>[
        Container(
            // width: MediaQuery.of(context).size.width - 40, // Remove if client says 
            // height: MediaQuery.of(context).size.height * (1/5),
            height: 200,
            decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xffec828c),
                    blurRadius: 10,
                  )
                ],
                // borderRadius: BorderRadius.only(bottomRight: Radius.circular(100)), // Remove if client says 
                gradient: LinearGradient(
                    begin: Alignment(0.0, 1.3),
                    end: Alignment(0.9, 0.7),
                    colors: [
                  const Color(0xffec828c),
                  const Color(0xfff6a04f)
                ]))),
        Container(
          alignment: Alignment.center,
          // width: MediaQuery.of(context).size.width - 40, // Remove if client says 
          height: 200,
          child: buildingListLayout(),
        ),
      ],
    );
  }

  createQualityCheck() {
    return Column(
      children: <Widget>[
        Container(
          margin: EdgeInsets.only(left: 20, right: 20, top: 40),
          child: Column(
            children: <Widget>[
              buildCreateLayout(),
              SizedBox(
                height: 30,
              ),
              buildCompleteReviewDropDown(
                  "Completed Reviews", Icons.arrow_drop_down),
              SizedBox(
                height: 20,
              ),
              buildInProgressReviewDropDown(
                  "In Progress Reviews", Icons.arrow_drop_down),
              SizedBox(height: 20),
            ],
          ),
        ),
        (selectedReviewInterval != null) ? infoCard() : Container()
      ],
    );
  }

  _displayDialog(BuildContext context, type, List list) async {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Selected " + type),
            content: Container(
              width: MediaQuery.of(context).size.width - 200,
              height: MediaQuery.of(context).size.height - 700,
              child: ListView.builder(
                  itemCount: list.length,
                  itemBuilder: (BuildContext buildingContext, int index) {
                    return Container(
                      alignment: Alignment.center,
                      height: 50,
                      margin: EdgeInsets.only(top: 3, bottom: 3),
                      child: Text(list[index]),
                      decoration: BoxDecoration(
                          border: Border.all(width: 2, color: Colors.grey[100]),
                          borderRadius: BorderRadius.circular(5)),
                    );
                  }),
            ),
            actions: <Widget>[
              new FlatButton(
                child: new Text('Close'),
                onPressed: () {
                  Navigator.pop(context);
                },
              )
            ],
          );
        });
  }

  infoCard() {
    selectedListView(List<String> list) {
      return Container(
        alignment: Alignment.center,
        // width: 150,
        width: MediaQuery.of(context).size.width / 4,
        height: 25,
        child: list.length > 0
            ? ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: list.length >= 3 ? 3 : list.length,
                itemBuilder: (BuildContext buildContext, int index) {
                  return Container(
                    alignment: Alignment.center,
                    margin: EdgeInsets.all(2),
                    padding: EdgeInsets.all(2),
                    child: Text(
                      list[index],
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    decoration: BoxDecoration(
                        color: Colors.grey[400],
                        borderRadius: BorderRadius.all(Radius.circular(10))),
                  );
                })
            : FittedBox(
                child: Text("None selected!"),
              ),
      );
    }

    dropDown(type, list) {
      return GestureDetector(
        onTap: () {
          return list.length > 0 ? _displayDialog(context, type, list) : null;
        },
        child: Container(
          alignment: Alignment.center,
          width: MediaQuery.of(context).size.width,
          height: 40,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              // Text(type),
              selectedListView(list),
              SizedBox(width: 10),
              Icon(
                Icons.arrow_drop_down,
                color: Colors.black,
              )
            ],
          ),
          decoration: BoxDecoration(
              border: Border.all(width: 2, color: Colors.grey),
              borderRadius: BorderRadius.circular(5)),
        ),
      );
    }

    return Stack(
      children: <Widget>[
        Container(
          margin: EdgeInsets.only(left: 50, top: 30),
          padding: EdgeInsets.only(left: 50, top: 40),
          child: Column(children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      SizedBox(height: 60),
                      Text("Intial Date", style: TextStyle(fontSize: 15)),
                      Text(
                          formatter.format(DateTime.parse(
                              selectedReviewInterval.startDate.toString())),
                          style: TextStyle(
                              fontSize: 19, fontWeight: FontWeight.bold)),
                      SizedBox(height: 20),
                      Text("Period Length", style: TextStyle(fontSize: 15)),
                      Text(selectedReviewInterval.frequency,
                          style: TextStyle(
                              fontSize: 19, fontWeight: FontWeight.bold)),
                      SizedBox(height: 20),
                      GestureDetector(
                        onTap: () async {
                          await deleteReviewInterval(selectedReviewInterval.id);

                          Navigator.pop(context , "deleted");

                        },
                        child: Container(
                          alignment: Alignment.center,
                          width: MediaQuery.of(context).size.width / 4,
                          height: 40,
                          child: FittedBox(
                            child: Text("Discard", style: TextStyle(
                            color: Colors.white,
                            // fontWeight: FontWeight.bold,
                            // fontSize: 25
                            ),
                          )),
                          decoration: BoxDecoration(
                            color: const Color(0xffec828c),
                            borderRadius: BorderRadius.all(Radius.circular(100))
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                // SizedBox(width: 10),
                Expanded(
                    child: Column(
                  // mainAxisAlignment: MainAxisAlignment.start,
                         crossAxisAlignment: CrossAxisAlignment.start,
                         children: <Widget>[
                           SizedBox(height: 30),
                           Text(
                             "Floor",
                              style: TextStyle(
                               fontSize: 15,
                             ),
                           ),
                           dropDown("Floor", floorList),
                           SizedBox(height: 20),
                           Text("Suite", style: TextStyle(fontSize: 15)),
                           dropDown("Suite", suiteList),
                           SizedBox(height: 20),
                           Text("Category", style: TextStyle(fontSize: 15)),
                           dropDown("Category", categoriesList)
                  ],
                ))
              ],
            ),
            SizedBox(height: 10),
          ]),
          height: MediaQuery.of(context).size.height / (2.8),
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.grey[400],
                  blurRadius: 10,
                )
              ],
              borderRadius: BorderRadius.only(topLeft: Radius.circular(100)),
              color: Colors.grey[200]),
        ),
        Container(
            child: Text(
              selectedReviewInterval.name,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20, color: Colors.white),
            ),
            height: 60,
            padding: EdgeInsets.only(top: 15),
            margin: EdgeInsets.only(left: 100),
            width: MediaQuery.of(context).size.width - 100,
            decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey[400],
                    blurRadius: 10,
                  )
                ],
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(100),
                    bottomLeft: Radius.circular(100)),
                // borderRadius:BorderRadius.circular(100),
                // color: Colors.white
                gradient: LinearGradient(
                    begin: Alignment(0.0, 1.3),
                    end: Alignment(0.5, 0.7),
                    colors: [
                      const Color(0xffec828c),
                      const Color(0xfff6a04f)
                    ])))
      ],
    );
  }

  buildCompleteReviewDropDown(String s, var arrow_drop_down) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
            margin: EdgeInsets.only(top: 10, left: 20, right: 20),
            child: Text(
              s,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            )),
        SizedBox(
          height: 5,
        ),
        Container(
          child: DropdownButtonHideUnderline(
            child: DropdownButton(
              icon: Icon(
                arrow_drop_down,
                size: 27,
                color: Colors.black,
              ),
              isExpanded: true,
              hint: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  s,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              // Not necessary for Option 1
              value: (_selectedCompletedReview != null)
                  ? _selectedCompletedReview
                  : null,
              onChanged: (newValue) {
                setState(() {
                  _selectedCompletedReview = newValue;
                });

                sendDataToMainList();
              },
              items: _completedReviewList.map((location) {
                return DropdownMenuItem(
                  child: Padding(
                      padding: EdgeInsets.all(8),
                      child: Text(location.name.toString(), overflow: TextOverflow.ellipsis)),
                  value: location,
                );
              }).toList(),
            ),
          ),
          height: 50,
          margin: EdgeInsets.only(top: 10, left: 20, right: 20),
          decoration: BoxDecoration(
              border: Border.all(width: 1, color: Colors.black),
              borderRadius: BorderRadius.circular(5)),
        ),
      ],
    );
  }

  buildInProgressReviewDropDown(String s, var arrow_drop_down) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
            margin: EdgeInsets.only(top: 10, left: 20, right: 20),
            child: Text(
              s,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            )),
        SizedBox(
          height: 5,
        ),
        Container(
          child: DropdownButtonHideUnderline(
            child: DropdownButton(
              icon: Icon(
                arrow_drop_down,
                size: 27,
                color: Colors.black,
              ),
              isExpanded: true,
              hint: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  s,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              // Not necessary for Option 1
              value: (_selectedInProgressReview != null)
                  ? _selectedInProgressReview
                  : null,
              onChanged: (newValue) {
                setState(() {
                  _selectedInProgressReview = newValue;
                });

                sendDataToMainList();
              },
              items: _inProgressList.map((location) {
                return DropdownMenuItem(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(location.name.toString(), overflow: TextOverflow.ellipsis),
                  ),
                  value: location,
                );
              }).toList(),
            ),
          ),
          height: 50,
          margin: EdgeInsets.only(top: 10, left: 20, right: 20),
          decoration: BoxDecoration(
              border: Border.all(width: 1, color: Colors.black),
              borderRadius: BorderRadius.circular(5)),
        ),
      ],
    );
  }

  buildCreateLayout() {
    return GestureDetector(
      onTap: ()  async {
       var res = await showCreatePopup();
       if(res=="done")
       Navigator.pop(context, "done");
      },
      child: Container(
        alignment: Alignment.center,
        height: 50,
        child: Text(
          'Create Filter',
          style: TextStyle(fontSize: 21, color: Colors.white),
        ),
        margin: EdgeInsets.only(top: 10, left: 20, right: 20),
        decoration: BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment(0, 1.9),
                end: Alignment(0.6, 0.2),
                colors: [const Color(0xffec828c), const Color(0xfff6a04f)]),
            color: Colors.deepOrangeAccent,
            boxShadow: [BoxShadow(color: Colors.grey, offset: Offset(2, 2))],
            borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

   showCreatePopup() async {
    var response = await showDialog(
        context: context,
        builder: (BuildContext context) {
          return CreateQualityCheck();
        });

    return response;
  }

  buildingListLayout() {
    return ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: buildingList.length,
        itemBuilder: (BuildContext ctx, int index) {
          return GestureDetector(
            onTap: () async {
              selectedIndex = index;
              isLoading = true;
              setState(() {});

             getData();

            },
            child: Container(
              margin: EdgeInsets.only(top: 60, left: 10, bottom: 70),
              child: Card(
                elevation: 6,
                shadowColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                child: Center(
                  child: Container(
                    height: (selectedIndex == (index)) ? 70 : 30,
                    width: MediaQuery.of(context).size.width * (1 / 3.1),
                    child: Center(
                      child: Text(
                        buildingList[index]["name"],
                        style: TextStyle(
                            fontSize: (selectedIndex == (index)) ? 22 : 17,
                            color: (selectedIndex == (index))
                                ? const Color(0xfff6a04f)
                                : const Color(0xffb3b3b3),
                            fontWeight: (selectedIndex == (index))
                                ? FontWeight.bold
                                : null),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        });
  }

  setDropDownsData(InProgressAndCompleted res) {
    _completedReviewList.clear();
    _inProgressList.clear();

    inProgressInterval.clear();
    completedInterval.clear();

    _selectedInProgressReview = null;
    _selectedCompletedReview = null;

    res.inProgress.forEach((element) {
      inProgressInterval.add(element);
    });

    res.completed.forEach((element) {
      completedInterval.add(element);
    });

    res.inProgress.forEach((element) {
      _inProgressList.add(element);
    });

    res.completed.forEach((element) {
      _completedReviewList.add(element);
    });

    isLoading = false;
    setState(() {});
  }

  void sendDataToMainList() {
    selectedFilteredData = {
      "selectedBuilding": buildingList[selectedIndex],
      "inprogressList":
          (inProgressInterval.length > 0) ? inProgressInterval : "",
      "completedList": (completedInterval.length > 0) ? completedInterval : "",
      "_selectedCompletedReview": (_selectedCompletedReview != null)
          ? completedInterval[
              _completedReviewList.indexOf(_selectedCompletedReview)]
          : "",
      "_selectedInProgressReview": (_selectedInProgressReview != null)
          ? inProgressInterval[
              _inProgressList.indexOf(_selectedInProgressReview)]
          : ""
    };
    Navigator.pop(context, selectedFilteredData);
  }
}
