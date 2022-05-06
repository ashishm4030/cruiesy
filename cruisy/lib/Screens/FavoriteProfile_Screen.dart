import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cruisy/Constant/constant.dart';
import 'package:cruisy/Screens/ProfileSetting_Screen.dart';
import 'package:cruisy/Widgets/BottomBar_Widget.dart';
import 'package:cruisy/Widgets/Text_Widget.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FavoriteProfileScreen extends StatefulWidget {
  final favorite_to;
  final user_name;
  final islike;
  final hotstatus;
  const FavoriteProfileScreen({Key? key, this.favorite_to, this.user_name, this.islike, this.hotstatus}) : super(key: key);

  @override
  _FavoriteProfileScreenState createState() => _FavoriteProfileScreenState();
}

class _FavoriteProfileScreenState extends State<FavoriteProfileScreen> {
  int _pageSelected = 0;
  bool Selected = false;
  bool Selectedlike = false;
  bool SelectedHot = false;
  bool isLoading = false;
  var user_Token;
  var favorite;
  var jsonData;
  var likeStatus;
  var user_id;
  var userProfileResponse;
  var userProfileData;
  var profileData;
  var images;
  var Multipic;
  var hotstatus;
  var UserToken;
  var imageList = [];
  PageController _pageController = PageController(initialPage: 0);

  AddFavoriteUser() async {
    setState(() {
      isLoading = true;
    });
    final prefs = await SharedPreferences.getInstance();
    user_Token = prefs.getString('UserToken');

    try {
      final response = await dio.post(
        add_user_favorite,
        data: {
          'favorite_to': widget.favorite_to,
        },
        options: Options(
          headers: {'Authorization': 'Bearer $user_Token'},
        ),
      );

      jsonData = jsonDecode(response.toString());

      if (jsonData['Status'] == 1) {
        setState(() {});

        Toasty.showtoast(
          jsonData['Message'],
        );
      } else if (jsonData['Status'] == 2) {
        setState(() {
          // setUserData();
        });

        Toasty.showtoast(
          jsonData['Message'],
        );
      }
    } on DioError catch (e) {}
  }

  AddHotUser() async {
    setState(() {
      isLoading = true;
    });
    final prefs = await SharedPreferences.getInstance();
    user_Token = prefs.getString('UserToken');
    user_id = prefs.getString('UserId');

    try {
      final response = await dio.post(
        add_to_hot,
        data: {
          'hot_to': widget.favorite_to,
          'user_id': user_id,
        },
        options: Options(
          headers: {'Authorization': 'Bearer $user_Token'},
        ),
      );

      jsonData = jsonDecode(response.toString());

      if (jsonData['Status'] == 1) {
        Toasty.showtoast(
          jsonData['Message'],
        );
      } else if (jsonData['Status'] == 2) {
        Toasty.showtoast(
          jsonData['Message'],
        );
      }
    } on DioError catch (e) {}
  }

  GetInformation() async {
    final prefs = await SharedPreferences.getInstance();
    user_Token = prefs.getString('UserToken');
    user_id = prefs.getString('UserId');

    try {
      userProfileResponse = await dio.post(get_user_profile,
          data: {"user_id": widget.favorite_to},
          options: Options(
            headers: {'Authorization': 'Bearer $user_Token'},
          ));

      userProfileData = jsonDecode(userProfileResponse.toString());

      if (userProfileData['Status'] == 1) {
        setState(() {
          profileData = userProfileData['data'];

          hotstatus = profileData["is_hot_me"];

          Multipic = profileData["user_image"];

          for (int i = 0; i < Multipic.length; i++) {
            imageList.add(Multipic[i]["image"]);
          }
        });
      }
      if (userProfileData['Status'] == 0) {
        Toasty.showtoast(userProfileData['Message']);
      }
    } on DioError catch (e) {}
  }

  BlockProfile(var i) async {
    final prefs = await SharedPreferences.getInstance();
    user_Token = prefs.getString('UserToken');

    try {
      final response = await dio.post(
        add_blocked_user,
        data: {
          'block_to': i,
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
          'report_to': widget.favorite_to,
          'report_type': 1,
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
    } on DioError catch (e) {
      print(e.response);
    }
  }

  @override
  void initState() {
    GetInformation();

    if (widget.islike == 1) {
      Selectedlike = true;
    } else {
      Selectedlike = false;
    }
    if (widget.hotstatus == 1) {
      setState(() {
        SelectedHot = true;
      });
    } else {
      setState(() {
        SelectedHot = false;
      });
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      backgroundColor: kbackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          Row(
            children: [
              GestureDetector(
                onTap: () {
                  setState(() {
                    if (Selectedlike == false) {
                      setState(() {
                        Selectedlike = true;
                      });
                    } else {
                      setState(() {
                        Selectedlike = false;
                      });
                    }
                    AddFavoriteUser();
                  });
                },
                child: Image.asset(
                  'assets/images/Favourites-1.png',
                  color: Selectedlike == true ? Colors.blue : Colors.grey,
                  scale: 5,
                ),
              ),
              SizedBox(
                width: 5,
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
                            'Block User',
                            fontWeight: FontWeight.bold,
                            fontSize: 22,
                          ),
                          SizedBox(
                            height: height * 0.01,
                          ),
                          GestureDetector(
                            onTap: () {
                              BlockProfile(widget.favorite_to);
                            },
                            child: RegularText(
                              'Block User',
                              fontSize: 18,
                            ),
                          ),
                          SizedBox(
                            height: height * 0.01,
                          ),
                          GestureDetector(
                            onTap: () {
                              ReportUser();
                            },
                            child: RegularText(
                              'Report User',
                              fontSize: 18,
                            ),
                          ),
                          SizedBox(
                            height: height * 0.02,
                          ),
                        ],
                      ),
                    ),
                  );
                },
                child: Image.asset(
                  'assets/images/Filter-2.png',
                  scale: 5,
                ),
              ),
              SizedBox(
                width: 15,
              ),
            ],
          ),
        ],
        leading: InkWell(
          onTap: () {
            Navigator.pop(context);
          },
          child: Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
        ),
      ),
      body: profileData == null
          ? Container(child: Center(child: CircularProgressIndicator()))
          : Stack(
              children: [
                PageView(
                  onPageChanged: (value) {
                    setState(() {
                      _pageSelected = value;
                    });
                  },
                  allowImplicitScrolling: true,
                  controller: _pageController,
                  scrollDirection: Axis.vertical,
                  children: List.generate(
                    imageList.length,
                    (index) => ClipRRect(
                      child: CachedNetworkImage(
                        imageUrl: "http://164.92.83.132/cruisy${imageList[index]}",
                        fit: BoxFit.cover,
                        width: width,
                        height: height,
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
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: 20,
                  top: height * 0.4,
                  child: Column(
                    children: List.generate(
                      imageList.length,
                      (index) => Container(
                        margin: EdgeInsets.only(bottom: 5),
                        height: 10,
                        width: 10,
                        decoration: BoxDecoration(color: _pageSelected == index ? kPrimaryColor : Colors.white, shape: BoxShape.circle),
                      ),
                    ),
                  ),
                ),
                imageList.isEmpty
                    ? Positioned(
                        child: Column(children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: CachedNetworkImage(
                              imageUrl: "$IMAGE_URL${profileData["profile_pic"]}",
                              fit: BoxFit.cover,
                              height: height,
                              width: width,
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
                          )
                        ]),
                      )
                    : Container(),
                Positioned(
                  bottom: 0,
                  child: Container(
                    padding: Selected == true ? EdgeInsets.only(top: 15) : EdgeInsets.symmetric(),
                    width: width,
                    height: Selected == true ? height * 0.4 : height * 0.2,
                    decoration: BoxDecoration(color: Color(0xff0d0d0d), borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                            child: Row(
                              children: [
                                RegularText(
                                  widget.user_name,
                                  color: Colors.white,
                                  fontSize: 19,
                                ),
                                Spacer(),
                                GestureDetector(
                                  onTap: () {
                                    if (Selected == false) {
                                      setState(() {
                                        Selected = true;
                                      });
                                    } else if (Selected == true) {
                                      setState(() {
                                        Selected = false;
                                      });
                                    }
                                  },
                                  child: Selected != true
                                      ? Icon(
                                          Icons.arrow_upward,
                                          color: Colors.white,
                                        )
                                      : Icon(
                                          Icons.arrow_downward,
                                          color: Colors.white,
                                        ),
                                )
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 15),
                            child: Row(
                              children: [
                                Image.asset(
                                  'assets/images/location.png',
                                  scale: 3.5,
                                ),
                                SizedBox(
                                  width: 5,
                                ),
                                RegularText(
                                  '129m away',
                                  color: Colors.white,
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 15),
                            child: Row(
                              children: [
                                Container(
                                  height: 10,
                                  width: 10,
                                  decoration: BoxDecoration(color: Color(0xff5bfa8d), shape: BoxShape.circle),
                                ),
                                SizedBox(
                                  width: 6,
                                ),
                                RegularText(
                                  profileData["is_user_online"] == 1 ? 'Online Now' : "Offline now",
                                  color: Color(0xff5bfa8d),
                                ),
                                Spacer(),
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      if (SelectedHot == false) {
                                        setState(() {
                                          SelectedHot = true;
                                        });
                                      } else {
                                        setState(() {
                                          SelectedHot = false;
                                        });
                                      }
                                      AddHotUser();
                                    });
                                  },
                                  child: SelectedHot == true
                                      ? Image.asset(
                                          'assets/images/hot.png',
                                          scale: 4,
                                        )
                                      : Image.asset(
                                          'assets/images/hot1.png',
                                          scale: 5,
                                        ),
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Stack(
                                  overflow: Overflow.visible,
                                  children: [
                                    Image.asset(
                                      'assets/images/Chats-2.png',
                                      scale: 5,
                                    ),
                                    Positioned(
                                      top: -9,
                                      right: -2,
                                      child: Container(
                                        padding: EdgeInsets.only(left: 4, right: 4, top: 4, bottom: 6),
                                        decoration: BoxDecoration(color: kPrimaryColor, shape: BoxShape.circle),
                                        child: RegularText(
                                          profileData["unread_count"].toString(),
                                          fontSize: 12,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Selected == true
                              ? Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.fromLTRB(15, 7, 15, 5),
                                      child: RegularText(
                                        'About Me',
                                        color: Colors.white,
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.fromLTRB(15, 0, 15, 10),
                                      child: RegularText(
                                        profileData["about_me"] ?? "",
                                        color: Colors.white,
                                        fontSize: 18,
                                      ),
                                    ),
                                    ProfileSettingButton(
                                      text: 'Height',
                                      visible: true,
                                      text1: profileData["height"] ?? "Not Added Height",
                                    ),
                                    ProfileSettingButton(
                                      text: 'Weight',
                                      visible: true,
                                      text1: profileData["weight"] ?? "Not Added weight",
                                    ),
                                    ProfileSettingButton(
                                      text: 'Body Type',
                                      visible: true,
                                      text1: profileData["body_type"] ?? "Not Added body type",
                                    ),
                                    ProfileSettingButton(
                                      text: 'Relationship Status',
                                      visible: true,
                                      text1: profileData["relationship_status"] ?? "Not Added status",
                                    ),
                                    SizedBox(
                                      height: 20,
                                    ),
                                  ],
                                )
                              : Container(),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
