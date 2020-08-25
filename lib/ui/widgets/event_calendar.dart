import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_calendar_carousel/classes/event.dart';
import 'package:flutter_calendar_carousel/classes/event_list.dart';
import 'package:flutter_calendar_carousel/flutter_calendar_carousel.dart';
import 'package:intl/intl.dart';

class EventCalendar extends StatefulWidget {

  var dateList;

  EventCalendar(this.dateList);

  @override
  _EventCalendarState createState() => _EventCalendarState();
}

class _EventCalendarState extends State<EventCalendar> {

  List redundantList = [];
  EventList<Event> _markedDateMap = new EventList();
  DateTime _currentDate = DateTime.now();
  DateTime _currentDate2 = DateTime.now();
  String _currentMonth = DateFormat.yMMM().format(DateTime.now());
  DateTime _targetDateTime = DateTime.now();

  CalendarCarousel _calendarCarouselNoHeader;



  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    loadEventsInCalendar();                    //mark dates with data....

  }


  loadEventsInCalendar()
  {
    for(DateTime e in widget.dateList){                              //add events to calendar...
      if(!redundantList.contains(e))
      {
        _markedDateMap.add(e , new Event(
          date: e,
          title: "event 1",
          dot: Container(
            padding: EdgeInsets.all(2),
            margin: EdgeInsets.only(left:20),
            alignment: Alignment.center,
            height: 15.0,
            width: 15.0,
            decoration: BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle
            ),
          ),
        ));
        redundantList.add(e);
      }
    }


  }


  @override
  Widget build(BuildContext context) {

    _calendarCarouselNoHeader = CalendarCarousel<Event>(
      todayBorderColor: Colors.green,
      onDayPressed: (DateTime date, List<Event> events) {
        this.setState(() => _currentDate2 = date);
        events.forEach((event) => print(event.title));
      },
      daysHaveCircularBorder: true,
      showOnlyCurrentMonthDate: false,
      weekendTextStyle: TextStyle(
        color: Colors.red,
      ),
      thisMonthDayBorderColor: Colors.grey,
      weekFormat: false,
      markedDatesMap: _markedDateMap,
      height: 420.0,
      selectedDateTime: _currentDate2,
      targetDateTime: _targetDateTime,
      customGridViewPhysics: NeverScrollableScrollPhysics(),
      markedDateCustomTextStyle: TextStyle(
        fontSize: 18,
        color: Colors.blue,
      ),
      showHeader: false,
      todayTextStyle: TextStyle(
        color: Colors.blue,
      ),
      todayButtonColor: Colors.yellow,
      selectedDayTextStyle: TextStyle(
        color: Colors.white,
      ),
      minSelectedDate: _currentDate.subtract(Duration(days: 31)),
      maxSelectedDate: _currentDate,
      prevDaysTextStyle: TextStyle(
        fontSize: 16,
        color: Colors.pinkAccent,
      ),
      inactiveDaysTextStyle: TextStyle(
        color: Colors.grey,
        fontSize: 16,
      ),
      onCalendarChanged: (DateTime date) {
        this.setState(() {
          _targetDateTime = date;
          _currentMonth = DateFormat.yMMM().format(_targetDateTime);
        });
      },
      onDayLongPressed: (DateTime date) {
        print('long pressed date $date');
      },
    );


    return Scaffold(
      body: SafeArea(
        child: calendar(),
      ),
    );
  }


  calendar()
  {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Container(
            margin: EdgeInsets.only(
              top: 30.0,
              bottom: 16.0,
              left: 16.0,
              right: 16.0,
            ),
            child: new Row(
              children: <Widget>[
                Expanded(
                    child: Text(
                      _currentMonth,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 24.0,
                      ),
                    )),
              ],
            ),
          ),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 16.0),
            child: _calendarCarouselNoHeader,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              RaisedButton(
                padding: const EdgeInsets.all(7),
                onPressed: (){
                  Navigator.pop(context , _calendarCarouselNoHeader.selectedDateTime);
                },
                child: Text("Done" , style: TextStyle(fontSize: 20),),
              ),
              RaisedButton(
                padding: const EdgeInsets.all(7),
                onPressed: (){
                  Navigator.pop(context);
                },
                child: Text("Cancel" , style: TextStyle(fontSize: 20),),
              )
            ],
          )
        ],
      ),
    );
  }



}
