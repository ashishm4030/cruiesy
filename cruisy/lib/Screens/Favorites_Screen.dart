import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cruisy/Constant/constant.dart';
import 'package:cruisy/Screens/FavoriteProfile_Screen.dart';
import 'package:cruisy/Widgets/Text_Widget.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({Key? key}) : super(key: key);

  @override
  _FavoritesScreenState createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool isloading = false;
  var response;
  var jsonData;
  var getChatResponse;
  var getChatData;
  var user_Token;

  bool Selected = false;

  GetChatDataFilter() async {
    final prefs = await SharedPreferences.getInstance();
    user_Token = prefs.getString('UserToken');
    setState(() {
      isloading = true;
    });
    try {
      getChatResponse = await dio.post(
        filter_online_favorite,
        data: {
          'type': 1,
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $user_Token',
          },
        ),
      );
      print("getChatResponse");
      print(getChatResponse);
      getChatData = jsonDecode(getChatResponse.toString());
      print("getChatData");
      print(getChatData);
      if (getChatData["Status"] == 2 && mounted) {
        setState(() {
          isloading = false;
          getChatList = getChatData['info'];

          print(getChatList);
          getChatList.isEmpty ? Toasty.showtoast("No One FavoriteUser is Online") : Toasty.showtoast(getChatData["Message"]);
          Navigator.of(context).pop();
        });
      } else {
        setState(() {
          isloading = false;
        });
      }
    } on DioError catch (e) {
      setState(() {
        isloading = false;
      });
      print(e);
      print(e.message);
      print(e.response);
    }
  }

  List<String> images = [
    'assets/images/p1.JPEG',
    'assets/images/p2.JPEG',
    'assets/images/p3.JPEG',
    'assets/images/p4.JPEG',
    'assets/images/p5.JPEG',
    'assets/images/p6.JPEG',
    'assets/images/p1.JPEG',
    'assets/images/p2.JPEG',
    'assets/images/p3.JPEG',
  ];

  List<String> name = [
    'Alex',
    'Jube',
    'Gauthier',
    'Jurrien',
    'Rahul',
    'Alex',
    'Jube',
    'Gauthier',
    'Jurrien',
  ];

  List FavoriteData = [];
  List getChatList = [];

  FavoriteUserList() async {
    setState(() {
      isloading = true;
    });

    final prefs = await SharedPreferences.getInstance();
    userToken = prefs.getString('UserToken');

    try {
      response = await dio.post(
        list_favorite_user,
        options: Options(
          headers: {'Authorization': 'Bearer $userToken'},
        ),
      );

      jsonData = jsonDecode(response.toString());

      if (jsonData['Status'] == 1) {
        setState(
          () {
            isloading = false;
            FavoriteData = jsonData['data'];

            log(FavoriteData.toString());
          },
        );
        // Toasty.showtoast(jsonData['Message']);
      }
      if (jsonData['Status'] == 0) {
        Toasty.showtoast(jsonData['Message']);
      }
    } on DioError catch (e) {
      print(e.response);
    }
  }

  var results;

  FutureOr onGoBack(dynamic value) {
    FavoriteUserList();
    setState(() {});
  }

  @override
  void initState() {
    FavoriteUserList();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: kbackgroundColor,
      appBar: AppBar(
        backgroundColor: kbackgroundColor,
        title: RegularText(
          'Favourites',
          color: Colors.white,
          fontSize: 18,
        ),
        actions: [
          GestureDetector(
            onTap: () {
              _scaffoldKey.currentState!.openEndDrawer();
            },
            child: Image.asset(
              'assets/images/Filter.png',
              scale: 5,
            ),
          ),
        ],
      ),
      endDrawer: Drawer(
          child: Container(
        color: kbackgroundColor,
        child: Column(
          children: [
            SafeArea(
              child: Column(
                children: [
                  Container(
                    width: width,
                    padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                    color: kbackgroundColor,
                    child: RegularText(
                      'Favorite Filters',
                      color: Colors.white,
                    ),
                  ),
                  Container(
                    height: 0.5,
                    color: klightGrey.withOpacity(0.5),
                  ),
                  Column(
                    children: [
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            Selected = true;
                            GetChatDataFilter();
                          });
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 15),
                          height: 50,
                          color: kbackgroundColor,
                          child: Row(
                            children: [
                              Container(
                                padding: EdgeInsets.all(4),
                                height: 20,
                                width: 20,
                                decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: klightGrey)),
                                child: Selected == true
                                    ? Container(
                                        height: 20,
                                        width: 20,
                                        decoration: BoxDecoration(shape: BoxShape.circle, color: kPrimaryColor),
                                      )
                                    : Container(),
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              RegularText(
                                'Online Now',
                                color: Colors.white,
                              ),
                            ],
                          ),
                        ),
                      ),
                      Container(
                        height: 0.5,
                        color: klightGrey.withOpacity(0.5),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      )),
      body: ModalProgressHUD(
          inAsyncCall: isloading,
          opacity: 0,
          child: getChatList.isNotEmpty
              ? GridView.builder(
                  itemCount: getChatList.length,
                  reverse: false, //default
                  // controller: ScrollController(),
                  primary: false,
                  shrinkWrap: true,
                  padding: EdgeInsets.all(5.0),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: 5.0,
                    crossAxisSpacing: 5.0,
                  ),
                  itemBuilder: (BuildContext context, int index) {
                    return Stack(
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => FavoriteProfileScreen(
                                          user_name: getChatList[index]['user_name'] ?? "",
                                          favorite_to: getChatList[index]["favorite_to"] ?? "",
                                          hotstatus: FavoriteData[index]["is_hot_me"] ?? "",
                                        ))).then((onGoBack));
                          },
                          child: Container(
                            height: height,
                            width: width,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(7),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(7),
                              child: CachedNetworkImage(
                                height: 100,
                                imageUrl: '$IMAGE_URL${getChatList[index]['profile_pic']}'.toString(),
                                placeholder: (context, url) => Container(
                                  alignment: Alignment.center,
                                  child: CircularProgressIndicator(),
                                ),
                                fit: BoxFit.cover,
                                errorWidget: (context, url, error) => Container(
                                  decoration: BoxDecoration(border: Border.all(color: klightGrey), borderRadius: BorderRadius.circular(7)),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.image,
                                        color: klightGrey,
                                        size: 40,
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          top: 5,
                          right: 5,
                          child: Image.asset(
                            'assets/images/Favourites-1.png',
                            scale: 6.5,
                          ),
                        ),
                        Positioned(
                          left: 8,
                          bottom: 5,
                          child: Row(
                            children: [
                              Container(
                                height: 8,
                                width: 8,
                                decoration: BoxDecoration(color: Color(0xff5bfa8d), shape: BoxShape.circle),
                              ),
                              SizedBox(
                                width: 2,
                              ),
                              RegularText(
                                getChatList[index]["user_name"] ?? "",
                                fontSize: 12,
                                color: Colors.white,
                              )
                            ],
                          ),
                        )
                      ],
                    );
                  },
                )
              : FavoriteData.isNotEmpty
                  ? GridView.builder(
                      itemCount: FavoriteData.length,
                      reverse: false, //default
                      // controller: ScrollController(),
                      primary: false,
                      shrinkWrap: true,
                      padding: EdgeInsets.all(5.0),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        mainAxisSpacing: 5.0,
                        crossAxisSpacing: 5.0,
                      ),
                      itemBuilder: (BuildContext context, int index) {
                        return Stack(
                          children: [
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => FavoriteProfileScreen(
                                              islike: 1,
                                              user_name: FavoriteData[index]['user_name'] ?? "",
                                              favorite_to: FavoriteData[index]["favorite_to"] ?? "",
                                              hotstatus: FavoriteData[index]["is_hot_me"] ?? "",
                                            ))).then((onGoBack));
                              },
                              child: Container(
                                height: height,
                                width: width,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(7),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(7),
                                  child: CachedNetworkImage(
                                    height: 100,
                                    imageUrl: '$IMAGE_URL${FavoriteData[index]['profile_pic']}'.toString(),
                                    placeholder: (context, url) => Container(
                                      alignment: Alignment.center,
                                      child: CircularProgressIndicator(),
                                    ),
                                    fit: BoxFit.cover,
                                    errorWidget: (context, url, error) => Container(
                                      decoration: BoxDecoration(border: Border.all(color: klightGrey), borderRadius: BorderRadius.circular(7)),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.image,
                                            color: klightGrey,
                                            size: 40,
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              top: 5,
                              right: 5,
                              child: Image.asset(
                                'assets/images/Favourites-1.png',
                                scale: 6.5,
                              ),
                            ),
                            Positioned(
                              left: 8,
                              bottom: 5,
                              child: Row(
                                children: [
                                  Container(
                                    height: 8,
                                    width: 8,
                                    decoration: BoxDecoration(color: Color(0xff5bfa8d), shape: BoxShape.circle),
                                  ),
                                  SizedBox(
                                    width: 2,
                                  ),
                                  RegularText(
                                    FavoriteData[index]["user_name"] ?? "",
                                    fontSize: 12,
                                    color: Colors.white,
                                  )
                                ],
                              ),
                            )
                          ],
                        );
                      },
                    )
                  : Container()),
    );
  }
}
