import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';
import 'package:nowyoucan/service/building.service.dart';
import 'package:nowyoucan/service/message_service.dart';
import 'package:nowyoucan/ui/widgets/loader.dart';

class CreateMessageScreen extends StatefulWidget {

  String userRole;
  var mainCtx;
  var currentUser;

  CreateMessageScreen(this.userRole, this.mainCtx, this.currentUser);

  @override
  _CreateMessageScreenState createState() => _CreateMessageScreenState();
}

class _CreateMessageScreenState extends State<CreateMessageScreen> {


  bool selectAllMembers = true , selectAllFloors = true , selectAllSuites = true ;


  bool isLoading = true;
  bool isFetching = false;
  var buildingList = [
  ];

  var suiteList = [
  ];

  List floorList = [
  ];

  var memberList = [];

  TextEditingController _messageController = new TextEditingController();

  var style = TextStyle(
      color: Colors.black,
      fontSize: 18
  );


  var selectedSuiteList = [] , selectedMemberList=[] ,selectedFloorList = [] , _selectedBuilding;
  int selectedSuiteCount=0 , selectedMemberCount=0 , selectedFloorCount=0;
  var expiryDate;


  @override
  void initState() {
    (() async {
      await getBuildingList();

      selectedSuiteCount = suiteList.length;

      isLoading = false;
      setState(() {

      });

    })();
  }



  getBuildingList() async {
    try {
      buildingList = await BuildingService.getBuilding();
//      _selectedBuilding = buildingList[0];


    } catch (error) {
      print("@getBuildingList Error " + error.toString());
    }
  }


  getFloorSuiteCategory() async
  {
    isLoading = true;
    setState(() {
    });

    var res = await MessageService.getFloorSuite(
      _selectedBuilding["_id"]);

    if(suiteList.length>0)
      {
        suiteList.clear();
      }
    else
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



    print(suiteList.toString());

    if(selectedSuiteList.length>0)
      {
        selectedSuiteList.clear();
        selectedSuiteCount=0;

      }


    for(int i=0 ; i<suiteList.length ; i++)
    {
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



    if(floorList.length>0)
    {
      floorList.clear();
    }

    if(selectedFloorList.length>0)
    {
      selectedFloorList.clear();
    }
    selectedFloorCount = 0;

    floorList = res["floorList"];
    floorList.forEach((element) {
      selectedFloorList.add(true);
    });
    selectedFloorCount = floorList.length;

    await getMembers();

    isLoading = false;
    setState(() {
    });

  }


  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child : Center(
          child: ListView(
            children: <Widget>[
              Column(
                children: <Widget>[
                  SizedBox(height: 40,),
                  Container(
                      alignment: Alignment.center,
                      child: Text('Create your message' , style: TextStyle( color: Colors.blue, fontSize: 24 , fontStyle: FontStyle.normal ,  fontWeight: FontWeight.normal),)),
                  Card(
                    elevation: 9,
                    margin: const EdgeInsets.all(30),
                    child: (!isLoading) ? Stack(
                      children: <Widget>[
                        Column(
                          children: <Widget>[
                            SizedBox(height: 10,),
                             Column(
                               crossAxisAlignment: CrossAxisAlignment.start,
                               children: <Widget>[
                                 Container(
                                     margin: const EdgeInsets.only(left: 20 , right: 20 , top: 30),
                                     child: Text('Select Building'  ,  style: style,)),
                                 selectBuilding(),
                               ],
                             ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Container(
                                    margin: const EdgeInsets.only(left: 20 , right: 20 , top: 30),
                                    child: Text('Select Floor'  ,  style: style,)),
                                selectFloor(),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Container(
                                    margin: const EdgeInsets.only(left: 20 , right: 20 , top: 30),
                                    child: Text('Select Suite'  ,  style: style,)),
                                selectSuite(),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Container(
                                    margin: const EdgeInsets.only(left: 20 , right: 20 , top: 30),
                                    child: Text('Select Member'  ,  style: style,)),
                                selectMember(),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Container(
                                    margin: const EdgeInsets.only(left: 20 , right: 20 , top: 30),
                                    child: Text('Select Expiry Date'  ,  style: style,)),
                                selectExpiryDate(),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Container(
                                    margin: const EdgeInsets.only(left: 20 , right: 20 , top: 30),
                                    child: Text('Enter Message'  ,  style: style,)),
                                SizedBox(height: 20,),
                                setMessageBox(),
                              ],
                            ),
                            SizedBox(height: 20,),
                            actionButtons(),
                            SizedBox(height: 50,)
                          ],
                        ),
                        (isFetching) ? Container(
                          height: 500,
                           child :  SpinKitCircle(
                             color: Colors.orange,
                             size: 200,
                           )
                        ) : Container()
                      ],
                    ) : Container(
                      height: 500,
                      child: Loader.getLoader(),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  selectBuilding()
  {
    return Container(
      width: MediaQuery.of(context).size.width/1.2,
      margin: const EdgeInsets.only(left: 20 , right: 20 , top: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.black)
      ),
      child: DropdownButtonHideUnderline(
        child: Container(
          margin: const EdgeInsets.all(6),
          child: DropdownButton(
            hint: Text('Select Building' , style: style,),
            value: _selectedBuilding,
            onChanged: (newValue){
              setState(() {
                _selectedBuilding = newValue;
                getFloorSuiteCategory();
              });
            },
            items: buildingList.map((location){
              return DropdownMenuItem(
                child: new Text(location["name"] , style: style,),
                value: location,
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  selectSuite()
  {
    return GestureDetector(
      onTap: () async {
        var res = await suiteDialog();

        if(res=="ok")
          {
            isLoading = true;
            setState(() {
            });
            await getMembers();
          }


      },
      child: Container(
        width: MediaQuery.of(context).size.width/1.2,
        margin: const EdgeInsets.only(left: 20 , right: 20 , top: 20),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.black)
        ),
        child: Container(
          margin: const EdgeInsets.all(6),
          padding: EdgeInsets.only(top: 10 , bottom: 10),
          child : Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text((selectedSuiteCount == 0) ? 'Select Suite' : '$selectedSuiteCount selected' , style: style,),
              Icon(Icons.arrow_drop_down)
            ],
          )
        ),
      ),
    );
  }

  selectFloor()
  {
    return GestureDetector(
      onTap: () async {
       var res = await floorDialog(context, floorList);

       if(res=="ok")
       {
         isLoading = true;
         setState(() {
         });
         await getMembers();
       }

      },
      child: Container(
        width: MediaQuery.of(context).size.width/1.2,
        margin: const EdgeInsets.only(left: 20 , right: 20 , top: 20),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.black)
        ),
        child: Container(
            margin: const EdgeInsets.all(6),
            padding: EdgeInsets.only(top: 10 , bottom: 10),
            child : Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text((selectedFloorCount == 0) ? 'Select Floor' : '$selectedFloorCount selected' , style: style,),
                Icon(Icons.arrow_drop_down)
              ],
            )
        ),
      ),
    );
  }

  selectMember()
  {
    return GestureDetector(
      onTap: (){
        memberDialog();
      },
      child: Container(
        width: MediaQuery.of(context).size.width/1.2,
        margin: const EdgeInsets.only(left: 20 , right: 20 , top: 20),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.black)
        ),
        child: Container(
            margin: const EdgeInsets.all(6),
            padding: EdgeInsets.only(top: 10 , bottom: 10),
            child : Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text((selectedMemberCount == 0) ? 'Select Member' : '$selectedMemberCount selected' , style: style,),
                Icon(Icons.arrow_drop_down)
              ],
            )
        ),
      ),
    );
  }

  selectExpiryDate()
  {
    return GestureDetector(
      onTap: (){
        _selectDate(context);
      },
      child: Container(
        width: MediaQuery.of(context).size.width/1.2,
        margin: const EdgeInsets.only(left: 20 , right: 20 , top: 20),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.black)
        ),
        child: Container(
            margin: const EdgeInsets.all(6),
            padding: EdgeInsets.only(top: 10 , bottom: 10),
            child : Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text((expiryDate == null) ? 'Select Expiry Date' : expiryDate.toString() , style: style,),
                Icon(Icons.calendar_today)
              ],
            )
        ),
      ),
    );
  }

  Future _selectDate(BuildContext context) async
  {
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate:  DateTime.now(),
        lastDate: DateTime(2025 , 07));

    if (picked != null)
    {
      expiryDate = DateFormat("yyyy-MM-dd").format(picked);
    }
    setState(() {
    });
  }

  memberDialog()
  {
    return showDialog(
      context: context,
      builder: (context)
        {
          return AlertDialog(
            title: Text('Select Members'),
            content: StatefulBuilder(
              builder: (BuildContext context , StateSetter setState)
              {
                return Container(
                  height: MediaQuery.of(context).size.height/1.5,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Container(
                            height: 50,
                            child: new Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Text('Select all'),
                                GestureDetector(
                                  onTap: (){
                                    if(selectAllMembers == true)
                                      {
                                        setState(() {
                                          selectAllMembers = false;

                                         //making all members select false.
                                          for(int i=0 ; i<selectedMemberList.length ; i++)
                                            selectedMemberList[i] = false;


                                          selectedMemberCount = 0;
                                        });
                                      }
                                    else
                                    {
                                    setState(() {
                                      selectAllMembers = true;
                                      for(int i=0 ; i<selectedMemberList.length ; i++)
                                        selectedMemberList[i] = true;
                                      selectedMemberCount = selectedMemberList.length;
                                    });
                                    }

                                  },
                                  child: Container(
                                    margin: EdgeInsets.all(6),
                                    height: 30,
                                    width: 30,
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(5),
                                        border: Border.all()
                                    ),
                                    child: (selectAllMembers) ? Icon(Icons.done) : null,
                                  ),
                                )
                              ],
                            ),
                          ),
                          Container(
                            height: 50,
                            child: new Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                Text(''),
                                GestureDetector(
//                                  onTap: (){
//                                    if(unselectAllMembers == true)
//                                      unselectAllMembers = false;
//                                    else
//                                      {
//                                        unselectAllMembers = true;
//                                        selectAllMembers = false;
//                                      }
//
//                                    setState(() {
//                                      for(int i=0 ; i<selectedMemberList.length ; i++)
//                                        selectedMemberList[i] = false;
//                                      selectedMemberCount=0;
//                                    });
//                                  },
                                  child: Container(
                                    margin: EdgeInsets.all(6),
                                    height: 30,
                                    width: 30,
//                                    decoration: BoxDecoration(
//                                        borderRadius: BorderRadius.circular(5),
//                                        border: Border.all()
//                                    ),
//                                    child: (unselectAllMembers)  ? Icon(Icons.done) : null,
                                  ),
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                      Container(
                        height: MediaQuery.of(context).size.height/2.5,
                        width: 500,
                        child: ListView.builder(
                            itemCount: memberList.length,
                            itemBuilder: (BuildContext context , int index)
                            {
                              return Container(
                                margin: const EdgeInsets.all(10),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: <Widget>[
                                    GestureDetector(
                                      onTap: (){

                                        setState(() {

                                          if(selectedMemberList[index] == true)
                                          {selectedMemberList[index] = false;
                                          selectedMemberCount--;
                                          }
                                          else
                                          { selectedMemberList[index] = true;
                                          selectedMemberCount++;
                                          }

                                        });


                                      },
                                      child: Container(
                                        height: 30,
                                        width: 30,
                                        child: (selectedMemberList[index] == true) ? Icon(Icons.done) : Container() ,
                                        decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(3),
                                            border: Border.all(color: Colors.black)
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 60,),
                                    Text(memberList[index]["firstName"].toString() , style: style,),
                                  ],
                                ),
                              );
                            }
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            actions: <Widget>[
              new FlatButton(
                  child: new Text('Cancel'),
                  onPressed: () async {
                    Navigator.pop(context);
                  }
              ),
              new FlatButton(
                  child: new Text('Done'),
                  onPressed: () {
                    Navigator.pop(context);
                  }
              ),
            ],
          );
        }

    );
  }


  floorDialog(BuildContext context  , list) async {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Select Floor'),
            content: StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                return  Container(
                  height: MediaQuery.of(context).size.height/1.5,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Container(
                            height: 50,
                            child: new Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Text('Select all'),
                                GestureDetector(
                                  onTap: (){
                                    if(selectAllFloors == true)
                                    {
                                      setState(() {
                                        selectAllFloors = false;
                                        for(int i=0 ; i<selectedFloorList.length ; i++)
                                          selectedFloorList[i] = false;
                                        selectedFloorCount = 0;
                                      });
                                    }
                                    else
                                    {
                                      setState(() {
                                        selectAllFloors = true;
                                        for(int i=0 ; i<selectedFloorList.length ; i++)
                                          selectedFloorList[i] = true;
                                        selectedFloorCount = selectedFloorList.length;
                                      });
                                    }

                                  },
                                  child: Container(
                                    margin: EdgeInsets.all(6),
                                    height: 30,
                                    width: 30,
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(5),
                                        border: Border.all()
                                    ),
                                    child: (selectAllFloors) ? Icon(Icons.done) : null,
                                  ),
                                )
                              ],
                            ),
                          ),
                          Container(
                            height: 50,
                            child: new Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                Text(''),
                                GestureDetector(
                                  child: Container(
                                    margin: EdgeInsets.all(6),
                                    height: 30,
                                    width: 30,
                                        ),
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                      Container(
                        height: MediaQuery.of(context).size.height/2,
                        width: 500,
                        child: ListView.builder(
                            itemCount: list.length,
                            shrinkWrap: true,
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
                                    FittedBox(child: Text(list[index]["floor"]["alias"].toString() , style: TextStyle(fontSize: 20),))
                                  ],
                                ),
                              );
                            }),
                      ),
                    ],
                  ),
                );
              },
            ),
            actions: <Widget>[
              new FlatButton(
                  child: new Text('Cancel'),
                  onPressed: () async {
                    Navigator.pop(context);
                  }
              ),
              new FlatButton(
                  child: new Text('Done'),
                  onPressed: () async {
                    Navigator.pop(context , "ok");
                  }
              )
            ],
          );
        });
  }






  suiteDialog()
  {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Select Suite'),
            content: StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                return Container(
                  height: MediaQuery.of(context).size.height/1.5,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Container(
                            height: 50,
                            child: new Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Text('Select all'),
                                GestureDetector(
                                  onTap: (){
                                    if(selectAllSuites == true)
                                    {
                                      setState(() {
                                        selectAllSuites = false;

                                        //unselecting all suites
                                        for(int i=0 ; i<suiteList.length ; i++)
                                        {
                                          for(int j=0 ; j<suiteList[i]["list"].length ; j++)
                                          {
                                            selectedSuiteList[i]["list"][j] = false;
                                          }
                                        }

                                        selectedSuiteCount = 0;
                                      });
                                    }
                                    else
                                    {
                                      setState(() {
                                        selectAllSuites = true;

                                       //selecting all suites
                                        for(int i=0 ; i<suiteList.length ; i++)
                                        {
                                          for(int j=0 ; j<suiteList[i]["list"].length ; j++)
                                          {
                                            selectedSuiteList[i]["list"][j] = true;
                                          }
                                        }

                                        selectedSuiteCount = selectedSuiteList.length;
                                      });
                                    }

                                  },
                                  child: Container(
                                    margin: EdgeInsets.all(6),
                                    height: 30,
                                    width: 30,
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(5),
                                        border: Border.all()
                                    ),
                                    child: (selectAllSuites) ? Icon(Icons.done) : null,
                                  ),
                                )
                              ],
                            ),
                          ),
                          Container(
                            height: 50,
                            child: new Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                Text(''),
                                GestureDetector(
                                  child: Container(
                                    margin: EdgeInsets.all(6),
                                    height: 30,
                                    width: 30,
                                  ),
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                      Container(
                        height: 400,
                        width: 500,
                        child: ListView.builder(
                            itemCount: suiteList.length,
                            itemBuilder: (BuildContext context , int index){

                              return Container(
                                margin: EdgeInsets.all(10),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: <Widget>[

                                    Text("${suiteList[index]["floor"]["alias"]}" , style: TextStyle(fontSize: 20 , fontWeight: FontWeight.bold),),
                                    Divider(color: Colors.black,),
                                    SizedBox(height: 10,),
                                    Container(
                                      height: 200,
                                      child: ListView.builder(
                                        physics: ClampingScrollPhysics(),
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
                      ),
                    ],
                  ),
                ) ;
              },
            ),
            actions: <Widget>[
              new FlatButton(
                  child: new Text('Cancel'),
                  onPressed: () async {
                    Navigator.pop(context);
                  }
              ),
              new FlatButton(
                  child: new Text('Done'),
                  onPressed: () async {
                    Navigator.pop(context , "ok");
                  }
              )
            ],
          );
        });


  }

  setMessageBox() 
  {
    return Container(
      padding: EdgeInsets.all(9),
      margin:  const EdgeInsets.only(left: 20 , right: 20 , top: 10),
      height: 170,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.black),
      ),
      child: TextField(
        controller: _messageController,
        maxLines: null,
        keyboardType: TextInputType.multiline,
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: 'Write message here...'
        ),
      ),
    );
  }

  actionButtons()
  {
    return Row(
      children: <Widget>[
        Expanded(
          child: GestureDetector(
              onTap: (){
                // Add logic for saving the eaction
                Navigator.pop(context);
              },
              child: actionButton("Send")
          ),
        ),
        Expanded(
            child:  GestureDetector(
                onTap: (){
                  Navigator.pop(context);
                },
                child: actionButton("Cancel")
            )),
      ],
    );
  }


  actionButton(type) {
    var color;
    if(type == "Send") {
      color = const Color(0xffd74545);
    } else {
      color = const Color(0xff0fe68e);
    }
    return GestureDetector(
      onTap: () async {

        if(type == "Send") {
          if(_messageController.text != "")
            {

              List selectedFloor = [] , selectedSuite=[] , selectedTradeExperts=[];

              for(int i=0 ; i<selectedFloorList.length ; i++)
              {
                if(selectedFloorList[i] == true)
                {
                  selectedFloor.add(floorList[i]["floor"]);
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

              for(int i=0 ; i<selectedMemberList.length ; i++)
              {
                if(selectedMemberList[i] == true)
                {
                  selectedTradeExperts.add(memberList[i]["_id"].toString());
                }
              }

              var body = {
                "building" : _selectedBuilding["_id"],
                "body" : _messageController.text,
                "expDate" : DateTime.parse(expiryDate.toString()).toUtc().toIso8601String(),
                "subject" : " ",
                "tradeExperts" : selectedTradeExperts,
                "floor" : selectedFloor,
                "suiteInfo" : selectedSuite
              };

              isFetching = true;
              setState(() {
              });

              await MessageService.postMessages(body);
               Navigator.pop(context);
            }
        } else {
          Navigator.pop(context);
        }

      },
      child: Container(
          child: Text(
              type,
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
              color: color
          )
      ),
    );
  }

  getMembers() async
  {

    if(memberList.length>0)
      {
        memberList.clear();
        selectedMemberCount=0;
        selectedMemberList.clear();
      }

    List selectedFloor = [] , selectedSuite=[];
    List floorNo = [] , suiteNo = [];

    for(int i=0 ; i<selectedFloorList.length ; i++)
    {
      if(selectedFloorList[i] == true)
      {
        selectedFloor.add(floorList[i]["floor"]);
      }
    }


    selectedFloor.forEach((element) {
      floorNo.add(element["number"]);
    });





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

    selectedSuite.forEach((element) {
      suiteNo.add({
        "floorNumber" : element["floorNumber"],
        "suiteNo" : element["suiteNo"]
      });
    });



    memberList = await MessageService.getFloorMembers({
      "building" : _selectedBuilding["_id"],
      "floor" : floorNo,
      "suiteInfo" : suiteNo
    });

    memberList.forEach((element) {
      selectedMemberList.add(true);
    });

    selectedMemberCount = selectedMemberList.length;

    isLoading = false;
    setState(() {
    });


  }







}
