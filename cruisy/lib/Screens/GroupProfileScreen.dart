import 'dart:convert';
import 'dart:io';

import 'package:cruisy/Accounts/Splash_Screen.dart';
import 'package:cruisy/Constant/constant.dart';
import 'package:cruisy/Screens/GroupChat_Screen.dart';
import 'package:cruisy/Widgets/Appbar_Widget.dart';
import 'package:cruisy/Widgets/Button_Widget.dart';
import 'package:cruisy/Widgets/Text_Widget.dart';
import 'package:cruisy/Widgets/Textfeild_Widget.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GroupProfileScreen extends StatefulWidget {
  final multiuserId;
  const GroupProfileScreen({Key? key, this.multiuserId}) : super(key: key);

  @override
  _GroupProfileScreenState createState() => _GroupProfileScreenState();
}

class _GroupProfileScreenState extends State<GroupProfileScreen> {
  TextEditingController groupname = TextEditingController();
  final picker = ImagePicker();
  File? _image;
  String? fileName;
  var userIdd;
  var chatResponse;
  var chatData;
  var chatId;
  var groupId;
  bool isLoading = false;

  CrateGroupChat({String? id, String? Groupname}) async {
    final prefs = await SharedPreferences.getInstance();
    userToken = prefs.getString('UserToken');
    userIdd = prefs.getString('UserId');
    setState(() {
      isLoading = true;
    });
    var formdata = FormData.fromMap({
      "no_group_pic": "no pic",
      "groupchat_created_to": id,
      "group_name": Groupname,
      "group_pic": _image != null ? await MultipartFile.fromFile(_image!.path, filename: _image!.path.split('/').last) : '',
    });
    try {
      chatResponse = await dio.post(
        "http://164.92.83.132:8000/chats/create_group_chat",
        data: formdata,
        options: Options(headers: {'Authorization': 'Bearer $userToken'}),
      );
      chatData = jsonDecode(chatResponse.toString());

      if (chatData['Status'] == 1) {
        Toasty.showtoast(chatData["Message"]);
        setState(() {
          isLoading = false;
          groupId = chatData["Info"][0]['group_id'];
        });
        socket.emit("join_group", {
          "user_id": userId,
          "group_id": groupId,
        });

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => GroupChatScreen(
              pop: true,
              groupId: groupId,
              groupname: groupname.text,
            ),
          ),
        );
      }
    } on DioError catch (e) {
      print(e.response);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kbackgroundColor,
      appBar: CostumeAppBar(
        text: '',
        bool: true,
      ),
      body: ModalProgressHUD(
        inAsyncCall: isLoading,
        opacity: 0,
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 10, left: 15, bottom: 10),
                  child: RegularText(
                    "Add Your Group Photo",
                    color: Colors.white,
                    fontSize: 18,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    getImage();
                  },
                  child: _image == null
                      ? Center(
                          child: Container(
                            height: 120,
                            margin: EdgeInsets.symmetric(horizontal: 100, vertical: 12),
                            decoration: BoxDecoration(color: kbackgroundColor, border: Border.all(color: Colors.grey.shade800)),
                            child: Image.asset(
                              'assets/images/add.png',
                              scale: 6,
                            ),
                          ),
                        )
                      : Center(
                          child: Container(
                              height: 120,
                              width: 120,
                              margin: EdgeInsets.symmetric(horizontal: 100, vertical: 12),
                              color: kbackgroundColor,
                              child: Image.file(_image!, fit: BoxFit.cover)),
                        ),
                ),
                SizedBox(
                  height: 15,
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 15, left: 15, bottom: 10),
                  child: RegularText(
                    "Add Your Group Name",
                    color: Colors.white,
                    fontSize: 18,
                  ),
                ),
                CostumeTextFiled(
                  hintcolor: Color(0xff505050),
                  controller: groupname,
                  isShow: false,
                  hintText: 'Enter Your Group Name',
                ),
                SizedBox(
                  height: 200,
                ),
                CostumeButton(
                  text: 'Create Group',
                  onTap: () {
                    setState(() {
                      if (validate(groupname: groupname.text)) {
                        CrateGroupChat(id: widget.multiuserId, Groupname: groupname.text);
                      }
                    });
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future getImage() async {
    final pickedFile = await picker.getImage(source: ImageSource.gallery);
    setState(() {
      _image = File(pickedFile!.path);

      if (_image != null) {
        fileName = _image!.path.split('/').last;
      }
    });
  }

  bool validate({required String groupname}) {
    if (groupname.isEmpty) {
      Toasty.showtoast('Please Enter Your Groupname');
      return false;
    } else {
      return true;
    }
  }
}
