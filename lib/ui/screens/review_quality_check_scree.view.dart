import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:nowyoucan/service/upload_image.dart';
import 'package:nowyoucan/ui/widgets/app_bar.dart';
import 'package:nowyoucan/ui/widgets/loader.dart';
import 'package:nowyoucan/ui/widgets/navigation_drawer_elements.dart';
import 'package:nowyoucan/service/qualityReviewItem.service.dart';
import 'package:nowyoucan/model/qualityReviewItem.model.dart';
import 'package:nowyoucan/model/qualityReviewComment.model.dart';
import 'package:nowyoucan/service/qualityReviewComment.service.dart';
import 'package:nowyoucan/model/qualityInterval.dart';
import 'package:nowyoucan/service/quality_service.dart';
import 'package:image_picker/image_picker.dart';

import 'dart:convert';
import 'dart:io';

class ReviewQualityCheckScreen extends StatefulWidget {
  String userRole;
  var mainCtx;
  var currentUser;
  var index;
  var data;
  String selectedReviewIntervalId;
  QualityReviewFacility facilityObj;

  ReviewQualityCheckScreen(this.selectedReviewIntervalId,this.facilityObj, this.data, this.index,
      this.userRole, this.mainCtx, this.currentUser);

  @override
  _ReviewQualityCheckScreenState createState() =>
      _ReviewQualityCheckScreenState();
}

class _ReviewQualityCheckScreenState extends State<ReviewQualityCheckScreen> {
  TextEditingController _textFieldController = TextEditingController();
  TextEditingController _commentController = TextEditingController();

  TextStyle style = TextStyle(
      fontSize: 17,
      fontWeight: FontWeight.bold,
      color: Colors.deepOrangeAccent);
  var totalRatingList = [];
  double overallRating = 0;
  var commentList = [];

  bool isLoading = true;
  bool isUploadingData = false;
  bool shareComment = false;
  final picker = ImagePicker();
  var imagePath=  null;
  List imageList = List();
  List<String> imageResults;

  List<QualiltyReviewItem> itemList = [];
  List<QualiltyReviewComment> reviewCommentList = [];
  QualityReviewFacility facilityObj;


  List<QualiltyReviewItem> qualityItemList = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    facilityObj = widget.facilityObj;

    // print(facilityObj.id);

    commentList = [];

    getReviewItemList();
    getReviewCommentList();
  }

  deleteQualityItem(itemId) async {
    try {
      isLoading = true;
      setState(() {});
      await QualityReviewItemService.deleteQualityItem(itemId);
      await getReviewItemList();
      isLoading = false;
      setState(() {});
    } catch (e) {
      print(e);
    }
  }

  deleteComment(itemId) async {
    try {
      isLoading = true;
      setState(() {});
      await QualityReviewCommentService.deleteComment(itemId);
      await getReviewCommentList()();
      isLoading = false;
      setState(() {});
    } catch (e) {
      print(e);
    }
  }

  addQualityItem(body) async {
    try {
      isLoading = true;
      setState(() {});

      await QualityReviewItemService.addQualityItem(body);
      await getReviewItemList();

      isLoading = false;
      setState(() {});
    } catch (e) {
      print("@postReviewItem");
    }
  }

  addComment(body) async {
    try {
      isLoading = true;
      setState(() {});

      await QualityReviewCommentService.addComment(body);
      await getReviewCommentList();

      isLoading = false;
      setState(() {});
    } catch (e) {
      print("@postReviewComment");
    }
  }

  getReviewItemList() async {
    try {
      qualityItemList = await QualityReviewItemService.list(facilityObj.id);
      setState(() {});
    } catch (e) {
      print("@getReviewItem");
      print(e);
    }
  }

  getReviewCommentList() async {
    try {
      reviewCommentList = await QualityReviewCommentService.list(facilityObj.id);
      isLoading = false;
      setState(() {});
    } catch (e) {
      print("@getReviewComment");
      print(e);
    }
  }

  getQualityReviewFacility() async {
     try {
    facilityObj = await QualityService.getReviewFacility(facilityObj.id);

     } catch (e) {
       print(e);
     }
  }


  _displayDialog(BuildContext context) async {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Enter Item'),
            content: TextField(
              controller: _textFieldController,
              decoration: InputDecoration(hintText: "Enter Item Name"),
            ),
            actions: <Widget>[
              new FlatButton(
                child: new Text('Done'),
                onPressed: () {
                  Navigator.pop(
                      context, (_textFieldController.text != "") ? "ok" : "");
                },
              )
            ],
          );
        });
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
                  height: 100,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      TextField(
                        controller: _commentController,
                        decoration:
                            InputDecoration(hintText: "Enter comment here..."),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Row(
                        children: <Widget>[
                          Text('Share with members'),
                          SizedBox(
                            width: 20,
                          ),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                if (shareComment) {
                                  shareComment = false;
                                } else {
                                  shareComment = true;
                                }
                              });
                            },
                            child: Container(
                              alignment: Alignment.center,
                              child: Container(
                                  child: Icon(
                                (shareComment) ? Icons.done : null,
                                size: 20,
                              )),
                              margin: EdgeInsets.all(5),
                              height: 20,
                              width: 20,
                              decoration: BoxDecoration(
                                  border: Border.all(color: Colors.black)),
                            ),
                          ),
                        ],
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
                  Navigator.pop(
                      context, (_commentController.text != "") ? "ok" : "");
                },
              )
            ],
          );
        });
  }

  actionButton(type) {
    var color;
    if(type == "Save") {
      color = const Color(0xffd74545);
    } else {
      color = const Color(0xff0fe68e);
    }
    return GestureDetector(
      onTap: () async {

        if(type == "Save")
          {
            isUploadingData = true;
            setState(() {

            });
            imageResults = await uploadImage();

            var qualityList = [];

            if(qualityItemList.length>0)
              {
                for(var item in qualityItemList)
                {
                  qualityList.add({
                    "_id" : item.id,
                    "rating" : item.rating
                  });
                }

              }


            if(imageResults!=null && qualityList!=null)
              {
                var res = await saveData({
                  "qualityitem" : qualityList,
                  "rating" : facilityObj.rating,
                  "image" : imageResults[0].toString()
                });
              }
            else if(qualityList!=null && imageResults==null)
              {
                // print("no image");
                var res = await saveData({
                  "qualityitem" : qualityList,
                  "rating" : facilityObj.rating,
                });
              }
            else if(imageResults!=null && qualityList==null)
              {
                var res = await saveData({
                  "rating" : facilityObj.rating,
                  "image" : imageResults[0].toString()
                });
              }


            isUploadingData = false;
            Navigator.pop(context , "saved");

          }
        else
          {
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
    this.setState(() {
      if(pickedFile != null)
      {
        imagePath = pickedFile.path;
        setState(() {

        });
      }

    });
    Navigator.of(context).pop();
  }

  _openCamera(BuildContext context) async
  {
    final pickedFile = await picker.getImage(source: ImageSource.camera , imageQuality: 80 , maxHeight: 500 , maxWidth: 500);
    this.setState(() {
      if(pickedFile != null)
      {
        imagePath = pickedFile.path;
        setState(() {

        });
      }

    });
    Navigator.of(context).pop();
  }

  buildSrollList(List list,String type) {
    return Container(
      padding: EdgeInsets.only(left: 10, right: 10),
      height: 30,
      child: ListView.builder(
        itemCount: list.length,
        scrollDirection: Axis.horizontal,
        itemBuilder: (BuildContext buildctx, int ind) {
          return Container(
            height: 25,
            alignment: Alignment.center,
            child: Text(type == "Task" ? list[ind].name : list[ind].firstName, 
              style: TextStyle(
                color: Colors.white
              ),
            ),
            // child: Text(list[ind].name != null ? list[ind].name : list[ind].firstName),
            margin: EdgeInsets.only(left: 5, right: 5),
            padding: EdgeInsets.only(left: 5, right: 5),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(
                Radius.circular(10)
              ),
              color: Colors.grey
            ),
          );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomPadding: true,
      appBar: BaseAppBar.getAppBar("\nReview Quality"),
      endDrawer: Drawer(
        child: DrawerElements.getDrawer('quality check', context,
            widget.userRole, widget.mainCtx, widget.currentUser),
      ),
      body: SafeArea(
        child: (!isLoading)
            ? SingleChildScrollView(
                child: Stack(
                  children: <Widget>[
                    Column(
                    children: <Widget>[
                      Container(
                        margin: EdgeInsets.only(left: 20),
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Scheduled Task",
                          textAlign: TextAlign.start,
                          style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: Colors.deepOrangeAccent),
                        ),
                      ),
                      SizedBox(height: 10),
                      buildSrollList(facilityObj.scheduledTaskConfig, "Task"),
                      SizedBox(height: 10),
                      Container(
                        margin: EdgeInsets.only(left: 20),
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Trade Expert Member Assigned",
                          textAlign: TextAlign.start,
                          style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: Colors.deepOrangeAccent),
                        ),
                      ),
                      SizedBox(height: 10),
                      buildSrollList(facilityObj.teMemberList, "Member"),
                      buildAddQualityLayout(),
                      SizedBox(
                        height: 20,
                      ),
                      buildOverallRatingLayout(),
                      SizedBox(
                        height: 20,
                      ),
                      buildCommentsSection(),
                      SizedBox(
                        height: 20,
                      ),
                      buildAddPhotoSection(),
                      SizedBox(
                        height: 20,
                      ),
                      Row(
                        children: <Widget>[


                      Expanded(
                        child: GestureDetector(
                          onTap: (){
                            // Add logic for saving the eaction
                            Navigator.pop(context);
                          },
                          child: actionButton("Save")
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
                      ),
                    ],
              ),
                    (isUploadingData) ? getLoader() : Container()
                  ],
                ))
            : Loader.getLoader(),
      ),
    );
  }

  buildAddQualityLayout() {
    return Container(
      margin: EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Expanded(
                  child: Text(
                "Add Review Quality Item",
                style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepOrangeAccent),
              )),
              Expanded(
                child: Container(
                  decoration:
                      BoxDecoration(shape: BoxShape.circle, color: Colors.grey),
                  height: 30,
                  width: 30,
                  child: GestureDetector(
                      onTap: () async {
                        var res = await _displayDialog(context);
                        if (res == "ok") {
                          addQualityItem({
                            "name": _textFieldController.text,
                            "qualityReviewFacility": facilityObj.id
                          });
                        }
                        _textFieldController.text = "";

                        setState(() {});
                      },
                      child: Icon(
                        Icons.add,
                        color: Colors.white,
                      )),
                ),
              )
            ],
          ),
          SizedBox(
            height: 20,
          ),
          (qualityItemList.length > 0)
              ? Container(
                  padding: EdgeInsets.all(5),
                  child: ListView.builder(
                      physics: ClampingScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: qualityItemList.length,
                      itemBuilder: (BuildContext context, int _index) {
                        return Container(
                          padding: EdgeInsets.all(6),
                          margin: EdgeInsets.only(bottom: 10),
                          decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(8)),
                          child: buildQualityItem(qualityItemList[_index], _index),
                        );
                      }),
                )
              : Container()
        ],
      ),
    );
  }


  buildQualityItem(QualiltyReviewItem item, int index) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        Container(
          alignment: Alignment.topLeft,
          child: Row(
//            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Container(
                width: MediaQuery.of(context).size.width/1.5,
                child: Text(
                  item.name,
                  // textAlign: TextAlign.left,
//                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 15),
                ),
              ),
              SizedBox(width: 10,),
             Expanded(
               child:  Container(
                 child: GestureDetector(
                     onTap: () => { confirmDeleteDialog(item.id , "item") },
                     child: Icon(
                       Icons.delete,
                       size: 26,
                     )),
               ),
             )

            ],
          ),
          margin: EdgeInsets.all(10),
          color: Colors.grey[200],
        ),
        SizedBox(
          width: 30,
        ),
        Container(
          // margin: EdgeInsets.only(left: 10, right: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Expanded(
                // child: buildRatingList(item, index),
                child: ratingRow(item)
              ),
              // SizedBox(
              //   width: 30,
              // ),
            ],
          ),
        )
      ],
    );
  }

  buildQualityItemRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Expanded(
            child: Text(
          "Name",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
        )),
        SizedBox(
          width: 20,
        ),
      ],
    );
  }


  ratingRow(QualiltyReviewItem item) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        ratingElement(item, 4),
        ratingElement(item, 3),
        ratingElement(item, 2),
        ratingElement(item, 1),
      ],
    );
  }

  calculateOverallRating() {
    var sum = 0;
    if(qualityItemList.length > 0)
    {
      for(QualiltyReviewItem item in qualityItemList) {
        if(item!=null && item.rating != null)
         { print("item.rating-----${item.rating.toString()}");
        sum += item.rating;}
      }


      facilityObj.rating = (sum ~/ qualityItemList.length);
    }

  }

  ratingElement(QualiltyReviewItem item,int rate) {

    // print("item : ${item.toString()}");
    // print("rate : ${rate}");

    var selected = "";
    var notSelected = "";
    switch(rate) {
      case 4: 
        selected = "images/excellent.png";
        notSelected = "images/excellent_black.png";
        break;
      case 3: 
        selected = "images/good.png";
        notSelected = "images/good_black.png";
        break;
      case 1:
        selected = "images/average.png";
        notSelected = "images/average_black.png";
        break;
      case 2:
        selected = "images/poor.png";
        notSelected = "images/poor_black.png";
        break;

    }

    return GestureDetector(
      onTap: () {
        item.rating = rate;
        // facilityObj.rating
        calculateOverallRating();
        setState(() {
        });
      },
      child: Container(
        margin: EdgeInsets.all(7),
        child: Container(
          child: Container(
            color: Colors.transparent,
            height: 36,
            width: 36,
            child:   Image.asset( item != null && item.rating == rate ? selected : notSelected),
          ),
        ),
      ),
    );
  }

  buildOverallRatingLayout() {
    return Row( 
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
            margin: EdgeInsets.all(10),
            child: Text(
              "Overall Rating",
              style: style,
            )),
        Container(
          alignment: Alignment.center,
//          child:  (facilityObj!=null) ? (facilityObj.rating>=1 && facilityObj.rating<=4) ? ratingElement(null, facilityObj.rating) : Container() : Container(),
          child: (facilityObj.rating !=null && facilityObj.rating > 0) ? ratingElement(null, facilityObj.rating) : Text(""),
          margin: EdgeInsets.only(left: 25, right: 25),
          height: 70,
          decoration: BoxDecoration(
              color: Colors.grey[200], borderRadius: BorderRadius.circular(10)),
        )
      ],
    );
  }

  buildCommentsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Expanded(
              child: Container(
                  margin: EdgeInsets.all(10),
                  child: Text(
                    "Add Comment",
                    style: style,
                  )),
            ),
            Expanded(
              child: Container(
                decoration:
                    BoxDecoration(shape: BoxShape.circle, color: Colors.grey),
                height: 30,
                width: 30,
                child: GestureDetector(
                    onTap: () async {
                      var res = await _displayCommentDialog(context);

                      if (res == "ok") {
                        addComment({
                          "comment": _commentController.text,
                          "memberShare": shareComment,
                          "qualityReviewFacility": facilityObj.id
                        });
                      }
                      _commentController.text = "";
                      shareComment = false;
                    },
                    child: Icon(
                      Icons.add,
                      color: Colors.white,
                    )),
              ),
            )
          ],
        ),
        SizedBox(
          height: 20,
        ),
        Container(
          padding: EdgeInsets.only(right: 7, left: 7),
          child: ListView.builder(
              physics: ClampingScrollPhysics(),
              shrinkWrap: true,
              itemCount: reviewCommentList.length,
              itemBuilder: (BuildContext context, int _index) {
                return Container(
                  margin: EdgeInsets.only(bottom: 20, left: 10, right: 12),
                  child: buildCommentRow(reviewCommentList[_index]),
                );
              }),
        )
      ],
    );
  }

  buildCommentRow(QualiltyReviewComment comment) {
    return Row(
      children: <Widget>[
        Expanded(
          child: Container(
            decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(6)),
            // margin: EdgeInsets.only(left: 10, right: 10),
            padding: EdgeInsets.all(10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Container(
                  child: Text(
                    comment.comment,
                    // commentList[index]["comment"].toString(),
                    style: TextStyle(fontSize: 20),
                  ),
                ),

                Row(
                  children: <Widget>[
                    Text(
                      'Share',
                      style: TextStyle(fontSize: 20),
                    ),
                    GestureDetector(
                      onTap: () {
                        comment.memberShare = !comment.memberShare;
                        // To update on the backend too
                        setState(() {
                        });
                      },
                      child: Container(
                        alignment: Alignment.center,
                        child: (comment.memberShare == true)
                            ? Container(
                                child: Icon(
                                Icons.done,
                                size: 20,
                              ))
                            : Icon(null),
                        margin: EdgeInsets.all(5),
                        height: 20,
                        width: 20,
                        decoration: BoxDecoration(border: Border.all(color: Colors.black)),
                      ),
                    ),
                    SizedBox(
                      width: 15,
                    ),
                    GestureDetector(
                        onTap: () {
                         confirmDeleteDialog(comment.id, "comment");
                        },
                        child: Icon(
                          Icons.delete,
                          size: 26,
                    ))
                  ],
                )
              ],
            )
          ),
        ),
        
      ],
    );
  }

  buildAddPhotoSection() {
    return Column(
      children: <Widget>[
        Container(
            alignment: Alignment.topLeft,
            margin: EdgeInsets.all(10),
            child: Text(
              "Add Photo",
              style: style,
            )),
        SizedBox(
          height: 10,
        ),
        Row(
          children: <Widget>[
            Expanded(
              child: Container(
                margin: EdgeInsets.only(right: 20, left: 20),
                height: 150,
                child: Container(
                  alignment: Alignment.center,
                  child: (facilityObj.images != null &&  facilityObj.images.length > 0) 
                        ? Image.network(facilityObj.images[0] , height: 130, width: 130,) 
                        : GestureDetector(
                      onTap: (){
                        selectImageDialog(context);
                      },
                      child:  (imagePath==null) ? Image.asset("images/addpic.png" , fit: BoxFit.contain , height: 60, width: 60,) : Image.file(File(imagePath) , fit: BoxFit.contain) )
                        ,
                ),
                decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(6)
                )
              )
            )
          ],
        )
      ],
    );
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
      imageUrlList = await ImageUploadService.upload(imageList , "reviewImage");
    }

    return imageUrlList;
  }

  getLoader()
  {
    return Container(
      height: 600,
      alignment: Alignment.center,
      child: SpinKitCircle(
        color: Colors.orangeAccent,
        size: 100.0,
        // controller: AnimationController(vsync: this, duration: const Duration(milliseconds: 1200)),
      ),
    );
  }

  saveData(body) async
  {
    var res = await QualityService.markReviewed(body, widget.selectedReviewIntervalId, facilityObj.id);
    return res;
  }

  confirmDeleteDialog(String id , String type)
  {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Confirm Delete'),
            content: Text('Delete action is irreversible!'),
            actions: <Widget>[
              new FlatButton(
                child: new Text('Confirm'),
                onPressed: () {
                  (type == "item") ? deleteQualityItem(id) : deleteComment(id);
                 Navigator.pop(context);
                },
              ),
              new FlatButton(
                child: new Text('Cancel'),
                onPressed: () {
                  Navigator.pop(context);
                },
              )
            ],
          );
        });
  }


}
