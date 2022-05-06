import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:clipboard/clipboard.dart';
import 'package:cruisy/Accounts/Splash_Screen.dart';
import 'package:cruisy/Constant/constant.dart';
import 'package:cruisy/Screens/ChatSetting_Screen.dart';
import 'package:cruisy/Screens/PersonalInfo_Screen.dart';
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

class ChatMessageScreen extends StatefulWidget {
  final image, name, userId, likeStatue, Chatid, otherId;
  const ChatMessageScreen({Key? key, this.image, this.name, this.userId, this.likeStatue, this.Chatid, this.otherId}) : super(key: key);

  @override
  _ChatMessageScreenState createState() => _ChatMessageScreenState();
}

class _ChatMessageScreenState extends State<ChatMessageScreen> {
  TextEditingController sendMessage = TextEditingController();
  ScrollController? _scrollController;
  var send;
  var userId;
  var userToken;
  var response;
  var jsondata;
  var chatMassages = [];
  var chatMassages1;
  var ChatListResponse;
  var ChatListJsonData;
  bool _isFirstLoadRunning = false;
  bool _isLoadMoreRunning = false;
  int _page = 0;
  bool _hasNextPage = true;
  FocusNode key = FocusNode();
  bool isVisible = true;
  var SendMessageAppend;
  var isTypingStatus;
  var isTypingStatus1;
  var User_Id;
  var Chat_Id;
  var istypee;
  var user_Token;
  var imageresponse;
  var imagedata;
  var imagee;
  bool? flag;

  List<String> images = [
    'assets/images/TextSelected.png',
    'assets/images/CameraSelected.png',
    'assets/images/Location1.png',
    'assets/images/SavedMessagesSelected.png',
  ];

  leftRoom() {
    Navigator.pop(context, {
      socket.emit('left_room', {'chat_id': widget.Chatid, 'user_id': widget.userId}),
    });
  }

  static final LatLng _kMapCenter = LatLng(21.170278, 70.831156);

  static final CameraPosition _kInitialPosition = CameraPosition(target: _kMapCenter, zoom: 11.0, tilt: 0, bearing: 0);

  int Selected = 0;
  int SelectedMessage = 0;
  File? _image;
  String? fileName;
  final picker = ImagePicker();
  List userid = [];

  List messagetextList = [
    "Reply",
    "Copy Message",
    "Delete Message",
    "Unsend Message",
    "Add to Saved Phrases",
  ];

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

  MessageList() async {
    setState(() {
      _isFirstLoadRunning = true;
    });
    final prefs = await SharedPreferences.getInstance();
    userToken = prefs.getString('UserToken');
    userId = prefs.getString('UserId');

    try {
      ChatListResponse = await dio.post(
        get_chat_messages,
        data: {
          "page_no": 1,
          'chat_id': widget.Chatid,
        },
        options: Options(headers: {'Authorization': 'Bearer $userToken'}),
      );

      ChatListJsonData = jsonDecode(ChatListResponse.toString());

      if (ChatListJsonData['Status'] == 1) {
        if (mounted) {
          setState(() {
            chatMassages = ChatListJsonData['info'];
          });
        }
      }
    } on DioError catch (e) {}
    setState(() {
      _isFirstLoadRunning = false;
    });
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
          get_chat_messages,
          data: {
            'page_no': _page,
            'chat_id': widget.Chatid,
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
                      chatMassages.add(i);
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
      } on DioError catch (e) {}
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
      MessageList();
    });
  }

  RejoinRoom() {
    socket.emit('join_room', {"user_id": userId, "chat_id": widget.Chatid});
    socket.emit('isType', {"isType": widget.Chatid});
  }

  Istypinggg() {
    socket.on('isType', (data) {
      if (mounted) {
        setState(() {
          isTypingStatus = data.toString();
          isTypingStatus1 = data['isType'].toString();

          flag = data['isType']["isShow"];

          User_Id = data['isType']["user_id"].toString();
          Chat_Id = data['isType']["chat_id"].toString();
        });
      }
    });
  }

  isTyping() {
    socket.emit('isType', {
      "chat_id": widget.Chatid,
      "user_id": userId,
      'other_id': widget.otherId,
      'isShow': true,
    });
  }

  isTypingClose() {
    socket.emit('isType', {
      "isType": widget.Chatid,
      "user_id": userId,
      'other_id': widget.otherId,
      'isShow': false,
    });
  }

  ReplyMessage() {
    setState(() {
      reply = false;
    });

    send = {
      'other_id': widget.otherId,
      'msg': sendMessage.text.isNotEmpty ? sendMessage.text : imagee,
      'chat_id': widget.Chatid,
      'user_id': userId,
      'msg_type': 4,
      "message_id": messageId,
    };

    if (socket.connected == false) {
      socket.connect();
      RejoinRoom();
      socket.emit('send_message', send);
    } else {
      socket.emit('send_message', send);
      sendMessage.clear();
    }
  }

  SendMessage() {
    send = {
      'other_id': widget.otherId,
      'msg': sendMessage.text.isNotEmpty ? sendMessage.text : imagee,
      'chat_id': widget.Chatid,
      'user_id': userId,
      'msg_type': sendMessage.text.isNotEmpty ? 1 : 2
    };

    if (socket.connected == false) {
      socket.connect();
      RejoinRoom();
      socket.emit('send_message', send);
    } else {
      socket.emit('send_message', send);
      sendMessage.clear();
    }
  }

  SendLocation() {
    send = {
      'other_id': widget.otherId,
      'msg': "https://www.google.com/maps/search/?api=1&query=${latitude},${longitude}",
      'chat_id': widget.Chatid,
      'user_id': userId,
      'msg_type': 3
    };

    if (socket.connected == false) {
      socket.connect();
      RejoinRoom();
      socket.emit('send_message', send);
    } else {
      socket.emit('send_message', send);
      sendMessage.clear();
    }
  }

  getRealTimeRequest() {
    socket.on('new_message', (data) {
      if (mounted) {
        setState(() {
          data["info"]["message_type"] == 4 ? MessageList() : chatMassages.insert(0, data['info']);
        });
      }
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
          isLoading = false;
        });
        SendMessage();
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } on DioError catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  var messageId;
  var messageText;
  bool reply = false;
  bool isLoading = false;

  FutureOr onGoBack(dynamic value) {
    MessageList();
    setState(() {});
  }

  @override
  void initState() {
    Istypinggg();
    getuserid();
    getUnsendMessage();
    getCurrentLocation();
    MessageList();
    getRealTimeRequest();
    _scrollController = ScrollController()..addListener(LoadMessageList);
    super.initState();

    setState(() {
      key;
    });
    super.initState();
  }

  getuserid() async {
    final prefs = await SharedPreferences.getInstance();
    userId = prefs.getString('UserId');
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    return WillPopScope(
      onWillPop: () {
        return leftRoom();
      },
      child: ModalProgressHUD(
        inAsyncCall: isLoading,
        color: kPrimaryColor,
        opacity: 0,
        child: Scaffold(
          backgroundColor: kbackgroundColor,
          appBar: PreferredSize(
            preferredSize: Size(width, 65),
            child: SafeArea(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        leftRoom();
                      },
                      child: Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PersonalInfo(
                              userId: widget.otherId,
                              image: widget.image,
                              likeStatus: widget.likeStatue,
                              OtherUserid: widget.otherId,
                            ),
                          ),
                        );
                      },
                      child: Container(
                        height: 50,
                        width: 50,
                        margin: EdgeInsets.only(left: 7),
                        decoration: BoxDecoration(shape: BoxShape.circle),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(50),
                          child: CachedNetworkImage(
                            imageUrl: "${widget.image}",
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
                    SizedBox(
                      width: 10,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        RegularText(
                          widget.name,
                          color: Colors.white,
                        ),
                      ],
                    ),
                    Spacer(),
                    SizedBox(
                      width: 5,
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          CupertinoPageRoute(
                            builder: (context) => ChatSettingScreen(
                              otherId: widget.otherId,
                              isGroup: false,
                              chatid: widget.Chatid,
                            ),
                          ),
                        );
                      },
                      child: Image.asset(
                        'assets/images/dots.png',
                        scale: 4.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  physics: BouncingScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: chatMassages.length,
                  reverse: true,
                  itemBuilder: (context, index) {
                    if (chatMassages[index]['message_by'].toString() == userId) {
                      return chatMassages[index]['message_type'] == 2
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
                                            imageUrl: '$IMAGE_URL${chatMassages[index]["message_text"]}',
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
                          : chatMassages[index]['message_type'] == 1
                              ? GestureDetector(
                                  onLongPress: () {
                                    setState(() {
                                      messageId = chatMassages[index]["message_id"];
                                      messageText = chatMassages[index]["message_text"];
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
                                                                    ? socket.emit('delete_personal_message', {'message_id': messageId, 'user_id': userId})
                                                                    : SelectedMessage == 3
                                                                        ? socket.emit('unsend_message', {
                                                                            'message_id': messageId,
                                                                            "unsend_type": 1,
                                                                            "user_id": userId,
                                                                            "chat_id": widget.Chatid,
                                                                            "group_id": 0,
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
                                    message: Uri.decodeFull(chatMassages[index]['message_text'].toString()),
                                    status: chatMassages[index]['is_read'] == null ? 1 : 2,
                                    time: formatDateTime(chatMassages[index]['created_at']),
                                  ),
                                )
                              : chatMassages[index]['message_type'] == 3
                                  ? GestureDetector(
                                      onTap: () {
                                        launch(chatMassages[index]['message_text']);
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
                                              "Location",
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
                                                  Uri.decodeFull(chatMassages[index]["chat_message"][0]["reply_text"]),
                                                  color: Colors.black,
                                                  fontSize: 16,
                                                ),
                                                Divider(
                                                  color: Colors.black,
                                                ),
                                                RegularText(
                                                  Uri.decodeFull(chatMassages[index]['message_text'].toString()),
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
                                            formatDateTime(chatMassages[index]['created_at']),
                                            textAlign: TextAlign.end,
                                            fontSize: 10,
                                            color: klightGrey,
                                          ),
                                        ),
                                      ],
                                    );
                    } else {
                      return chatMassages[index]['message_type'] == 2
                          ? GestureDetector(
                              onTap: () {
                                showGeneralDialog(
                                  context: context,
                                  barrierColor: Colors.black12.withOpacity(0.8),
                                  pageBuilder: (_, __, ___) {
                                    return Stack(
                                      children: [
                                        Center(
                                          child: CachedNetworkImage(
                                            imageUrl: '$IMAGE_URL${chatMassages[index]["message_text"]}',
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
                          : chatMassages[index]['message_type'] == 1
                              ? GestureDetector(
                                  onLongPress: () {
                                    setState(() {
                                      messageId = chatMassages[index]["message_id"];
                                      messageText = chatMassages[index]["message_text"];
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
                                                                    ? socket.emit('delete_personal_message', {'message_id': messageId, 'user_id': userId})
                                                                    : SelectedMessage == 3
                                                                        ? socket.emit('unsend_message', {
                                                                            'message_id': messageId,
                                                                            "unsend_type": 1,
                                                                            "user_id": userId,
                                                                            "chat_id": widget.Chatid,
                                                                            "group_id": 0,
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
                                  child: chatMassages[index]['is_delete'] == 1
                                      ? Container()
                                      : ChatBubbleReceiver(
                                          message: Uri.decodeFull(chatMassages[index]['message_text'].toString()),
                                          status: chatMassages[index]['is_read'] == null ? 1 : 2,
                                          time: formatDateTime(chatMassages[index]['created_at']),
                                        ),
                                )
                              : chatMassages[index]['message_type'] == 3
                                  ? GestureDetector(
                                      onTap: () {
                                        launch(chatMassages[index]['message_text']);
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
                                              "Location",
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
                                                        Uri.decodeFull(chatMassages[index]["chat_message"][0]["reply_text"]),
                                                        color: Colors.black,
                                                        fontSize: 16,
                                                      ),
                                                      Divider(
                                                        color: Colors.black,
                                                      ),
                                                      RegularText(
                                                        Uri.decodeFull(chatMassages[index]['message_text'].toString()),
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
                                                  formatDateTime(chatMassages[index]['created_at']),
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
                    if (isTypingStatus1 != null && flag == true && Chat_Id == widget.Chatid)
                      RegularText(
                        " ${User_Id != userId ? widget.name : ""}",
                        color: klightGrey,
                      ),
                    if (isTypingStatus1 != null && flag == true && Chat_Id == widget.Chatid)
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
              Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  SizedBox(
                    height: 10,
                  ),
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
                        focusNode: key,
                        hintcolor: Color(0xff505050),
                        controller: sendMessage,
                        onChanged: (value) {
                          if (value.isNotEmpty) {
                            isTyping();
                          } else {
                            isTypingClose();
                          }
                        },
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
                                    : ChatListJsonData["image_count"] == 0 ||
                                            ChatListJsonData["image_count"] == 1 ||
                                            ChatListJsonData["image_count"] == 2 ||
                                            ChatListJsonData["image_count"] == 3
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
                                Positioned(
                                  top: 80,
                                  right: 150,
                                  child: Image.asset(
                                    'assets/images/geo.png',
                                    scale: 5.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      : Container(),
                ],
              ),
              SizedBox(height: height * 0.015),
            ],
          ),
        ),
      ),
    );
  }

  late String inputFormat;
  formatDateTime(var date) {
    var dateFormat = DateFormat.jm();
    var utcDate = dateFormat.format(DateTime.parse(date));
    String createdDate = dateFormat.parse(utcDate, true).toLocal().toString();
    inputFormat = dateFormat.format(DateTime.parse(createdDate));
    return inputFormat;
  }
}

class ChatBubbleReceiver extends StatelessWidget {
  final message;
  final status;
  final time;
  final profilepic;
  const ChatBubbleReceiver({this.message, this.status, this.time, this.profilepic});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(10, 2, 10, 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Card(
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
                        padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
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
                              message,
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ],
                        ),
                      ),
                    ),
                    RegularText(
                      time,
                      textAlign: TextAlign.end,
                      fontSize: 10,
                      color: klightGrey,
                    )
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}

class ChatBubbleSender extends StatelessWidget {
  final message;
  final status;
  final time;
  final profilepic;

  const ChatBubbleSender({this.message, this.status, this.time, this.profilepic});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                SizedBox(height: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(8),
                        topRight: Radius.circular(8),
                        bottomLeft: Radius.circular(8),
                      )),
                      child: Container(
                        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.6),
                        padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                        decoration: BoxDecoration(
                            color: kPrimaryColor,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(8),
                              topRight: Radius.circular(8),
                              bottomLeft: Radius.circular(8),
                            )),
                        child: RegularText(
                          message,
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    RegularText(
                      time,
                      textAlign: TextAlign.end,
                      fontSize: 10,
                      color: klightGrey,
                    ),
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
