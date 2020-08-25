import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nowyoucan/service/user.dart';
import 'package:nowyoucan/ui/popUps/recentCommentPicture.dart';
import 'package:nowyoucan/ui/widgets/app_bar.dart';
import 'package:nowyoucan/ui/widgets/event_calendar.dart';
import 'package:nowyoucan/ui/widgets/navigation_drawer_elements.dart';
import 'package:nowyoucan/service/scheduledTasks.dart';
import 'package:nowyoucan/model/scheduledTask.dart';
import 'package:nowyoucan/ui/widgets/loader.dart';

class RecentCommentsScreen extends StatefulWidget {

  var ctx;
  String userRole;
  var currentUser;

  RecentCommentsScreen(this.ctx , this.userRole, this.currentUser);

  @override
  _RecentCommentsScreenState createState() => _RecentCommentsScreenState();
}

class _RecentCommentsScreenState extends State<RecentCommentsScreen> {

  DateTime now = new DateTime.now();
  var dateChangeCount=0;

  bool isLoading = true;

  List<ScheduledTaskList> scheduledTaskList = [];

  var dateList =[];


  @override
  initState() {
    (() async {
      widget.currentUser = await User.me();
      getRecentCommentList();
      getRecentCommentDate();

      setState(() {

      });
    })();



  }


  getRecentCommentDate() async
  {
    var res = await ScheduledTaskService.getRecentCommentsDates();

    res.forEach((element) {
      var date = element["date"].toString();
      dateList.add(DateFormat("yyyy-MM-dd").parse(date.toString()));

    });
    

  }

  getRecentCommentList() async {
    try {
      isLoading = true;
      setState(() {
      });
      DateTime date1 = new DateTime(now.year, now.month, now.day + dateChangeCount);
      var formatter = new DateFormat('yyyy-MM-dd');
      String formattedDate = formatter.format(date1);
      print(formattedDate);
      var res = await ScheduledTaskService.getRecentTaskList(formattedDate);
      if (res != null) {
        scheduledTaskList = res;
      }
      isLoading = false;
      setState(() {
      });
    } catch (error) {
      print("@getRecentCommentList");
      print(error);
    }
  }
  @override
  Widget build(BuildContext context) {

    DateTime displayedDate = new DateTime(now.year, now.month, now.day+dateChangeCount);
    var formatter = new DateFormat('MMM d, yyyy');
    String formattedDate = formatter.format(displayedDate);

    onDateChange(val) {
      dateChangeCount += val;
      getRecentCommentList();
      setState(() {
      });
    }

//    var diff;
//    Future _selectDate(BuildContext context) async
//    {
//      final DateTime picked = await showDatePicker(
//          context: context,
//          initialDate: DateTime.now(),
//          firstDate:  DateTime(2020 , 7),
//          lastDate: DateTime.now());
//
//      if (picked != null && picked != displayedDate)
//      {
//        diff = picked.difference(displayedDate).inDays;
//        dateChangeCount= dateChangeCount + diff;
//      }
//      getRecentCommentList();
//      setState(() {
//      });
//    }


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
                if(displayedDate.difference(DateTime(2020,07)).inDays>0)
                onDateChange(-1);
              },
              child: Container(
                width: MediaQuery.of(context).size.width * (1 / 5),
                height: 50,
                decoration: boxStyle(displayedDate.difference(DateTime(2020,07)).inDays>0),
                child: Icon(Icons.chevron_left),
              ),
            ),
          ),
          SizedBox(width: 20.0),
          GestureDetector(
            onTap:() async {
//              _selectDate(context);

              var result = await Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => EventCalendar(dateList)),
              );


            if(result != null)
              {
                DateTime currDisplayedDate  =  displayedDate;
                displayedDate = result;
                var diff = displayedDate.difference(currDisplayedDate).inDays;
                dateChangeCount= dateChangeCount + diff;

                getRecentCommentList();
              }

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
                if(displayedDate.difference(DateTime.now()).inDays<0)
                onDateChange(1);
              },
              child: Container(
                width: MediaQuery.of(context).size.width * (1 / 5),
                height: 50,
                decoration: boxStyle(displayedDate.difference(DateTime.now()).inDays<0),
                child: Icon(Icons.chevron_right),
              ),
            ),
          )
        ],
      );
    }

  return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomPadding: true,
      appBar: BaseAppBar.getAppBar("Recent \n Comments"),
      endDrawer: Drawer(
        child: DrawerElements.getDrawer('recent comments' , context, widget.userRole , widget.ctx ,widget.currentUser),
      ),
      // bottomNavigationBar: ,
      body: SafeArea(
        child: ListView(
          children: <Widget>[
            SizedBox(height: 20.0),
            dateRow(),
            SizedBox(height: 20.0),
            (isLoading) ? Loader.getListLoader(context) : commentList(),
          ],
        ),
      ),
    );
  }


  commentList()                                       //List of recent comments building wise
  {
    return (scheduledTaskList.length > 0) ? ListView.builder(
        shrinkWrap: true,
        physics: ClampingScrollPhysics(),
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
                          scheduledTaskList[index].buildingName,
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
                      child: childContainer(scheduledTaskList[index]),
                    )
                  ],
                ),
              ),
            ),
          );
        }
    ): Container(
      alignment: Alignment.center,
      margin: EdgeInsets.only(top: 30.0),
      child: Text("No Results Found!"),
    );
  }

  childContainer(ScheduledTaskList taskList)                         //Expansion tile children when tile is expanded
  {
    // List  = data;
    print(taskList.task);
    return ListView.builder(
      scrollDirection: Axis.vertical,
      shrinkWrap: true,
      physics: ClampingScrollPhysics(),
      itemCount: taskList.task.length,
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
            child: childCardData(taskList.task[index].comment , taskList.task[index].images , taskList.task[index].name , taskList.task[index].config.name , taskList.task[index].member.firstName ),
          ),
        );
      },
    );
  }

  childCardData(comment, imageList, shift , facilityName , memName)
  {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        buildCardData(comment , shift , facilityName , memName),
        (imageList != null) ? buildImageList(imageList) : Column(),
      ],
    );
  }

  buildCardData(comment, shift, facilityName , memberName)
  {
    return Column(
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Expanded(
              child:  Row(
                children: <Widget>[
                  Container(child: Image.asset("images/suit.png" , scale: 2.0,),),
                  SizedBox(width: 10,),
                  Container(child: Text('$facilityName' , maxLines: 1, overflow: TextOverflow.ellipsis,)),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: 20,),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Expanded(
              child: Row(
                children: <Widget>[
                  Container(child: Image.asset("images/clocknew.png" , scale: 2.0,),),
                  SizedBox(width: 10,),
                  Container(child: Text('$shift' , maxLines: 1, overflow: TextOverflow.ellipsis,)),
                ],
              ),
            )
          ],
        ),
        SizedBox(height: 20,),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('Comment : ' , style: TextStyle(fontSize: 17 , fontWeight: FontWeight.bold),),
            Expanded(child: Text('$comment' , maxLines: 2, overflow: TextOverflow.ellipsis,))
          ],
        ),
        SizedBox(height: 20,),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('Member Name : ' , style: TextStyle(fontSize: 17 , fontWeight: FontWeight.bold),),
            Expanded(child: Text('$memberName' , maxLines: 1, overflow: TextOverflow.ellipsis,))
          ],
        )
      ],
    );
  }

  buildImageList(imageList)
  {
    return Container(
      margin: EdgeInsets.only(top: 20),
      height:100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
          itemCount: imageList.length,
          itemBuilder: (BuildContext context , int index)
          {
            return GestureDetector(
              onTap: (){
                print(imageList[index]);
                displayPicture(imageList[index]);
              },
              child: Container(
                margin: EdgeInsets.all(4),
                height: 50,
                width: 80,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(5)),
                  color: Colors.white,
                  border: Border.all(
                    color: Colors.grey,
                    // width: 1
                  ),
                  boxShadow: [BoxShadow(
                      color: const Color(0xff4f4f4f),
                      // offset: Offset(7.347880794884119e-16, 12),
                      blurRadius: 2,
                      spreadRadius: 0
                  )]
                ),
                child: Image.network(
                  imageList[index],
                  // 'https://picsum.photos/250?image=9',
                // child: Image.asset(imageList[index],
                fit: BoxFit.contain,
                ),
              ),
            );
          }
          ),
    );
  }

  void displayPicture(imageName)
  {
    showDialog(context: context,
    barrierDismissible: true,
    builder: (BuildContext context)
    {
      return RecentCommentsPicture(imageName);
    }
    );
  }

}
