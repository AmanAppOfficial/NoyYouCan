import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:intl/intl.dart';
import 'package:nowyoucan/model/requestSwap.model.dart';
import 'package:nowyoucan/service/requestSwap.service.dart';
import 'package:nowyoucan/service/user.dart';
import 'package:nowyoucan/ui/widgets/app_bar.dart';
import 'package:nowyoucan/ui/widgets/loader.dart';
import 'package:nowyoucan/ui/widgets/navigation_drawer_elements.dart';

class RequestedSwapScreen extends StatefulWidget {
  String userRole;
  BuildContext ctx;
  var currentUser;

  RequestedSwapScreen(this.userRole, this.ctx, this.currentUser);

  @override
  _RequestedSwapScreenState createState() => _RequestedSwapScreenState();
}

class _RequestedSwapScreenState extends State<RequestedSwapScreen> {

  List<RequestSwapList>  dataList = [];
  bool isLoading = false;

  DateTime selectedDate = DateTime.now();

  Future<Null> _selectDate(BuildContext context, String initialformattedDate) async {
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        firstDate: DateTime(2015, 8),
        lastDate: DateTime(2101));
    if (picked != null && picked != selectedDate)
      selectedDate = picked;
      var formatter = new DateFormat('yyyy-MM-dd');
      initialformattedDate = formatter.format(selectedDate);
      getSwapList(initialformattedDate);
      setState(() {
      });
  }

  getSwapList(date) async
  {
    isLoading = true;
    dataList  = await RequestSwapService.getSwapList(date);
    isLoading = false;
    setState(() {
    });
  }

  @override
  void initState() {
    super.initState();

    (() async {
      isLoading = true;
      widget.currentUser = await User.me();

      var formatter = new DateFormat('yyyy-MM-dd');
      getSwapList(formatter.format(selectedDate));

      setState(() {
      });
    })();




  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomPadding: true,
      appBar: BaseAppBar.getAppBar("Requested \nSwaps"),
      endDrawer: Drawer(
        child: DrawerElements.getDrawer('', context, widget.userRole , widget.ctx , widget.currentUser),
      ),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            buildDateWidget(),
            Expanded(

              child:  (!isLoading) ?
              (dataList.length > 0) ? buildDataList() : Center(child: Text("No Record!" , style: TextStyle(fontSize: 20),))
                  : Loader.getLoader()) ,

          ],
        ),
      ),
    );
  }

  buildDateWidget()
  {
    var initialFormatter = new DateFormat('yyyy-MM-dd');
    String initialformattedDate = initialFormatter.format(selectedDate);

    return Align(
      alignment: Alignment.topRight,
      child: Container(
        alignment: Alignment.center,
        margin: const EdgeInsets.all(20),
        width: 200,
        height: 50,
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(initialformattedDate , style: TextStyle(fontWeight: FontWeight.normal),),
              GestureDetector(
                  onTap: ()=>{_selectDate(context , initialformattedDate)
                  },
                  child: Icon(Icons.calendar_today , color: Colors.orangeAccent,))
            ],
          ),
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(7),
          boxShadow: [BoxShadow(
            blurRadius: 2,
            color: Colors.grey,
            spreadRadius: 0
          )],
          color: Colors.white,
        ),
      ),
    );
  }

  buildDataList()
  {
    return ListView.builder(
        shrinkWrap:  true,
        physics: ClampingScrollPhysics(),
        itemCount: dataList.length,
        itemBuilder: (BuildContext context , int index)
        {
          return Container(
            padding: EdgeInsets.all(20),
            margin: const EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 10),
              width: MediaQuery.of(context).size.width,
             child: buildCardData(index),
             decoration: BoxDecoration(
                borderRadius: BorderRadius.all(
                    Radius.circular(6)
                ),
                border: Border.all(
                    color: const Color(0xffffffff),
                    width: 0.4
                ),
                boxShadow: [BoxShadow(
                    color: const Color(0x52b7b8ba),
                    offset: Offset(0, 0),
                    blurRadius: 8,
                    spreadRadius: 2
                )
                ],
                color: const Color(0xfff9f9f9)
            ),
          );
        }
    );
  }

  buildCardData(int index)
  {
    return Column(
      children: <Widget>[
        buildDataRows(index , "Date : ",  dataList[index].date , Icons.calendar_today),
        SizedBox(height: 10,),
        Row(
          children: <Widget>[
            buildDataRows(index, "Shift : ", dataList[index].shiftName , Icons.filter_tilt_shift),
            Expanded(
              child: GestureDetector(
                onTap: () async {
                  isLoading = true;
                  setState(() {
                  });

                  var res = await RequestSwapService.acceptRequest(dataList[index].id.toString());
                  isLoading = false;

                  var formatter = new DateFormat('yyyy-MM-dd');
                  getSwapList(formatter.format(selectedDate));


                },
                child: Container(
                    alignment: Alignment.center,
                    margin: const EdgeInsets.all(20),
                    height: 48,
                    child: Text( "Accept",
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w300,
                            fontFamily: "Gotham",
                            fontStyle: FontStyle.normal,
                            fontSize: 16.0),
                        textAlign: TextAlign.center),
                    decoration: BoxDecoration(
                        borderRadius:
                        BorderRadius.all(Radius.circular(20)),
                        color: Colors.green
                    )
                ),
              ),
            )
          ],
        ),

        SizedBox(height: 10,),
        buildDataRows(index, "Requested By : ", dataList[index].requestBy , Icons.person)
      ],
    );
  }

  buildDataRows(int index , var key , var value , IconData icon)
  {
    return  Row(children: <Widget>[
      Icon(icon , size: 25, color: Colors.orangeAccent,),
      SizedBox(width: 10,),
      Text(key , style: TextStyle(fontWeight: FontWeight.bold , fontSize: 15),),
      Text(value)
    ],);
  }
}
