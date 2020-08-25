/**
 * @descrption Mark unavailable pop up
 * @author Aman Srivastava
 */


import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:nowyoucan/service/shiftAllocation.dart';

class MarkUnavailable extends StatefulWidget {

  DateTime date;
  String shiftRotationId;
  String allocatedShiftId;

  MarkUnavailable(this.date, this.shiftRotationId, this.allocatedShiftId);

  @override
  _MarkUnavailableState createState() => _MarkUnavailableState();
}

class _MarkUnavailableState extends State<MarkUnavailable> {

  String date;
  String shiftRotationId;
  String allocatedShiftId;

  List<String> _locations = ['Sick Leave', 'Annual Leave', 'Career Leave', 'Other']; // Option 2
  String _selectedLocation; // Option 2
  bool showMarkTextLayout = false;
  bool showActionMarkButtons = false;
  TextEditingController reasonController = new TextEditingController();

  bool isMarked = false;

  @override
  void initState() {
    super.initState();

    date =widget.date.toUtc().toIso8601String();
    shiftRotationId = widget.shiftRotationId;
    allocatedShiftId = widget.allocatedShiftId;
  }

  markDone() async
  {
    try
        {
          isMarked = true;
          setState(() {

          });

          var result = await ShiftAllocationService.markUnavailable({
            "date" : date,
            "reason" : (_selectedLocation == "Other") ? reasonController : _selectedLocation,
            "shift"  : allocatedShiftId,
            "shiftRotation" : shiftRotationId
          });



          print("result=======$result");

          Fluttertoast.showToast(msg: "Completed!");
          isMarked = false;
          reasonController.text = "";
          showActionMarkButtons = false;
          _selectedLocation = null;
          showMarkTextLayout = false;
          Navigator.pop(context);
        }
    catch(error) {
      print(error);
    }
  }


  @override
  Widget build(BuildContext context) {
    return markDialog();
  }

  createLoader()
  {
    return SpinKitCircle(
      color: Colors.orangeAccent,
      size: 170.0,
      // controller: AnimationController(vsync: this, duration: const Duration(milliseconds: 1200)),
    );
  }

  markDialog() {
    return Dialog(
        shape: RoundedRectangleBorder(
            borderRadius:
            BorderRadius.circular(9.0)), //this right here
        child: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Container(
                height: 450,
                margin: const EdgeInsets.all(8),
                child: Stack(
                  children: <Widget>[
                    Column(
                      children: <Widget>[
                      header(),
                        warningText(),
                        dropDownList(),
                        (showMarkTextLayout) ? addActionText() : Container(),
                        (showActionMarkButtons)  ? actionButtons(): Container()
                      ],
                    ),
                    (isMarked) ?  Center(child: Container(
                        height: MediaQuery.of(context).size.height,
                        alignment: Alignment.center,
                        child :createLoader())) : Container(
                    )
                  ],
                ),
              );
            }
        )
    );
  }

  actionButtons()
  {
    return Expanded (
      child: Container(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Expanded(
              child: GestureDetector(
                onTap: (){
                  markUnavailable(reasonController.text , _selectedLocation);


                  },
                child: Container(
                    child: Text(
                        "Confirm",
                        style: const TextStyle(
                            color:  Colors.white,
                            fontWeight: FontWeight.w300,
                            fontFamily: "Gotham",
                            fontStyle:  FontStyle.normal,
                            fontSize: 18.0
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
                      reasonController.text = "";
                      showActionMarkButtons = false;
                      _selectedLocation = null;
                      showMarkTextLayout = false;
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
                            fontSize: 18.0
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
      ) ,
    );
  }

  dropDownList()
  {
    return Center(
      child: Container(

        padding: EdgeInsets.all(3),
        width: 350,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.all(
                Radius.circular(9.4576)
            ),
            boxShadow: [BoxShadow(
                color: Colors.grey,
                offset: Offset(0,0),
                blurRadius: 2,
                spreadRadius: 0
            )] ,
            color: Colors.white
        ),
        margin: const EdgeInsets.only(top: 15 , bottom: 15 , left: 10 , right: 10),
        child :  DropdownButtonHideUnderline(
          child: Container(
            margin: EdgeInsets.only(left: 5 , right: 5),
            child: DropdownButton(
              hint: Text('Select'), // Not necessary for Option 1
              value: _selectedLocation,
              onChanged: (newValue) {
                setState(() {
                  _selectedLocation = newValue;
                  if(_selectedLocation != null)
                  {
                    showActionMarkButtons = true;
                  }
                  if(newValue == "Other")
                  {
                    showMarkTextLayout = true;
                  }
                  else
                  {
                    showMarkTextLayout = false;}

                });
              },
              items: _locations.map((location) {
                return DropdownMenuItem(
                  child: new Text(location),
                  value: location,
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }

  addActionText()
  {
    return Expanded(
      child: Container(
        margin: EdgeInsets.only(left: 10 , right: 10 , top: 10),
        child: TextField(
          controller: reasonController,
          maxLength: 100,
          maxLines: 1,
          decoration: InputDecoration(
              hintText: 'Enter reason'
          ),
        ),
      ),
    );
  }

  warningText()
  {
    return Container(
      margin: const EdgeInsets.only(left: 10 , right: 10 , top: 30 , bottom: 20),
      alignment: Alignment.center,
      child: Text(
          "'Mark Unavailable' action is irreversible.  Please select carefully",
          style: const TextStyle(
              color:  const Color(0xff343233),
              fontWeight: FontWeight.w400,
              fontFamily: "Gotham",
              fontStyle:  FontStyle.normal,
              fontSize: 16.0
          ),
          textAlign: TextAlign.center
      ),
    );
  }

  header() {
    return   Container(
      margin: const EdgeInsets.all(19),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(
              "Select Reason and Confirm",
              style: const TextStyle(
                  color:  const Color(0xfff6a050),
                  fontWeight: FontWeight.w700,
                  fontFamily: "Gotham",
                  fontStyle:  FontStyle.normal,
                  fontSize: 14.5
              ),
              textAlign: TextAlign.center
          ),
          GestureDetector(
              onTap: (){
               if(!isMarked)
                { showMarkTextLayout = false;
                showActionMarkButtons = false;
                _selectedLocation = null;
                reasonController.text = "";
                Navigator.pop(context);}},
              child: Image.asset(('images/cancelicon.png') , scale: 22.2,))
        ],
      ),
    );
  }

  void markUnavailable(String text, String selectedLocation)
  {
    print("code================= :  ${text}");
    print("code===========  ${selectedLocation}");
    markDone();
  }


}
