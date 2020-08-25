import 'dart:async';

import 'package:flutter/material.dart';
import 'package:nowyoucan/service/auth.dart';
import 'package:nowyoucan/service/user.dart';
import 'package:nowyoucan/ui/screens/dashboard_screen.dart';
import 'package:nowyoucan/ui/screens/login_screen.dart';
import 'package:nowyoucan/ui/screens/main_screen.dart';
import 'package:nowyoucan/utils/PushNotifications.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Timer timer;
  @override
  void initState() {
    super.initState();
    timer = new Timer(new Duration(seconds: 3), () {
      getRole(context);
    });


  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: Image.asset('images/background.png', fit: BoxFit.cover),
          ),
        ),
      ),
    );
  }
}


Future<String> getRole(BuildContext context) async
{
  var role =  await AuthService.getRole();

  if(role==null || role=="")
  {
    Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (BuildContext context) => LoginScreen()));
  }
  else
  {
    var currentUser = await getUser();
    Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (BuildContext context) => MainScreen(role , currentUser)));
  }

}


getUser() async
{
  var currentUser = await User.me();

  await PushNotifications.init();

  return currentUser;
}
