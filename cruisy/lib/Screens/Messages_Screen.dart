import 'dart:async';
import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cruisy/Accounts/Splash_Screen.dart';
import 'package:cruisy/Constant/constant.dart';
import 'package:cruisy/Screens/ChatMessage_Screen.dart';
import 'package:cruisy/Screens/CreateGroupChat_Screen.dart';
import 'package:cruisy/Screens/GroupChat_Screen.dart';
import 'package:cruisy/Screens/Store_Screen.dart';
import 'package:cruisy/Widgets/Text_Widget.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timeago/timeago.dart' as timeago;

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({Key? key}) : super(key: key);

  @override
  _MessagesScreenState createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  TabController? _tabController;
  int _currentTabIndex = 0;

  @override
  void initState() {

    getUserToken();
    // AddLoad();
    setState(() {
      _tabController = TabController(length: TabText.length, vsync: this, initialIndex: 0);
      _tabController!.addListener(() {
        setState(() {
          _currentTabIndex = _tabController!.index;
        });
      });
    });
    super.initState();
  }

  List<String> TabText = ['Chats', 'Taps'];
  int SelectedTabs = 0;
  var tabsindex;
  bool _isLoading = false;
  var getChatData;
  var getChatResponse;
  var getChatList = [];
  var getGroupChatList = [];

  GetChatData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    user_token = prefs.getString('UserToken');

    setState(() {
      _isLoading = true;
    });
    try {
      getChatResponse = await dio.post(
        get_list_chat_user,
        options: Options(
          headers: {
            'Authorization': 'Bearer $user_token',
          },
        ),
      );

      getChatData = jsonDecode(getChatResponse.toString());
      if (getChatData["Status"] == 1) {
        setState(() {
          _isLoading = false;
          getChatList = getChatData['info']["personal_chat"];
          getGroupChatList = getChatData['info']["group_chat"];

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

  var updateUserResponse;
  var updateUserData;

  var user_token;
  Future getUserToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    user_token = prefs.getString('UserToken');

  }

  FutureOr onGoBack(dynamic value) {
    GetChatData();
    setState(() {});
  }

  int Selected = 4;
  List<String> title = ['Unread', 'Favorites', 'Online Now'];

  int SelectedTap = 4;
  List<String> title_Tap = ['Looking', 'Friendly', 'Hot'];

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: kbackgroundColor,
      appBar: PreferredSize(
        preferredSize: Size(width, 55),
        child: SafeArea(
          child: Container(
            height: 55,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Row(
                  children: [
                    Expanded(
                      flex: 7,
                      child: TabBar(
                        indicatorColor: Colors.white,
                        unselectedLabelColor: klightGrey,
                        labelColor: kGreyColor,
                        controller: _tabController,
                        tabs: List.generate(
                          TabText.length,
                          (index) => Listener(
                            onPointerDown: (event) {

                            },
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 4),
                              child: Stack(
                                overflow: Overflow.visible,
                                children: [
                                  Container(
                                    child: Text(
                                      TabText[index],
                                      style: TextStyle(fontSize: 16),
                                    ),
                                  ),

                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                        flex: 1,
                        child: SizedBox(
                          width: 15,
                        )),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          CupertinoPageRoute(
                            builder: (context) => CreateGroupChatScreen(),
                          ),
                        ).then((onGoBack));
                      },
                      child: Image.asset(
                        'assets/images/chattab.png',
                        scale: 5,
                      ),
                    ),
                    SizedBox(
                      width: 15,
                    ),
                  ],
                ),
                Container(
                  height: 0.5,
                  color: klightGrey.withOpacity(0.5),
                ),
              ],
            ),
          ),
        ),
      ),

      body: TabBarView(controller: _tabController, children: [
        ChatTabScreen(),
        Container(
          padding: EdgeInsets.only(top: 15, bottom: 15, left: 7, right: 15),
          child: TabsScreen(),
        ),
      ]),
    );
  }
}

class ChatTabScreen extends StatefulWidget {
  @override
  _ChatTabScreenState createState() => _ChatTabScreenState();
}

class _ChatTabScreenState extends State<ChatTabScreen> {
  TextEditingController searchController = TextEditingController();
  List searchList = [];

  var getChatResponse;
  var getGroupChatResponse;
  var getChatData;
  var getGroupChatData;
  var user_token;
  var time;
  var getChatList = [];
  var getGroupChatList = [];
  var BothListt = [];
  Dio dio = Dio();
  bool _isLoading = false;

  GetChatData(var value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    user_token = prefs.getString('UserToken');

    setState(() {
      _isLoading = true;
    });
    try {
      getChatResponse = await dio.post(get_list_chat_user,
          options: Options(
            headers: {
              'Authorization': 'Bearer $user_token',
            },
          ),
          data: {
            "search_user": value,
          });

      getChatData = jsonDecode(getChatResponse.toString());
      if (getChatData["Status"] == 1) {
        setState(() {
          _isLoading = false;
          getChatList = getChatData['info']["personal_chat"];
          getGroupChatList = getChatData['info']["group_chat"];
          for (int i = 0; i < getGroupChatList.length; i++) {
            time = getGroupChatList[i]["created_at"];

          }
          BothListt.addAll(getChatList);
          BothListt.addAll(getGroupChatList);

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

  updateCount() async {
    socket.on('count_update', (data) {

      if (mounted) {
        for (int i = 0; i < getChatList.length; i++) {

          if (data['chat_id'].toString() == getChatList[i]['chat_id'].toString()) {
            setState(() {
              getChatList[i]['unread_count'] = data['unread_count'];
              getChatList[i]['message_text'] = data['message_text'];
              getChatList[i]['created_at'] = data['created_at'];
              getChatList[i]['message_type'] = data['message_type'];
            });
          }
        }
      }
      GetChatData("");
    });
  }

  updateGroupCount() async {
    socket.on('count_update', (data) {

      if (mounted) {
        for (int i = 0; i < getGroupChatList.length; i++) {
          if (data['group_id'].toString() == getGroupChatList[i]['group_id'].toString()) {
            setState(() {
              getGroupChatList[i]["unread_count"] = data['unread_count'];
              getGroupChatList[i]['message_text'] = data['gmessage_text'];
              getGroupChatList[i]['created_at'] = data['created_at'];
              getGroupChatList[i]['gmessage_type'] = data['gmessage_type'];
            });
          }
        }
      }
      GetChatData("");
    });
  }

  late String inputFormat;
  formatDateTime(var date) {
    var dateFormat = DateFormat.jm();
    var utcDate = dateFormat.format(DateTime.parse(date));
    String createdDate = dateFormat.parse(utcDate, true).toLocal().toString();
    inputFormat = dateFormat.format(DateTime.parse(createdDate));
    return inputFormat;
  }

  FutureOr onGoBack(dynamic value) {
    GetChatData("");
    setState(() {});
  }

  GoAndChat({
    String? ChatId,
    String? name,
    String? otherId,
    String? image,
  }) {
    socket.emit("join_room", {
      "user_id": userId,
      "chat_id": ChatId,
    });
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChatMessageScreen(
            otherId: otherId,
            image: image,
            Chatid: ChatId,
            name: name,
            userId: userId,
          ),
        )).then((onGoBack));
  }

  GoAndGroupChat({
    String? GroupId,
    String? GroupName,
  }) {

    socket.emit("join_group", {
      "user_id": userId,
      "group_id": GroupId,
    });

    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => GroupChatScreen(
            pop: false,
            groupId: GroupId,
            groupname: GroupName,
          ),
        )).then((onGoBack));
  }


  @override
  void initState() {
    GetChatData("");
    updateGroupCount();
    updateCount();
    getUserToken();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kbackgroundColor,
      body: Padding(
        padding: EdgeInsets.only(top: 15, bottom: 15, left: 7, right: 15),
        child: Column(
          children: [
            TextField(
              controller: searchController,
              maxLines: 1,
              onChanged: (value) {
                if (value.isNotEmpty) {
                  print(value);
                  print("value");
                  GetChatData(value);
                } else {
                  print("Clear");
                  GetChatData("");
                }
              },
              cursorColor: Colors.white,
              keyboardType: TextInputType.text,
              style: TextStyle(color: Colors.white, fontSize: 16),
              decoration: InputDecoration(
                prefixIcon: Image.asset(
                  'assets/images/Shape-2.png',
                  scale: 4,
                  color: klightGrey,
                ),
                hintText: 'Search Chat',
                hintStyle: TextStyle(color: klightGrey, fontSize: 16),
                contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(40),
                  borderSide: BorderSide(color: Colors.white, width: 1.0),
                ),
                focusedBorder: kOutlineInputBorderBlack,
                enabledBorder: kOutlineInputBorderBlack,
                errorBorder: kOutlineInputBorderBlack,
                focusedErrorBorder: kOutlineInputBorderBlack,
              ),
            ),
            SizedBox(
              height: 10,
            ),

            Expanded(
              child: Container(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            RegularText(
                              "Group Chats",
                              color: getGroupChatList.isEmpty ? Colors.transparent : Colors.white,
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Container(
                              child: Column(
                                children: List.generate(
                                  getGroupChatList.length,
                                  (index) => GestureDetector(
                                    onTap: () {
                                      GoAndGroupChat(
                                        GroupId: getGroupChatList[index]['group_id'].toString(),
                                        GroupName: getGroupChatList[index]['chats_name'] ?? '',
                                      );
                                    },
                                    child: Stack(
                                      children: [
                                        Container(
                                          margin: EdgeInsets.only(bottom: 15),
                                          color: kbackgroundColor,
                                          child: Row(
                                            children: [
                                              Container(
                                                decoration: BoxDecoration(
                                                    // border: Border.all(color: getGroupChatList[index]['is_user_online'] == 1 ? kPrimaryColor : Colors.transparent),
                                                    borderRadius: BorderRadius.circular(12)),
                                                child: ClipRRect(
                                                  borderRadius: BorderRadius.circular(12),
                                                  child: CachedNetworkImage(
                                                    imageUrl: getGroupChatList[index]['profile_pic'] == null ? '' : '$IMAGE_URL${getGroupChatList[index]['profile_pic']}',
                                                    placeholder: (context, url) => Container(
                                                      alignment: Alignment.center,
                                                      child: CircularProgressIndicator(),
                                                    ),
                                                    fit: BoxFit.cover,
                                                    width: 85,
                                                    height: 80,
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
                                                      height: 85.0,
                                                      width: 85.0,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              SizedBox(
                                                width: 10,
                                              ),
                                              Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  RegularText(
                                                    getGroupChatList[index]['chats_name'] ?? '',
                                                    color: isbusiness == 1 || isbusinessUnlimited == 1
                                                        ? getGroupChatList[index]["unread_count"] == 0
                                                            ? Color(0xff808080)
                                                            : Colors.white
                                                        : Colors.grey,
                                                    fontSize: 12,
                                                  ),
                                                  getGroupChatList[index]["gmessage_type"] == 1
                                                      ? Container(
                                                          width: 200,
                                                          child: RegularText(
                                                            '${getGroupChatList[index]['message_text'] != null ? Uri.decodeFull(getGroupChatList[index]['message_text'].toString()) : ""}',
                                                            maxLines: 1,
                                                            color: isbusiness == 1 || isbusinessUnlimited == 1
                                                                ? getGroupChatList[index]["unread_count"] == 0
                                                                    ? Color(0xff808080)
                                                                    : Colors.white
                                                                : Colors.grey,
                                                            fontSize: 17,
                                                          ),
                                                        )
                                                      : getGroupChatList[index]["gmessage_type"] == 2
                                                          ? RegularText(
                                                              '${"image"}',
                                                              color: isbusiness == 1 || isbusinessUnlimited == 1
                                                                  ? getGroupChatList[index]["unread_count"] == 0
                                                                      ? Color(0xff808080)
                                                                      : Colors.white
                                                                  : Colors.grey,
                                                              fontSize: 17,
                                                            )
                                                          : getGroupChatList[index]["gmessage_type"] == 3
                                                              ? RegularText(
                                                                  '${"Location"}',
                                                                  color: isbusiness == 1 || isbusinessUnlimited == 1
                                                                      ? getGroupChatList[index]["unread_count"] == 0
                                                                          ? Color(0xff808080)
                                                                          : Colors.white
                                                                      : Colors.grey,
                                                                  fontSize: 17,
                                                                )
                                                              : Container(
                                                                  width: 200,
                                                                  child: RegularText(
                                                                    Uri.decodeFull(getGroupChatList[index]['message_text'].toString()),
                                                                    color: isbusiness == 1 || isbusinessUnlimited == 1
                                                                        ? getGroupChatList[index]["unread_count"] == 0
                                                                            ? Color(0xff808080)
                                                                            : Colors.white
                                                                        : Colors.grey,
                                                                    fontSize: 17,
                                                                    maxLines: 1,
                                                                  ),
                                                                ),
                                                ],
                                              ),

                                            ],
                                          ),
                                        ),

                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            RegularText(
                              "Personal Chats",
                              color: getChatList.isEmpty ? Colors.transparent : Colors.white,
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Container(
                              padding: EdgeInsets.only(bottom: isbusiness == 1 || isbusinessUnlimited == 1 ? 50 : 100),
                              child: Column(
                                children: List.generate(
                                    getChatList.length,
                                    (index) => GestureDetector(
                                          onTap: () {
                                            GoAndChat(
                                                image: '$IMAGE_URL${getChatList[index]['profile_pic']}',
                                                name: getChatList[index]['chats_name'] ?? '',
                                                ChatId: getChatList[index]["chat_id"].toString(),
                                                otherId: getChatList[index]["other_id"].toString());
                                          },
                                          child: Container(
                                            margin: EdgeInsets.only(bottom: 15),
                                            height: 85,
                                            color: kbackgroundColor,
                                            child: Row(
                                              children: [
                                                Stack(
                                                  children: [
                                                    Container(
                                                      width: 85,
                                                      height: 85,
                                                      decoration: BoxDecoration(
                                                        borderRadius: BorderRadius.circular(12),

                                                      ),
                                                      child: ClipRRect(
                                                        borderRadius: BorderRadius.circular(12),
                                                        child: CachedNetworkImage(
                                                          imageUrl: getChatList[index]['profile_pic'] == null ? '' : '$IMAGE_URL${getChatList[index]['profile_pic']}',
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
                                                                ),
                                                              ],
                                                            ),
                                                            height: 85.0,
                                                            width: 85.0,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    getChatList[index]['unread_count'] == 1
                                                        ? Positioned(
                                                            bottom: 7,
                                                            left: 7,
                                                            child: Container(
                                                              height: 8,
                                                              width: 8,
                                                              decoration: BoxDecoration(color: Color(0xff5bfa8d), shape: BoxShape.circle),
                                                            ),
                                                          )
                                                        : Container(),

                                                  ],
                                                ),
                                                SizedBox(
                                                  width: 10,
                                                ),
                                                Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  children: [
                                                    RegularText(
                                                      getChatList[index]['chats_name'] ?? '',
                                                      color: isbusiness == 1 || isbusinessUnlimited == 1
                                                          ? getChatList[index]["unread_count"] == 0
                                                              ? Color(0xff808080)
                                                              : Colors.white
                                                          : Colors.grey,
                                                      fontSize: 12,
                                                    ),
                                                    getChatList[index]["message_type"] == 1
                                                        ? Container(
                                                            width: 200,
                                                            child: getChatList[index]["is_delete"] == 1
                                                                ? Container()
                                                                : RegularText(
                                                                    '${getChatList[index]['message_text'] != null ? Uri.decodeFull(getChatList[index]['message_text'].toString()) : ""}',
                                                                    maxLines: 1,
                                                                    color: isbusiness == 1 || isbusinessUnlimited == 1
                                                                        ? getChatList[index]["unread_count"] == 0
                                                                            ? Color(0xff808080)
                                                                            : Colors.white
                                                                        : Colors.grey,
                                                                    fontSize: 17,
                                                                  ),
                                                          )
                                                        : getChatList[index]["message_type"] == 2
                                                            ? RegularText(
                                                                '${"image"}',
                                                                color: isbusiness == 1 || isbusinessUnlimited == 1
                                                                    ? getChatList[index]["unread_count"] == 0
                                                                        ? Color(0xff808080)
                                                                        : Colors.white
                                                                    : Colors.grey,
                                                                fontSize: 17,
                                                              )
                                                            : getChatList[index]["message_type"] == 3
                                                                ? RegularText(
                                                                    '${"Location"}',
                                                                    color: isbusiness == 1 || isbusinessUnlimited == 1
                                                                        ? getChatList[index]["unread_count"] == 0
                                                                            ? Color(0xff808080)
                                                                            : Colors.white
                                                                        : Colors.grey,
                                                                    fontSize: 17,
                                                                  )
                                                                : RegularText(
                                                                    '',
                                                                  ),
                                                  ],
                                                ),

                                              ],
                                            ),
                                          ),
                                        )),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TabsScreen extends StatefulWidget {
  @override
  _TabsScreenState createState() => _TabsScreenState();
}

class _TabsScreenState extends State<TabsScreen> {
  String timeUntil(DateTime date) {
    return timeago.format(date, allowFromNow: true);
  }

  var getChatTapResponse;
  var getChatTapData;
  var user_token;
  bool _isLoading = false;
  var getChatTapList = [];

  GetChatTapData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    user_token = prefs.getString('UserToken');

    setState(() {
      _isLoading = true;
    });
    try {
      getChatTapResponse = await dio.post(
        list_hot_user,
        options: Options(
          headers: {
            'Authorization': 'Bearer $user_token',
          },
        ),
      );

      getChatTapData = jsonDecode(getChatTapResponse.toString());
      if (getChatTapData["Status"] == 1) {
        setState(() {
          _isLoading = false;
          getChatTapList = getChatTapData['data'];

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

  @override
  void initState() {
    GetChatTapData();
    super.initState();
  }

  late String inputFormat;
  formatDateTime(var date) {
    var dateFormat = DateFormat.jm();
    var utcDate = dateFormat.format(DateTime.parse(date));
    String createdDate = dateFormat.parse(utcDate, true).toLocal().toString();
    inputFormat = dateFormat.format(DateTime.parse(createdDate));
    return inputFormat;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kbackgroundColor,
      body: getChatTapList.length == 0
          ? Center(
              child: RegularText(
                'Nobody has tapped your \nprofile yet. When they do,\n they’ll appear here.',
                fontSize: 16,
              ),
            )
          : getChatTapList.isEmpty
              ? Center(
                  child: RegularText(
                    'No data Found',
                    fontSize: 16,
                    color: Colors.white,
                  ),
                )
              : ListView.builder(
                  itemCount: getChatTapList.length,
                  itemBuilder: (context, index) {
                    return Container(
                      margin: EdgeInsets.only(bottom: 15),
                      height: 85,
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: CachedNetworkImage(
                              height: 85,
                              width: 85,
                              imageUrl: getChatTapList[index]['profile_pic'] == null ? '' : '$IMAGE_URL${getChatTapList[index]['profile_pic']}'.toString(),
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
                                height: 85.0,
                                width: 85.0,
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 15,
                          ),
                          RegularText(
                            getChatTapList[index]['user_name'].toString(),
                            color: Colors.white,
                          ),
                          Spacer(),
                          Align(
                            alignment: Alignment.topRight,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                RegularText(
                                  formatDateTime(getChatTapList[index]['created_at'].toString()),
                                  color: klightGrey,
                                  fontSize: 12,
                                ),
                                SizedBox(
                                  height: 1,
                                ),
                                Image.asset(
                                  'assets/images/hot.png',
                                  scale: 5,
                                ),
                                RegularText(
                                  'Hot',
                                  color: kPrimaryColor,
                                  fontSize: 12,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
    );
  }
}
