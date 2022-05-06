import 'dart:async';
import 'dart:convert';

import 'package:cruisy/Accounts/LogInScreen.dart';
import 'package:cruisy/Constant/constant.dart';
import 'package:cruisy/Widgets/BottomBar_Widget.dart';
import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:socket_io_client/socket_io_client.dart';

var UserId;
late Socket socket;
String? socketID;

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  final notifications = FlutterLocalNotificationsPlugin();
  late AndroidNotificationChannel channel;
  var updateUserResponse;
  var user_token;
  var updateUserData;

  @override
  void initState() {
    getToken();
    getCurrentLocation();
    getDeviceToken();

    final IOSInitializationSettings initializationSettingsIOS = IOSInitializationSettings(
      requestSoundPermission: true,
      requestBadgePermission: true,
      requestAlertPermission: true,
      defaultPresentAlert: true,
      defaultPresentBadge: true,
      defaultPresentSound: true,
      onDidReceiveLocalNotification: onDidReceiveLocalNotification,
    );

    const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('launch_background');

    var initializationSettings = InitializationSettings(iOS: initializationSettingsIOS, android: initializationSettingsAndroid);

    notifications.initialize(initializationSettings, onSelectNotification: onSelectNotification);

    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      RemoteNotification? notification = message.notification;

      AppleNotification? ios = message.notification?.apple;
      if (notification != null && ios != null) {
        notifications.show(
          notification.hashCode,
          notification.title,
          notification.body,
          NotificationDetails(iOS: IOSNotificationDetails(presentAlert: true, presentBadge: true, presentSound: true)),
        );
        NotificationSettings settings = await messaging.requestPermission(alert: true, badge: true, provisional: true, sound: true);
      }
      AndroidNotification? android = message.notification?.android;
      if (notification != null && android != null) {
        notifications.show(
          notification.hashCode,
          notification.title,
          notification.body,
          NotificationDetails(
            android: AndroidNotificationDetails('1', 'Test', icon: 'notification'),
            iOS: IOSNotificationDetails(presentAlert: true, presentBadge: true, presentSound: true),
          ),
        );
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {});

    FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage? message) async {
      if (message != null) {}
    });

    Timer(
      Duration(seconds: 3),
      () => Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => userToken == null ? LogInScreen() : BottomBar(),
        ),
      ),
    );
    // UserIsOnline();
    super.initState();
  }

  Future<dynamic> onSelectNotification(payload) async {}

  void onDidReceiveLocalNotification(int? id, String? title, String? body, String? payload) async {
    return;
  }

  UserIsOnline() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    user_token = prefs.getString('UserToken');

    try {
      updateUserResponse = await dio.post(
        update_user_isonline,
        data: {
          'is_online': 1,
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $user_token',
          },
        ),
      );

      updateUserData = jsonDecode(updateUserResponse.toString());
      if (updateUserData["Status"] == 1) {
        setState(() {});
      } else {}
    } on DioError catch (e) {}
  }

  getToken() async {
    await getDeviceId();
    userToken = await getPrefData(key: "UserToken");
    userId = await getPrefData(key: "UserId");

    if (userId != null) {
      RegisterSocket();
    }
  }

  RegisterSocket() {
    socket = io("http://164.92.83.132:8000/", <String, dynamic>{
      "transports": ['websocket']
    });
    socket.on(
        "connect",
        (data) => {
              socket.emit("socket_register", {"user_id": userId}),
              socketID = socket.id,
            });
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Center(
          child: Image.asset(
            'assets/images/Curisby-A.png',
            height: height * 0.55,
            width: width * 0.55,
          ),
        ),
      ),
    );
  }
}
