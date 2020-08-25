import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:multiselectable_dropdown/multiselectable_dropdown.dart';
import 'package:nowyoucan/service/building.service.dart';
import 'package:nowyoucan/service/quality_service.dart';
import 'package:nowyoucan/ui/widgets/loader.dart';

class CreateQualityCheck extends StatefulWidget {
  @override
  _CreateQualityCheckState createState() => _CreateQualityCheckState();
}

class _CreateQualityCheckState extends State<CreateQualityCheck> {

  bool isLoading = true;
  bool iscreateLoading = false;

  var selectedFloorCount=0 , selectedCategoryCount=0 , selectedSuiteCount=0;

  var _reviewperiodLengthList = ["Day" , "Week", "Month", "FortNight"];
  String _selectedReviewPeriodLength ;
  var _selectedBuilding;

  TextEditingController _nameController = new TextEditingController();
  DateTime selectedDate;

  var buildingsList = [];

  List floorList = [
  ];


  List suiteList = [
  ];



  List facililtyCategoryList = [
  ];



  var selectedFloorList = [] , selectedCategoryList = [] , selectedSuiteList=[];



  @override
  void initState() {
    (() async {

      selectedCategoryCount = facililtyCategoryList.length;

      await getBuildingList();

      isLoading = false;
      setState(() {

      });

    })();
  }


  getBuildingList() async {
    try {
     buildingsList = await BuildingService.getBuilding();
     _selectedBuilding = buildingsList[0];


    } catch (error) {
      print("@getBuildingList Error " + error.toString());
    }
  }

  createReview(body) async
  {
    var res = await QualityService.createReviewInterval(body);

    print("created successfully");

    return res;

  }


  getFloorSuiteCategory(selectedBuildingId , selectedFrequency , startDate) async
  {
    isLoading = true;
    setState(() {
    });




    var res = await QualityService.getFloorSuiteCategory({
      "building" : selectedBuildingId,
      "frequency" : selectedFrequency,
      "startDate" : startDate
    });
    print(res.toString());

    suiteList = [];
    var floorHash = {};
    for(var suite in res["suiteList"]) {
      suite = suite["suite"];
      if(floorHash[suite["floorNumber"]] == null) {
        var newObj = {
          "floor": {
            "number": suite["floorNumber"],
            "alias": suite["floorNo"]
          },
          "list": []
        };
        suiteList.add(newObj);
        floorHash[suite["floorNumber"]] = newObj;
      }

      floorHash[suite["floorNumber"]]["list"].add(suite);
    }


    for(int i=0 ; i<suiteList.length ; i++)
      {
        print(suiteList.length);
        selectedSuiteList.add({
          "id" : i,
          "list" : []
        });


        for(int j=0 ; j<suiteList[i]["list"].length ; j++)
          {
            selectedSuiteList[i]["list"].add(true);
          }
      }

    print(selectedSuiteList.toString());

    selectedSuiteCount = suiteList.length;



    floorList = res["floorList"];
    floorList.forEach((element) {
      selectedFloorList.add(true);
    });
    selectedFloorCount = floorList.length;

    facililtyCategoryList = res["categoryList"];
    facililtyCategoryList.forEach((element) {
      selectedCategoryList.add(true);
    });
    selectedCategoryCount = facililtyCategoryList.length;



    isLoading = false;
    setState(() {
    });

  }


  @override
  Widget build(BuildContext context) {

    return  ListView(
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
                                                    "Create Filter",
                                                    style: const TextStyle(
                                                        color:  Colors.white,
                                                        fontWeight: FontWeight.bold,
                                                        fontFamily: "Gotham",
                                                        fontStyle:  FontStyle.normal,
                                                        fontSize: 22.5),
                                                    textAlign: TextAlign.center)
                                            ),
                                            GestureDetector(
                                              onTap: (){
                                                Navigator.pop(context);
                                              },
                                              child: Container(
                                                child: Image.asset(('images/whitecancelicon.png') , scale: 1.6,),
                                              ),
                                            )
                                          ],
                                        ),
                                        margin: EdgeInsets.only(left: 25 , right: 19 , top: 30),
                                      ),
                                      Container(
                                          child: details(),

                                          margin: EdgeInsets.only(top: 20 , bottom: 40),
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
        ),
      ],
    );
  }

  details()
  {

    return   (!isLoading) ?  (iscreateLoading) ?  Container(height: 400,
      child: SpinKitCircle(
        size: 150,
        color: Colors.orangeAccent,
      ),
    ) :Stack(
      children: <Widget>[
        Container(
            alignment: Alignment.center,
            margin: EdgeInsets.only(top: 20 , bottom: 10),
            child: Container(
              child: Column(
                children: <Widget>[
                  buildingListView(),
                  SizedBox(height: 20,),
                  buildNameBox(),
                  SizedBox(height: 20,),
                  buildReviewDateDropDown(
                      "Initial Date Of Review", Icons.calendar_today),
                  SizedBox(height: 20,),
                  buildReviewPeriodLengthDropDown(
                      "Selected Period Length", Icons.arrow_drop_down),
                  SizedBox(height: 20,),
                  buildFloorSelect(),
                  SizedBox(height: 20,),
                  buildSuiteSelect(),
                  SizedBox(height: 20,),
                  buildFacilityCategorySelect(),
                  SizedBox(height: 20,),
                  actionButtons()
                ],
              ),
            )
        ),
      ],
    ) : Container(
      height: 600,
      child: Loader.getLoader(),
    );
  }


  actionButtons()
  {
    return Container(
      margin: EdgeInsets.all(10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Expanded(
            child: GestureDetector(
              onTap: () async {


                if(_nameController.text!="")
                  {

                    List selectedFloor = [] , selectedCategory=[] , selectedSuite=[];

                    for(int i=0 ; i<selectedFloorList.length ; i++)
                    {
                      if(selectedFloorList[i] == true)
                      {
                        selectedFloor.add(floorList[i]["floor"]);
                      }
                    }

                    for(int i=0 ; i<selectedCategoryList.length ; i++)
                    {
                      if(selectedCategoryList[i] == true)
                      {
                        selectedCategory.add(facililtyCategoryList[i]["_id"]);
                      }
                    }



                    for(int i=0 ; i < selectedSuiteList.length ; i++)
                    {
                      for(int j=0 ; j<selectedSuiteList[i]["list"].length ; j++)
                      {
                        if(selectedSuiteList[i]["list"][j] == true)
                        {
                          selectedSuite.add(suiteList[i]["list"][j]);
                        }
                      }
                    }

                    iscreateLoading = true;
                    setState(() {
                    });

                    var res = await createReview(
                    {
                      "building" : _selectedBuilding["_id"],
                      "categories" : selectedCategory,
                      "floor" : selectedFloor,
                      "frequency": _selectedReviewPeriodLength,
                      "name" : _nameController.text,
                      "startDate" : selectedDate.toUtc().toIso8601String(),
                      "suite" : selectedSuite
                    }
                    );


                Navigator.pop(context  ,"done");
                  }
                else
                  {
                    Fluttertoast.showToast(msg: "Please Enter Name!" , textColor: Colors.black , backgroundColor: Colors.white);
                  }


              },
              child: Container(
                  child: Text(
                     "Create",
                      style: const TextStyle(
                          color:  Colors.white,
                          fontWeight: FontWeight.w300,
                          fontFamily: "Gotham",
                          fontStyle:  FontStyle.normal,
                          fontSize: 14.0
                      ),
                      textAlign: TextAlign.center
                  ),
                  alignment: Alignment.center,
                  margin: EdgeInsets.all(10),
                  height: 50,
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
                  Navigator.pop(context);
              },
              child: Container(
                  alignment: Alignment.center,
                  child: Text(
                      "Cancel",
                      style: const TextStyle(
                          color:  Colors.white,
                          fontWeight: FontWeight.w300,
                          fontFamily: "Gotham",
                          fontStyle:  FontStyle.normal,
                          fontSize: 14.0
                      ),
                      textAlign: TextAlign.center
                  ),
                  height: 50,
                  margin: EdgeInsets.all(10),
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
      ),
    );
  }

  buildReviewDateDropDown(String s, var arrow_drop_down) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
            margin: EdgeInsets.only(top:10 , left: 20, right: 20),
            child: Text(s , style: TextStyle(fontSize: 17 , fontWeight: FontWeight.bold),)),
        SizedBox(height: 4,),
        Container(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text((selectedDate != null) ? DateFormat("MMM dd, yyyy").format(selectedDate) : "" , overflow: TextOverflow.ellipsis,),
                ),
              ),
              GestureDetector(
                onTap: (){
                  _selectDate(context);
                },
                child: Padding(
                  padding: EdgeInsets.all(7),
                  child: Icon(arrow_drop_down),
                ),
              )
            ],
          ),
          height: 50,
          margin: EdgeInsets.only(top:10 , left: 20, right: 20),
          decoration: BoxDecoration(
              border: Border.all(width: 1, color: Colors.black),
              borderRadius: BorderRadius.circular(5)
          ),
        ),
      ],
    );
  }


  buildReviewPeriodLengthDropDown(String s, var arrow_drop_down) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
            margin: EdgeInsets.only(top:10 , left: 20, right: 20),
            child: Text(s , style: TextStyle(fontSize: 17 , fontWeight: FontWeight.bold))),
        SizedBox(height: 4,),
        Container(
          child: DropdownButtonHideUnderline(
            child: DropdownButton(
              icon: Icon(arrow_drop_down, size: 27, color: Colors.black,),
              isExpanded: true,
              hint: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(s , overflow: TextOverflow.ellipsis,),
              ),
              // Not necessary for Option 1
              value: _selectedReviewPeriodLength,
              onChanged: (newValue) {
                setState(() {
                  _selectedReviewPeriodLength = newValue;


                      if(_selectedReviewPeriodLength!=null)
                        {
                          getFloorSuiteCategory(_selectedBuilding["_id"], _selectedReviewPeriodLength, selectedDate.toUtc().toIso8601String());
                        }



                });
              },
              items: _reviewperiodLengthList.map((location) {
                return DropdownMenuItem(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(location , overflow: TextOverflow.ellipsis),
                  ),
                  value: location,
                );
              }).toList(),
            ),
          ),
          height: 50,
          margin: EdgeInsets.only(top:10 , left: 20, right: 20),
          decoration: BoxDecoration(
              border: Border.all(width: 1, color: Colors.black),
              borderRadius: BorderRadius.circular(5)
          ),
        ),
      ],
    );
  }

  buildingListView() {

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
            margin: EdgeInsets.only(top:10 , left: 20, right: 20),
            child: Text("Building" ,  style: TextStyle(fontSize: 17 , fontWeight: FontWeight.bold),)),
        SizedBox(height: 4,),
        Container(
          child: DropdownButtonHideUnderline(
            child: DropdownButton(
              icon: Icon(Icons.arrow_drop_down, size: 27, color: Colors.black,),
              isExpanded: true,
              hint: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text("Select Building" , overflow: TextOverflow.ellipsis,),
              ),
              // Not necessary for Option 1
              value: _selectedBuilding,
              onChanged: (newValue) {
                setState(() {
                  _selectedBuilding = newValue;

                });
              },
              items: buildingsList.map((location) {
                return DropdownMenuItem(
                  child: Padding
                    (
                      padding: EdgeInsets.all(8),
                      child: Text(
                          location["name"],overflow: TextOverflow.ellipsis)),
                  value: location,
                );
              }).toList(),
            ),
          ),
          height: 50,
          margin: EdgeInsets.only(top:10 , left: 20, right: 20),
          decoration: BoxDecoration(
              border: Border.all(width: 1, color: Colors.black),
              borderRadius: BorderRadius.circular(5)
          ),
        ),
      ],
    );
  }



  buildNameBox()
  {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
            margin: EdgeInsets.only(top:10 , left: 20, right: 20),
            child: Text("Name" , style: TextStyle(fontSize: 16 , fontWeight: FontWeight.bold),)),
        SizedBox(height: 4,),
        Container(
          padding: EdgeInsets.all(6),
          height: 50,
          child: TextField(
            controller: _nameController,
            maxLines: 1,
            decoration: InputDecoration.collapsed(
              hintText: "Name",
              border: InputBorder.none,
            ),
          ),
          margin: EdgeInsets.only(top:10 , left: 20, right: 20),
          decoration: BoxDecoration(
              border: Border.all(width: 1, color: Colors.black),
              borderRadius: BorderRadius.circular(5)
          ),
        ),
      ],
    );
  }


    Future _selectDate(BuildContext context) async {
      final DateTime picked = await showDatePicker(
          context: context,
          initialDate: (selectedDate != null) ? selectedDate : DateTime.now(),
          firstDate: DateTime(2015, 8),
          lastDate: DateTime.now()
      );
      if (picked != null)
        setState(() {
          selectedDate = picked;
        });

  }

  buildFloorSelect()
  {

    return  Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
            margin: EdgeInsets.only(top:10 , left: 20, right: 20),
            child: Text("Select Floor" , style: TextStyle(fontSize: 16 , fontWeight: FontWeight.bold),)),
        SizedBox(height: 4,),
        GestureDetector(
          onTap: () async {
            await _displayFloorDialog(context, floorList);

            setState(() {

            });

          },
          child: Container(
            padding: EdgeInsets.all(6),
            height: 50,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text("${selectedFloorCount} selected"),
                Icon(Icons.arrow_drop_down)
              ],
            ),
            margin: EdgeInsets.only(top:10 , left: 20, right: 20),
            decoration: BoxDecoration(
                border: Border.all(width: 1, color: Colors.black),
                borderRadius: BorderRadius.circular(5)
            ),
          ),
        ),
      ],
    );

  }


  buildFacilityCategorySelect()
  {
    return  Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
            margin: EdgeInsets.only(top:10 , left: 20, right: 20),
            child: Text("Select Category" , style: TextStyle(fontSize: 16 , fontWeight: FontWeight.bold),)),
        SizedBox(height: 4,),
        GestureDetector(
          onTap: () async {

            await _displayCategoryDialog(context, facililtyCategoryList);

            setState(() {

            });

          },
          child: Container(
            padding: EdgeInsets.all(6),
            height: 50,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text("${selectedCategoryCount} selected"),
                Icon(Icons.arrow_drop_down)
              ],
            ),
            margin: EdgeInsets.only(top:10 , left: 20, right: 20),
            decoration: BoxDecoration(
                border: Border.all(width: 1, color: Colors.black),
                borderRadius: BorderRadius.circular(5)
            ),
          ),
        ),
      ],
    );

  }


  buildSuiteSelect()
  {
    return  Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
            margin: EdgeInsets.only(top:10 , left: 20, right: 20),
            child: Text("Select Suite" , style: TextStyle(fontSize: 16 , fontWeight: FontWeight.bold),)),
        SizedBox(height: 4,),
        GestureDetector(
          onTap: () async {
            await _displaySuiteDialog(context, suiteList);
            setState(() {
            });

          },
          child: Container(
            padding: EdgeInsets.all(6),
            height: 50,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text("${selectedSuiteCount} selected"),
                Icon(Icons.arrow_drop_down)
              ],
            ),
            margin: EdgeInsets.only(top:10 , left: 20, right: 20),
            decoration: BoxDecoration(
                border: Border.all(width: 1, color: Colors.black),
                borderRadius: BorderRadius.circular(5)
            ),
          ),
        ),
      ],
    );

  }





  _displayFloorDialog(BuildContext context  , list) async {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Select Floor'),
            content: StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                return  Container(
                  height: 400,
                  width: 500,
                  child: ListView.builder(
                      itemCount: list.length,
                      itemBuilder: (BuildContext context , int index){


                        return Container(
                          margin: EdgeInsets.all(10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              GestureDetector(
                                onTap: (){

                                  setState(() {
                                    if(selectedFloorList[index] == true)
                                    {
                                      selectedFloorList[index] = false;
                                      selectedFloorCount--;
                                    }
                                    else
                                    {
                                      selectedFloorList[index] = true;
                                      selectedFloorCount++;
                                    }

                                  });


                                },
                                child: Container(
                                  height: 30,
                                  width: 30,
                                  child: (selectedFloorList[index] == true) ? Icon(Icons.done) : null,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(3),
                                      border: Border.all(color: Colors.black)
                                  ),
                                ),
                              ),
                              SizedBox(width: 60,),
                              Text(list[index]["floor"]["name"].toString() , style: TextStyle(fontSize: 20),)
                            ],
                          ),
                        );
                      }),
                );
              },
            ),
            actions: <Widget>[
              new FlatButton(
                child: new Text('Done'),
                onPressed: () {
                  Navigator.pop(context);
                 }
              )
            ],
          );
        });
  }


  _displayCategoryDialog(BuildContext context  , list) async {



    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Select Category'),
            content: StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                return  Container(
                  height: 400,
                  width: 500,
                  child: ListView.builder(
                      itemCount: list.length,
                      itemBuilder: (BuildContext context , int index){

                        return Container(
                          margin: EdgeInsets.all(10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              GestureDetector(
                                onTap: (){

                                  setState(() {
                                    if(selectedCategoryList[index] == true)
                                    {
                                      selectedCategoryList[index] = false;
                                    selectedCategoryCount--;
                                    }
                                    else
                                    {
                                      selectedCategoryList[index] = true;
                                    selectedCategoryCount++;
                                    }

                                  });


                                },
                                child: Container(
                                  height: 30,
                                  width: 30,
                                  child: (selectedCategoryList[index] == true) ? Icon(Icons.done) : null,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(3),
                                      border: Border.all(color: Colors.black)
                                  ),
                                ),
                              ),
                              SizedBox(width: 60,),
                              Text(list[index]["name"].toString() , style: TextStyle(fontSize: 20),)
                            ],
                          ),
                        );
                      }),
                );
              },
            ),
            actions: <Widget>[
              new FlatButton(
                  child: new Text('Done'),
                  onPressed: () {

                    Navigator.pop(context);
                  }
              )
            ],
          );
        });
  }

  _displaySuiteDialog(BuildContext context, list)
  {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Select Suite'),
            content: StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                return  Container(
                  height: 400,
                  width: 500,
                  child: ListView.builder(
                      itemCount: list.length,
                      itemBuilder: (BuildContext context , int index){

                        return Container(
                          margin: EdgeInsets.all(10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[

                              Text("${list[index]["floor"]["alias"]}" , style: TextStyle(fontSize: 20 , fontWeight: FontWeight.bold),),
                              Divider(color: Colors.black,),
                              SizedBox(height: 10,),
                              Container(
                                height: 200,
                                child: ListView.builder(
                                    itemCount: suiteList[index]["list"].length,
                                    itemBuilder: (BuildContext context , int indexInner)
                                    {


                                      return Row(
                                        children: <Widget>[
                                          GestureDetector(
                                            onTap: (){
                                              setState(() {
                                                if(selectedSuiteList[index]["list"][indexInner] == true)
                                                  {
                                                    selectedSuiteList[index]["list"][indexInner] = false;
                                                    selectedSuiteCount--;
                                                  }
                                                else
                                                  {
                                                    selectedSuiteList[index]["list"][indexInner] = true;
                                                    selectedSuiteCount++;
                                                  }

                                              });


                                            },
                                            child: Container(
                                              height: 30,
                                              width: 30,
                                              child:  (selectedSuiteList[index]["list"][indexInner] == true) ?  Icon(Icons.done)  : null  ,
                                              decoration: BoxDecoration(
                                                  borderRadius: BorderRadius.circular(3),
                                                  border: Border.all(color: Colors.black)
                                              ),
                                            ),
                                          ),
                                          SizedBox(width: 60,),
                                          Text('${suiteList[index]["list"][indexInner]["suiteNo"]}' , style: TextStyle(fontSize: 20),),
                                        ],
                                      );
                                    }
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                );
              },
            ),
            actions: <Widget>[
              new FlatButton(
                  child: new Text('Done'),
                  onPressed: () {
                    Navigator.pop(context);
                  }
              )
            ],
          );
        });
  }







}
