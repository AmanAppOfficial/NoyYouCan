import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:intl/intl.dart';
import 'package:nowyoucan/model/notification.model.dart';
import 'package:nowyoucan/service/message_service.dart';
import 'package:nowyoucan/service/notification.service.dart';
import 'package:nowyoucan/service/user.dart';
import 'package:nowyoucan/ui/widgets/app_bar.dart';
import 'package:nowyoucan/ui/widgets/loader.dart';
import 'package:nowyoucan/ui/widgets/navigation_drawer_elements.dart';


class NotificationScreen extends StatefulWidget {

  String userRole;
  var mainCtx;
  var currentUser;

  NotificationScreen(this.mainCtx , this.userRole, this.currentUser);
  
  @override
  _NotificationScreenState createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {

  bool isLoading = true;
  List<NotificationList> list ;

  var messageList = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    (() async {
      widget.currentUser = await User.me();
      getNotificationsData();

      setState(() {
      });

    })();

  }


  getNotificationsData() async
  {
    list = await NotificationService.getNotifications();

    if(widget.userRole != "Trade Expert Company")
    await getMessagesData();

    isLoading = false;
    setState(() {
    });
  }


  getMessagesData() async
  {

    messageList = await MessageService.getMessages();


  }


  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomPadding: true,
      appBar: BaseAppBar.getAppBar("Notification"),
      endDrawer: Drawer(
        child: DrawerElements.getDrawer('notification' , context, widget.userRole , widget.mainCtx , widget.currentUser),
      ),
      body: SafeArea(
        child: Center(
          child: (isLoading)  ? Container(
            child: Loader.getLoader(),
        ) : ListView(
          children: <Widget>[
            Container(
                child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: list.length,
                    itemBuilder: (BuildContext context , int index)
                    {
                      return notificationCard(index ,list);
                    }
                ),
              ),
            (widget.userRole != "Trade Expert Company") ?  Container(
              child: ListView.builder(
                  shrinkWrap: true,
                  physics: ClampingScrollPhysics(),
                  itemCount: messageList.length,
                  itemBuilder: (BuildContext context , int index)
                  {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: <Widget>[
                        Container(
                             margin: EdgeInsets.only(right: 29),
                            child: Row(
                               mainAxisAlignment: MainAxisAlignment.end,
                              children: <Widget>[
                                 Text("Sent By : " , style: TextStyle(color: Colors.black),),
                                 Text(messageList[index]["sender"]["firstName"] , style: TextStyle(color: Colors.grey),
                                )
                              ],
                            )
                        ),
                            SizedBox(height: 5,),
                        messageCard(messageList[index]),
                      ],
                    );
                  }
              ),
            ) : Container()
          ],
        ),
        ),
      ),
    );;
  }

  Widget notificationCard(int index , List<NotificationList> data)
  {
    return Container(
      margin: EdgeInsets.all(17),
      padding: EdgeInsets.all(0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(40.0)),
        boxShadow: [BoxShadow(
          color: Colors.grey[300],
          blurRadius: 15,
        )],
      ),
      child: Container(
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            gradient: LinearGradient(
                begin: Alignment(0.0, 1.3),
                end: Alignment(0.5, 0.7),
                colors: [
                                    const Color(0xffec828c),                             //red and orange(default)
                                    const Color(0xfff6a04f)

//                  Colors.greenAccent,                             //green and yellow
//                  Colors.yellow

//                Colors.lightBlueAccent,
//                  Colors.white

//                Colors.pinkAccent,
//                  Colors.white

//                Colors.cyanAccent,
//                  Colors.lightBlueAccent

                ]),
//              borderRadius: BorderRadius.circular(10)
        ),
        child: buildCardData(index , data),
      ),
    );
  }

  buildCardData(int index , List<NotificationList> data)
  {
    return Container(
      padding: EdgeInsets.all(9),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
        buildDateRow(data[index].date),
          SizedBox(height: 10,),
       buildCommentsRow(data[index].message)
      ],),
    );
  }

  buildDateRow(date)
  {
    var timeMomentStr = '';

    DateTime createdAt = DateTime.parse(date);
    DateTime currentDate = DateTime.now();
    var diff = currentDate.difference(createdAt);

    checkMoment(timeMomentStr , diff , createdAt);

    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
       Container(
         width: 40,
         height: 40,
         decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(100.0),
             border: Border.all(
                 width: 0.0,
                 style:BorderStyle.none ,
                 color: Color.fromARGB(255, 0 , 0, 0)
             ),
             image: DecorationImage(
                 fit: BoxFit.cover,
                 image: AssetImage("images/notification.png",)
             )
         ),
       ),
        SizedBox(width: 20,),
        Text(timeMomentStr , style: TextStyle(color: Colors.white , fontWeight: FontWeight.bold),)
      ],
    );
  }

  buildCommentsRow(comment)
  {
    return  Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Expanded(
            child: Text(
              comment,maxLines: 4,overflow: TextOverflow.ellipsis, style: TextStyle(fontSize:16 , color: Colors.black)))
      ],
    );
  }

  void checkMoment(String timeMomentStr, Duration diff, DateTime createdAt)
  {
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
  }

  Widget messageCard(message)
  {
    return Container(
      margin: EdgeInsets.only(left: 17 , right: 17 , bottom: 17),
      padding: EdgeInsets.all(0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(40.0)),
        boxShadow: [BoxShadow(
          color: Colors.grey[300],
          blurRadius: 15,
        )],
      ),
      child: Container(
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          gradient: LinearGradient(
              begin: Alignment(0.0, 1.3),
              end: Alignment(0.5, 0.7),
              colors: [
                const Color(0xffec828c),                             //red and orange(default)
                const Color(0xfff6a04f)
              ]),
//              borderRadius: BorderRadius.circular(10)
        ),
        child: messageCardData(message),
      ),
    );
  }

  messageCardData(message)
  {
    return Container(
      padding: EdgeInsets.all(9),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          messageDateRow(message),
          SizedBox(height: 10,),
          buildCommentsRow(message["body"]),

        ],),
    );
  }

  messageDateRow(message)
  {
    return  Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(100.0),
              border: Border.all(
                  width: 0.0,
                  style:BorderStyle.none ,
                  color: Color.fromARGB(255, 0 , 0, 0)
              ),
              image: DecorationImage(
                  fit: BoxFit.cover,
                  image: AssetImage("images/message_logo.png",)
              )
          ),
        ),
        SizedBox(width: 20,),
        Text(DateFormat("dd,MMM yyy").format(DateTime.parse(message["createdAt"])).toString() , style: TextStyle(color: Colors.white , fontWeight: FontWeight.bold),),
      ],
    );
  }
}
