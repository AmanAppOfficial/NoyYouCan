/**
 * @descrption Check request swap pop up
 * @author Aman Srivastava
 */


import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:intl/intl.dart';
import 'package:nowyoucan/model/requestSwap.model.dart';
import 'package:nowyoucan/model/shiftAllocation.model.dart';
import 'package:nowyoucan/service/requestSwap.service.dart';
import 'package:nowyoucan/ui/widgets/loader.dart';


class CheckRequestSwapPopup extends StatefulWidget {

  DateTime displayedDate;
  ShiftAllocation allocatedShift;

  CheckRequestSwapPopup(this.displayedDate, this.allocatedShift);



  @override
  _CheckRequestSwapPopupState createState() => _CheckRequestSwapPopupState();
}




class _CheckRequestSwapPopupState extends State<CheckRequestSwapPopup> {


  List<RequestSwapList> CheckSwap = [];

  String formattedDate;
  bool isLoading = false;
  bool isListLoading = false;


  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    var formatter = new DateFormat('yyyy-MM-dd');
    formattedDate = formatter.format(widget.displayedDate);

    getSwapList(formattedDate);

  }

  getSwapList(date) async
  {
    isLoading = true;
    CheckSwap  = await RequestSwapService.getSwapList(date);
    isLoading = false;
    setState(() {
    });
  }

  @override
  Widget build(BuildContext context) {

    return ListView(
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
                                                            "Requested Shift Swaps",
                                                            style: const TextStyle(
                                                                color:  Colors.white,
                                                                fontWeight: FontWeight.bold,
                                                                fontFamily: "Gotham",
                                                                fontStyle:  FontStyle.normal,
                                                                fontSize: 17.5),
                                                            textAlign: TextAlign.center)
                                                    ),
                                                    GestureDetector(
                                                      onTap: (){Navigator.pop(context);},
                                                      child: Container(
                                                        child: Image.asset(('images/whitecancelicon.png') , scale: 1.8,),
                                                      ),
                                                    )
                                                  ],
                                                ),
                                                margin: EdgeInsets.only(left: 25 , right: 19 , top: 30),
                                              ),
                                              Container(
                                                  child:  (!isLoading) ?
                                                  (CheckSwap.length > 0) ?
                                                  details()
                                                      : Container(
                                                        alignment: Alignment.center,
                                                        width: double.infinity,
                                                        height : 400,
                                                            child: Text("No records!" , style: TextStyle(fontWeight: FontWeight.normal , fontSize: 30),))
                                                      : Container(
                                                    height : 400,
                                                    child: Loader.getLoader(),
                                                  ),

                                                  margin: EdgeInsets.only(top: 40 , bottom: 40),
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
                )
              ],
            );

    }

  details()
  {
    return Stack(
      children: <Widget>[
        Container(
          alignment: Alignment.center,
          margin: EdgeInsets.only(top: 10 , left: 6 , right: 6 , bottom: 5),
          child: Column(
            children: <Widget>[
              Center(
                child: Column(
                  children: <Widget>[

                    buildList()

                  ],
                ),
              ),
            
            ],
          ),
        ),
        (isListLoading) ?  Container(
          height: 400,
          width: MediaQuery.of(context).size.width,
          child: Loader.getLoader(),
        ) : Container(),
      ],
    );
  }

  buildList() 
  {

    return Container(
      height: MediaQuery.of(context).size.height/1.7,
      child: ListView.builder(
        scrollDirection: Axis.vertical,
          itemCount: CheckSwap.length,
          itemBuilder: (BuildContext context , int index)
          {
            return  (CheckSwap[index].preferredId == widget.allocatedShift.shift.id) ? buildCards(index) :Container(
                alignment: Alignment.center,
                width: double.infinity,
                height : 400,
                child: Text("No records!" , style: TextStyle(fontWeight: FontWeight.normal , fontSize: 30),));
          }
      ),
    );
  }

  var cardBoxStyle = BoxDecoration(
      borderRadius: BorderRadius.all(Radius.circular(10)),
      border: Border.all(color: const Color(0xffffffff), width: 0.4),
      boxShadow: [
        BoxShadow(
            color: const Color(0x52b7b8ba),
            offset: Offset(0, 0),
            blurRadius: 8,
            spreadRadius: 0)
      ],
      color: const Color(0xfff9f9f9)
  );

  var textStyle = const TextStyle(
    color: const Color(0xff343233),
    fontWeight: FontWeight.w400,
    fontFamily: "Gotham",
    fontStyle: FontStyle.normal,
    fontSize: 14.5,
  );

  buildCards(int index)
  {
    return Container(
      margin: EdgeInsets.only(top: 10),
      height: 150,
      child: Container(
        margin: const EdgeInsets.only(
            left: 20, right: 20, top: 10, bottom: 10),
        width: MediaQuery.of(context).size.width,
        decoration: cardBoxStyle,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            nameWidget(CheckSwap[index].requestBy),
            SizedBox(
              height: 15,
            ),
            Row(
              children: <Widget>[
                Expanded(
                  child: Container(
                    margin: EdgeInsets.only(left: 12),
                    child: Column(
                      children: <Widget>[
                        dateWidget(CheckSwap[index].date),
                        SizedBox(
                          height: 10,
                        ),
                        shiftWidget(CheckSwap[index].shiftName),
                      ],
                    ),
                  ),
                ),
                actionButton(CheckSwap[index].id),
              ],
            )
          ],
        ),
      ),
    );
  }

  nameWidget(String name)
  {
    return Container(
      width: 240,
      margin: EdgeInsets.all(12),
      child: Text("${name}",
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
          style: textStyle,
          textAlign: TextAlign.left),
    );
  }

  dateWidget(String date)
  {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Icon(
          Icons.calendar_today,
          color: Colors.orangeAccent,
        ),
        SizedBox(
          width: 10,
        ),
        Text("$date",
            style: textStyle,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center)
      ],
    );
  }

  shiftWidget(String shift)
  {
    return Row(
      mainAxisAlignment:
      MainAxisAlignment.start,
      crossAxisAlignment:
      CrossAxisAlignment.start,
      children: <Widget>[
        Icon(
          Icons.wb_sunny,
          color: Colors.orangeAccent,
        ),
        SizedBox(
          width: 10,
        ),
        Container(
          width: 40,
          child: Text(
              "$shift",
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              style: textStyle,
              textAlign: TextAlign.center),
        )
      ],
    );
  }

  actionButton(String id)
  {
    return Expanded(
      child: GestureDetector(
        onTap: () async {
          isListLoading = true;
          setState(() {
          });
        var res = await RequestSwapService.acceptRequest(id.toString());
        isListLoading = false;
        Navigator.pop(context);
        },
        child: Container(
            alignment: Alignment.center,
            margin: const EdgeInsets.only(
                left: 12, right: 12),
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
                color: Color(0xfff6a050)
            )
        ),
      ),
    );
  }


  }
