import 'dart:convert';

import 'package:cruisy/Constant/constant.dart';
import 'package:cruisy/Screens/ReceivedPhoto_Screen.dart';
import 'package:cruisy/Widgets/Appbar_Widget.dart';
import 'package:cruisy/Widgets/BottomBar_Widget.dart';
import 'package:cruisy/Widgets/Text_Widget.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChatSettingScreen extends StatefulWidget {
  final otherId, groupid, isGroup, chatid;
  const ChatSettingScreen({Key? key, this.otherId, this.groupid, this.isGroup, this.chatid}) : super(key: key);

  @override
  _ChatSettingScreenState createState() => _ChatSettingScreenState();
}

class _ChatSettingScreenState extends State<ChatSettingScreen> {
  var user_Token;
  var jsonData;
  var UserToken;
  int Selected = 0;

  BlockProfile() async {
    final prefs = await SharedPreferences.getInstance();
    user_Token = prefs.getString('UserToken');
    try {
      final response = await dio.post(
        add_blocked_user,
        data: {
          'block_to': widget.otherId,
        },
        options: Options(
          headers: {'Authorization': 'Bearer $user_Token'},
        ),
      );

      jsonData = jsonDecode(response.toString());

      if (jsonData['Status'] == 1) {
        Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => BottomBar()), (route) => false);
        Toasty.showtoast(
          jsonData['Message'],
        );
        if (jsonData['Status'] == 0) {
          Toasty.showtoast(
            jsonData['Message'],
          );
        }
      } else {
        Toasty.showtoast('Something Went Wrong');
      }
    } on DioError catch (e) {}
  }

  ReportUser() async {
    final prefs = await SharedPreferences.getInstance();
    UserToken = prefs.getString('UserToken');

    try {
      final response = await dio.post(
        add_to_report,
        data: {
          'report_by': UserToken,
          'report_to': widget.otherId,
          'report_type': Selected + 1,
        },
        options: Options(
          headers: {'Authorization': 'Bearer $UserToken'},
        ),
      );

      jsonData = jsonDecode(response.toString());

      if (jsonData['Status'] == 1) {
        Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => BottomBar()), (route) => false);
        Toasty.showtoast(
          jsonData['Message'],
        );
        if (jsonData['Status'] == 0) {
          Toasty.showtoast(
            jsonData['Message'],
          );
        }
      } else {
        Toasty.showtoast('Something Went Wrong');
      }
    } on DioError catch (e) {}
  }

  List reporttext = [
    "Not interested in this person",
    "Fake profile / spam",
    "Inappropriate message",
    "Inappropriate photo",
    "someone is in danger",
  ];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: kbackgroundColor,
      appBar: CostumeAppBar(
        text: 'Settings',
        bool: true,
      ),
      body: Column(
        children: [
          Container(
            height: 0.5,
            color: klightGrey.withOpacity(0.5),
          ),
          SettingButton(
            text: 'Received Photos',
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ReceivePhoto(
                            groupid: widget.groupid,
                            isGroup: widget.isGroup,
                            chatid: widget.chatid,
                          )));
            },
          ),
          SettingButton(
            text: 'Block User',
            onTap: () {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20.0))),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      RegularText(
                        'Are You Sure You Want to Block this User?',
                        letterSpacing: 1,
                        fontSize: 16,
                      ),
                      SizedBox(
                        height: height * 0.03,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          GestureDetector(
                            onTap: () {
                              Navigator.pop(context);
                            },
                            child: Container(
                              height: height * 0.04,
                              width: width * 0.3,
                              decoration: BoxDecoration(border: Border.all(color: Colors.black), borderRadius: BorderRadius.circular(8)),
                              child: Center(
                                child: RegularText(
                                  "No",
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            width: width * 0.02,
                          ),
                          GestureDetector(
                            onTap: () {
                              BlockProfile();
                            },
                            child: Container(
                              height: height * 0.04,
                              width: width * 0.3,
                              decoration: BoxDecoration(color: Colors.white, border: Border.all(color: Colors.black), borderRadius: BorderRadius.circular(8)),
                              child: Center(
                                child: RegularText(
                                  "Yes",
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              );
            },
          ),
          GestureDetector(
            onTap: () {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20.0))),
                  content: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      SizedBox(
                        height: height * 0.02,
                      ),
                      RegularText(
                        'Report User',
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                      ),
                      SizedBox(
                        height: height * 0.01,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: List.generate(
                          5,
                          (index) => Padding(
                            padding: EdgeInsets.all(8.0),
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  Selected = index;
                                  ReportUser();
                                });
                              },
                              child: RegularText(
                                reporttext[index],
                                fontSize: 18,
                              ),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              );
            },
            child: SettingButton(
              text: 'Report User',
            ),
          ),
        ],
      ),
    );
  }
}

class SettingButton extends StatelessWidget {
  final String text;
  final Function()? onTap;
  const SettingButton({Key? key, required this.text, this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    return Column(
      children: [
        Container(
          height: 0.5,
          color: klightGrey.withOpacity(0.5),
        ),
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: width,
            padding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
            child: RegularText(
              text,
              fontSize: 17,
              color: Colors.white,
            ),
          ),
        ),
        Container(
          height: 0.5,
          color: klightGrey.withOpacity(0.5),
        ),
      ],
    );
  }
}
