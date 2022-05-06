import 'dart:convert';

import 'package:cruisy/Constant/constant.dart';
import 'package:cruisy/Widgets/Text_Widget.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HostingStatus_Screen extends StatefulWidget {
  const HostingStatus_Screen({Key? key}) : super(key: key);

  @override
  _HostingStatus_ScreenState createState() => _HostingStatus_ScreenState();
}

class _HostingStatus_ScreenState extends State<HostingStatus_Screen> {
  bool isLoading = false;
  var EditProfileResponse;
  var EditProfileData;
  var user_Token;
  var ison = [];
  List hostId = [];
  var ComUserId;

  EditProfile() async {
    final prefs = await SharedPreferences.getInstance();
    user_Token = prefs.getString('UserToken');
    setState(() {
      isLoading = true;
    });
    var formdata = FormData.fromMap({
      "no_image": "",
      "hosting_status_id": ComUserId,
    });
    try {
      EditProfileResponse = await dio.post(
        edit_profile,
        data: formdata,
        options: Options(
          headers: {"Authorization": "Bearer $user_Token"},
        ),
      );

      EditProfileData = jsonDecode(EditProfileResponse.toString());

      if (EditProfileData["Status"] == 1) {
        setState(() {
          isLoading = false;
          Navigator.pop(context);
        });

        Toasty.showtoast(EditProfileData["Message"]);
      } else {
        setState(() {
          isLoading = false;
        });

        Toasty.showtoast(EditProfileData["Message"]);
      }
    } on DioError catch (e) {
      setState(() {
        isLoading = false;
      });

      print(e.response);
    }
  }

  var listViewUserResponse;

  var listViewUserData;
  List HostingrList = [];
  var hostflag;

  List_Hosting_Data() async {
    final prefs = await SharedPreferences.getInstance();
    user_Token = prefs.getString('UserToken');
    setState(() {
      isLoading = true;
    });
    try {
      listViewUserResponse = await dio.post(
        get_hosting_status,
        options: Options(
          headers: {
            'Authorization': 'Bearer $user_Token',
          },
        ),
      );

      listViewUserData = jsonDecode(listViewUserResponse.toString());
      if (listViewUserData["Status"] == 1) {
        setState(() {
          isLoading = false;
          HostingrList = listViewUserData['data'];
        });
        for (int i = 0; i < HostingrList.length; i++) {
          hostflag = HostingrList[i]["is_hosting"];

          if (hostflag == 1) {
            setState(() {
              ison.add(true);
              hostId.add(HostingrList[i]["hosting_status_id"]);
            });
          } else {
            setState(() {
              ison.add(false);
            });
          }
        }

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

  @override
  void initState() {
    List_Hosting_Data();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Color(0xff0d0d0d),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: RegularText(
          'Hosting Status',
          fontSize: 18,
        ),
        leading: GestureDetector(
            onTap: () {
              EditProfile();
            },
            child: Icon(Icons.arrow_back)),
      ),
      body: WillPopScope(
        onWillPop: () {
          return EditProfile();
        },
        child: HostingrList.isEmpty
            ? Container()
            : ModalProgressHUD(
                inAsyncCall: isLoading,
                opacity: 0,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 0.5,
                      color: klightGrey.withOpacity(0.5),
                    ),
                    Container(
                      width: width,
                      padding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                      color: Color(0xff0d0d0d),
                      child: RegularText(
                        'Where are you currently?',
                        color: Colors.white,
                      ),
                    ),
                    Container(
                      height: 0.5,
                      color: klightGrey.withOpacity(0.5),
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: HostingrList.length,
                        itemBuilder: (context, index) {
                          return Column(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  setState(() {

                                    if (ison[index] == false) {
                                      ison[index] = true;
                                    } else if (ison[index] == true) {
                                      ison[index] = false;
                                    }
                                  });
                                  if (hostId.isEmpty) {

                                    setState(() {
                                      hostId.add(HostingrList[index]["hosting_status_id"]);
                                    });

                                  } else if (hostId.contains(HostingrList[index]["hosting_status_id"])) {

                                    setState(() {
                                      hostId.remove(HostingrList[index]["hosting_status_id"]);
                                    });

                                  } else {

                                    setState(() {
                                      hostId.add(HostingrList[index]["hosting_status_id"]);
                                    });

                                  }
                                  setState(() {
                                    ComUserId = hostId.join(",");

                                  });
                                },
                                child: Container(
                                  padding: EdgeInsets.symmetric(horizontal: 15, vertical: 17),
                                  width: width,
                                  color: kbackgroundColor,
                                  child: Row(
                                    children: [
                                      RegularText(
                                        HostingrList[index]["hosting_status"] ?? "",
                                        color: Colors.white,
                                        fontSize: 17,
                                      ),
                                      Spacer(),
                                      Container(
                                          height: 20,
                                          width: 20,
                                          decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.transparent)),
                                          child: ison[index] == true
                                              ? Image.asset(
                                                  'assets/images/Tick.png',
                                                  fit: BoxFit.cover,
                                                )
                                              : Container()),
                                    ],
                                  ),
                                ),
                              ),
                              Container(
                                height: 0.5,
                                color: klightGrey.withOpacity(0.5),
                              ),
                            ],
                          );
                        },
                      ),
                    )
                  ],
                ),
              ),
      ),
    );
  }
}
