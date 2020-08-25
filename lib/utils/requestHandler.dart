import 'package:nowyoucan/utils/ApiConstants.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:fluttertoast/fluttertoast.dart';

class RequestHandler {
  static const authorizationHeader = "authorization";

  static Future POST(url, body) async {
    var response = await http.post( Uri.parse(ApiConstants.URL + url),
        headers: {
          "Content-Type": "application/json",
          authorizationHeader: await getToken()
        },
        body: json.encode(body),
        encoding: Encoding.getByName("utf-8"));
    return responseHandler(response);
  }

  static Future GET(url, [params]) async {
    if (params != null) {
      url += "?" + encodeQuery(params);
    }
    var response = await http.get( Uri.parse(ApiConstants.URL + url),
        headers: {
          "Content-Type": "application/json",
          authorizationHeader: await getToken()
        });
    return responseHandler(response);
  }

  static Future PUT(url, body) async {
    var response = await http.put(Uri.parse(ApiConstants.URL + url),
        headers: {  
          "Content-Type": "application/json",
          authorizationHeader: await getToken()
        },
        body: json.encode(body),
        encoding: Encoding.getByName("utf-8")
      );

    return responseHandler(response);
  }


  static Future DELETE(url) async {
    var response = await http.delete( Uri.parse(ApiConstants.URL + url),
        headers: {
          "Content-Type": "application/json",
          authorizationHeader: await getToken()
        });
    return responseHandler(response);
  }

  static responseHandler(response) {
    if (response.statusCode == 200) return json.decode(response.body);
    else {
      Fluttertoast.showToast(msg: "Oops! Something went wrong.");
      return {};
    }
  }

  static getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
     print("toke===============${prefs.getString("token")}");
    return prefs.getString('token');
  }

  static encodeQuery(params) {
    List<String> query = [];
    params.forEach((key, value) {
      query.add(key.toString() + "=" + value.toString());
    });
    return query.join("&");
  }
}