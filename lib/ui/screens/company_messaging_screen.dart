import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nowyoucan/service/message_service.dart';
import 'package:nowyoucan/ui/screens/create_message_screen.dart';
import 'package:nowyoucan/ui/widgets/app_bar.dart';
import 'package:nowyoucan/ui/widgets/loader.dart';
import 'package:nowyoucan/ui/widgets/navigation_drawer_elements.dart';

class CompanyMessagingScreen extends StatefulWidget {
  String userRole;
  var mainCtx;
  var currentUser;


  CompanyMessagingScreen(this.userRole, this.mainCtx, this.currentUser);


  @override
  _CompanyMessagingScreenState createState() => _CompanyMessagingScreenState();
}

class _CompanyMessagingScreenState extends State<CompanyMessagingScreen> {

  bool isLoading = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    getMessageData();

  }

  var messageList = [];


getMessageData() async
{

  isLoading = true;
  setState(() {
  });

  messageList = await MessageService.getMessages();


  isLoading = false;

  setState(() {
  });

}


  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomPadding: true,
      appBar: BaseAppBar.getAppBar("\nMessages"),
      endDrawer: Drawer(
        child: DrawerElements.getDrawer('company message', context, widget.userRole , widget.mainCtx , widget.currentUser),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.pinkAccent,
        child: Icon(Icons.add , size: 40,),
        onPressed: () async {
         var res =  await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CreateMessageScreen(widget.userRole , widget.mainCtx , widget.currentUser)),
          );


         getMessageData();
        },
      ),

      body: (!isLoading) ? ListView.builder(
          itemCount: messageList.length,
          itemBuilder: (BuildContext context , int index)
          {
            return messageCard(messageList[index]);
          }
      ) :
      Center(
        child: Loader.getLoader(),
      ),
    );
  }




  Widget messageCard(messageItem)
  {
    return Container(
      margin: const EdgeInsets.only(left: 17 , right: 17 , top: 20),
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
        ),
        child: messageCardContent(messageItem),
      ),
    );
  }


  messageCardContent(messageItem)
  {
    return Container(
      padding: EdgeInsets.all(9),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          dateRow(DateTime.parse(messageItem["createdAt"])),
          SizedBox(height: 10,),
          messageRow(messageItem["body"])
        ],),
    );
  }

  dateRow(date)
  {

    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(100.0),
              image: DecorationImage(
                  fit: BoxFit.cover,
                  image: AssetImage("images/message_logo.png",)
              )
          ),
        ),
        SizedBox(width: 20,),
        Text(DateFormat("dd,MMM yyy").format(date).toString() , style: TextStyle(color: Colors.black87 , fontWeight: FontWeight.bold),)
      ],
    );
  }

  messageRow(message)
  {
    return  Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Expanded(
            child: Text(
                message,maxLines: 4,overflow: TextOverflow.ellipsis, style: TextStyle(fontSize:18 , color: Colors.black , fontWeight: FontWeight.w400)))
      ],
    );
  }

}
