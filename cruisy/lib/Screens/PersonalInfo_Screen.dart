import 'dart:convert';

import 'package:age_calculator/age_calculator.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cruisy/Constant/constant.dart';
import 'package:cruisy/Widgets/Text_Widget.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PersonalInfo extends StatefulWidget {
  final image, userId, likeStatus, OtherUserid;
  const PersonalInfo({Key? key, this.image, this.userId, this.likeStatus, this.OtherUserid}) : super(key: key);

  @override
  _PersonalInfoState createState() => _PersonalInfoState();
}

class _PersonalInfoState extends State<PersonalInfo> {
  bool Selected = false;
  bool isLoading = false;
  var user_Token;
  var user_id;
  var jsonData;
  var userProfileResponse;
  var Favorite_Status;
  var userProfileData;
  var profileData;
  var dateofbirth;
  DateDuration? duration;
  var eighteenPlus;

  @override
  void initState() {

    setState(() {
      if (widget.likeStatus == "1") {
        Selected = true;

      } else {
        Selected = false;

      }
    });

    GetInformation();

    super.initState();
  }


  AddtoView() async {
    setState(() {
      isLoading = true;
    });
    final prefs = await SharedPreferences.getInstance();
    user_Token = prefs.getString('UserToken');

    try {
      final response = await dio.post(
        add_to_view,
        data: {
          'view_to': widget.userId,
        },
        options: Options(
          headers: {'Authorization': 'Bearer $user_Token'},
        ),
      );

      jsonData = jsonDecode(response.toString());

      if (jsonData['Status'] == 1) {
        setState(() {
          Navigator.pop(context);
        });
      } else if (jsonData['Status'] == 2) {
        setState(() {});
        Toasty.showtoast(
          jsonData['Message'],
        );
      }
    } on DioError catch (e) {
      print(e.response);
    }
  }

  AddFavoriteUser() async {
    setState(() {
      isLoading = true;
    });
    final prefs = await SharedPreferences.getInstance();
    user_Token = prefs.getString('UserToken');

    try {
      final response = await dio.post(
        add_user_favorite,
        data: {
          'favorite_to': widget.userId,
        },
        options: Options(
          headers: {'Authorization': 'Bearer $user_Token'},
        ),
      );

      jsonData = jsonDecode(response.toString());

      if (jsonData['Status'] == 1) {
        setState(() {

        });
        Toasty.showtoast(
          jsonData['Message'],
        );
      } else if (jsonData['Status'] == 2) {
        setState(() {

        });
        Toasty.showtoast(
          jsonData['Message'],
        );
      }
    } on DioError catch (e) {
      print(e.response);
    }
  }

  GetInformation() async {
    final prefs = await SharedPreferences.getInstance();
    user_Token = prefs.getString('UserToken');
    user_id = prefs.getString('UserId');

    try {
      userProfileResponse = await dio.post(get_user_profile,
          data: {"user_id": widget.OtherUserid},
          options: Options(
            headers: {'Authorization': 'Bearer $user_Token'},
          ));

      userProfileData = jsonDecode(userProfileResponse.toString());

      if (userProfileData['Status'] == 1) {
        setState(() {
          profileData = userProfileData['data'];

          dateofbirth = profileData["date_of_birth"].toString().split("T")[0];
          DateTime birthday = DateTime.parse(dateofbirth);
          duration = AgeCalculator.age(birthday);
          setState(() {
            eighteenPlus = duration!.years;
          });

        });
      }
      if (userProfileData['Status'] == 0) {
        Toasty.showtoast(userProfileData['Message']);
      }
    } on DioError catch (e) {
      print(e.response);
    }
  }


  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    return WillPopScope(
      onWillPop: () {
        return AddtoView();
      },
      child: Scaffold(
        backgroundColor: Color(0xff0d0d0d),
        body: userProfileData == null
            ? Container(
                alignment: Alignment.center,
                child: CircularProgressIndicator(
                  color: Colors.white,
                ))
            : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Stack(
                      children: [
                        Container(
                          height: height * 0.3,
                          width: width,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(7),
                            child: CachedNetworkImage(
                              imageUrl: widget.image,
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
                        Positioned(
                          bottom: 10,
                          right: 15,
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                if (Selected == false) {
                                  setState(() {
                                    Selected = true;
                                  });
                                } else {
                                  setState(() {
                                    Selected = false;
                                  });
                                }
                                AddFavoriteUser();
                              });
                            },
                            child: Image.asset(
                              'assets/images/Favourites-1.png',
                              height: 40,
                              color: Selected == true ? Colors.blueAccent : Colors.grey,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Padding(
                          padding: EdgeInsets.only(top: 15, left: 15),
                          child: RegularText(
                            'Personal Info',
                            color: Colors.white,
                            fontSize: 22,
                          ),
                        ),
                        Spacer(),
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: GestureDetector(
                            onTap: () {
                              AddtoView();
                            },
                            child: Image.asset(
                              "assets/images/close.png",
                              scale: 7,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SingleChildScrollView(
                      child: Padding(
                        padding: EdgeInsets.only(left: 15, top: 10),
                        child: Row(
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                personalInfo1(
                                  text: 'Age',
                                  text1: eighteenPlus.toString(),
                                ),
                                personalInfo1(
                                  text: 'Weight',
                                  text1: profileData["weight"] ?? "Not Added Weight",
                                ),
                                personalInfo1(
                                  text: 'Orientation',
                                  text1: profileData["orientation"] ?? "Not Added orientation",
                                ),
                                personalInfo1(
                                  text: 'Foreskin',
                                  text1: profileData["foreskin"] ?? "Not Added Foreskin",
                                ),
                                personalInfo1(
                                  text: 'Hair color',
                                  text1: profileData["hair_colour"] ?? "Not Added Hair color",
                                ),
                                personalInfo1(
                                  text: 'Style',
                                  text1: profileData["style"] ?? "Not Added Style",
                                ),
                                personalInfo1(
                                  text: 'Race',
                                  text1: profileData["race"] ?? "Not Added Race",
                                ),
                                personalInfo1(
                                  text: 'Piercings',
                                  text1: profileData["piercings"].toString(),
                                ),
                              ],
                            ),
                            SizedBox(
                              width: width * 0.15,
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                personalInfo1(
                                  text: 'Height',
                                  text1: profileData["height"] ?? "Not Added height",
                                ),
                                personalInfo1(
                                  text: 'Size',
                                  text1: profileData["cock_size"].toString(),
                                ),
                                personalInfo1(
                                  text: 'Position',
                                  text1: profileData["position"] ?? "Not Added Position",
                                ),
                                personalInfo1(
                                  text: 'Body Hair',
                                  text1: profileData["body_hair"] ?? "Not Added body hair",
                                ),
                                personalInfo1(
                                  text: 'Eye color',
                                  text1: profileData["eye_colour"] ?? "Not Added eye colour",
                                ),
                                personalInfo1(
                                  text: 'Body',
                                  text1: profileData["body_type"] ?? "Not Added body type",
                                ),
                                personalInfo1(
                                  text: 'Tattoos',
                                  text1: profileData["tattoos"].toString(),
                                ),
                                personalInfo1(
                                  text: 'Smoking',
                                  text1: profileData["smoking"] ?? "Not Added smoking",
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

class personalInfo1 extends StatelessWidget {
  final text;
  final text1;

  const personalInfo1({Key? key, this.text, this.text1}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RegularText(
          text,
          color: klightGrey,
          fontSize: 13,
        ),
        RegularText(
          text1,
          color: Colors.white,
          fontSize: 14,
        ),
        SizedBox(
          height: 15,
        ),
      ],
    );
  }
}
