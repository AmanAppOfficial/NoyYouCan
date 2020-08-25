import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class BaseAppBar
{

  static getAppBar(String title)
  {
    Row buildAppbar(String text)                                                                    //Main app bar layout 1 screen.....
    {
      SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
          statusBarColor: Colors.white
      ));
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          // Layer 2
          Container(
            width: 60,
            height: 65,
            child: Image.asset('images/new_logo.png' , fit: BoxFit.fitWidth),
          ),
          Spacer(),
          Container(
            margin: EdgeInsets.only(top: 20),
            child: Text(
                "$text",
                style: const TextStyle(
                    color:  const Color(0xff000441),
                    fontWeight: FontWeight.w500,
                    fontFamily: "Gotham",
                    fontStyle:  FontStyle.normal,
                    fontSize: 14.0
                ),
                textAlign: TextAlign.center
            ),
          ),
          Spacer(),
        ],
      );
    }

    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor : Colors.white , elevation: 0,title: buildAppbar(title),
      actions: [
        Builder(
          builder: (context) => IconButton(
            icon: Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openEndDrawer(),
            tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
          ),
        ),
      ],
    );


  }



}