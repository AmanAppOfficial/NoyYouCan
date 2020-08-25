import 'dart:convert';
import 'dart:io';

/**
 * @descrption Scheduled task pop up
 * @author Aman Srivastava
 */


import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:nowyoucan/model/scheduledTask.dart';
import 'package:nowyoucan/model/shiftRotation.dart';
import 'package:nowyoucan/service/commentCategory.dart';
import 'package:nowyoucan/model/commentCategory.model.dart';
import 'package:nowyoucan/service/scheduledTasks.dart';
import 'package:nowyoucan/service/upload_image.dart';
import 'package:nowyoucan/ui/widgets/loader.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:html/dom.dart' as dom;
import 'package:image_picker/image_picker.dart';







class ScheduledTaskPopup extends StatefulWidget {


  ScheduledTask task ;
  String date ;
  ShiftRotation selectedShiftRotation;

  ScheduledTaskPopup(this.task, this.date, this.selectedShiftRotation);


  @override
  _ScheduledTaskPopupState createState() => _ScheduledTaskPopupState(

  );
}

class _ScheduledTaskPopupState extends State<ScheduledTaskPopup> {

  List images;
  List imageFileList= List();
  var isSelected = "Incidents";
  TextEditingController _commentController = new TextEditingController();
  // var taskDescription = "";
  List<String> commentCategories = ["Consumable","Incident","Exception"];
  var taskName = "Meeting Roon_test";
  var scheduleDate = "2020-05-13";
  var occurence = "Mor1";
  String categorySelected;

  List<CommentCategory> commentCategoryList = [];
  CommentCategory selectedCategory ;
  ScheduledTask task;
  String date;
  bool isLoading = true;

  bool isMarked = false;

  var numOfImages=0;
  List imageList = List();
  List<File> imageFile = List();
  final picker = ImagePicker();
  bool isQrRequired ;

  @override
  void initState() => {


    (() async {
      task = widget.task;
      date = widget.date;

      isQrRequired = task.isQRrequired;

      await getCommentCategory();
      await getScheduledTask();
      isLoading = false;
      print(imageFileList.toString());
      setState(() {
      });
    })()
  };

  getTask() async {
    try {
      await ScheduledTaskService.get();
    } catch(err) {

    }
  }

  getScheduledTask() async {
    try {
      print(task.status);
       var scheduleTaskResponse = await ScheduledTaskService.getScheduledTask(task.id);
       var commentCategoryId = scheduleTaskResponse["commentCategory"];
      var commentText = scheduleTaskResponse["comment"];
      images = scheduleTaskResponse["images"];

       _commentController.text = commentText.toString();

       if(_commentController.text == "null")
         {
           _commentController.text = "";
         }

        for(int index=0;  index<commentCategoryList.length ; index++)
         {
           if(commentCategoryList[index].id.trim() == commentCategoryId.toString().trim())
             selectedCategory = commentCategoryList[index];
         }


    } catch(error) {

    }
  }
  
  getCommentCategory() async {
    try {
      commentCategoryList = await CommentCategoryService.get();
//      if (commentCategoryList.length > 0) {
//        selectedCategory = commentCategoryList[0];
//      }
      print(commentCategoryList);
    } catch(error) {
      print("@ErrorgetCommentCategory" + error.toString());
    }
  }

  completetask() async {
    try {
      isMarked = true;
      setState(() {
      });

      await validatePostData(imageFileList , selectedCategory , _commentController);

//      Fluttertoast.showToast(msg: "Completed!");
      isMarked = false;
      Navigator.pop(context, "Completed");
    } catch(error) {
      // Fluttertoast.showToast(msg: "Oops ")
      print(error);
    }
  }

  _openGallery(BuildContext context , int index) async
  {
    final pickedFile = await picker.getImage(source: ImageSource.gallery , imageQuality: 80 , maxHeight: 500 , maxWidth: 500);
    this.setState(() {
      if(pickedFile != null)
        {

           if(index <= imageFileList.length - 1)
             {
               imageFileList[index] = pickedFile;
             }
           else
             {
               imageFileList.add(pickedFile);
             }

           imageFile = List();
           imageFileList.forEach((element)
           {
             imageFile.add(File(element.path));
           });


        }

    });
    Navigator.of(context).pop();
  }

  _openCamera(BuildContext context , int index) async
  {
    final pickedFile = await picker.getImage(source: ImageSource.camera , imageQuality: 80 , maxHeight: 500 , maxWidth: 500);
    this.setState(() {
      if(pickedFile != null)
        {

          if(index <= imageFileList.length - 1)
          {
            imageFileList[index] = pickedFile;
          }
          else
          {
            imageFileList.add(pickedFile);
          }

          imageFile = List();
          imageFileList.forEach((element)
          {
            imageFile.add(File(element.path));
          });


        }

    });
    Navigator.of(context).pop();
  }


  Future<void> _showChoiceDialog(BuildContext context , int index)
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
                  _openGallery(context , index);
                },
              ),
              GestureDetector(
                child: Container(
                  padding: EdgeInsets.all(10),
                  child: Text("Camera" ,  style: TextStyle(fontSize: 20),),),
                onTap: (){
                  _openCamera(context , index);
                },
              )
            ],
          ),
        ),
      );
    });
  }


  @override
  Widget build(BuildContext context) {
    return (isLoading) ? Loader.getLoader() : ListView(
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
                                                    "Schedule Tasks",
                                                    style: const TextStyle(
                                                        color:  Colors.white,
                                                        fontWeight: FontWeight.bold,
                                                        fontFamily: "Gotham",
                                                        fontStyle:  FontStyle.normal,
                                                        fontSize: 22.5),
                                                    textAlign: TextAlign.center)
                                            ),
                                            GestureDetector(
                                              onTap: (){ if(!isMarked)
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

  buildText(String text)
  {
    return Text(
        "$text",
        style: const TextStyle(
            color:  const Color(0xff343233),
            fontWeight: FontWeight.w400,
            fontFamily: "Gotham",
            fontStyle:  FontStyle.normal,
            fontSize: 15.0
        ),
        textAlign: TextAlign.center
    );

  }



  details()
  {

    return   Stack(
      children: <Widget>[
        Container(
            alignment: Alignment.center,
            margin: EdgeInsets.only(top: 10 , bottom: 10),
            child: Container(
              child: Column(
                children: <Widget>[
                  buttonRow(),
                  (isSelected == "Incidents")  ? Column(
                    children: <Widget>[
                      commentCategoryLayout(),
                      commentSection(),
                      taskNameLayout(),
                      timingLayout(),
//                      (isQrRequired) ? qrLayout() : Container(),
                      addImageLayout(),
                      actionButtons(),
                    ],
                  ) : Container(
                    child : taskDescriptionLayout(),
                  ),
                ],
              ),
            )
        ),
        (isMarked) ?  Center(child: Container(
          height: MediaQuery.of(context).size.height,
            alignment: Alignment.center,
            child :createLoader())) : Container(
        )
      ],
    );
  }

  buttonRow() {                                            //Buttons layout.......
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        Expanded(
          child: GestureDetector(
            onTap: (){
              isSelected = "Incidents";
              setState(() {});
            },
            child: Container(
                alignment: Alignment.center,
                height: 38,
                child: buildText("Details"),
                margin: EdgeInsets.all(8),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(
                        Radius.circular(8.4576)
                    ),
                    boxShadow: [BoxShadow(
                        color: Colors.grey,
                        offset: Offset(0,0),
                        blurRadius: 2,
                        spreadRadius: 0
                    )] ,
                    color: (isSelected == "Incidents") ? const Color(0xffeaeaea) : Colors.white
                )
            ),
          ),
        ),
        Expanded(
          child: GestureDetector(
            onTap: (){
              isSelected = "Details";
              setState(() {});
            },
            child: Container(
                alignment: Alignment.center,
                child: buildText("Description"),
                margin: EdgeInsets.all(8),
                height: 38,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(
                        Radius.circular(8.4576)
                    ),
                    boxShadow: [BoxShadow(
                        color: Colors.grey,
                        offset: Offset(0,0),
                        blurRadius: 2,
                        spreadRadius: 0
                    )] ,
                    color: (isSelected == "Details") ? const Color(0xffeaeaea) : Colors.white
                )
            ),
          ),
        ),


      ],
    );
  }


  commentCategoryLayout()                                     //Radio buttons layout
  {
    return Column(
      children: <Widget>[
        Container(
          margin: EdgeInsets.only(left: 36 , top: 20, bottom: 10),
          alignment: Alignment.topLeft,
          child: Text(
              "Comments Categories",
              style: const TextStyle(
                  color:  const Color(0xff343233),
                  fontWeight: FontWeight.w400,
                  fontFamily: "Gotham",
                  fontStyle:  FontStyle.normal,
                  fontSize: 14.0
              ),
              textAlign: TextAlign.center
          ),
        ),
        Container(
          margin: EdgeInsets.all(8),
          child: Column(
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
               Column(
                 children: <Widget>[
                   Row(
                     children: <Widget>[
                       GestureDetector(
                         onTap: (){
                          //  categorySelected = commentCategories[0];
                           selectedCategory = commentCategoryList[0];
                           setState(() {});
                         } ,
                         child: buildCheckBox( (selectedCategory != null) ? (selectedCategory.id == commentCategoryList[0].id) ? Colors.orangeAccent :Colors.white : Colors.white),
                       ),
                       SizedBox(width: 6,),
                       Icon(Icons.print , color: Colors.orangeAccent, size: 40,),
                     ],
                   ),
                   SizedBox(height: 10,),
                   buildCategoryText(commentCategoryList[0].name),
                 ],
               ),
                SizedBox(width: 6,),
                Column(
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        GestureDetector(
                          onTap: (){
                            // categorySelected = commentCategories[1];
                            selectedCategory = commentCategoryList[1];
                            setState(() {});
                          } ,
                          child:buildCheckBox((selectedCategory != null) ? (selectedCategory.id == commentCategoryList[1].id) ? Colors.orangeAccent :Colors.white : Colors.white),
                        ),
                        SizedBox(width: 6,),
                        Icon(Icons.print , color: Colors.orangeAccent, size: 40,),
                      ],
                    ),
                    SizedBox(height: 10,),
                    buildCategoryText(commentCategoryList[1].name),
                  ],
                ),

                SizedBox(width: 6,),
                Column(
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        GestureDetector(
                          onTap: (){
                            // categorySelected = commentCategories[2];
                            selectedCategory = commentCategoryList[2];
                            setState(() {});
                          } ,
                          child: buildCheckBox((selectedCategory != null) ? (selectedCategory.id == commentCategoryList[2].id) ? Colors.orangeAccent :Colors.white : Colors.white),
                        ),
                        SizedBox(width: 6,),
                        Icon(Icons.print , color: Colors.orangeAccent, size: 40,),


                      ],
                    ),
                    SizedBox(height: 10,),
                    buildCategoryText(commentCategoryList[2].name),
                  ],
                ),
              ],
            ),



          ],
          ),
        )
      ],
    );
  }

  commentSection()
  {
    return Column(
      children: <Widget>[
        Container(
          margin: EdgeInsets.only(left: 36 , top: 20, bottom: 10),
          alignment: Alignment.topLeft,
          child: Text(
              "Comments",
              style: const TextStyle(
                  color:  const Color(0xff343233),
                  fontWeight: FontWeight.w400,
                  fontFamily: "Gotham",
                  fontStyle:  FontStyle.normal,
                  fontSize: 14.0
              ),
              textAlign: TextAlign.center
          ),
        ),

        Container(
          margin: EdgeInsets.only(top: 4 , left: 25 , right: 25 , bottom: 10),
            height: 90,
            child: Container(
              margin: EdgeInsets.all(7),
              child: TextField(
                controller: _commentController,
                decoration: new InputDecoration.collapsed(
                    hintText: '  Comment...'
                ),
                keyboardType: TextInputType.multiline,
                maxLines: null,
              ),
            ),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.all(
                    Radius.circular(9.4576)
                ),
                boxShadow: [BoxShadow(
                    color: Colors.grey,
                    offset: Offset(0.4,0),
                    blurRadius: 5,
                    spreadRadius: 0
                )] ,
                color: Colors.white
            )
        )
      ],
    );
  }

  taskNameLayout()
  {
    return Column(
      children: <Widget>[
        Container(
          margin: EdgeInsets.only(left: 36 , top: 20, bottom: 10),
          alignment: Alignment.topLeft,
          child: Text(
              "Task Name",
              style: const TextStyle(
                  color:  const Color(0xff343233),
                  fontWeight: FontWeight.w400,
                  fontFamily: "Gotham",
                  fontStyle:  FontStyle.normal,
                  fontSize: 14.0
              ),
              textAlign: TextAlign.center
          ),
        ),
        Container(
          alignment: Alignment.centerLeft,
            margin: EdgeInsets.only(top: 4 , left: 25 , right: 25 , bottom: 10),
            height: 49,
            width: MediaQuery.of(context).size.width,
            child: Container(
              margin: EdgeInsets.all(7),
              child: Text(
                  task.config.name + "_" + task.name,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      color:  const Color(0xff3a3838),
                      fontWeight: FontWeight.w300,
                      fontFamily: "Gotham",
                      fontStyle:  FontStyle.normal,
                      fontSize: 17.0
                  ),
                  textAlign: TextAlign.left
              ),
            ),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.all(
                    Radius.circular(9.4576)
                ),
                color: const Color(0xffeaeaea)
            )
        )

      ],
    );
  }

  taskDescriptionLayout()
  {
    return Column(
      children: <Widget>[
        Container(
          margin: EdgeInsets.only(left: 36 , top: 20, bottom: 10),
          alignment: Alignment.topLeft,
          child: Text(
              "Task Description",
              style: const TextStyle(
                  color:  const Color(0xff343233),
                  fontWeight: FontWeight.w400,
                  fontFamily: "Gotham",
                  fontStyle:  FontStyle.normal,
                  fontSize: 14.0
              ),
              textAlign: TextAlign.center
          ),
        ),

        Container(
            margin: EdgeInsets.only(top: 4 , left: 25 , right: 25 , bottom: 10),
            child: Container(
              width: MediaQuery.of(context).size.width,
              margin: EdgeInsets.all(7),
              child: Html(
                data: task.config.desc,

              )
            ),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.all(
                    Radius.circular(9.4576)
                ),
                boxShadow: [BoxShadow(
                    color: Colors.grey,
                    offset: Offset(0.4,0),
                    blurRadius: 5,
                    spreadRadius: 0
                )] ,
                color: Colors.white
            )
        )
      ],
    );
  }

  timingLayout()
  {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        Column(
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(left: 0 , top: 20, bottom: 10),
              alignment: Alignment.topLeft,
              child: Text(
                  "Schedual Date",
                  style: const TextStyle(
                      color:  const Color(0xff343233),
                      fontWeight: FontWeight.w400,
                      fontFamily: "Gotham",
                      fontStyle:  FontStyle.normal,
                      fontSize: 14.0
                  ),
                  textAlign: TextAlign.center
              ),
            ),
            Container(
              alignment: Alignment.center,
              width: MediaQuery.of(context).size.width/3,
                height: 39,
                child: Text(
                    date,
                    style: const TextStyle(
                        color:  const Color(0xff3a3838),
                        fontWeight: FontWeight.w300,
                        fontFamily: "Gotham",
                        fontStyle:  FontStyle.normal,
                        fontSize: 15.0
                    ),
                    textAlign: TextAlign.left
                ),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(
                        Radius.circular(9.4576)
                    ),
                    color: const Color(0xffeaeaea)
                )
            )
          ],
        ),
        Column(
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(left: 0 , top: 20, bottom: 10),
              alignment: Alignment.topLeft,
              child: Text(
                  "Occurrence",
                  style: const TextStyle(
                      color:  const Color(0xff343233),
                      fontWeight: FontWeight.w400,
                      fontFamily: "Gotham",
                      fontStyle:  FontStyle.normal,
                      fontSize: 14.0
                  ),
                  textAlign: TextAlign.center
              ),
            ),
            Container(
              alignment: Alignment.center,
                width: MediaQuery.of(context).size.width/3,
                height: 39,
                child: Text(
                    "$occurence",
                    style: const TextStyle(
                        color:  const Color(0xff3a3838),
                        fontWeight: FontWeight.w300,
                        fontFamily: "Gotham",
                        fontStyle:  FontStyle.normal,
                        fontSize: 15.0
                    ),
                    textAlign: TextAlign.left
                ),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(
                        Radius.circular(9.4576)
                    ),
                    color: const Color(0xffeaeaea)
                )
            )
          ],
        )
      ],
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
              onTap: (){
                completetask();
                // Navigator.pop(context);
              },
              child: Container(
                  child: Text(
                      (task.status == "Pending") ? "Mark as complete" : "Update",
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
                if(!isMarked)
                  {
                    Navigator.pop(context);
                  }

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

  createLoader()
  {
    return SpinKitCircle(
      color: Colors.orangeAccent,
      size: 170.0,
      // controller: AnimationController(vsync: this, duration: const Duration(milliseconds: 1200)),
    );
  }

  buildCheckBox(Color color)
  {
    return Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.all(
                Radius.circular(4)
            ),
            boxShadow: [BoxShadow(
                color: Colors.grey,
                offset: Offset(0,0.5),
                blurRadius: 2,
                spreadRadius: 0
            )] ,
            color: color
        )
    );
  }

  buildCategoryText(String text)
  {
    return Text(
        "${text}",
        style: const TextStyle(
            color:  const Color(0xff343233),
            fontWeight: FontWeight.w400,
            fontFamily: "Gotham",
            fontStyle:  FontStyle.normal,
            fontSize: 12.0
        ),
        textAlign: TextAlign.center
    );
  }

  addImageLayout()
  {
    return Container(
      margin: EdgeInsets.all(20),
      height: 140,
      child: Center(
        child:

          ListView.builder(
            scrollDirection: Axis.horizontal,
              itemCount:  (images.length != 0)  ? (images.length) : ((imageFileList.length <3) ? imageFileList.length + 1 : imageFileList.length) ,
              itemBuilder: (BuildContext context , int index)
              {
                return GestureDetector(
                    onTap: (){
                      if(images.length == 0)
                      _showChoiceDialog(context , index);
                    },
                    child: (images.length != 0) ? Image.network(images[index] , height: 130, width: 130,) :
                    ((index < imageFile.length) ? Image.file(imageFile[index] ,  fit: BoxFit.contain , height: 130, width: 130) :
                    Image.asset("images/addpic.png" , fit: BoxFit.contain , height: 60, width: 60,))
                );

              }),

      ),
    );
  }

  validatePostData(List imageFileList, CommentCategory selectedCategory, TextEditingController commentController) async
  {
    if(imageFileList.length == 0 && selectedCategory == null && commentController.text == "")
      {
        var result = await ScheduledTaskService.completeTask(task.id , {});
      }
    else if(imageFileList.length !=0 && selectedCategory == null)
    {
      Fluttertoast.showToast(msg: "Comment Category Required");
    }
    else if(commentController.text !="" && selectedCategory == null)
    {
      Fluttertoast.showToast(msg: "Comment Category Required");
    }
    else
    {
      if(imageFileList.length !=0)
      {
        imageFileList.forEach((element) {
          imageList.add((File(element.path)));
        });
        List<String> imageUrlList = await ImageUploadService.upload(imageList , "task");

        if(commentController.text == "" && selectedCategory == null)
        {
          var result = await ScheduledTaskService.completeTask(task.id , {
            "images" : json.encode(imageUrlList)
          });
        }
        else if(commentController.text != "" && selectedCategory==null)
        {
          var result = await ScheduledTaskService.completeTask(task.id, {
            "comment": commentController.text,
            "images" : json.encode(imageUrlList)
          });
        }
        else if(commentController.text == "null" && selectedCategory!=null)
        {
          var result = await ScheduledTaskService.completeTask(task.id, {
            "commentCategory" : selectedCategory.id,
            "images" : json.encode(imageUrlList)
          });
        }
        else
        {
          var result = await ScheduledTaskService.completeTask(task.id, {
            "commentCategory":selectedCategory.id,
            "comment":commentController.text,
            "images" : json.encode(imageUrlList)
          });
        }

      }
      else
      {
        if(commentController.text == "" && selectedCategory == null)
        {
          var result = await ScheduledTaskService.completeTask(task.id , {});
        }
        else if(commentController.text != "" && selectedCategory==null)
        {
          var result = await ScheduledTaskService.completeTask(task.id, {
            "comment":commentController.text
          });
        }
        else if(commentController.text == "null" && selectedCategory!=null)
        {
          var result = await ScheduledTaskService.completeTask(task.id, {
            "commentCategory" : selectedCategory.id
          });
        }
        else if(commentController.text != "null" && selectedCategory!=null)
        {
          var result = await ScheduledTaskService.completeTask(task.id, {
            "commentCategory" : selectedCategory.id,
            "comment":commentController.text
          });
        }
      }
    }

  }

//  qrLayout()
//  {
//    return GestureDetector(
//
//      onTap: ()  async {
//       var res = await scanQR();
//       print(res.toString());
//      },
//
//      child: Container(
//        padding: EdgeInsets.all(7),
//        margin: EdgeInsets.only(left: 20 , top: 40 , right: 20 , bottom: 20),
//        alignment: Alignment.center,
//        decoration: BoxDecoration(
//          color: Colors.grey[500],
//          borderRadius: BorderRadius.circular(8)
//        ),
//          child: Text('Scan' , style: TextStyle(fontSize: 25 , color: Colors.black),),
//      ),
//    );
//  }
//

}
