import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';

const kPrimaryColor = Color(0xff555CFF);
const kGreyColor = Color(0xFFF5F5F5);
const kbackgroundColor = Color(0xff000000);
const klightGrey = Color(0xff505050);
const kfbcolor = Color(0xff3B5998);
const kdisable = Color(0xff555CFF);
int chatFilter = 0;
int chatTapFilter = 0;
int FavoriteTapFilter = 0;

const KAppBarStyle = TextStyle(color: Colors.white, fontSize: 18, fontFamily: 'Roboto');

final kOutlineInputBorder = OutlineInputBorder(
  borderRadius: BorderRadius.circular(40),
  borderSide: BorderSide(color: klightGrey, width: 1.0),
);
final kOutlineInputBorder1 = OutlineInputBorder(
  borderRadius: BorderRadius.circular(40),
  borderSide: BorderSide(color: klightGrey, width: 1.0),
);
final kOutlineInputBorderDrop = OutlineInputBorder(
  borderRadius: BorderRadius.circular(40),
  borderSide: BorderSide(color: klightGrey, width: 1.0),
);
final kOutlineInputBorderBlack = OutlineInputBorder(
  borderRadius: BorderRadius.circular(40),
  borderSide: BorderSide(color: klightGrey, width: 1.0),
);

Dio dio = Dio();

Future setPrefData({required String key, required String value}) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setString(key, value);
}

Future getPrefData({required String key}) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  var data = prefs.getString(key);
  return data;
}

Future clearPrefData() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.clear();
}

Future removePrefData({required String key}) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.remove(key);
}

class Toasty {
  static showtoast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
      textColor: Colors.white,
      backgroundColor: Colors.black.withOpacity(0.5),
    );
  }
}

var device_token;
var device_type;
var device_id;
var latitude;
var longitude;
var userToken;
var userId;

const customProgressIndicator = CupertinoActivityIndicator(animating: true, radius: 25);

Future<void> getCurrentLocation() async {
  Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

  latitude = position.latitude;
  longitude = position.longitude;
  LocationPermission permission;
  permission = await Geolocator.requestPermission();
}

getDeviceId() async {
  var deviceInfo = DeviceInfoPlugin();
  if (Platform.isIOS) {
    device_type = 2;
    var iosDeviceInfo = await deviceInfo.iosInfo;
    device_id = iosDeviceInfo.identifierForVendor;
  } else {
    device_type = 1;
    var androidDeviceInfo = await deviceInfo.androidInfo;
    device_id = androidDeviceInfo.androidId;
  }
}

FirebaseMessaging messaging = FirebaseMessaging.instance;

getDeviceToken() async {
  device_token = await messaging.getToken(
    vapidKey: "KP5PSBMSCF",
  );
}

getUserToken() async {
  userToken = await getPrefData(key: "UserToken");
  userId = await getPrefData(key: "UserId");
}

const BASE_URL = 'http://164.92.83.132:8000/users';
const IMAGE_URL = 'http://164.92.83.132/cruisy/';

const sign_up = '$BASE_URL/sign_up';
const login = '$BASE_URL/login';
const change_password = '$BASE_URL/change_password';
const forgot_password = '$BASE_URL/forgot_password';
const reset_password = '$BASE_URL/reset_password';
const log_out = '$BASE_URL/log_out';
const delete_profile = '$BASE_URL/delete_profile';
const edit_profile = '$BASE_URL/edit_profile';
const edit_account_setting = '$BASE_URL/edit_account_setting';
const list_favorite_user = '$BASE_URL/list_favorite_user';
const list_viewed_user = '$BASE_URL/list_viewed_user';
const home_screen_data = '$BASE_URL/home_screen_data';
const add_user_favorite = '$BASE_URL/add_user_favorite';
const get_chat_taps = '$BASE_URL/get_chat_taps';
const update_user_isonline = '$BASE_URL/update_user_isonline';
const get_user_profile = '$BASE_URL/get_user_profile';
const login_by_thirdparty = '$BASE_URL/login_by_thirdparty';
const filter_online_favorite = '$BASE_URL/filter_online_favorite';
const add_to_view = '$BASE_URL/add_to_view';
const add_to_report = '$BASE_URL/add_to_report';
const create_chat = '$BASE_URL/chats/create_chat';
const add_blocked_user = '$BASE_URL/add_blocked_user';
const add_to_hot = '$BASE_URL/add_to_hot';
const list_hot_user = '$BASE_URL/list_hot_user';
const list_block_user = '$BASE_URL/list_block_user';
const get_hosting_status = '$BASE_URL/get_hosting_status';
const list_map_data = '$BASE_URL/list_map_data';
const get_chat_messages = 'http://164.92.83.132:8000/chats/get_chat_messages';
const get_chat = 'http://164.92.83.132:8000/users/get_chat';
var ChatUrl = "http://164.92.83.132:8000/chats/create_chat";
var send_image = "http://164.92.83.132:8000/chats/send_image";
var get_list_chat_user = "http://164.92.83.132:8000/chats/get_list_chat_user";
var get_list_groupchat_user = "http://164.92.83.132:8000/chats/get_list_groupchat_user";
var get_groupchat_messages = "http://164.92.83.132:8000/chats/get_groupchat_messages";
var get_group_chat_photo = "http://164.92.83.132:8000/chats/get_group_chat_photo";
var get_personal_chat_photo = "http://164.92.83.132:8000/chats/get_personal_chat_photo";
var map_data = "http://164.92.83.132:8000/users/map_data";
var list_join_user_group = "http://164.92.83.132:8000/chats/list_join_user_group";
