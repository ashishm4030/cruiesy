import 'dart:async';
import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cruisy/Constant/constant.dart';
import 'package:cruisy/Widgets/Appbar_Widget.dart';
import 'package:cruisy/Widgets/Text_Widget.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ViewedYouScreen extends StatefulWidget {
  final image, userId, likeStatus;
  const ViewedYouScreen({Key? key, this.image, this.userId, this.likeStatus}) : super(key: key);

  @override
  _ViewdYouScreenState createState() => _ViewdYouScreenState();
}

class _ViewdYouScreenState extends State<ViewedYouScreen> {
  bool isLoading = false;
  var listViewUserResponse;
  var listViewUserData;
  var listViewUserList = [];

  List_View_User_Data() async {
    setState(() {
      isLoading = true;
    });
    try {
      listViewUserResponse = await dio.post(
        list_viewed_user,
        options: Options(
          headers: {
            'Authorization': 'Bearer $user_token',
          },
        ),
      );
      listViewUserData = jsonDecode(listViewUserResponse.toString());
      if (listViewUserData["Status"] == 1) {
        setState(() {
          isLoading = false;
          listViewUserList = listViewUserData['data'];

        });
      } else if (listViewUserData["code"] == 306) {
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

  var user_token;
  Future getUserToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    user_token = prefs.getString('UserToken');

    await List_View_User_Data();
  }

  @override
  void initState() {

    getUserToken();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: kbackgroundColor,
      appBar: CostumeAppBar(
        text: 'Viewed You',
        bool: true,
      ),
      body: ModalProgressHUD(
        inAsyncCall: isLoading,
        opacity: 0,
        child: listViewUserList.isEmpty && isLoading == false
            ? Center(
                child: RegularText(
                  "No One See Your Profile",
                  color: Colors.grey,
                ),
              )
            : ListView.builder(
                itemCount: listViewUserList.length,
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
                              imageUrl: listViewUserList[index]['profile_pic'] == null ? '' : '$IMAGE_URL${listViewUserList[index]['profile_pic']}',
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
                              'Viewed you',
                              color: klightGrey,
                              fontSize: 12,
                            ),
                            RegularText(
                              listViewUserList[index]['user_name'] ?? '',
                              color: Colors.white,
                              fontSize: 17,
                            ),
                          ],
                        ),
                        Spacer(),
                        GestureDetector(
                          onTap: () {

                          },
                          child: Image.asset(
                            'assets/images/Views.png',
                            color: kPrimaryColor,
                            scale: 4,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
      ),
    );
  }
}
