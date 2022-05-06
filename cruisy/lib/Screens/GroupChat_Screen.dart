import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:clipboard/clipboard.dart';
import 'package:cruisy/Accounts/Splash_Screen.dart';
import 'package:cruisy/Constant/constant.dart';
import 'package:cruisy/Screens/ChatMessage_Screen.dart';
import 'package:cruisy/Screens/ChatSetting_Screen.dart';
import 'package:cruisy/Screens/GroupMemberScreen.dart';
import 'package:cruisy/Screens/Store_Screen.dart';
import 'package:cruisy/Widgets/Text_Widget.dart';
import 'package:cruisy/Widgets/Textfeild_Widget.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class GroupChatScreen extends StatefulWidget {
  final pop, groupId, groupname;
  const GroupChatScreen({Key? key, this.pop, this.groupId, this.groupname}) : super(key: key);

  @override
  _GroupChatScreenState createState() => _GroupChatScreenState();
}

class _GroupChatScreenState extends State<GroupChatScreen> with SingleTickerProviderStateMixin {
  TextEditingController sendMessage = TextEditingController();
  ScrollController? _scrollController;
  int Selected = 0;
  int SelectedMessage = 0;
  bool isVisible = true;
  FocusNode key = FocusNode();
  bool _isFirstLoadRunning = false;
  var groupChatListResponse;
  var groupChatListJsonData;

  static final LatLng _kMapCenter = LatLng(latitude, longitude);

  static final CameraPosition _kInitialPosition = CameraPosition(target: _kMapCenter, zoom: 11.0, tilt: 0, bearing: 0);

  File? _image;
  String? fileName;
  final picker = ImagePicker();
  var groupchatMassages = [];
  var groupchatMassages1;
  var isTypingStatus1;
  var isTypingStatus;
  bool? flag;
  var User_Id;
  var Group_Id;
  var User_Name;
  var user_Token;
  bool isLoading = false;
  var imageresponse;
  var imagedata;
  var imagee;
  bool _hasNextPage = true;
  bool _isLoadMoreRunning = false;
  int _page = 0;
  var ChatListResponse;
  var ChatListJsonData;
  AnimationController? _controller;
  Animation<Offset>? animation;
  bool reply = false;
  var image_count;
  var imageCount;
  var group_id;
  var user_name;
  var user_id;
  var imagecount;
  var groupid;
  var messageId;
  var messageText;
  var send;

  Future getImage() async {
    final pickedFile = await picker.getImage(source: ImageSource.gallery);
    setState(() {
      _image = File(pickedFile!.path);

      if (_image != null) {
        fileName = _image!.path.split('/').last;
        SendImage();
      }
    });
  }

  RejoinRoom() {
    socket.emit("join_group", {
      "user_id": userId,
      "group_id": widget.groupId,
    });
  }

  isTyping() {
    socket.emit('isType', {"group_id": widget.groupId, "user_id": userId, "user_name": user_name, 'isShow': true, "group_name": widget.groupname});
  }

  getUsername() async {
    final prefs = await SharedPreferences.getInstance();
    user_name = prefs.getString('UserName');
    user_id = prefs.getString('UserId');
  }

  isTypingClose() {
    socket.emit('isType', {
      "group_id": widget.groupId,
      "user_id": userId,
      'isShow': false,
    });
  }

  Istypinggg() {
    socket.on('isType', (data) {
      if (mounted) {
        setState(() {
          isTypingStatus = data.toString();
          isTypingStatus1 = data['isType'].toString();

          flag = data['isType']["isShow"];
          User_Id = data['isType']["user_id"].toString();
          Group_Id = data['isType']["group_id"].toString();
          User_Name = data['isType']["user_name"];
        });
      }
    });
  }

  FutureOr onGoBack(dynamic value) {
    GroupMessageList();
    setState(() {});
  }

  SendMessage() {
    send = {
      'msg': sendMessage.text.isNotEmpty ? sendMessage.text : imagee,
      'group_id': widget.groupId,
      'user_id': userId,
      'msg_type': sendMessage.text.isNotEmpty ? 1 : 2,
      "group_name": widget.groupname
    };

    if (socket.connected == false) {
      socket.connect();
      RejoinRoom();
      socket.emit('send_group_message', send);
    } else {
      socket.emit('send_group_message', send);
      sendMessage.clear();
    }
  }

  ReplyMessage() {
    setState(() {
      reply = false;
    });

    send = {
      'msg': sendMessage.text.isNotEmpty ? sendMessage.text : imagee,
      'group_id': widget.groupId,
      'user_id': user_id,
      'msg_type': 4,
      "group_name": widget.groupname,
      "gmessage_id": messageId,
    };

    if (socket.connected == false) {
      socket.connect();
      RejoinRoom();
      socket.emit('send_group_message', send);
    } else {
      socket.emit('send_group_message', send);
      sendMessage.clear();
    }
  }

  SendLocation() {
    send = {
      'msg': "https://www.google.com/maps/search/?api=1&query=${latitude},${longitude}",
      'group_id': widget.groupId,
      'user_id': userId,
      'msg_type': 3,
      "group_name": widget.groupname
    };

    if (socket.connected == false) {
      socket.connect();
      RejoinRoom();
      socket.emit('send_group_message', send);
    } else {
      socket.emit('send_group_message', send);
      sendMessage.clear();
    }
  }

  List messagetextList = [
    "Reply",
    "Copy Message",
    "Delete Message",
    "Unsend Message",
    "Add to Saved Phrases",
  ];

  List<String> images = [
    'assets/images/TextSelected.png',
    'assets/images/CameraSelected.png',
    'assets/images/Location1.png',
    'assets/images/SavedMessagesSelected.png',
  ];

  leftGroup() {
    Navigator.pop(context, {
      socket.emit('left_group', {'group_id': widget.groupId, 'user_id': userId}),
    });
  }

  getRealTimeRequest() {
    socket.on('new_group_message', (data) {
      if (mounted) {
        setState(() {
          data["info"]["gmessage_type"] == 4 ? GroupMessageList() : groupchatMassages.insert(0, data['info']);
        });
      }
    });
  }

  GroupMessageList() async {
    setState(() {
      _isFirstLoadRunning = true;
    });

    final prefs = await SharedPreferences.getInstance();
    userToken = prefs.getString('UserToken');
    userId = prefs.getString('UserId');
    try {
      groupChatListResponse = await dio.post(
        get_groupchat_messages,
        data: {
          "page_no": 1,
          'group_id': widget.groupId,
        },
        options: Options(headers: {'Authorization': 'Bearer $userToken'}),
      );

      groupChatListJsonData = jsonDecode(groupChatListResponse.toString());

      if (groupChatListJsonData['Status'] == 1) {
        if (mounted) {
          setState(() {
            groupchatMassages = groupChatListJsonData['info'];

            groupchatMassages1 = groupchatMassages[0]["chat_message"];
          });
        }
      }
    } on DioError catch (e) {
      print(e.response);
    }
    setState(() {
      _isFirstLoadRunning = false;
    });
  }

  SendImage() async {
    final prefs = await SharedPreferences.getInstance();
    user_Token = prefs.getString('UserToken');

    setState(() {
      isLoading = true;
    });
    var formdata = FormData.fromMap({
      "image": _image != null ? await MultipartFile.fromFile(_image!.path, filename: _image!.path.split('/').last) : '',
    });
    try {
      imageresponse = await dio.post(
        send_image,
        data: formdata,
        options: Options(
          headers: {"Authorization": "Bearer $user_Token"},
        ),
      );

      imagedata = jsonDecode(imageresponse.toString());

      if (imagedata["Status"] == 1) {
        imagee = imagedata["data"]["image"].toString();
        setState(() {
          SendMessage();
          isLoading = false;
          socket.emit('image_group_count', {'user_id': userId, 'group_id': widget.groupId});
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } on DioError catch (e) {
      print(e.response);
    }
  }

  late String inputFormat;
  formatDateTime(var date) {
    var dateFormat = DateFormat.jm();
    var utcDate = dateFormat.format(DateTime.parse(date));
    String createdDate = dateFormat.parse(utcDate, true).toLocal().toString();
    inputFormat = dateFormat.format(DateTime.parse(createdDate));
    return inputFormat;
  }

  LoadMessageList() async {
    if (_hasNextPage == true && _isFirstLoadRunning == false && _isLoadMoreRunning == false && _scrollController!.position.extentAfter < 300) {
      setState(() {
        _isLoadMoreRunning = true;
        _page++;
      });
      final prefs = await SharedPreferences.getInstance();
      userToken = prefs.getString('UserToken');
      userId = prefs.getString('UserId');

      try {
        ChatListResponse = await dio.post(
          get_groupchat_messages,
          data: {
            "page_no": _page,
            'group_id': widget.groupId,
          },
          options: Options(
            headers: {'Authorization': 'Bearer $userToken'},
          ),
        );

        var an;
        var ank = [];
        if (ChatListResponse.statusCode == 200) {
          setState(() {
            an = jsonDecode(ChatListResponse.toString());
          });

          if (an['Status'] == 1) {
            if (_page == 1) {
              SchedulerBinding.instance!.addPostFrameCallback((_) {
                _scrollController!.jumpTo(_scrollController!.position.minScrollExtent);
              });
            }
            setState(() {
              ank = an["info"];
              if (ank.length > 0) {
                {
                  for (var i in ank) {
                    if (_page == 1) {
                    } else {
                      groupchatMassages.add(i);
                    }
                  }
                }
              } else {
                setState(() {
                  _hasNextPage = false;
                });
              }
            });
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

  getUnsendMessage() {
    socket.on('unsend_message', (data) {
      if (mounted) {
        setState(() {});
      }
      GroupMessageList();
    });
  }

  getCount() async {
    final prefs = await SharedPreferences.getInstance();
    imagecount = prefs.getString('ImageCount');
  }

  setUserData() async {
    await setPrefData(key: 'ImageCount', value: imageCount.toString());
    await setPrefData(key: 'GroupId', value: group_id.toString());
  }

  @override
  void initState() {
    _scrollController = ScrollController()..addListener(LoadMessageList);

    getCount();
    getUnsendMessage();
    getUsername();
    getCurrentLocation();
    Istypinggg();
    GroupMessageList();
    getRealTimeRequest();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    animation = Tween(
      begin: const Offset(0.0, 0.0),
      end: const Offset(0.3, 0.0),
    ).animate(
      CurvedAnimation(
        curve: Curves.decelerate,
        parent: _controller!,
      ),
    );
    super.initState();
  }

  @override
  dispose() {
    _controller!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    return WillPopScope(
      onWillPop: () {
        return leftGroup();
      },
      child: ModalProgressHUD(
        inAsyncCall: isLoading,
        color: kPrimaryColor,
        opacity: 0,
        child: Scaffold(
          backgroundColor: kbackgroundColor,
          appBar: AppBar(
            backgroundColor: kbackgroundColor,
            leading: InkWell(
              onTap: () {
                if (widget.pop == true) {
                  setState(() {
                    Navigator.pop(context);
                    Navigator.pop(context);
                    leftGroup();
                  });
                } else if (widget.pop == false) {
                  setState(() {
                    leftGroup();
                  });
                }
              },
              child: Icon(
                Icons.arrow_back,
                color: Colors.white,
              ),
            ),
            title: GestureDetector(
              onTap: () {
                Navigator.push(context, CupertinoPageRoute(builder: (context) => GroupMemberScreen(groupid: widget.groupId)));
              },
              child: RegularText(
                "${widget.groupname} Group",
                color: Colors.white,
                fontSize: 18,
              ),
            ),
            actions: [
              Padding(
                padding: EdgeInsets.only(right: 10),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.push(context, CupertinoPageRoute(builder: (context) => ChatSettingScreen(groupid: widget.groupId, isGroup: true)));
                      },
                      child: Image.asset(
                        'assets/images/dots.png',
                        scale: 5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          body: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  physics: BouncingScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: groupchatMassages.length,
                  reverse: true,
                  itemBuilder: (context, index) {
                    if (groupchatMassages[index]['gmessage_by'].toString() == userId) {
                      return groupchatMassages[index]['gmessage_type'] == 2
                          ? GestureDetector(
                              onTap: () {
                                showGeneralDialog(
                                  context: context,
                                  barrierColor: Colors.black12.withOpacity(0.8), // Background color
                                  pageBuilder: (_, __, ___) {
                                    return Stack(
                                      children: [
                                        Center(
                                          child: CachedNetworkImage(
                                            imageUrl: '$IMAGE_URL${groupchatMassages[index]["gmessage_text"]}',
                                            imageBuilder: (context, imageProvider) => Container(
                                              height: 300,
                                              decoration: BoxDecoration(
                                                image: DecorationImage(
                                                  image: imageProvider,
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                            ),
                                            placeholder: (context, url) => Container(
                                              alignment: Alignment.center,
                                              child: CircularProgressIndicator(),
                                            ),
                                          ),
                                        ),
                                        Positioned(
                                          top: 20,
                                          right: 10,
                                          child: GestureDetector(
                                            child: Icon(
                                              Icons.close_rounded,
                                              color: Colors.white,
                                              size: 40,
                                            ),
                                            onTap: () {
                                              Navigator.pop(context);
                                            },
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                              child: Container(
                                height: 50,
                                width: 100,
                                decoration: BoxDecoration(borderRadius: BorderRadius.circular(30), color: kbackgroundColor, border: Border.all(color: kPrimaryColor)),
                                margin: EdgeInsets.only(left: 200, bottom: 20, right: 10, top: 10),
                                child: Center(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.camera_alt_outlined,
                                        color: kPrimaryColor,
                                      ),
                                      SizedBox(
                                        width: 5,
                                      ),
                                      RegularText(
                                        "Expiring Photo",
                                        color: kPrimaryColor,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            )
                          : groupchatMassages[index]['gmessage_type'] == 1
                              ? GestureDetector(
                                  onLongPress: () {
                                    setState(() {
                                      messageId = groupchatMassages[index]["gmessage_id"];
                                      messageText = groupchatMassages[index]["gmessage_text"];
                                    });

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
                                              'Message Options',
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
                                                  padding: EdgeInsets.only(left: 10, right: 10, bottom: 7),
                                                  child: GestureDetector(
                                                    onTap: () {
                                                      setState(() {
                                                        SelectedMessage = index;

                                                        SelectedMessage == 0
                                                            ? reply = true
                                                            : SelectedMessage == 1
                                                                ? FlutterClipboard.copy(Uri.decodeFull(messageText)).then((value) => print('copied text'))
                                                                : SelectedMessage == 2
                                                                    ? socket.emit('delete_group_message', {'gmessage_id': messageId, 'user_id': user_id})
                                                                    : SelectedMessage == 3
                                                                        ? socket.emit('unsend_message', {
                                                                            'message_id': messageId,
                                                                            "unsend_type": 2,
                                                                            "user_id": user_id,
                                                                            "chat_id": 0,
                                                                            "group_id": widget.groupId,
                                                                          })
                                                                        : Container();

                                                        Navigator.pop(context);
                                                      });
                                                    },
                                                    child: RegularText(
                                                      messagetextList[index],
                                                      fontSize: 18,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                    ).then((onGoBack));
                                  },
                                  child: ChatBubbleSender(
                                    message: Uri.decodeFull(groupchatMassages[index]['gmessage_text'].toString()),
                                    status: groupchatMassages[index]['gmessage_status'] == null ? 1 : 2,
                                    time: formatDateTime(groupchatMassages[index]['created_at']),
                                  ),
                                )
                              : groupchatMassages[index]['gmessage_type'] == 3
                                  ? GestureDetector(
                                      onTap: () {
                                        launch(groupchatMassages[index]['gmessage_text']);
                                      },
                                      child: Container(
                                        margin: EdgeInsets.only(left: 150, bottom: 20, right: 10, top: 10),
                                        height: 50,
                                        width: 100,
                                        decoration: BoxDecoration(color: kbackgroundColor, border: Border.all(color: kPrimaryColor), borderRadius: BorderRadius.circular(12)),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.location_on_outlined,
                                              color: kPrimaryColor,
                                            ),
                                            SizedBox(
                                              width: 5,
                                            ),
                                            RegularText(
                                              "Current Location",
                                              color: kPrimaryColor,
                                            ),
                                          ],
                                        ),
                                      ),
                                    )
                                  : Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Card(
                                          elevation: 2,
                                          margin: EdgeInsets.only(right: 10, bottom: 5, top: 5),
                                          shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(8),
                                            topRight: Radius.circular(8),
                                            bottomLeft: Radius.circular(8),
                                          )),
                                          child: Container(
                                            constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.6),
                                            padding: EdgeInsets.only(left: 7, top: 5, bottom: 5),
                                            decoration: BoxDecoration(
                                                color: kPrimaryColor,
                                                borderRadius: BorderRadius.only(
                                                  topLeft: Radius.circular(8),
                                                  topRight: Radius.circular(8),
                                                  bottomLeft: Radius.circular(8),
                                                )),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                RegularText(
                                                  Uri.decodeFull(groupchatMassages[index]["chat_message"][0]["reply_text"]),
                                                  color: Colors.black,
                                                  fontSize: 16,
                                                ),
                                                Divider(
                                                  color: Colors.black,
                                                ),
                                                RegularText(
                                                  Uri.decodeFull(groupchatMassages[index]['gmessage_text'].toString()),
                                                  color: Colors.white,
                                                  fontSize: 16,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: EdgeInsets.only(right: 10),
                                          child: RegularText(
                                            formatDateTime(groupchatMassages[index]['created_at']),
                                            textAlign: TextAlign.end,
                                            fontSize: 10,
                                            color: klightGrey,
                                          ),
                                        ),
                                      ],
                                    );
                    } else {
                      return groupchatMassages[index]['gmessage_type'] == 2
                          ? GestureDetector(
                              onTap: () {
                                showGeneralDialog(
                                  context: context,
                                  barrierColor: Colors.black12.withOpacity(0.8), // Background color
                                  pageBuilder: (_, __, ___) {
                                    return Stack(
                                      children: [
                                        Center(
                                          child: CachedNetworkImage(
                                            imageUrl: '$IMAGE_URL${groupchatMassages[index]["gmessage_text"]}',
                                            imageBuilder: (context, imageProvider) => Container(
                                              height: 300,
                                              decoration: BoxDecoration(
                                                image: DecorationImage(
                                                  image: imageProvider,
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                            ),
                                            placeholder: (context, url) => Container(
                                              alignment: Alignment.center,
                                              child: CircularProgressIndicator(),
                                            ),
                                          ),
                                        ),
                                        Positioned(
                                          top: 20,
                                          right: 10,
                                          child: GestureDetector(
                                            child: Icon(
                                              Icons.close_rounded,
                                              color: Colors.white,
                                              size: 40,
                                            ),
                                            onTap: () {
                                              Navigator.pop(context);
                                            },
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                              child: Container(
                                height: 50,
                                width: 100,
                                decoration: BoxDecoration(borderRadius: BorderRadius.circular(30), color: kbackgroundColor, border: Border.all(color: Colors.white)),
                                margin: EdgeInsets.only(right: 200, bottom: 20, left: 10, top: 10),
                                child: Center(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.camera_alt_outlined,
                                        color: Colors.white,
                                      ),
                                      SizedBox(
                                        width: 5,
                                      ),
                                      RegularText(
                                        "Expiring Photo",
                                        color: Colors.white,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            )
                          : groupchatMassages[index]['gmessage_type'] == 1
                              ? GestureDetector(
                                  onLongPress: () {
                                    setState(() {
                                      messageId = groupchatMassages[index]["gmessage_id"];
                                      messageText = groupchatMassages[index]["gmessage_text"];
                                    });
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
                                              'Message Options',
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
                                                        SelectedMessage = index;

                                                        SelectedMessage == 0
                                                            ? reply = true
                                                            : SelectedMessage == 1
                                                                ? FlutterClipboard.copy(Uri.decodeFull(messageText)).then((value) => print('copied text'))
                                                                : SelectedMessage == 2
                                                                    ? socket.emit('delete_group_message', {'gmessage_id': messageId, 'user_id': user_id})
                                                                    : SelectedMessage == 3
                                                                        ? socket.emit('unsend_message', {
                                                                            'message_id': messageId,
                                                                            "unsend_type": 2,
                                                                            "user_id": user_id,
                                                                            "chat_id": 0,
                                                                            "group_id": widget.groupId,
                                                                          })
                                                                        : Container();
                                                        Navigator.pop(context);
                                                      });
                                                    },
                                                    child: RegularText(
                                                      messagetextList[index],
                                                      fontSize: 18,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                    ).then((onGoBack));
                                  },
                                  child: ChatBubbleReceiver(
                                    message: Uri.decodeFull(groupchatMassages[index]['gmessage_text'].toString()),
                                    status: groupchatMassages[index]['gmessage_status'] == null ? 1 : 2,
                                    time: formatDateTime(groupchatMassages[index]['created_at']),
                                  ),
                                )
                              : groupchatMassages[index]['gmessage_type'] == 3
                                  ? GestureDetector(
                                      onTap: () {
                                        launch(groupchatMassages[index]['gmessage_text']);
                                      },
                                      child: Container(
                                        margin: EdgeInsets.only(right: 150, bottom: 20, left: 10, top: 10),
                                        height: 50,
                                        width: 100,
                                        decoration: BoxDecoration(color: kbackgroundColor, border: Border.all(color: Colors.white), borderRadius: BorderRadius.circular(12)),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.location_on_outlined,
                                              color: Colors.white,
                                            ),
                                            SizedBox(
                                              width: 5,
                                            ),
                                            RegularText(
                                              "Current Location",
                                              color: Colors.white,
                                            ),
                                          ],
                                        ),
                                      ),
                                    )
                                  : Container(
                                      child: Stack(
                                        overflow: Overflow.visible,
                                        children: [
                                          Column(
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Card(
                                                margin: EdgeInsets.only(left: 12, bottom: 5, top: 5),
                                                color: klightGrey,
                                                elevation: 2,
                                                shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.only(
                                                  topRight: Radius.circular(8),
                                                  topLeft: Radius.circular(8),
                                                  bottomRight: Radius.circular(8),
                                                )),
                                                child: Container(
                                                  constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.6),
                                                  padding: EdgeInsets.only(top: 5, bottom: 5, left: 7),
                                                  decoration: BoxDecoration(
                                                      color: klightGrey,
                                                      borderRadius: BorderRadius.only(
                                                        topRight: Radius.circular(8),
                                                        topLeft: Radius.circular(8),
                                                        bottomRight: Radius.circular(8),
                                                      )),
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      RegularText(
                                                        Uri.decodeFull(groupchatMassages[index]["chat_message"][0]["reply_text"]),
                                                        color: Colors.black,
                                                        fontSize: 16,
                                                      ),
                                                      Divider(
                                                        color: Colors.black,
                                                      ),
                                                      RegularText(
                                                        Uri.decodeFull(groupchatMassages[index]['gmessage_text'].toString()),
                                                        color: Colors.white,
                                                        fontSize: 16,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              Padding(
                                                padding: EdgeInsets.only(left: 10),
                                                child: RegularText(
                                                  formatDateTime(groupchatMassages[index]['created_at']),
                                                  textAlign: TextAlign.end,
                                                  fontSize: 10,
                                                  color: klightGrey,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    );
                    }
                  },
                ),
              ),
              Padding(
                padding: EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    if (isTypingStatus1 != null && flag == true && Group_Id == widget.groupId)
                      RegularText(
                        " ${User_Id != userId ? User_Name : ""}",
                        color: klightGrey,
                      ),
                    if (isTypingStatus1 != null && flag == true && Group_Id == widget.groupId)
                      RegularText(
                        " ${User_Id != userId ? "is typing..." : ""}",
                        color: klightGrey,
                      ),
                  ],
                ),
              ),
              reply == true
                  ? SizedBox(
                      height: 50,
                    )
                  : Container(),
              Stack(
                overflow: Overflow.visible,
                children: [
                  Positioned(
                    top: -50,
                    child: Visibility(
                      visible: reply,
                      child: Container(
                        height: 50,
                        width: width,
                        padding: EdgeInsets.only(left: 15, right: 15),
                        decoration: BoxDecoration(border: Border.all(color: klightGrey)),
                        child: Row(
                          children: [
                            Align(
                              alignment: Alignment.centerLeft,
                              child: RegularText(
                                Uri.decodeFull(messageText ?? ""),
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  CostumeTextFiled(
                    onTap: () {
                      isVisible = false;
                      Selected = 0;
                    },
                    onChanged: (value) {
                      if (value.isNotEmpty) {
                        isTyping();
                      } else {
                        isTypingClose();
                      }
                    },
                    hintcolor: Color(0xff505050),
                    controller: sendMessage,
                    hintText: 'Type Somthing....',
                    isShow: false,
                    suffix: InkWell(
                      onTap: () {
                        if (sendMessage.text.isEmpty) {
                          return print("Empty message");
                        } else {
                          reply == true ? ReplyMessage() : SendMessage();
                          isTypingClose();
                        }
                      },
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                        child: RegularText(
                          'Send',
                          color: kPrimaryColor,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(
                    4,
                    (index) => GestureDetector(
                      onTap: () {
                        setState(() {
                          Selected = index;

                          if (index == 0) {
                            setState(() {
                              FocusScope.of(context).autofocus(key);
                            });
                          }
                          if (index == 1) {
                            isbusiness == 1 || isbusinessUnlimited == 1
                                ? getImage()
                                : groupChatListJsonData["image_count"] == 0 ||
                                        groupChatListJsonData["image_count"] == 1 ||
                                        groupChatListJsonData["image_count"] == 2 ||
                                        groupChatListJsonData["image_count"] == 3 ||
                                        groupChatListJsonData["image_count"] == 4
                                    ? getImage().then((onGoBack))
                                    : Toasty.showtoast("Your Limitation Finish");
                          }
                          if (index == 2) {
                            setState(() {
                              isVisible = true;
                              FocusScope.of(context).unfocus();
                            });
                          }
                        });
                      },
                      child: Image.asset(
                        images[index],
                        color: Selected == index ? kPrimaryColor : Color(0xff505050),
                        height: 20,
                        width: 20,
                      ),
                    ),
                  ),
                ),
              ),
              Selected == 2
                  ? Visibility(
                      visible: isVisible,
                      child: Container(
                        height: height * 0.33,
                        child: Stack(
                          children: [
                            GoogleMap(
                              initialCameraPosition: _kInitialPosition,
                              myLocationEnabled: true,
                              zoomControlsEnabled: false,
                              mapToolbarEnabled: false,
                              // onMapCreated: _onMapCreate,
                            ),
                            Positioned(
                              bottom: 10,
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    isVisible = false;
                                    SendLocation();
                                  });
                                },
                                child: Container(
                                  margin: EdgeInsets.symmetric(horizontal: 18),
                                  height: 50,
                                  width: width * 0.9,
                                  decoration: BoxDecoration(color: kPrimaryColor, borderRadius: BorderRadius.circular(10)),
                                  child: Center(
                                    child: RegularText(
                                      'Send Location',
                                      color: Colors.white,
                                      fontFamily: '',
                                      fontSize: 18,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : Container(),
            ],
          ),
        ),
      ),
    );
  }
}
