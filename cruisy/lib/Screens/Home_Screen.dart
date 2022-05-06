import 'dart:async';
import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cruisy/Accounts/Splash_Screen.dart';
import 'package:cruisy/Constant/constant.dart';
import 'package:cruisy/Screens/ChatMessage_Screen.dart';
import 'package:cruisy/Screens/ExploreScreen.dart';
import 'package:cruisy/Screens/Store_Screen.dart';
import 'package:cruisy/Screens/ViewedYou_Screen.dart';
import 'package:cruisy/Widgets/Custom_Dropdown.dart';
import 'package:cruisy/Widgets/Text_Widget.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:shared_preferences/shared_preferences.dart';

int Selected = 0;
TextEditingController Weight = TextEditingController();
TextEditingController Height = TextEditingController();
TextEditingController Age = TextEditingController();
var BodyType;
var Position;
var RelationShipStatus;

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  ScrollController? _scrollController;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  Completer<GoogleMapController> _controller = Completer();
  static final CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  bool isshow = false;
  bool isshow1 = false;
  bool isshow2 = false;
  bool isshow3 = false;
  bool isshow4 = false;
  bool showage = false;
  var image;
  var lat;
  var long;

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

  bool _isLoading = false;
  var homeScreenResponse;
  var loadresponse;
  var UserId;
  var Favorite_Status;
  var userid;
  var userimage;
  var likestatus;
  var homeScreenData;
  var chatResponse;
  var chatData;
  int total_viewer = 0;
  var freshFaceList = [];
  var nearByList = [];
  var userToken;
  var response;
  var jsondata;
  var UserList;
  var userIdd;
  var chatId;
  var CreateChatList;
  List likelist = [];
  int _page = 1;

  HomeScreenData() async {
    final prefs = await SharedPreferences.getInstance();
    userToken = prefs.getString('UserToken');

    setState(() {
      _isLoading = true;
    });
    try {
      homeScreenResponse = await dio.post(
        home_screen_data,
        data: {
          'lattitude': latitude,
          'longitude': longitude,
          "page_no": 1,
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $userToken',
          },
        ),
      );

      homeScreenData = jsonDecode(homeScreenResponse.toString());
      if (homeScreenData["Status"] == 1) {

        setState(() {
          _isLoading = false;
          total_viewer = homeScreenData['info']['viewer'];
          freshFaceList = homeScreenData['info']['fresh_faces'];
          nearByList = homeScreenData['info']['whos_near_by'];
          for (var i = 0; i < freshFaceList.length; i++) {
            likelist.add(freshFaceList[i]["is_liked_me"]);
          }

        });
      } else if (homeScreenData["code"] == 306) {
        setState(() {
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } on DioError catch (e) {
      setState(() {
        _isLoading = false;
      });


      print(e.response);
    }
  }

  bool _hasNextPage = true;
  bool _isLoadMoreRunning = false;
  Animation<Offset>? animation;
  bool _isFirstLoadRunning = false;

  LoadHomeList() async {
    if (_hasNextPage == true && _isFirstLoadRunning == false && _isLoadMoreRunning == false && _scrollController!.position.extentAfter < 300) {
      setState(() {
        _isLoadMoreRunning = true;
        _page++;

      });
      final prefs = await SharedPreferences.getInstance();
      userToken = prefs.getString('UserToken');
      userId = prefs.getString('UserId');

      try {
        loadresponse = await dio.post(
          home_screen_data,
          data: {
            "page_no": _page,
            'lattitude': latitude,
            'longitude': longitude,
          },
          options: Options(
            headers: {'Authorization': 'Bearer $userToken'},
          ),
        );

        var an;
        var ank = [];
        if (loadresponse.statusCode == 200) {
          setState(() {
            an = jsonDecode(loadresponse.toString());
          });

          if (an['Status'] == 1) {
            if (an['info']['whos_near_by'].length > 0) {
              setState(() {
                nearByList.addAll(an['info']['whos_near_by']);

              });
            } else {
              setState(() {
                _hasNextPage = false;
              });
            }

          }
        }
      } on DioError catch (e) {
        print(e.response);
      }
      setState(() {
        _isLoadMoreRunning = false;
      });
    }
  }

  HomeScreenDataFilter() async {
    final prefs = await SharedPreferences.getInstance();
    userToken = prefs.getString('UserToken');

    setState(() {
      _isLoading = true;
    });
    try {
      homeScreenResponse = await dio.post(
        home_screen_data,
        data: {
          'lattitude': latitude,
          'longitude': longitude,
          "page_no": 1,
          'type': Selected,
          'age': Age.text,
          'weight': Weight.text,
          'height': Height.text,
          'body_type': BodyType,
          'position': Position,
          'relationship_status': RelationShipStatus,
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $userToken',
          },
        ),
      );

      homeScreenData = jsonDecode(homeScreenResponse.toString());
      if (homeScreenData["Status"] == 1) {
        setState(() {
          ClearData();
          if (Selected == 0) {
            Age.text.isEmpty ? Container() : Navigator.pop(context);
          } else if (Selected == 8) {
            Weight.text.isEmpty ? Container() : Navigator.pop(context);
          } else if (Selected == 9) {
            Height.text.isEmpty ? Container() : Navigator.pop(context);
          } else if (Selected == 10) {
            BodyType.isEmpty ? Container() : Navigator.pop(context);
          } else if (Selected == 11) {
            Position.isEmpty ? Container() : Navigator.pop(context);
          } else if (Selected == 12) {
            RelationShipStatus.isEmpty ? Container() : Navigator.pop(context);
          } else {
            Navigator.pop(context);
          }
          _isLoading = false;
          total_viewer = homeScreenData['info']['viewer'];
          freshFaceList = homeScreenData['info']['fresh_faces'];
          nearByList = homeScreenData['info']['whos_near_by'];
          for (var i = 0; i < freshFaceList.length; i++) {
            likelist.add(freshFaceList[i]["is_liked_me"]);
          }

        });
      } else if (homeScreenData["code"] == 306) {
        setState(() {
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } on DioError catch (e) {
      setState(() {
        _isLoading = false;
      });


      print(e.response);
    }
  }

  CrateChat({int? id, String? name, String? profilepic, String? likeStatue, String? userId, String? otherId}) async {
    print(id);

    final prefs = await SharedPreferences.getInstance();
    userToken = prefs.getString('UserToken');
    userIdd = prefs.getString('UserId')!;
    print("userIdd");
    print(userIdd);
    print(userToken);
    try {
      chatResponse = await dio.post(
        "http://164.92.83.132:8000/chats/create_chat",
        data: {"chat_created_to": id},
        options: Options(headers: {'Authorization': 'Bearer $userToken'}),
      );
      chatData = jsonDecode(chatResponse.toString());
      print("chat data is $chatData");
      if (chatData['Status'] == 1) {
        CreateChatList = chatData["info"];
        print("CreateChatList");
        print(CreateChatList);
        print(chatData["info"]);
        chatId = chatData["info"][0]['chat_id'].toString();
        print("chatId");
        print(chatId);
        socket.emit("join_room", {
          "user_id": userIdd,
          "chat_id": chatId,
        });
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatMessageScreen(
                otherId: otherId,
                userId: userIdd,
                image: profilepic,
                likeStatue: likeStatue,
                name: name,
                Chatid: chatId,
              ),
            ));
      }
    } on DioError catch (e) {
      print(e.response);
      print(e.message);
    }
  }

  ClearData() {
    Age.clear();
    Height.clear();
    Weight.clear();
  }

  @override
  dispose() {
    _scrollController!.removeListener(LoadHomeList);
    super.dispose();
  }

  getData() async {
    await HomeScreenData();
    getCurrentLocation();
  }

  FutureOr onGoBack(dynamic value) {
    HomeScreenData();
    setState(() {});
  }

  @override
  void initState() {
    getData();
    _scrollController = ScrollController()..addListener(LoadHomeList);

    super.initState();
  }

  int length1 = 10;

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: kbackgroundColor,
      appBar: PreferredSize(
        preferredSize: Size(width, 70),
        child: SafeArea(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: [
                Image.asset(
                  'assets/images/Views.png',
                  scale: 5,
                ),
                RegularText(
                  '${total_viewer} Viewers',
                  fontSize: 16,
                  color: Colors.white,
                ),
                SizedBox(
                  width: 6,
                ),
                InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      CupertinoPageRoute(
                        builder: (context) => ViewedYouScreen(
                          userId: nearByList[0]["user_id"],
                          image: userimage ?? "",
                          likeStatus: likelist,
                        ),
                      ),
                    );
                  },
                  child: RegularText(
                    'See All',
                    fontSize: 16,
                    color: kPrimaryColor,
                  ),
                ),
                Spacer(),
                GestureDetector(
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => Explore()));
                  },
                  child: Image.asset(
                    'assets/images/Explore.png',
                    scale: 4,
                  ),
                ),
                SizedBox(
                  width: 4,
                ),
                GestureDetector(
                  onTap: () {
                    _scaffoldKey.currentState!.openEndDrawer();
                  },
                  child: Image.asset(
                    'assets/images/Filter.png',
                    scale: 4,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      endDrawer: Drawer(
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

                                        if (Selected == 0) {
                                          showage = true;
                                        } else if (Selected == 8) {
                                          isshow = true;
                                        } else if (Selected == 9) {
                                          isshow1 = true;
                                        } else if (Selected == 10) {
                                          isshow2 = true;
                                        } else if (Selected == 11) {
                                          isshow3 = true;
                                        } else if (Selected == 12) {
                                          isshow4 = true;
                                        }
                                        if (Selected == 4) {
                                          isbusiness == 1 || isbusinessUnlimited == 1 ? HomeScreenDataFilter() : Toasty.showtoast("Please purchase");
                                        }
                                        if (Selected == 6) {
                                          isbusiness == 1 || isbusinessUnlimited == 1 ? HomeScreenDataFilter() : Toasty.showtoast("Please purchase");
                                        }
                                        if (Selected == 1) {
                                          HomeScreenDataFilter();
                                        }
                                        if (Selected == 2) {
                                          HomeScreenDataFilter();
                                        }
                                      },
                                    );
                                  },
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    children: [
                                      Container(
                                        padding: EdgeInsets.only(
                                            top: index == 5
                                                ? 0
                                                : index == 7
                                                    ? 0
                                                    : 10,
                                            left: 10,
                                            right: 10,
                                            bottom: index == 5
                                                ? 0
                                                : index == 7
                                                    ? 0
                                                    : 10),
                                        color: index == 3 ? Color(0xff0d0d0d) : kbackgroundColor,
                                        child: Row(
                                          children: [
                                            index == 5
                                                ? Container()
                                                : index == 7
                                                    ? Container()
                                                    : index == 3
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
                                                : index == 5
                                                    ? Container()
                                                    : index == 7
                                                        ? Container()
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
                                                                        Visibility(
                                                                          visible: showage,
                                                                          child: Row(
                                                                            children: [
                                                                              Expanded(
                                                                                flex: 4,
                                                                                child: Container(
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
                                                                              ),
                                                                              Spacer(),
                                                                              GestureDetector(
                                                                                onTap: () {
                                                                                  isbusiness == 1 || isbusinessUnlimited == 1
                                                                                      ? HomeScreenDataFilter()
                                                                                      : Toasty.showtoast("please Purchase");
                                                                                  // Navigator.pop(context);
                                                                                },
                                                                                child: RegularText(
                                                                                  "Done",
                                                                                  color: Age.text.isEmpty ? Colors.transparent : Colors.white,
                                                                                ),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  )
                                                                : index == 8
                                                                    ? Container(
                                                                        width: 200,
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
                                                                                child: Row(
                                                                                  children: [
                                                                                    Expanded(
                                                                                      flex: 4,
                                                                                      child: TextFormField(
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
                                                                                    Spacer(),
                                                                                    Expanded(
                                                                                      child: GestureDetector(
                                                                                        onTap: () {
                                                                                          isbusiness == 1 || isbusinessUnlimited == 1
                                                                                              ? HomeScreenDataFilter()
                                                                                              : Toasty.showtoast("please Purchase");
                                                                                          Navigator.pop(context);
                                                                                        },
                                                                                        child: RegularText(
                                                                                          "Done",
                                                                                          color: Weight.text.isEmpty ? Colors.transparent : Colors.white,
                                                                                        ),
                                                                                      ),
                                                                                    ),
                                                                                  ],
                                                                                ),
                                                                              ),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      ) // Weight
                                                                    : index == 9
                                                                        ? Container(
                                                                            width: 200,
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
                                                                                    child: Row(
                                                                                      children: [
                                                                                        Expanded(
                                                                                          flex: 4,
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
                                                                                        Spacer(),
                                                                                        Expanded(
                                                                                          child: GestureDetector(
                                                                                            onTap: () {
                                                                                              isbusiness == 1 || isbusinessUnlimited == 1
                                                                                                  ? HomeScreenDataFilter()
                                                                                                  : Toasty.showtoast("please Purchase");
                                                                                              Navigator.pop(context);
                                                                                            },
                                                                                            child: RegularText(
                                                                                              "Done",
                                                                                              color: Height.text.isEmpty ? Colors.transparent : Colors.white,
                                                                                            ),
                                                                                          ),
                                                                                        ),
                                                                                      ],
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                              ],
                                                                            ),
                                                                          )
                                                                        : index == 10
                                                                            ? Container(
                                                                                width: 200,
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
                                                                                    Visibility(
                                                                                      visible: isshow2,
                                                                                      child: Row(
                                                                                        children: [
                                                                                          Expanded(
                                                                                            flex: 50,
                                                                                            child: CustomDropdown(
                                                                                              value: BodyType,
                                                                                              onChanged: (value) {

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
                                                                                              DropdownText: 'Body Type',
                                                                                              text: '',
                                                                                            ),
                                                                                          ),
                                                                                          Spacer(),
                                                                                          GestureDetector(
                                                                                            onTap: () {
                                                                                              isbusiness == 1 || isbusinessUnlimited == 1
                                                                                                  ? HomeScreenDataFilter()
                                                                                                  : Toasty.showtoast("please Purchase");
                                                                                            },
                                                                                            child: RegularText(
                                                                                              "Done",
                                                                                              color: BodyType == null ? Colors.transparent : Colors.white,
                                                                                            ),
                                                                                          ),
                                                                                        ],
                                                                                      ),
                                                                                    )
                                                                                  ],
                                                                                ),
                                                                              )
                                                                            : index == 11
                                                                                ? Container(
                                                                                    width: 200,
                                                                                    child: Column(
                                                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                                                      children: [
                                                                                        RegularText(
                                                                                          "Position",
                                                                                          color: Colors.white,
                                                                                        ),
                                                                                        SizedBox(
                                                                                          height: 5,
                                                                                        ),
                                                                                        Visibility(
                                                                                          visible: isshow3,
                                                                                          child: Row(
                                                                                            children: [
                                                                                              Expanded(
                                                                                                flex: 50,
                                                                                                child: CustomDropdown(
                                                                                                  value: Position,
                                                                                                  onChanged: (value) {

                                                                                                    setState(() {
                                                                                                      Position = value;
                                                                                                    });
                                                                                                  },
                                                                                                  select: ['Top', 'Bottom', 'Verse'],
                                                                                                  DropdownText: 'Position',
                                                                                                  text: '',
                                                                                                ),
                                                                                              ),
                                                                                              Spacer(),
                                                                                              GestureDetector(
                                                                                                onTap: () {
                                                                                                  isbusiness == 1 || isbusinessUnlimited == 1
                                                                                                      ? HomeScreenDataFilter()
                                                                                                      : Toasty.showtoast("please Purchase");
                                                                                                },
                                                                                                child: RegularText(
                                                                                                  "Done",
                                                                                                  color: Position == null ? Colors.transparent : Colors.white,
                                                                                                ),
                                                                                              ),
                                                                                            ],
                                                                                          ),
                                                                                        ),
                                                                                      ],
                                                                                    ),
                                                                                  )
                                                                                : index == 12
                                                                                    ? Container(
                                                                                        width: 200,
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
                                                                                            Visibility(
                                                                                              visible: isshow4,
                                                                                              child: Row(
                                                                                                children: [
                                                                                                  Expanded(
                                                                                                    flex: 5,
                                                                                                    child: CustomDropdown(
                                                                                                      value: RelationShipStatus,
                                                                                                      onChanged: (value) {
                                                                                                      setState(() {
                                                                                                          RelationShipStatus = value;
                                                                                                        });
                                                                                                      },
                                                                                                      select: ['Single', 'Married'],
                                                                                                      DropdownText: 'Status',
                                                                                                      text: '',
                                                                                                    ),
                                                                                                  ),
                                                                                                  Spacer(),
                                                                                                  GestureDetector(
                                                                                                    onTap: () {
                                                                                                      isbusiness == 1 || isbusinessUnlimited == 1
                                                                                                          ? HomeScreenDataFilter()
                                                                                                          : Toasty.showtoast("please Purchase");
                                                                                                    },
                                                                                                    child: RegularText(
                                                                                                      "Done",
                                                                                                      color: RelationShipStatus == null ? Colors.transparent : Colors.white,
                                                                                                    ),
                                                                                                  ),
                                                                                                ],
                                                                                              ),
                                                                                            ),
                                                                                          ],
                                                                                        ),
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
                                      index == 5
                                          ? Container()
                                          : index == 7
                                              ? Container()
                                              : Container(
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
      ),
      body: ModalProgressHUD(
        inAsyncCall: _isLoading,
        opacity: 0,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 15),
              child: RegularText(
                'Fresh Faces',
                color: Colors.white,
                fontSize: 22,
              ),
            ),
            SizedBox(
              height: height * 0.15,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: List.generate(
                    freshFaceList.length,
                    (index) => Column(
                      children: [
                        Stack(
                          children: [
                            Container(
                              margin: EdgeInsets.only(left: 12, right: 10, top: 12, bottom: 4),
                              height: height * 0.1,
                              width: width * 0.2,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16.5),
                                  border: isbusiness == 1 || isbusinessUnlimited == 1
                                      ? freshFaceList[index]["is_user_online"] == 1
                                          ? Border.all(color: kPrimaryColor, width: 2)
                                          : Border.all(color: Colors.transparent)
                                      : Border.all(color: Colors.transparent)),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(15),
                                child: CachedNetworkImage(
                                  imageUrl: freshFaceList[index]['profile_pic'] == null ? '' : '$IMAGE_URL${freshFaceList[index]['profile_pic']}'.toString(),
                                  placeholder: (context, url) => Container(
                                    alignment: Alignment.center,
                                    child: CircularProgressIndicator(),
                                  ),
                                  fit: BoxFit.cover,
                                  errorWidget: (context, url, error) => Container(
                                    decoration: BoxDecoration(border: Border.all(color: klightGrey), borderRadius: BorderRadius.circular(16.5)),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.image,
                                          color: klightGrey,
                                          size: 24,
                                        )
                                      ],
                                    ),
                                    height: 90.0,
                                    width: 90.0,
                                  ),
                                ),
                              ),
                            ),

                          ],
                        ),
                        RegularText(
                          freshFaceList[index]['user_name'] == null ? '' : freshFaceList[index]['user_name'].toString(),
                          color: Colors.white,
                          fontSize: 11,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: RegularText(
                'Who’s Nearby',
                color: Colors.white,
                fontSize: 22,
              ),
            ),
            nearByList.isEmpty && _isLoading == false
                ? Center(
                    child: Column(
                      children: [
                        SizedBox(
                          height: height * 0.2,
                        ),
                        Icon(
                          Icons.access_time_outlined,
                          color: Colors.grey,
                        ),
                        RegularText(
                          "No One Near You",
                          color: Colors.grey,
                          fontSize: 18,
                        ),
                      ],
                    ),
                  )
                : Expanded(
                    child: Container(
                      padding: EdgeInsets.only(bottom: isbusiness == 1 || isbusinessUnlimited == 1 ? 75 : 125),
                      child: GridView.builder(
                        itemCount: isbusiness == 1 || isbusinessUnlimited == 1 ? nearByList.length : nearByList.length,
                        reverse: false, //default
                        controller: _scrollController,
                        primary: false,
                        shrinkWrap: true,
                        padding: EdgeInsets.all(5.0),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          mainAxisSpacing: 4.0,
                          crossAxisSpacing: 4.0,
                        ),
                        itemBuilder: (BuildContext context, int index) {
                          return GestureDetector(
                            onTap: () {

                              CrateChat(
                                id: nearByList[index]['user_id'],
                                userId: userIdd,
                                name: nearByList[index]['user_name'],
                                profilepic: '$IMAGE_URL${nearByList[index]['profile_pic']}',
                                likeStatue: nearByList[index]['is_liked_me'].toString(),
                                otherId: nearByList[index]['user_id'].toString(),
                              ).then((onGoBack));

                            },
                            child: Stack(
                              children: [
                                Container(
                                  height: height,
                                  width: width,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(7),
                                    border: isbusiness == 1 || isbusinessUnlimited == 1
                                        ? nearByList[index]['is_user_online'] == 1
                                            ? Border.all(color: kPrimaryColor, width: 2)
                                            : Border.all(color: Colors.transparent)
                                        : Border.all(color: Colors.transparent),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(7),
                                    child: CachedNetworkImage(
                                      imageUrl: nearByList[index]['profile_pic'] == null ? '' : '$IMAGE_URL${nearByList[index]['profile_pic']}'.toString(),
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
                                nearByList[index]["is_liked_me"] == 1
                                    ? Positioned(
                                        top: 5,
                                        right: 5,
                                        child: Image.asset(
                                          'assets/images/Favourites-1.png',
                                          scale: 6.5,
                                        ),
                                      )
                                    : Container(),
                                Positioned(
                                  left: 8,
                                  bottom: 5,
                                  child: Row(
                                    children: [
                                      nearByList[index]['user_name'] == null
                                          ? Container()
                                          : Container(
                                              height: 8,
                                              width: 8,
                                              decoration: BoxDecoration(color: Color(0xff5bfa8d), shape: BoxShape.circle),
                                            ),
                                      SizedBox(
                                        width: 2,
                                      ),
                                      RegularText(
                                        nearByList[index]['user_name'] == null ? '' : nearByList[index]['user_name'].toString(),
                                        fontSize: 12,
                                        color: Colors.white,
                                      )
                                    ],
                                  ),
                                )
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
