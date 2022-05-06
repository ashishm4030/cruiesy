import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cruisy/Constant/constant.dart';
import 'package:cruisy/Widgets/Appbar_Widget.dart';
import 'package:cruisy/Widgets/Text_Widget.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BlockUserScreen extends StatefulWidget {
  const BlockUserScreen({Key? key}) : super(key: key);

  @override
  _BlockUserScreenState createState() => _BlockUserScreenState();
}

class _BlockUserScreenState extends State<BlockUserScreen> {
  bool isLoading = false;
  var listViewUserResponse;
  var listBlockUserData;
  var user_token;
  var listBlockUserList = [];

  List_Block_User() async {
    final prefs = await SharedPreferences.getInstance();
    user_token = prefs.getString('UserToken');
    setState(() {
      isLoading = true;
    });
    try {
      listViewUserResponse = await dio.post(
        list_block_user,
        options: Options(
          headers: {
            'Authorization': 'Bearer $user_token',
          },
        ),
      );
      listBlockUserData = jsonDecode(listViewUserResponse.toString());
      if (listBlockUserData["Status"] == 1) {
        setState(() {
          isLoading = false;
          listBlockUserList = listBlockUserData['data'];
        });
      } else if (listBlockUserData["code"] == 306) {
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
    }
  }

  @override
  void initState() {
    List_Block_User();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: kbackgroundColor,
      appBar: CostumeAppBar(
        text: 'Block User',
        bool: true,
      ),
      body: ModalProgressHUD(
        inAsyncCall: isLoading,
        opacity: 0,
        child: listBlockUserList.isEmpty && isLoading == false
            ? Center(
                child: RegularText(
                  "No One Block User",
                  color: Colors.grey,
                ),
              )
            : ListView.builder(
                itemCount: listBlockUserList.length,
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
                              imageUrl: listBlockUserList[index]['profile_pic'] == null ? '' : '$IMAGE_URL${listBlockUserList[index]['profile_pic']}',
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
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            RegularText(
                              'Block User',
                              color: klightGrey,
                              fontSize: 12,
                            ),
                            RegularText(
                              listBlockUserList[index]['user_name'] ?? '',
                              color: Colors.white,
                              fontSize: 17,
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                }),
      ),
    );
  }
}
