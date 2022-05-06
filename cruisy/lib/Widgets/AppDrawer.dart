import 'dart:convert';

import 'package:cruisy/Constant/constant.dart';
import 'package:cruisy/Widgets/Custom_Dropdown.dart';
import 'package:cruisy/Widgets/Text_Widget.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeFilterAppdrawer extends StatefulWidget {
  const HomeFilterAppdrawer({Key? key}) : super(key: key);

  @override
  _HomeFilterAppdrawerState createState() => _HomeFilterAppdrawerState();
}

class _HomeFilterAppdrawerState extends State<HomeFilterAppdrawer> {
  TextEditingController Weight = TextEditingController();
  TextEditingController Height = TextEditingController();
  TextEditingController Age = TextEditingController();
  int Selected = 0;
  var BodyType;
  var Position;
  var RelationShipStatus;
  bool isshow = false;
  bool isshow1 = false;

  List<String> title = [
    'Age',
    'Looking For',
    'Tribes',
    'Tribes',
    'Weight',
    'Weight',
    'Weight',
    'Weight',
    'Weight',
    'Height',
    'Body Type',
    'Position',
    'Relationship Status',
  ];

  List<String> title1 = [
    'See who’s online right now',
    'See only people with photos',
    'See only people with face photos',
  ];

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    return Drawer(
      child: Container(
        color: kbackgroundColor,
        height: MediaQuery.of(context).size.height,
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: width,
                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                color: Color(0xff0d0d0d),
                child: RegularText(
                  'Basic Filters',
                  color: Colors.white,
                ),
              ),
              Container(
                height: 0.5,
                color: klightGrey.withOpacity(0.5),
              ),
              Expanded(
                child: Container(
                  child: SingleChildScrollView(
                    child: Column(
                      children: List.generate(
                          title.length,
                          (index) => GestureDetector(
                                onTap: () {
                                  setState(
                                    () {
                                      Selected = index;
                                      if (Selected == 8) {
                                        isshow = true;
                                      } else if (Selected == 9) {
                                        isshow1 = true;
                                      }

                                    },
                                  );
                                },
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    Container(
                                      padding: EdgeInsets.only(top: 10, left: 10, right: 10, bottom: 10),
                                      color: index == 3 ? Color(0xff0d0d0d) : kbackgroundColor,
                                      child: Row(
                                        children: [
                                          index == 3
                                              ? Container()
                                              : Container(
                                                  padding: EdgeInsets.all(2.5),
                                                  height: 20,
                                                  width: 20,
                                                  decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: klightGrey)),
                                                  child: Selected == index
                                                      ? Container(
                                                          height: 20,
                                                          width: 20,
                                                          decoration: BoxDecoration(shape: BoxShape.circle, color: kPrimaryColor),
                                                        )
                                                      : Container(),
                                                ),
                                          SizedBox(
                                            width: 8,
                                          ),
                                          index == 3
                                              ? RegularText(
                                                  'Advanced Filters',
                                                  color: Colors.white,
                                                )
                                              : index == 4
                                                  ? Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        RegularText(
                                                          "Online Now",
                                                          color: Colors.white,
                                                        ),
                                                        RegularText(
                                                          "See who’s online right now",
                                                          color: Colors.white,
                                                        ),
                                                      ],
                                                    )
                                                  : index == 0
                                                      ? Container(
                                                          width: 150,
                                                          child: Column(
                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                            children: [
                                                              RegularText(
                                                                "Age",
                                                                color: Colors.white,
                                                              ),
                                                              SizedBox(
                                                                height: 5,
                                                              ),
                                                              Container(
                                                                height: 40,
                                                                child: TextField(
                                                                  controller: Age,
                                                                  keyboardType: TextInputType.number,
                                                                  style: TextStyle(color: kPrimaryColor, fontFamily: 'RobotoCR', fontSize: 13),
                                                                  decoration: InputDecoration(
                                                                    contentPadding: EdgeInsets.only(left: 10),
                                                                    hintText: 'Age',
                                                                    hintStyle: TextStyle(color: Colors.grey, fontFamily: 'RobotoCR', fontSize: 13),
                                                                    border: OutlineInputBorder(
                                                                      borderRadius: BorderRadius.circular(0),
                                                                      borderSide: BorderSide(color: Colors.black, width: 1.0),
                                                                    ),
                                                                    focusedBorder: OutlineInputBorder(
                                                                      borderRadius: BorderRadius.circular(10),
                                                                      borderSide: BorderSide(color: klightGrey, width: 1.0),
                                                                    ),
                                                                    enabledBorder: OutlineInputBorder(
                                                                      borderRadius: BorderRadius.circular(10),
                                                                      borderSide: BorderSide(color: klightGrey, width: 1.0),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        )
                                                      : index == 8
                                                          ? Container(
                                                              width: 150,
                                                              child: Column(
                                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                                children: [
                                                                  RegularText(
                                                                    "Weight",
                                                                    color: Colors.white,
                                                                  ),
                                                                  SizedBox(
                                                                    height: 5,
                                                                  ),
                                                                  Visibility(
                                                                    visible: isshow,
                                                                    child: Container(
                                                                      height: 40,
                                                                      child: TextField(
                                                                        controller: Weight,
                                                                        keyboardType: TextInputType.number,
                                                                        style: TextStyle(color: kPrimaryColor, fontFamily: 'RobotoCR', fontSize: 13),
                                                                        decoration: InputDecoration(
                                                                          hintText: 'Weight',
                                                                          contentPadding: EdgeInsets.only(left: 10),
                                                                          hintStyle: TextStyle(color: Colors.grey, fontFamily: 'RobotoCR', fontSize: 13),
                                                                          border: OutlineInputBorder(
                                                                            borderRadius: BorderRadius.circular(0),
                                                                            borderSide: BorderSide(color: Colors.black, width: 1.0),
                                                                          ),
                                                                          focusedBorder: OutlineInputBorder(
                                                                            borderRadius: BorderRadius.circular(10),
                                                                            borderSide: BorderSide(color: klightGrey, width: 1.0),
                                                                          ),
                                                                          enabledBorder: OutlineInputBorder(
                                                                            borderRadius: BorderRadius.circular(10),
                                                                            borderSide: BorderSide(color: klightGrey, width: 1.0),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            )
                                                          : index == 9
                                                              ? Container(
                                                                  width: 150,
                                                                  child: Column(
                                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                                    children: [
                                                                      RegularText(
                                                                        "Height",
                                                                        color: Colors.white,
                                                                      ),
                                                                      SizedBox(
                                                                        height: 5,
                                                                      ),
                                                                      Visibility(
                                                                        visible: isshow1,
                                                                        child: Container(
                                                                          height: 40,
                                                                          child: TextField(
                                                                            controller: Height,
                                                                            keyboardType: TextInputType.number,
                                                                            style: TextStyle(color: kPrimaryColor, fontFamily: 'RobotoCR', fontSize: 13),
                                                                            decoration: InputDecoration(
                                                                              contentPadding: EdgeInsets.only(left: 10),
                                                                              hintText: 'Height',
                                                                              hintStyle: TextStyle(color: Colors.grey, fontFamily: 'RobotoCR', fontSize: 13),
                                                                              border: OutlineInputBorder(
                                                                                borderRadius: BorderRadius.circular(0),
                                                                                borderSide: BorderSide(color: Colors.black, width: 1.0),
                                                                              ),
                                                                              focusedBorder: OutlineInputBorder(
                                                                                borderRadius: BorderRadius.circular(10),
                                                                                borderSide: BorderSide(color: klightGrey, width: 1.0),
                                                                              ),
                                                                              enabledBorder: OutlineInputBorder(
                                                                                borderRadius: BorderRadius.circular(10),
                                                                                borderSide: BorderSide(color: klightGrey, width: 1.0),
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                )
                                                              : index == 10
                                                                  ? Container(
                                                                      width: 150,
                                                                      child: Column(
                                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                                        children: [
                                                                          RegularText(
                                                                            "Body Type",
                                                                            color: Colors.white,
                                                                          ),
                                                                          SizedBox(
                                                                            height: 5,
                                                                          ),
                                                                          CustomDropdown(
                                                                            value: BodyType,
                                                                            onChanged: (value) {
                                                                              print(value);
                                                                              setState(() {
                                                                                BodyType = value;
                                                                              });
                                                                            },
                                                                            select: [
                                                                              'Bear',
                                                                              'Muscle',
                                                                              'Guy Next Door',
                                                                              'Jock',
                                                                              'Geek',
                                                                              'Leather',
                                                                              'Discreet',
                                                                              'College',
                                                                              'Otter',
                                                                              'Military',
                                                                              'Twink',
                                                                              'Bisexual',
                                                                              'Transgender'
                                                                            ],
                                                                            DropdownText: 'BodyType',
                                                                            text: '',
                                                                          )
                                                                        ],
                                                                      ),
                                                                    )
                                                                  : index == 11
                                                                      ? Container(
                                                                          width: 150,
                                                                          child: Column(
                                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                                            children: [
                                                                              RegularText(
                                                                                "Body Type",
                                                                                color: Colors.white,
                                                                              ),
                                                                              SizedBox(
                                                                                height: 5,
                                                                              ),
                                                                              CustomDropdown(
                                                                                value: Position,
                                                                                onChanged: (value) {
                                                                                  print(value);
                                                                                  setState(() {
                                                                                    Position = value;
                                                                                  });
                                                                                },
                                                                                select: ['Top', 'Bottom', 'Verse'],
                                                                                DropdownText: 'Position',
                                                                                text: '',
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        )
                                                                      : index == 12
                                                                          ? Container(
                                                                              width: 150,
                                                                              child: Column(
                                                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                                                children: [
                                                                                  RegularText(
                                                                                    "RelationShip Status",
                                                                                    color: Colors.white,
                                                                                  ),
                                                                                  SizedBox(
                                                                                    height: 5,
                                                                                  ),
                                                                                  CustomDropdown(
                                                                                    value: RelationShipStatus,
                                                                                    onChanged: (value) {
                                                                                      print(value);
                                                                                      setState(() {
                                                                                        RelationShipStatus = value;
                                                                                      });
                                                                                    },
                                                                                    select: ['Single', 'Married'],
                                                                                    DropdownText: 'Status',
                                                                                    text: '',
                                                                                  ),
                                                                                ],
                                                                              ),
                                                                            )
                                                                          : index == 5
                                                                              ? Column(
                                                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                                                  children: [
                                                                                    RegularText(
                                                                                      "Photos Only",
                                                                                      color: Colors.white,
                                                                                    ),
                                                                                    RegularText(
                                                                                      "See only people with photos",
                                                                                      color: Colors.white,
                                                                                    ),
                                                                                  ],
                                                                                )
                                                                              : index == 7
                                                                                  ? Column(
                                                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                                                      children: [
                                                                                        RegularText(
                                                                                          "Face Photos Only",
                                                                                          color: Colors.white,
                                                                                        ),
                                                                                        RegularText(
                                                                                          "See only people with face photos",
                                                                                          color: Colors.white,
                                                                                        ),
                                                                                      ],
                                                                                    )
                                                                                  : index == 6
                                                                                      ? RegularText(
                                                                                          "Haven't Chatted Today",
                                                                                          color: Colors.white,
                                                                                        )
                                                                                      : RegularText(
                                                                                          title[index],
                                                                                          color: Colors.white,
                                                                                        ),
                                          Spacer(),
                                          index == 1
                                              ? RegularText(
                                                  'Chat',
                                                  color: kPrimaryColor,
                                                )
                                              : Container()
                                        ],
                                      ),
                                    ),
                                    Container(
                                      height: 0.5,
                                      color: klightGrey.withOpacity(0.5),
                                    ),
                                  ],
                                ),
                              )),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ChatFilterdrawer extends StatefulWidget {
  const ChatFilterdrawer({Key? key}) : super(key: key);

  @override
  _ChatFilterdrawerState createState() => _ChatFilterdrawerState();
}

class _ChatFilterdrawerState extends State<ChatFilterdrawer> {
  int Selected = 0;
  List<String> title = ['Unread', 'Favorites', 'Online Now'];
  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    return Drawer(
        child: Container(
      color: Color(0xff0d0d0d),
      child: Column(
        children: [
          SafeArea(
            child: Column(
              children: [
                Container(
                  width: width,
                  padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                  color: Color(0xff0d0d0d),
                  child: RegularText(
                    'Chat Filters',
                    color: Colors.white,
                  ),
                ),
                Container(
                  height: 0.5,
                  color: klightGrey.withOpacity(0.5),
                ),
                Column(
                  children: List.generate(
                    3,
                    (index) => Column(
                      children: [
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              Selected = index;
                            });
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 15),
                            height: 50,
                            color: kbackgroundColor,
                            child: Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(3),
                                  height: 20,
                                  width: 20,
                                  decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: klightGrey)),
                                  child: Selected == index
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
                                  title[index],
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
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ));
  }
}

class TabFilterdrawer extends StatefulWidget {
  const TabFilterdrawer({Key? key}) : super(key: key);

  @override
  _TabFilterdrawerState createState() => _TabFilterdrawerState();
}

class _TabFilterdrawerState extends State<TabFilterdrawer> {
  int Selected = 0;
  List<String> title = ['Looking', 'Friendly', 'Hot'];
  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    return Drawer(
        child: Container(
      color: Color(0xff0d0d0d),
      child: Column(
        children: [
          SafeArea(
            child: Column(
              children: [
                Container(
                  width: width,
                  padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                  color: Color(0xff0d0d0d),
                  child: RegularText(
                    'Tap Filters',
                    color: Colors.white,
                  ),
                ),
                Container(
                  height: 0.5,
                  color: klightGrey.withOpacity(0.5),
                ),
                Column(
                  children: List.generate(
                    3,
                    (index) => Column(
                      children: [
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              Selected = index;
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
                                  child: Selected == index
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
                                  title[index],
                                  color: Colors.white,
                                ),
                              ],
                            ),
                          ),
                        ),
                        Container(
                          height: 0.5,
                          color: klightGrey,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ));
  }
}

class FavoriteFilterDrawer extends StatefulWidget {
  const FavoriteFilterDrawer({Key? key}) : super(key: key);

  @override
  _FavoriteFilterDrawerState createState() => _FavoriteFilterDrawerState();
}

class _FavoriteFilterDrawerState extends State<FavoriteFilterDrawer> {
  bool Selected = false;
  bool isloading = false;
  var response;
  var jsonData;
  var getChatResponse;
  var getChatData;
  var user_Token;
  var getChatList;

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
          print("============");
          print(getChatList);
          Toasty.showtoast(getChatData["Message"]);
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

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    return Drawer(
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
                          Navigator.of(context).pop();
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
    ));
  }
}
