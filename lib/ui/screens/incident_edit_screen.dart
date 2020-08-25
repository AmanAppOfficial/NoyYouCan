import 'dart:io';

/**
 * @descrption Incident detail screen
 * @author Aman Srivastava
 */



import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
// import 'package:http/http.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:nowyoucan/model/incident.model.dart';
import 'package:nowyoucan/model/incidentComment.model.dart';
import 'package:nowyoucan/service/incident.service.dart';
import 'package:nowyoucan/service/upload_image.dart';
import 'package:nowyoucan/service/user.dart';
import 'package:nowyoucan/ui/widgets/app_bar.dart';
import 'package:nowyoucan/ui/widgets/loader.dart';
import 'package:nowyoucan/ui/widgets/navigation_drawer_elements.dart';
import 'package:nowyoucan/ui/popUps/member-assign.view.dart';
import 'package:uuid/uuid.dart';
import 'package:uuid/uuid_util.dart';


class IncidentEditScreen extends StatefulWidget {

  IncidentList incident=null;
  String userRole;
  var mainCtx;
  var currentUser;


  IncidentEditScreen(this.incident, this.userRole , this.mainCtx, this.currentUser);

  @override
  _IncidentEditScreenState createState() => _IncidentEditScreenState();
}

class _IncidentEditScreenState extends State<IncidentEditScreen> {



  List<IncidentComment> commentList;

  String buildingText = '';
  String facilityText = '';
  String itemText = '';
  String suiteText = '';
  String floorText = '';
  String firstResponderText = '';
  String tradeExpertText = '';
  String addressText = '';
  // To add
  String categoryText = '';
  String incidentText = '';

  bool isLoading = true;
  bool isCommentListLoading = false;
  String timeMomentStr;
  final picker = ImagePicker();
  var imagePath=  null;
  var parent;
  List imageList = List();
  TextEditingController commentController = new TextEditingController();
  TextEditingController _replyController = new TextEditingController();

  // IncidentDetailData data;
  
  IncidentList incidentDetail;

  markResolved() async {
    print(incidentDetail.id);
    var response = await IncidentService.markResolved(incidentDetail.id);
    print(response);
    Fluttertoast.showToast(msg: "Incident Updated Successfully");
    Navigator.pop(context, "Refresh");
  }

  getIncidentDetails() async
  {
    isLoading = true;
    setState(() {
    });

    incidentDetail = await IncidentService.getDetails(widget.incident.id);
    this.buildingText = incidentDetail.buildingName;
    this.addressText = incidentDetail.buildingAddress;
    if(incidentDetail.facilityPerSuiteId != null) {
      this.facilityText = incidentDetail.facilityPerSuiteAlias;
    } else if(incidentDetail.facilityPerFloorId != null) {
      this.facilityText = incidentDetail.facilityPerFloorAlias;
    }

    if(incidentDetail.itemId != null) {
      this.itemText = incidentDetail.itemAlias;
    } else {
      this.itemText = "N/A";
    }

    if(incidentDetail.suite != null) {
      this.suiteText = incidentDetail.suite.suiteNo;
      this.floorText = incidentDetail.suite.floorAlias;
    } else if (incidentDetail.floor != null) {
      this.floorText = incidentDetail.floor.floorAlias;
      this.suiteText = "N/A";
    }

    if (incidentDetail.firstResponderCompanyId != null) {
     this.firstResponderText = incidentDetail.firstResponderCompanyEmail;  
    } else {
      this.firstResponderText = "N/A";
    }

    if (incidentDetail.tradeExpertMemeberId != null) {
     this.tradeExpertText = incidentDetail.tradeExpertMemeberEmail;
    } else {
      this.tradeExpertText = "N/A";
    }

    if (incidentDetail.categoryId != null) {
      this.categoryText = incidentDetail.categoryName;
    } else {
      this.categoryText = "N/A";
    }

    if(incidentDetail.facilityIncidentTypeId != null) {
      this.incidentText = incidentDetail.facilityIncidentTypeName;
    } else if(incidentDetail.facilityItemIncidentTypeId != null) {
      this.incidentText = incidentDetail.facilityItemIncidentTypeName;
    } else {
      this.incidentText = "Other";
    }

    commentList = await IncidentService.incidentComments(widget.incident.id);

    isLoading = false;
    setState(() {
    });

  }


  @override
  void initState() {
    super.initState();

    (() async {
      widget.currentUser = await User.me();
      getIncidentDetails();
      setState(() {
      });



    })();
  }


  createComment(body)
  async {
    isCommentListLoading = true;
    setState(() {
    });

    var res = await IncidentService.createIncidentComment(body);

    commentList = await IncidentService.incidentComments(widget.incident.id);

    isCommentListLoading = false;
    setState(() {

    });

  }

  Future<void> selectImageDialog(BuildContext context)
  {
    return showDialog(context : context , builder: (BuildContext context)
    {
      return AlertDialog(
        title: Text('Choose'),
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              GestureDetector(
                child: Container(
                    padding: EdgeInsets.all(10),
                    child: Text("Gallery" , style: TextStyle(fontSize: 20),)),
                onTap: (){
                  _openGallery(context);
                },
              ),
              GestureDetector(
                child: Container(
                  padding: EdgeInsets.all(10),
                  child: Text("Camera" ,  style: TextStyle(fontSize: 20),),),
                onTap: (){
                  _openCamera(context);
                },
              )
            ],
          ),
        ),
      );
    });
  }


  _openGallery(BuildContext context) async
  {

    final pickedFile = await picker.getImage(source: ImageSource.gallery , imageQuality: 80 , maxHeight: 500 , maxWidth: 500);

      if(pickedFile != null)
      {
        imagePath = pickedFile.path;

        var res = await uploadImage();

            if(res != null && parent==null)
            {
              var commentId = Uuid().v1();
              createComment({
                "commentId" : commentId,
                "fileMimeType" : "image/png",
                "fileUrl" : res[0].toString(),
                "incident" : incidentDetail.id.toString()
              });
            }
            else
              {
                var commentId = Uuid().v1();
                createComment({
                  "commentId" : commentId,
                  "fileMimeType" : "image/png",
                  "fileUrl" : res[0].toString(),
                  "incident" : incidentDetail.id.toString(),
                  "parentId" : parent.toString()
                });
              }





      }


    Navigator.of(context).pop();
  }

  _openCamera(BuildContext context) async
  {
    final pickedFile = await picker.getImage(source: ImageSource.camera , imageQuality: 80 , maxHeight: 500 , maxWidth: 500);

      if(pickedFile != null)
      {
        imagePath = pickedFile.path;

        var res = await uploadImage();

        if(res != null)
        {
          var commentId = Uuid().v1();
          createComment({
            "commentId" : commentId,
            "fileMimeType" : "image/png",
            "fileUrl" : res[0].toString(),
            "incident" : incidentDetail.id.toString()
          });
        }


      }


    Navigator.of(context).pop();
  }


  @override
  Widget build(BuildContext context) {


    return Scaffold(
      backgroundColor: Colors.white,
      appBar: BaseAppBar.getAppBar('incident'),
      endDrawer: Drawer(
        child: DrawerElements.getDrawer('incident' , context, widget.userRole , widget.mainCtx , widget.currentUser),
      ),
      body: (isLoading) ? Container(
        child: Center(
          child: Loader.getLoader(),
        ),
      ) : ListView(
        scrollDirection: Axis.vertical,
        children: <Widget>[
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  detailLayout('images/floor.png' , 'BUILDING' , incidentDetail.buildingName),
                  detailLayout('images/Location.png' , 'ADDRESS' , addressText),
                  // detailLayout('images/briefcase.png' , 'FACILITY' , facilityText),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  detailLayout('images/board.png' , 'INCIDENT' , incidentText),
                  detailLayout('images/navigation.png' , 'INCIDENT CATEGORY' , categoryText),
                  // detailLayout('images/briefcase.png' , 'FACILITY' , facilityText),
                  // detailLayout('images/Location.png' , 'ADDRESS' , addressText),
                ],
              ),
              Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  detailLayout('images/briefcase.png' , 'FACILITY' , facilityText),
                  // detailLayout('images/item.png' , 'ITEM' , itemText),
                  detailLayout('images/suit.png' , 'SUITE' , suiteText),
                ],
              ),
              Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  detailLayout('images/alignment.png' , 'FLOOR' , floorText),
                  detailLayout('images/item.png' , 'ITEM' , itemText),
                  // detailLayout('images/tie.png' , 'FIRST RESPONDER' , firstResponderText),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  detailLayout('images/chart.png' , 'TRADE EXPERRT' , tradeExpertText),
                  detailLayout('images/tie.png' , 'FIRST RESPONDER' , firstResponderText),
                  // detailLayout('images/briefcase.png' , 'FACILITY' , facilityText),
                  // detailLayout('images/Location.png' , 'ADDRESS' , addressText),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: Container(
                      child: InkWell(
                        onTap: () {
                          markResolved();
                        },
                        child: Text("Mark as Resolved" , 
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20.0
                          )
                        ),
                      ),
                      alignment: Alignment.center,
                      margin: EdgeInsets.only(top: 20.0, right: 20.0, left: 20.0),
                      // width: 180.0,
                      height: 50.0,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Color(0xff90c217),
                        boxShadow: [
                          new BoxShadow(
                            color: Colors.grey,
                            offset: Offset(0.0, 0.5),
                            blurRadius: 4
                          ),],
                        shape: BoxShape.rectangle,
                      ),
                  ))
                ],
              ),
              commentsLayout(),
               writeComment()
              // images/board.png
    // - images/navigation.png
            ],
          )
        ],
      ),
    );
  }

  Column detailLayout(String imagepath , String text , String elementsText) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
      Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          new Container(
            margin: const EdgeInsets.only(top: 40 , right: 7 , bottom: 4 , left: 10),
            width: 50.0,
            height: 35.0,
            child: Image.asset('$imagepath' ,scale: 2,),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                new BoxShadow(
                  color: Colors.grey,
                  blurRadius: 2.0,
                  offset: Offset(0.0, 0.6),
                ),],
              shape: BoxShape.circle,
            ),
          ),
          Container(
              margin: EdgeInsets.only(top: 25 , left: 5),
              child: Text('$text' , style: TextStyle(color: Colors.grey , fontSize: 13),)),
        ],
      ), (text == "TRADE EXPERRT" && elementsText == "N/A" ) ? InkWell(
        onTap: () => {
          // print("text");
          memberAssign(incidentDetail)
          
        },
        child: Container(
            child: Text("ASSIGN TRADE EXPERT" , style: TextStyle(
              color: Colors.white
            )),
            alignment: Alignment.center,
            margin: const EdgeInsets.all(4),
            width: 180.0,
            height: 30.0,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Color(0xfff6a04f),
              boxShadow: [
                new BoxShadow(
                  color: Colors.grey,
                  offset: Offset(0.0, 0.5),
                  blurRadius: 4
                ),],
              shape: BoxShape.rectangle,
            ),
        ),
      ):
        Container(
          child: Center(
            child: new Text(
              '$elementsText',
              overflow: TextOverflow.fade,
              maxLines: 1,
              softWrap: false,
              style: new TextStyle(
                fontSize: 13.0,
                color: Colors.orange,
                fontWeight: FontWeight.normal,
              ),
            ),
          ),
          margin: const EdgeInsets.all(4),
          width: 180.0,
          height: 50.0,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Colors.white,
            boxShadow: [
              new BoxShadow(
                color: Colors.grey,
                offset: Offset(0.0, 0.3),
                blurRadius: 2
              ),],
            shape: BoxShape.rectangle,
          ),
        ),
      ],

    );
  }

  memberAssign(IncidentList incident) async {
    var res = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return (MediaQuery.of(context).orientation == Orientation.portrait) ?
        MemberAssign(incident) :
        ListView(
          children: <Widget>[
            MemberAssign(incident)
          ],
        );
      });
      print(res);
      // getIncidentDetails();
    }




  Container commentsLayout()
  {

    return Container(
      margin: const EdgeInsets.only(top: 20.0),
      color:Color.fromARGB(238, 238, 238, 238),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
              margin: const EdgeInsets.only(top: 20.0 , left: 20.0),
              child: Text('Comment' , style: TextStyle(fontSize: 18.0 , color: Colors.black , fontWeight: FontWeight.bold),)),
          (!isCommentListLoading) ? Container(
            height: 453,
            child: ListView.builder(
                itemCount: commentList.length,
                itemBuilder: (BuildContext context, int index)
                {
                  return commentView(commentList[index]);
                }
            ),
          ) : Container(
            height: 453,
            alignment: Alignment.center,
            child: Loader.getListLoader(context),
          ),
        ],
      ),
    );


  }

  commentView(IncidentComment commentData)
  {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        messageBox(commentData , [Colors.lightBlue, Colors.blue]),
       childComment(commentData.child),

      ],
    );
  }

  childComment(List<IncidentComment> child)
  {
    return Container(
      child: ListView.builder(
        shrinkWrap: true,
          physics: ClampingScrollPhysics(),
          itemCount: child.length,
          itemBuilder: (BuildContext context, int index)
          {
              return messageBox(child[index] , [Colors.grey, Colors.black38]);
          }
      ),
    );

  }

  messageBox( IncidentComment comment , color)
  {

    createMoment(DateTime.parse(comment.createdAt).toLocal());

    return Container(
      child: Column(
        crossAxisAlignment: (comment.createdBy.id != widget.currentUser["_id"]) ? CrossAxisAlignment.start : CrossAxisAlignment.end,
        children: <Widget>[
          Container(
            width: 300,
            child: Container(
              margin: EdgeInsets.only(top: 15 , left: 20 , right: 20),
              child: Row(
                children: <Widget>[
                  Container(
                    child: Text(comment.createdBy.firstName + ","  , style: TextStyle(color : Colors.black ,fontWeight: FontWeight.bold),),
                  ),
                  Text(timeMomentStr.toString() , style: TextStyle(fontSize: 13 , color: Colors.black),),
                ],
              ),
            ),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: (comment.createdBy.id != widget.currentUser["_id"])?  MainAxisAlignment.start : MainAxisAlignment.end,
            children: <Widget>[
              (comment.message != null) ?
              Container(
                width: 300,
                decoration: BoxDecoration(
//              color: color,
                    gradient: LinearGradient(
                        begin: Alignment(0, 1.9),
                        end: Alignment(0.6, 0.2),

                        colors: color ),
                    borderRadius:(comment.createdBy.id != widget.currentUser["_id"]) ?  BorderRadius.only(topRight: Radius.circular(8) , bottomLeft: Radius.circular(8) , bottomRight:  Radius.circular(8) ) : BorderRadius.only(topRight: Radius.circular(8) , bottomLeft: Radius.circular(8) , topLeft:  Radius.circular(8) ),
                ),
                margin: EdgeInsets.only(top: 5 , left: 20 , right: 7),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                        margin: EdgeInsets.all(10),
                        child: Text(comment.message , style: TextStyle(color: Colors.white ,fontSize: 18),)),
                  ],
                ),
              )
                  : Image.network(comment.imageUrl , width: 200, height: 200,)
              ,
              GestureDetector(
                onTap: (){

                  var parentId = (comment.parentId != null) ? comment.parentId : comment.commentId;
                  openReplyBox(parentId , context);

                },
                child: Container(
                    alignment: Alignment.topRight,
                    margin: EdgeInsets.only(top: 10),
                    child: Text("Reply")),
              )
            ],
          ),
        ],
      ),
    );
  }

   createMoment(DateTime date)
  {
    Duration time = DateTime.now().difference(date);

    if(time.inSeconds <= 59) {
      timeMomentStr = "Few Seconds Ago";
    } else if (time.inMinutes > 0 && time.inMinutes <= 10) {
      timeMomentStr = "Few Minutes Ago";
    } else if(time.inMinutes > 10 && time.inMinutes <= 59) {
      timeMomentStr = time.inMinutes.toString() +" Minutes Ago";
    } else if (time.inMinutes > 0 && time.inMinutes <= 24)  {
      timeMomentStr = "Few Hours Ago";
    } else if (time.inMinutes > 24 && time.inMinutes <= (24*3)){
      timeMomentStr = "Few Days Ago";
    } else if (time.inMinutes >= (24*3) && time.inMinutes <= (24*15)){
      timeMomentStr = time.inDays.toString() + " Days Ago";
    } else {
      timeMomentStr = DateFormat("HH:mm  dd MMM,yyyy").format(date);
    }
  }

  writeComment()
  {
    return Container(
      padding: EdgeInsets.all(7),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Expanded(
            child: TextField(
              controller: commentController,
              decoration: InputDecoration(
                  hintText: "Write comment..."
              ),
            ),
          ),
          GestureDetector(
            onTap: (){
              selectImageDialog(context);
            },
            child: Container(
//                padding: EdgeInsets.all(5),
              height: 40,
              width: 40,
              child: Icon(Icons.insert_photo),
//              color: Colors.grey,
            ),
          ),
          InkWell(
            onTap: (){
              //hit create api
              print("text : ${commentController.text}");
            },
            child: GestureDetector(
              onTap: (){
                var commentId = Uuid().v1();

                if(commentController.text != "")
                  {
                    createComment({
                      "commentId" : commentId.toString(),
                      "incident" : incidentDetail.id.toString(),
                      "message" : commentController.text,
                    });
                  }


                commentController.text = "";

              },
              child: Container(
                padding: EdgeInsets.all(5),
                height: 40,
                width: 40,
                child: Image.asset("images/message_icon.png" , fit: BoxFit.contain),
              ),
            ),
          )
        ],
      ),
      decoration: BoxDecoration(
        color: Colors.white,
      ),
    );
  }

  openReplyBox(String parentId, BuildContext context) async {
    parent = null;
    parent = parentId;
   var res =  await _displayCommentDialog(context);
   if(res != null)
     {
       var commentId = Uuid().v1();
       print(res.toString());

       createComment({
         "commentId" : commentId.toString(),
         "incident" : incidentDetail.id.toString(),
         "message" : res.toString(),
         "parentId" : parentId.toString()
       });

     }


  }

  _displayCommentDialog(BuildContext context) async {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Enter Comment'),
            content: StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                return Container(
                  height: 150,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        height: 100,
                        child: TextField(
                          controller: _replyController,
                          decoration:
                          InputDecoration(hintText: "Enter comment here..."),
                        ),
                      ),
                      SizedBox(height: 10,),
                      GestureDetector(
                        onTap: () async {
                          _replyController.text =null;
                          _openGallery(context);
//                          Navigator.of(context).pop();
                        },
                        child: Container(
                          padding: EdgeInsets.all(5),
                          height: 40,
                          width: 40,
                          child: Icon(Icons.insert_photo , size: 30,),
                        ),
                      )
                    ],
                  ),
                );
              },
            ),
            actions: <Widget>[
              new FlatButton(
                child: new Text('Done'),
                onPressed: () {

                  if(_replyController.text != "")
                    {
                      Navigator.pop(context , _replyController.text);
                    }

                },
              )
            ],
          );
        });
  }



  uploadImage() async
  {

    if(imageList.length>0)
    {
      imageList.clear();
    }

    List imageUrlList;
    if(imagePath!=null)
    {
      imageList.add(File(imagePath));
      imageUrlList = await ImageUploadService.upload(imageList , "files");
    }

    return imageUrlList;
  }



}





