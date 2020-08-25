import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:nowyoucan/ui/screens/login_screen.dart';
import 'package:nowyoucan/utils/ApiConstants.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import 'package:http/http.dart';
import 'package:nowyoucan/utils/requestHandler.dart';

class AuthService {
  static Future<bool> login(String email, String password , fcmToken) async {
    Map<String, String> body = {
      'email': email,
      'password': password,
      "deviceId" : fcmToken
    };

    // String url = ApiConstants.URL + ApiConstants.LOGIN_ENDPOINT;

    // var response = await post(Uri.parse(url),
    //     headers: {"Content-Type": "application/json"},
    //     body: json.encode(body),
    //     encoding: Encoding.getByName("utf-8"));

    var response = await RequestHandler.POST(ApiConstants.LOGIN_ENDPOINT, body);

    if (response != null || response != {}) {
      // var jbody = json.decode(response.body);
      var jbody = response;
      if (jbody["data"]["token"] == "" || jbody["data"]["token"] == null)
        return false;
      
      if(jbody["data"]["user"]["role"][0] == "Trade Expert Company" || jbody["data"]["user"]["role"][0] == "Trade Expert") {

      }
      await saveToken(jbody["data"]["token"], jbody["data"]["user"]["role"][0]);
      Fluttertoast.showToast(msg: "Login Successful");
      return true;
    } else {
      Fluttertoast.showToast(msg: "Invalid Email or Password");
      return false;
    }
  }

  static Future saveToken(String token, String role) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
    print("token-=-=-=-=-----------$token");
    await prefs.setString('role', role);
  }

  static Future<bool> isAuthenticated(BuildContext context) async {
    String token = "";
    SharedPreferences prefs = await SharedPreferences.getInstance();
    token = prefs.getString('token');
    print("token---- $token");

    if (token == "" || token == null) {
      return false; // OPTIONAL VALUE. True by default.
    }
    return true;
  }
  
  static forgotPassword(body) async
  {
    var res = await RequestHandler.POST(ApiConstants.FORGOT_PASSWORD , body);
    return res;
  }
  
  static logout(context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove("token");
    prefs.remove("role");
    Fluttertoast.showToast(msg: "Logout Sucessfully");
//    return pushNewScreen(
//      context,
//      screen: LoginScreen(),
//      platformSpecific: true, // OPTIONAL VALUE. False by default, which means the bottom nav bar will persist
//      withNavBar: false, // OPTIONAL VALUE. True by default.
//    );

  return Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginScreen()));

  }


  static getRole() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      return prefs.get("role");
    } catch(error) {
      print("@getRole" + error.toString());
    }
  } 
}
