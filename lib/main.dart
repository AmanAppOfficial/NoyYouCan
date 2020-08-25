import 'package:flutter/material.dart';
import 'package:nowyoucan/service/auth.dart';
import 'package:flutter/services.dart';
import 'package:nowyoucan/ui/screens/login_screen.dart';
import 'package:nowyoucan/ui/screens/main_screen.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:nowyoucan/service/auth.dart';
import 'package:nowyoucan/ui/screens/splash_screen.dart';


void main() {

  runApp(MyApp());

}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {


  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
        statusBarColor: Colors.white));
    return MaterialApp(
      theme: ThemeData(
          dividerColor: Colors.white,
          textSelectionHandleColor: Colors.orangeAccent,
          primaryColor: const Color(0xfff6a04f),
          cursorColor: Colors.orangeAccent
      ),
      debugShowCheckedModeBanner: false,
        home: SplashScreen());
  }



}
