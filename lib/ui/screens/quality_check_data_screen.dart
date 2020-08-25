import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:nowyoucan/service/building.service.dart';
import 'package:nowyoucan/service/quality_service.dart';
import 'package:nowyoucan/service/scheduledTasks.dart';
import 'package:nowyoucan/service/user.dart';
import 'package:nowyoucan/ui/screens/quality_filter_screen.dart';
import 'package:nowyoucan/ui/screens/review_quality_check_scree.view.dart';
import 'package:nowyoucan/ui/widgets/app_bar.dart';
import 'package:nowyoucan/ui/widgets/loader.dart';
import 'package:nowyoucan/ui/widgets/navigation_drawer_elements.dart';
import 'package:nowyoucan/model/qualityInterval.dart';

class QualityCheckDataScreen extends StatefulWidget {

  String userRole;
  var mainCtx;
  var currentUser ;

  QualityCheckDataScreen(this.userRole, this.mainCtx, this.currentUser);

  
  @override
  _QualityCheckDataScreenState createState() => _QualityCheckDataScreenState();
}

class _QualityCheckDataScreenState extends State<QualityCheckDataScreen> {

  var data ={
    "Suite" : "full floor",
    "Facility" : "meeting room",
    "Member" : "workmem1",
    "Task" : "Cleaning",
    "Result" : "good",
    "Receiver Name" : "workTe",
    "Floor" : "2"
  };

  bool isLoading = true;
  var buildingList = [];
  var selectedBuilding;
  int selectedIndex = 1;

  var overAllRating = "";

  var analyticsData;

  InProgressAndCompleted reviewCountList;
  List<QualityFacilityFloor> facilityList = [];
  QualityInterval  selectedReviewInterval;

  @override
  initState() {
    (() async {
      widget.currentUser = await User.me();
      await getBuildingList();
    })();
  }


  getBuildingList() async {
    // try {
      buildingList = await BuildingService.getBuilding();
      if (buildingList != null && buildingList.length > 0) {
        // selectedBuilding = buildingList[0];
        selectBuilding(buildingList[0], 0);
      }
    // } catch (error) {
      // print("@getBuildingList Error " + error.toString());
    // }
  }

  selectBuilding(building, index) async {
    selectedBuilding = building;
    selectedIndex = index;
    print("------------------------------------------------");
    print("Selected index : ${selectedBuilding}");

    await getQualityInterval(selectedBuilding["_id"]);
  }

  getQualityInterval(buildingId) async {  
//    buildingId = "5c63cb0aa5f5b405a730e830"; // To be commented when done
    reviewCountList = await QualityService.getReviewIntervalList(buildingId);



    // reviewCountList = {"inProgress":[
    //   {"_id":"5f0eb7930117f25625a5d23d","name":"twst"}
    //   ],
    //   "completed":[]
    // };

     print("++++++++++------------- ${reviewCountList.toString()}");



    if(reviewCountList.inProgress.length > 0) {

      print("inprogress");
      getIntervalReviewFacilityList(reviewCountList.inProgress[0]);
    } else if(reviewCountList.completed.length > 0) {
      print("completed");
      getIntervalReviewFacilityList(reviewCountList.completed[0]);
    }
    else
      {
        print("none");
        isLoading = false;
        setState(() {});
      }
  }


  getAnalytics() async
  {
    var res = await QualityService.getReviewAnalytics(selectedReviewInterval.id);
    analyticsData = res;
    return res;
  }

  getIntervalReviewFacilityList(QualityInterval reviewInterval) async {
    // try {
      print("InPorgresssID" + reviewInterval.id);
      selectedReviewInterval = reviewInterval;
      getReviewDetails();
      facilityList = await QualityService.getReviewFacilityList(selectedReviewInterval.id);
      setState(() {
      });
      await getAnalytics();
      isLoading = false;
      setState(() {});
    // } catch(e) {
    //   print("@getIntervalReviewFacilityList");
    //   print(e);
    // }
  }

  getReviewDetails() async {
    try {
      selectedReviewInterval = await QualityService.getReviewDetails(selectedReviewInterval.id);
    } catch (e) {
      print("@getReviewDetails");
      print(e);
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:  Colors.white,
      resizeToAvoidBottomPadding: true,
      appBar: BaseAppBar.getAppBar("\nQuality Check"),
      floatingActionButton:  FloatingActionButton(
          elevation: 0.0,
//          child: Image.asset('images/filter.png' ,),
          child : Container(
              height: 30,
              child: Image.asset("images/filter.png" , filterQuality: FilterQuality.high,)),
          backgroundColor: Colors.deepOrangeAccent,
          onPressed: () async {
            // Until data get loading no action for floating icon
            if (buildingList == null 
            || selectedIndex == null 
            || selectedBuilding == null 
            || reviewCountList == null ) return;
            
            var res = await  Navigator.of(context).push(MaterialPageRoute(
                builder: (BuildContext context) => QualityFilterScreen(
                    {
                      "selectedReviewInterval": selectedReviewInterval,
                      "buildingList" : buildingList,
                      "selectedBuildingIndex" : selectedIndex,
                      "selectedBuildingId" : selectedBuilding["_id"],
                      "inProgressList" : reviewCountList.inProgress,
                      "completedList" :  reviewCountList.completed,
                    },
                    widget.mainCtx , widget.userRole , widget.currentUser)));

            if(res == "ok")
              {

              }
            else if(res=="done")
              {

              }
              else
                if(res == "deleted")
                  {
                    Navigator.pop(context);
                  }
                else
                reloadList(res);

          }
      ),
      endDrawer: Drawer(
        child: DrawerElements.getDrawer(
            'quality check', context, widget.userRole, widget.mainCtx,
            widget.currentUser),
      ),
      body: (!isLoading) ?  ListView(
       children: <Widget>[
            SizedBox(height: 10,),
            Row(
              children: <Widget>[
              topHeaderRowCards(selectedBuilding != null ? selectedBuilding["name"].toString() : "-"),
              SizedBox(width: 20),
              topHeaderRowCards(selectedReviewInterval != null ? selectedReviewInterval.name : "-"),
              ],
            ),
            SizedBox(height: 20,),
             analyticsLayout(),
             SizedBox(height: 20,),
            Container(
              child:  floorAccordion(),
            ),

       ], 
      )  : Loader.getListLoader(context),
    );
  }

  topHeaderRowCards(tagName) {
    return Expanded( child: Container(
        child: Center(
          child: Text(tagName, style: TextStyle(
            color: Colors.white,
            fontSize: 20,
          ), overflow: TextOverflow.ellipsis),
        ),
        height: 45,
        decoration: BoxDecoration(
            boxShadow: [BoxShadow(
              color: Color(0xffec828c),
              blurRadius: 4,
            )],
            borderRadius:BorderRadius.circular(8),
            gradient: LinearGradient(
                begin: Alignment(0.0, 1.3),
                end: Alignment(0.5, 0.7),
                colors: [
                  const Color(0xffec828c),
                  const Color(0xfff6a04f)
                ])
        ),
      ),
    );
  }

   facilityData(int index , QualityReviewFacility list)
  {
    return Padding(
      padding: const EdgeInsets.all(14.0),
      child: Column(
        children: <Widget>[
          SizedBox(height: 30,),
          Row(
            children: <Widget>[
              Expanded(child: buildItem(list.tradeExpertCategoryName , Icons.group_work),),
              Expanded(child:  buildItem(list.facilityAlias , Icons.work),)

            ],
          ),
          SizedBox(height: 10,),
          // Row(
          //   children: <Widget>[
          //     Expanded(child:  Row(
          //     crossAxisAlignment: CrossAxisAlignment.center,
          //     children: <Widget>[
          //       Icon(Icons.person , color: Colors.orangeAccent,),
          //       SizedBox(width: 20,),
          //       Expanded(
          //           child: Text( list.teMemberList[0].firstName,  style: TextStyle(fontSize: 17 , color: Colors.black54) , overflow: TextOverflow.ellipsis,))
          //     ],
          //   )),
          //     // Expanded(child: buildItem( list.teMemberList , Icons.person),),
          //     // SizedBox(height: 10,),
          //     // Expanded(child:  buildItem(list.facilityAlias , Icons.work),)
              
          //   ],
          // ),
          SizedBox(height: 10,),
          Row(
            children: <Widget>[
              Expanded(child: buildItem( list.reviewedByFirstName != null ?  list.reviewedByFirstName : "-", Icons.person_outline),),
              SizedBox(height: 10,),
              buildViewButton(index , list)
            ],
          ),
        ],
      ),
    );
  }


   facilityCard(int index , QualityReviewFacility list)
  {
    return Container(
        child: facilityData(index , list),
        margin: EdgeInsets.all(20),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(width: 0),
            color: const Color(0xfff9f9f9)
        )
    );
  }


   buildItem(String value , IconData icon)
  {
    return   Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Icon(icon , color: Colors.orangeAccent,),
        SizedBox(width: 20,),
        Expanded(
            child: Text( value,  style: TextStyle(fontSize: 17 , color: Colors.black54) , overflow: TextOverflow.ellipsis,))
      ],
    );
  }

   buildViewButton(int index ,QualityReviewFacility list)
  {
    return Expanded(
      child: GestureDetector(
        onTap: () async {



          var result =  await Navigator.of(context).push(MaterialPageRoute(
              builder: (BuildContext context) => ReviewQualityCheckScreen(selectedReviewInterval.id ,  list, data , index , widget.userRole ,widget.mainCtx , widget.currentUser)));

          if(result == "saved")
            {
              isLoading = true;
              setState(() {
              });
              await getIntervalReviewFacilityList(selectedReviewInterval);
            }


        },
        child: Container(
          margin: EdgeInsets.all(7),
          width: 150,
          alignment: Alignment.center,
          child: Padding(
              padding: EdgeInsets.all(10),
              child: Text("Take Action" ,
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w300,
                    fontFamily: "Gotham",
                    fontStyle: FontStyle.normal,
                    fontSize: 16.0),)),
          decoration: BoxDecoration(
            color: Colors.orangeAccent,
            borderRadius: BorderRadius.circular(7),

          ),
        ),
      ),
    );
  }

  headingTag(title , total, completed) {
    return Row(
      children: <Widget>[
        Container(
            margin: EdgeInsets.only(right: 10 , left: 0, top: 10.0),
            alignment: Alignment.center,
            child: Text(
                title,
                style: const TextStyle(
                    color:  const Color(0xffffffff),
                    fontWeight: FontWeight.w400,
                    fontFamily: "Gotham",
                    fontStyle:  FontStyle.normal,
                    fontSize: 20.5
                ),
                textAlign: TextAlign.left
            ),
            width: 160,
            height: 45,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.only(topRight :  Radius.circular(25) , bottomRight:  Radius.circular(25)),
                gradient: LinearGradient(
                    begin: Alignment(0, 1.9),
                    end: Alignment(0.6, 0.2),
                    colors: [const Color(0xffec828c), const Color(0xfff6a04f)])
            )
        ),
        SizedBox(width: 5,),
        (completed != null) ? buildCount("Completed" , completed , const Color(0xff90c217)) : Container() ,
        SizedBox(width: 20,),
        (total != null && completed != null) ? buildCount("In Progress" , total - completed > 0 ? total - completed : 0  , Colors.blueGrey) : Container(),
      ],
    );
  }



  floorAccordion()
  {
    return (facilityList.length > 0) ?  ListView.builder(
        itemCount: facilityList.length,
        shrinkWrap: true,
        physics: ClampingScrollPhysics(),
        itemBuilder: (BuildContext ctx , int index)
        {

          return Container(
            margin: EdgeInsets.only(bottom: 20 , left: 10 , right: 10),
            child: Card(
              elevation: 4.0,
              shadowColor: Colors.white,
              child: Padding(
                padding: const EdgeInsets.only(top : 10.0 , bottom: 10.0),
                child: ListTileTheme(
                  contentPadding: EdgeInsets.all(0),
                  child: ExpansionTile(
                    backgroundColor:Colors.white,
                    trailing: Image.asset('images/bottomicon.webp' , scale: 4,),
                    title: headingTag("Floor " +  facilityList[index].floorAlias, facilityList[index].total , facilityList[index].completed), // To  pass title
                    children: <Widget>[
                      ListView.builder(
                        itemCount: facilityList[index].list.length,
                        shrinkWrap: true,
                        physics: ClampingScrollPhysics(),
                        itemBuilder: (BuildContext ctx1 , int index1) {
                          return floorCardContainer(facilityList[index].list[index1], index);
                        }
                      )

                    ],
                  ),
                ),
              ),
            ),
          );

          
        }
    ): Container(
      alignment: Alignment.center,
      margin: EdgeInsets.only(top: 20),
      child: Text("No data available! " , style: TextStyle(fontSize: 20),),
    )
    ;


  }

  floorCardContainer(QualityFacilityList list, index) {
    return (list.suiteNo == null) ? 
      facilityCardList(list) :
      suiteCardContainer(list);
  }

  suiteCardContainer(QualityFacilityList list) {
    return ListTileTheme(
        contentPadding: EdgeInsets.all(0),
        child: ExpansionTile(
          backgroundColor:Colors.white,
          trailing: Image.asset('images/bottomicon.webp' , scale: 4,),
          title: headingTag("Suite " +  list.suiteNo, null, null), // To  pass title
          children: <Widget>[
            facilityCardList(list)
          ],
        ),
      );
  }

  facilityCardList(QualityFacilityList list) {
    return ListView.builder(
      itemCount: list.facilityList.length,
      shrinkWrap: true,
      physics: ClampingScrollPhysics(),
      itemBuilder: (BuildContext ctx , int index1) {
        // return Text("data");
        return Stack(
          children: <Widget>[
            facilityCard(index1 , list.facilityList[index1] ),
            Align(
              alignment: Alignment.topLeft,
              child: buildReview(list.facilityList[index1].rating != null ? list.facilityList[index1].rating : 0),
            ),
          ],
        );
      }
    );
  }

  buildReview(review) {
    return Container(
      margin: EdgeInsets.only(right: 3),
      child: (review == 4) ? buildIcon("images/excellent.png", Colors.redAccent) :
             (review == 3) ? buildIcon("images/good.png" , Colors.redAccent) :
             (review == 2) ? buildIcon("images/poor.png" , Colors.redAccent) :
             (review == 1) ? buildIcon("images/average.png" , Colors.redAccent) :
             Container()
    );
  }

  buildCount(action , index, Color color)
  {
    return Expanded(
      child: Column(
        children: <Widget>[
          FittedBox(
            child:  Text(action,
                style:  TextStyle(
                    color: color,
                    fontWeight: FontWeight.w400,
                    fontFamily: "Gotham",
                    fontStyle: FontStyle.normal,
                    fontSize: 13.5),
                textAlign: TextAlign.center),
          ),
          SizedBox(height: 7,),
          Container(
              alignment: Alignment.center,
              margin: EdgeInsets.only(
                  left: 5.0, right: 5.0, top: 2.0),
              height: 30,
              child: Text(
                 "${index}",
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w300,
                      fontFamily: "Gotham",
                      fontStyle: FontStyle.normal,
                      fontSize: 18.0),
                  textAlign: TextAlign.center),
              decoration: BoxDecoration(
                  borderRadius:
                  BorderRadius.all(Radius.circular(10)),
                  color: color
              )
          ),
        ],
      ),
    );
  }

  buildIcon(icon , color)
  {return Container(
    margin: EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6)
      ),
      child: Image.asset(icon , scale: 2.5,));}

  void reloadList(res) async
  {
    if(res != null)
      {
        selectedBuilding = res["selectedBuilding"];
        selectedIndex = buildingList.indexOf(selectedBuilding);

        if(res["inprogressList"]!="")
        reviewCountList.inProgress = res["inprogressList"];
        if(res["completedList"] != "")
          reviewCountList.completed = res["completedList"];

        if(res["_selectedInProgressReview"] != "")
          {
            selectedReviewInterval = res["_selectedInProgressReview"];
          }

        else
          selectedReviewInterval = res["_selectedCompletedReview"];

        isLoading = true;
        setState(() {
        });
        await getIntervalReviewFacilityList(selectedReviewInterval);



      }

  }

  analyticsLayout()
  {

    if(analyticsData != null)
    calculateOverallRating(analyticsData["rating"]);

    return Column(
      children: <Widget>[
        Row(
          children: <Widget>[
            analyticsDataCard((analyticsData!=null) ?  analyticsData["total"].toString() : "0", "Facilities" , 1),
            analyticsDataCard((analyticsData != null) ? analyticsData["completed"].toString() : "0" , "Completed" , 2),
          ],
        ),
        Row(
          children: <Widget>[
            analyticsDataCard((analyticsData != null) ? analyticsData["inProgress"].toString() : "0" , "InProgress" ,3),
            analyticsDataCard(overAllRating.toString() , "Rating" , 4),
          ],
        ),
      ],
    );
  }

  analyticsDataCard(count , task , cardIndex)
  {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment(0.0, 1.2),
                end: Alignment(0.9, 0.7),
                colors:(cardIndex == 1) ?  [
                  Colors.deepOrangeAccent,
                  Colors.orangeAccent
                ] :
                (cardIndex ==2) ?  [
                  Colors.green,
                  Colors.lightGreen
                ] :
                (cardIndex == 3) ?  [
                  Colors.grey,
                  Colors.blueGrey
                ] :
                    [
                      Colors.lightBlueAccent,
                      Colors.blue
                    ]
            ),
          borderRadius: BorderRadius.circular(10),
        ),
//        height: 90,
        margin: EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Expanded(
              child: Container(
                alignment: Alignment.center,
                margin: EdgeInsets.all(9),
                height: 50,
                child: Text("$count" , style: TextStyle(fontSize: (cardIndex!=4) ? 35 : 30 , fontWeight: FontWeight.normal,)),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                ),
              ),
            ),
           FittedBox(
             child:  Container
               (
               margin: EdgeInsets.all(10),
               child: Text('$task' , style: TextStyle(color: Colors.white , fontSize: 16),),
             ),
           )
          ],
        ),
      ),
    );
  }

  void calculateOverallRating(analyticsData)
  {

        if(analyticsData == 1)
        {
          overAllRating = "Poor";
        }
        else if(analyticsData == 2)
        {
          overAllRating = "Average";
        }
        else if(analyticsData == 3)
        {
          overAllRating = "Good";
        }
        else if(analyticsData == 4)
        {
          overAllRating = "Excellent";
        }


  }




}
