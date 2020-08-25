import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';


class PushNotifications
{
  static final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  static FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();
  static init() async
  {
    print("here-----------init---");

    _firebaseMessaging.configure(
        onMessage: (Map<String , dynamic> message) async
        {
          print("onMessage ${message}");
        },
        onLaunch: (Map<String , dynamic> message) async
        {
          print("onMessage ${message}");
        },
        onResume: (Map<String , dynamic> message) async
        {
          print("onMessage ${message}");
        }
    );

  }

  static getToken() async
  {
    String token = await _firebaseMessaging.getToken();
    print("token ${token}");
    getFCMToken();
    return token;
  }
 static void getFCMToken(){

//    final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
    String _message = '';
    _firebaseMessaging.getToken().then((token) {
      print("firebase ----------------");
      print(token);
      print("firebase----------------");
    }
    );
    if (Platform.isIOS){
      _firebaseMessaging.requestNotificationPermissions(
          IosNotificationSettings(sound: true, badge: true, alert: true)
      );
      _firebaseMessaging.onIosSettingsRegistered
          .listen((IosNotificationSettings settings)
      {
        print("Settings registered: $settings");
      });
      print("ios platform");
    }
    _firebaseMessaging.configure(
        onMessage: (Map<String, dynamic> message) async {
          print('on message $message');
          showNotification(message);
//          setState(() => _message = message["notification"]["title"]);
        }, onResume: (Map<String, dynamic> message) async {
      print('on resume $message');
//      setState(() => _message = message["notification"]["title"]);
    }, onLaunch: (Map<String, dynamic> message) async {
      print('on launch $message');
//      setState(() => _message = message["notification"]["title"]);
    });
    var initializationSettingsAndroid = new AndroidInitializationSettings('@mipmap/ic_launcher');
    var initializationSettingsIOS = new IOSInitializationSettings();
    var platform = InitializationSettings(initializationSettingsAndroid,initializationSettingsIOS);

    flutterLocalNotificationsPlugin.initialize(platform);

  }
 static void showNotification(Map<String, dynamic> message) async{
    var android = new AndroidNotificationDetails("channel_id","CHANNLE NAME","channelDescription");
    var ios = new IOSNotificationDetails();
    var platform = new NotificationDetails(android, ios);
    await flutterLocalNotificationsPlugin.show(0, message["notification"]["title"],message["notification"]["body"],platform);

//  message["notification"]["data"]
  }


}