import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
// import 'package:http/http.dart';
// import 'package:nowyoucan/response/loginResponse/LoginResponse.dart';
// import 'package:nowyoucan/utils/ApiConstants.dart';
// import 'package:shared_preferences/shared_preferences.dart';
import 'package:nowyoucan/service/auth.dart';
import 'package:nowyoucan/service/user.dart';
import 'package:nowyoucan/ui/screens/forgot_password_screen.dart';
// import 'package:nowyoucan/ui/screens/dashboard_screen.dart';
import 'package:nowyoucan/ui/screens/main_screen.dart';
import 'package:nowyoucan/ui/screens/splash_screen.dart';
import 'package:nowyoucan/utils/PushNotifications.dart';

TextStyle style = TextStyle(
    fontFamily: 'Montserrat',
    fontSize: 20.0,
    color: Colors.black); // default text style

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _toggleVisibility = true;
  final email_controller = TextEditingController();
  final password_controller = TextEditingController();



  Future<bool> _onWillPop() async {
    SystemNavigator.pop();
    return false;
  }


  sendFirebaseToken() async
  {
    var token = await PushNotifications.getToken();
    print("here----   token   ---");

    return token;
  }

  @override
  Widget build(BuildContext context) {

    final emailField = TextField(
      controller: email_controller,
      obscureText: false,
      style: style,
      decoration: InputDecoration(
        prefixIcon: Image.asset(
          'images/mail.png',
          scale: 1.4,
        ),
        contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
        hintText: "Email",
        // border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
        labelStyle: TextStyle(color: Colors.black, fontSize: 24.0),
      ),
    );

    final passwordField = TextField(
      controller: password_controller,
      obscureText: _toggleVisibility,
      style: style,
      decoration: InputDecoration(
        suffixIcon: IconButton(
          onPressed: () {
            setState(() {
              _toggleVisibility = !_toggleVisibility;
            });
          },
          icon: _toggleVisibility
              ? Icon(Icons.visibility_off)
              : Icon(Icons.visibility),
          color: Colors.black,
        ),
        prefixIcon: Image.asset(
          'images/password.png',
          scale: 1.4,
        ),
        contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
        hintText: "Password",
        // border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
        labelStyle: TextStyle(color: Colors.black, fontSize: 24.0),
      ),
    );

    final loginButon = Container(
        alignment: Alignment.center,
        child: Text(
          'LOG IN',
          style: TextStyle(
              fontStyle: FontStyle.normal, color: Colors.white, fontSize: 20),
        ),
        width: 200,
        height: 45,
        decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                  color: Colors.grey, offset: Offset(0.0, 4.5), blurRadius: 9.5)
            ],
            borderRadius: BorderRadius.circular(60),
            gradient: LinearGradient(
                begin: Alignment(0.4, 0.5),
                end: Alignment(0, 0.7),
                colors: [const Color(0xffec828c), const Color(0xfff6a04f)])));

    final forgotPassword = Container(
      padding: EdgeInsets.only(top: 15.0),
      child: Text("Forgot Password?",
          style: TextStyle(color: Colors.grey, fontSize: 15.0)),
    );

    return  WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        body: Container(
          margin: const EdgeInsets.only(left: 10, right: 10),
          child: ListView(
            children: <Widget>[
              Container(
                margin: const EdgeInsets.only(top: 70, left: 10, right: 10),
                child: Padding(
                  padding: const EdgeInsets.all(18.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      SizedBox(
                        height: 100.0,
                        child: Image.asset(
                          "images/new_logo.png",
                          fit: BoxFit.contain,
                        ),
                      ),
                      SizedBox(height: 115.0),
                      emailField,
                      SizedBox(height: 25.0),
                      passwordField,
                      SizedBox(
                        height: 35.0,
                      ),
                      Row(
                        children: <Widget>[
                          GestureDetector(
                              onTap: () async {
                                FocusScope.of(context).requestFocus(
                                    FocusNode()); //For hiding soft keyboard


                                var fcmToken = await sendFirebaseToken();


                                var email = email_controller.text.trim();
                                var password = password_controller.text;
                                bool auth =
                                await AuthService.login(email, password , fcmToken);

                                if (auth == true)
                                  getRole(context);
                                else
                                  Fluttertoast.showToast(
                                      msg: "Invalid Credentials!",
                                      toastLength: Toast.LENGTH_SHORT,
                                      gravity: ToastGravity.BOTTOM,
                                      timeInSecForIosWeb: 2,
                                      backgroundColor: Colors.orangeAccent,
                                      textColor: Colors.white,
                                      fontSize: 16.0);
                              },
                              child: Container(
                                alignment: Alignment(-1.0, 0.0),
                                child: loginButon,
                              )),
                          Expanded(
                            child: GestureDetector(
                                onTap: () async {
                                  print("Forgot password clicked");
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => ForgotPasswordScreen()),
                                  );
                                },
                                child: Container(
                                  // margin: const EdgeInsets.only(top: 60),
                                  alignment: Alignment(1.0, 0.0),
                                  child: forgotPassword,
                                )),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 15.0,
                      ),
                    ],
                  ),
                ),
              ),

            ],

          ),
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage("images/background1.png"),
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
    );
  }

  Future<String> getRole(BuildContext context) async
  {

    var role =  await AuthService.getRole();
    var user = await User.me();

    Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (BuildContext context) => MainScreen(role , user)));


  }

}
