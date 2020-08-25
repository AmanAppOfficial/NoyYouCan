/**
 * @descrption Missing tasks screen
 * @author Aman Srivastava
 */


import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nowyoucan/model/scheduledTask.dart';
import 'package:nowyoucan/service/user.dart';
import 'package:nowyoucan/ui/widgets/app_bar.dart';
import 'package:nowyoucan/ui/widgets/navigation_drawer_elements.dart';
import 'package:nowyoucan/service/scheduledTasks.dart';
import 'package:nowyoucan/ui/widgets/loader.dart';
import 'package:nowyoucan/model/scheduledTask.dart';

class MissingTaskScreen extends StatefulWidget {

  var ctx;
  String userRole;
  var currentUser;

  MissingTaskScreen(this.ctx, this.userRole, this.currentUser);

  @override
  _MissingTaskScreenState createState() => _MissingTaskScreenState();
}

class _MissingTaskScreenState extends State<MissingTaskScreen> {

  DateTime now = new DateTime.now();
  var dateChangeCount=-1;
  bool isLoading = true;
  // var _controller = ScrollController();

  @override
  void initState() => {
    (() async {

      // set up listener here
      // _controller.addListener(() {
      //   print("---------------");
      //   if (_controller.position.atEdge) {
      //     print("--------------");
      //     if (_controller.position.pixels == 0){
      //       print("Top");
      //     }
      //       // you are at top position
      //     else{
      //       print("Bottom");
      //     }
      //       // you are at bottom position
      //   }
      // });

      widget.currentUser = await User.me();

      getMissingTaskList();

      setState(() {
      });

    })()

};
  
  List<ScheduledTaskList> scheduledTaskList = [];

  getMissingTaskList() async {
    try {
      isLoading = true;
      setState(() {
      });
      DateTime displayedDate = new DateTime(now.year, now.month, now.day+dateChangeCount);
      var formatter = new DateFormat('yyyy-MM-dd');
      scheduledTaskList = await ScheduledTaskService.getMissedTaskList(formatter.format(displayedDate));
      isLoading = false;
      setState(() {
      });
    } catch(error) {
      print("@getMissingTaskList");
      print(error);
    }
  }

  


  @override
  Widget build(BuildContext context) {

    DateTime date1 = new DateTime(now.year, now.month, now.day+ dateChangeCount);
    var formatter = new DateFormat('MMM d, yyyy');
    String formattedDate = formatter.format(date1);

    onDateChange(val) {
      dateChangeCount += val;
      getMissingTaskList();
      setState(() {
      });
    }


    var diff;
    Future _selectDate(BuildContext context) async
    {
      final DateTime picked = await showDatePicker(
          context: context,
          initialDate: DateTime(now.year, now.month, now.day -1 ),
          firstDate:  DateTime(2020 , 7),
          lastDate: DateTime(now.year, now.month, now.day -1 ));

      if (picked != null && picked != date1)
      {
        diff = picked.difference(date1).inDays;
        dateChangeCount= dateChangeCount + diff;
      }
      getMissingTaskList();
      setState(() {
      });
    }

    dateRow() {                        //Date Layout
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
                if(date1.difference(DateTime(2020,07)).inDays>0)
              onDateChange(-1);
              },
              child: Container(
                width: MediaQuery.of(context).size.width * (1 / 5),
                height: 50,
                decoration: boxStyle(date1.difference(DateTime(2020,07)).inDays>0),
                child: Icon(Icons.chevron_left),
              ),
            ),
          ),
          SizedBox(width: 20.0),
          GestureDetector(
            onTap: (){
              _selectDate(context);
            },
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
                if(date1.difference(DateTime.now()).inDays<-1)
                  onDateChange(1);
              },
              child: Container(
                width: MediaQuery.of(context).size.width * (1 / 5),
                height: 50,
                decoration: boxStyle(date1.difference(DateTime.now()).inDays<-1),
                child: Icon(Icons.chevron_right),
              ),
            ),
          )
        ],
      );
    }


    return  Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomPadding: true,
      appBar: BaseAppBar.getAppBar("Missed \n Tasks"),
      endDrawer: Drawer(
        child: DrawerElements.getDrawer('missing tasks' , context, widget.userRole ,  widget.ctx , widget.currentUser),
      ),
      // bottomNavigationBar: ,
      body: SafeArea(
        child: ListView(
          children: <Widget>[
            SizedBox(height: 20.0),
            dateRow(),
            SizedBox(height: 20.0),
            (isLoading) ? Loader.getListLoader(context) : taskList(),
          ],
        ),
      ),
    );
  }

  taskList()                                       //List of missing tasks
  {
    return (scheduledTaskList.length > 0) ? ListView.builder(
        shrinkWrap: true,
        physics: ClampingScrollPhysics(),
        // itemCount: missingTasksList.length,
        itemCount: scheduledTaskList.length,
        itemBuilder: (BuildContext context , int index)
        {
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
                      "${scheduledTaskList[index].buildingName}",
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
//                      height:110,
                      child: childContainer(scheduledTaskList[index].task),
                    )
                  ],
                ),
              ),
            ),
          );
        }
      ) : Container(
        alignment: Alignment.center,
        margin: EdgeInsets.only(top: 30.0),
        child: Text("No Results Found!"),
      );
  }

  childContainer(List<ScheduledTask> taskList)                         //Expansion tile children when tile is expanded
  {
    // List taskList = data;
    var maxItem = 10;
    return ListView.builder(
      scrollDirection: Axis.vertical,
      shrinkWrap: true,
      physics: ClampingScrollPhysics(),
      itemCount: taskList.length, // viki
      // controller: _controller,
      // itemCount: (taskList.length<maxItem) ? taskList.length : maxItem,
      itemBuilder: (BuildContext context , int index) {
        return Container(
          margin: const EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 10),
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
                offset: Offset(0, 0),
                blurRadius: 8,
                spreadRadius: 0
            )
            ],
            color: const Color(0xfff9f9f9)
          ),
          child: Container(
            margin: EdgeInsets.all(18),
            child: Column(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Container(
                      child: Image.asset("images/edit.png" , scale: 1.8,),
                    ),
                    SizedBox(width: 6,),
                    Container(
                      child: Flexible(
                        child: Text(taskList[index].config.name ,  maxLines: 1,overflow: TextOverflow.ellipsis,
                     ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20,),
                buildInCardDetail(
                  taskList[index].config.floor != null  
                    ? taskList[index].config.floor.floorAlias 
                    : (taskList[index].config.suite != null ? taskList[index].config.suite.floorAlias : " t ")  ,
                  taskList[index].config.suite != null && taskList[index].config.suite.suiteNo != null ? taskList[index].config.suite.suiteNo : "N/A" , "images/alignment.png" , "images/Location.png"),
                
                // SizedBox(height: 20,),
                // buildInCardDetail(taskList[index].name , taskList[index].config.name , "images/clocknew.png" , "images/edit.png"),
                SizedBox(height: 20,),
                buildInCardDetail(taskList[index].name  , taskList[index].member.firstName , "images/suit.png" , "images/profile-round.png"),
                ],
          ),
        ),
      );
    },
    );
  }

  buildInCardDetail(String element1 , String element2 , String image1 , String image2)                  //Elements of data in expanded card
  {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Expanded(child: Row(
          children: <Widget>[
            Container(
              child: Image.asset(image1 , scale: 1.8,),
            ),
            SizedBox(width: 6,),
            Container(
              width: 100,
              child: Text('$element1' ,  overflow: TextOverflow.ellipsis,
                maxLines: 1,),
            ),
          ],
        )),
        Expanded(child: Row(
          children: <Widget>[
            Container(
              child: Image.asset(image2 , scale: 1.8,),
            ),
            SizedBox(width: 6,),
            Container(
              width: 100,
              child: Text('$element2' ,  overflow: TextOverflow.ellipsis,
                maxLines: 1,),
            ),
          ],
        )),
      ],
    );
  }
}
