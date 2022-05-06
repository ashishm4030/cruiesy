import 'dart:convert';
import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cruisy/Constant/constant.dart';
import 'package:cruisy/Screens/GroupProfileScreen.dart';
import 'package:cruisy/Widgets/Appbar_Widget.dart';
import 'package:cruisy/Widgets/Text_Widget.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CreateGroupChatScreen extends StatefulWidget {
  const CreateGroupChatScreen({Key? key}) : super(key: key);

  @override
  _CreateGroupChatScreenState createState() => _CreateGroupChatScreenState();
}

class _CreateGroupChatScreenState extends State<CreateGroupChatScreen> {
  bool isSelected = false;
  bool isloading = false;
  var GroupResponse;
  var GroupData;
  var ison = [];
  List CreateGroupChatList = [];
  var userIdd;
  var chatResponse;
  var chatData;
  var chatId;
  var groupId;
  List<String> images = [
    'assets/images/p1.JPEG',
    'assets/images/p2.JPEG',
    'assets/images/p3.JPEG',
    'assets/images/p4.JPEG',
    'assets/images/p5.JPEG',
    'assets/images/p1.JPEG',
    'assets/images/p2.JPEG',
    'assets/images/p3.JPEG',
  ];

  List<String> name = [
    'Alex Walker',
    'Jube Bowman',
    'Gauthier Drewitt',
    'Jurrien Oldhof',
    'Rahul Malviya',
    'Alex Walker',
    'Jube Bowman',
    'Gauthier Drewitt',
  ];

  @override
  void initState() {
    CreateChatData();
    super.initState();
  }

  var user_id;

  List FavoriteData = [];
  List getChatList = [];

  CreateChatData() async {
    setState(() {
      isloading = true;
    });

    final prefs = await SharedPreferences.getInstance();
    userToken = prefs.getString('UserToken');
    user_id = prefs.getString('UserId');

    try {
      GroupResponse = await dio.post(
        list_favorite_user,
        options: Options(
          headers: {'Authorization': 'Bearer $userToken'},
        ),
      );

      GroupData = jsonDecode(GroupResponse.toString());

      if (GroupData['Status'] == 1) {
        setState(
          () {
            isloading = false;
            FavoriteData = GroupData['data'];

            log(FavoriteData.toString());
            for (var i in FavoriteData) {
              ison.add(false);
            }
          },
        );
      }
      if (GroupData['Status'] == 0) {
        Toasty.showtoast(GroupData['Message']);
      }
    } on DioError catch (e) {}
  }

  List fleetId = [];
  var ComUserId;
  bool isShow = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Visibility(
        visible: isShow,
        child: GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => GroupProfileScreen(
                  multiuserId: ComUserId,
                ),
              ),
            );
          },
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 19),
            height: 50,
            width: double.infinity,
            decoration: BoxDecoration(
              color: kPrimaryColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
                child: RegularText(
              'Create Group Chat',
              fontSize: 18,
              color: Colors.white,
            )),
          ),
        ),
      ),
      backgroundColor: kbackgroundColor,
      appBar: CostumeAppBar(
        text: 'Create Group Chat',
        bool: true,
      ),
      body: ModalProgressHUD(
        inAsyncCall: isloading,
        opacity: 0,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Column(
            children: [
              Expanded(
                child: ListView.builder(
                    physics: BouncingScrollPhysics(),
                    itemCount: FavoriteData.length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            if (ison[index] == false) {
                              ison[index] = true;

                              setState(() {
                                isShow = true;
                              });
                            } else if (ison[index] == true) {
                              ison[index] = false;
                            }
                          });
                          if (fleetId.isEmpty) {
                            setState(() {
                              fleetId.add(user_id);
                              fleetId.add(FavoriteData[index]["favorite_to"]);
                            });
                          } else if (fleetId.contains(FavoriteData[index]["favorite_to"])) {
                            setState(() {
                              fleetId.remove(FavoriteData[index]["favorite_to"]);
                            });
                          } else {
                            setState(() {
                              fleetId.add(FavoriteData[index]["favorite_to"]);
                            });
                          }
                          setState(() {
                            ComUserId = fleetId.join(",");
                          });
                        },
                        child: Container(
                          color: kbackgroundColor,
                          height: 85,
                          margin: EdgeInsets.only(bottom: 15, left: 15, right: 15),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: CachedNetworkImage(
                                  imageUrl: '$IMAGE_URL${FavoriteData[index]['profile_pic']}',
                                  fit: BoxFit.cover,
                                  height: 150,
                                  width: 100,
                                  progressIndicatorBuilder: (context, url, downloadProgress) => Center(child: CircularProgressIndicator()),
                                  errorWidget: (context, url, error) => Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.camera_alt,
                                        color: Colors.grey,
                                        size: 20,
                                      ),
                                      RegularText(
                                        "Add Photo",
                                        color: Colors.grey,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: 15,
                              ),
                              RegularText(
                                FavoriteData[index]["user_name"] ?? "",
                                color: Colors.white,
                              ),
                              Spacer(),
                              Container(
                                height: 20,
                                width: 20,
                                decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: klightGrey)),
                                child: ison[index] == true
                                    ? Image.asset(
                                        'assets/images/Tick.png',
                                        fit: BoxFit.cover,
                                      )
                                    : Container(),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
