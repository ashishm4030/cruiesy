import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cruisy/Constant/constant.dart';
import 'package:cruisy/Widgets/Appbar_Widget.dart';
import 'package:cruisy/Widgets/Text_Widget.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ReceivePhoto extends StatefulWidget {
  final groupid, chatid, isGroup;
  const ReceivePhoto({Key? key, this.groupid, this.chatid, this.isGroup}) : super(key: key);

  @override
  _ReceivePhotoState createState() => _ReceivePhotoState();
}

class _ReceivePhotoState extends State<ReceivePhoto> {
  bool isLoading = false;
  var receivephotoResponse;
  var receivephotoResponse1;
  var receivePhotoData;
  var receivePhotoData1;
  var receivePhoto = [];
  var receivePhotoss = [];
  var receivePersonalPhoto = [];
  var receivePersonalPhotoss = [];

  ReceivePhotos() async {
    final prefs = await SharedPreferences.getInstance();
    userToken = prefs.getString('UserToken');

    setState(() {
      isLoading = true;
    });
    try {
      receivephotoResponse = await dio.post(
        get_group_chat_photo,
        data: {
          'group_id': widget.groupid,
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $userToken',
          },
        ),
      );

      receivePhotoData = jsonDecode(receivephotoResponse.toString());
      if (receivePhotoData["Status"] == 1) {
        setState(() {
          receivePhoto = receivePhotoData["data"];

          for (int i = 0; i < receivePhoto.length; i++) {
            if (receivePhoto[i]['gmessage_by'].toString() != userId) {
              receivePhotoss.add(receivePhoto[i]['gmessage_text']);

            }
          }

          isLoading = false;
        });
      } else if (receivePhotoData["code"] == 306) {
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

  ReceivePersonalPhotos() async {
    final prefs = await SharedPreferences.getInstance();
    userToken = prefs.getString('UserToken');

    setState(() {
      isLoading = true;
    });
    try {
      receivephotoResponse1 = await dio.post(
        get_personal_chat_photo,
        data: {
          'chat_id': widget.chatid,
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $userToken',
          },
        ),
      );

      receivePhotoData1 = jsonDecode(receivephotoResponse1.toString());
      if (receivePhotoData1["Status"] == 1) {
        setState(() {
          receivePersonalPhoto = receivePhotoData1["data"];

          for (int i = 0; i < receivePersonalPhoto.length; i++) {
            if (receivePersonalPhoto[i]['message_by'].toString() != userId) {
              receivePersonalPhotoss.add(receivePersonalPhoto[i]['message_text']);

            }
          }
          isLoading = false;
        });
      } else if (receivePhotoData1["code"] == 306) {
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
    widget.isGroup == true ? ReceivePhotos() : ReceivePersonalPhotos();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kbackgroundColor,
      appBar: CostumeAppBar(
        text: '',
        bool: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            widget.isGroup == true
                ? GridView.builder(
                    shrinkWrap: true,
                    padding: EdgeInsets.zero,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: receivePhotoss.length,
                    reverse: false, //default
                    primary: false,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      mainAxisSpacing: 4.0,
                      crossAxisSpacing: 4.0,
                    ),
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () {
                          showGeneralDialog(
                            context: context,
                            barrierColor: Colors.black12.withOpacity(0.8), // Background color
                            pageBuilder: (_, __, ___) {
                              return Stack(
                                children: [
                                  Center(
                                    child: CachedNetworkImage(
                                      imageUrl: '$IMAGE_URL${receivePhotoss[index]}'.toString(),
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
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          child: Container(
                            // padding: EdgeInsets.only(right: 5, top: 5),
                            alignment: Alignment.topRight,
                            child: GestureDetector(
                              child: receivePhotoss.isEmpty
                                  ? Center(
                                      child: RegularText(
                                        "No Receive Photos",
                                        color: Colors.white,
                                        fontSize: 20,
                                      ),
                                    )
                                  : CachedNetworkImage(
                                      imageUrl: '$IMAGE_URL${receivePhotoss[index]}'.toString(),
                                      fit: BoxFit.cover,
                                      height: 150,
                                      width: 150,
                                      progressIndicatorBuilder: (context, url, downloadProgress) => Center(child: CircularProgressIndicator()),
                                      errorWidget: (context, url, error) => Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.camera_alt,
                                            color: Colors.grey,
                                            size: 20,
                                          ),
                                          RegularText(
                                            "Add Photo",
                                            color: Colors.grey,
                                          ),
                                        ],
                                      ),
                                    ),
                            ),
                          ),
                        ),
                      );
                    },
                  )
                : GridView.builder(
                    shrinkWrap: true,
                    padding: EdgeInsets.zero,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: receivePersonalPhotoss.length,
                    reverse: false, //default
                    primary: false,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      mainAxisSpacing: 4.0,
                      crossAxisSpacing: 4.0,
                    ),
                    itemBuilder: (context, index) {
                      return  ClipRRect(
                              borderRadius: BorderRadius.circular(8.0),
                              child: Container(
                                // padding: EdgeInsets.only(right: 5, top: 5),
                                alignment: Alignment.topRight,
                                child: GestureDetector(
                                  child: receivePersonalPhotoss.isEmpty
                                      ? Center(
                                          child: RegularText(
                                            "No Receive Photos",
                                            color: Colors.white,
                                            fontSize: 20,
                                          ),
                                        )
                                      : CachedNetworkImage(
                                          imageUrl: '$IMAGE_URL${receivePersonalPhotoss[index]}'.toString(),
                                          fit: BoxFit.cover,
                                          height: 150,
                                          width: 150,
                                          progressIndicatorBuilder: (context, url, downloadProgress) => Center(child: CircularProgressIndicator()),
                                          errorWidget: (context, url, error) => Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons.camera_alt,
                                                color: Colors.grey,
                                                size: 20,
                                              ),
                                              RegularText(
                                                "Add Photo",
                                                color: Colors.grey,
                                              ),
                                            ],
                                          ),
                                        ),
                                ),
                              ),
                            )
                         ;
                    },
                  )
          ],
        ),
      ),
    );
  }
}
