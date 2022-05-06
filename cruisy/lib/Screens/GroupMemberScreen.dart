import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cruisy/Constant/constant.dart';
import 'package:cruisy/Widgets/Appbar_Widget.dart';
import 'package:cruisy/Widgets/Text_Widget.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GroupMemberScreen extends StatefulWidget {
  final groupid;
  const GroupMemberScreen({Key? key, this.groupid}) : super(key: key);

  @override
  _GroupMemberScreenState createState() => _GroupMemberScreenState();
}

class _GroupMemberScreenState extends State<GroupMemberScreen> {
  bool isLoading = false;
  var memberResponse;
  var memberData;
  List memberList = [];

  MemberList() async {
    final prefs = await SharedPreferences.getInstance();
    userToken = prefs.getString('UserToken');
    setState(() {
      isLoading = true;
    });
    try {
      memberResponse = await dio.post(
        list_join_user_group,
        data: {
          'group_id': widget.groupid,
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $userToken',
          },
        ),
      );

      memberData = jsonDecode(memberResponse.toString());
      if (memberData["Status"] == 1) {
        setState(() {
          memberList = memberData["info"];

          isLoading = false;
        });
      } else if (memberData["code"] == 306) {
        setState(() {
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } on DioError catch (e) {
      setState(() {
        isLoading = false;
      });

      print(e.response);
    }
  }

  @override
  void initState() {
    MemberList();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: kbackgroundColor,
      appBar: CostumeAppBar(
        text: "Group Members",
        bool: true,
      ),
      body: ModalProgressHUD(
        inAsyncCall: isLoading,
        opacity: 0,
        child: ListView.builder(
            itemCount: memberList.length,
            itemBuilder: (context, index) {
              return Container(
                height: height * 0.1,
                margin: EdgeInsets.only(left: 5, right: 10, bottom: 10, top: 10),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        height: height * 0.1,
                        width: width * 0.22,
                        child: CachedNetworkImage(
                          imageUrl: memberList[index]['profile_pic'] == null ? '' : '$IMAGE_URL${memberList[index]['profile_pic']}',
                          placeholder: (context, url) => Container(
                            alignment: Alignment.center,
                            child: CircularProgressIndicator(),
                          ),
                          fit: BoxFit.cover,
                          errorWidget: (context, url, error) => Container(
                            decoration: BoxDecoration(border: Border.all(color: klightGrey), borderRadius: BorderRadius.circular(12)),
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
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 15,
                    ),
                    RegularText(
                      memberList[index]['user_name'] ?? '',
                      color: Colors.white,
                      fontSize: 17,
                    ),
                  ],
                ),
              );
            }),
      ),
    );
  }
}
