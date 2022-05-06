import 'dart:async';
import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cruisy/Accounts/ChangePassword_Screen.dart';
import 'package:cruisy/Constant/constant.dart';
import 'package:cruisy/Screens/EditProfile_Screen1.dart';
import 'package:cruisy/Screens/HostingStatus_Screen.dart';
import 'package:cruisy/Screens/InviteFriends_Screen.dart';
import 'package:cruisy/Screens/ProfileSetting_Screen.dart';
import 'package:cruisy/Screens/Store_Screen.dart';
import 'package:cruisy/Widgets/BottomBar_Widget.dart';
import 'package:cruisy/Widgets/Text_Widget.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  var user_Token;
  var user_id;
  var userProfileResponse;
  var userProfileData;
  var username;
  var userEmail;
  var profileData;
  bool isSwitched = true;
  bool isLoading = false;
  var EditProfileResponse;
  var EditProfileData;
  var ProfileData;
  var is_incognito_Tap;
  int incognito_Tap = 0;

  GetInformation() async {
    final prefs = await SharedPreferences.getInstance();
    user_Token = prefs.getString('UserToken');
    user_id = prefs.getString('UserId');

    try {
      userProfileResponse = await dio.post(get_user_profile,
          data: {"user_id": user_id},
          options: Options(
            headers: {'Authorization': 'Bearer $user_Token'},
          ));

      userProfileData = jsonDecode(userProfileResponse.toString());

      if (userProfileData['Status'] == 1) {
        setState(() {
          profileData = userProfileData['data'];

          is_incognito_Tap = profileData['is_incognito'];

          if (is_incognito_Tap == 1) {
            isSwitched = true;
          } else {
            isSwitched = false;
          }
          username = profileData["user_name"];
          userEmail = profileData["email_id"];
          ProfilePic = profileData["profile_pic"];

        });
      }
      if (userProfileData['Status'] == 0) {
        Toasty.showtoast(userProfileData['Message']);
      }
    } on DioError catch (e) {
      print(e.response);

    }
  }

  FutureOr onGoBack(dynamic value) {
    GetInformation();
    setState(() {});
  }

  EditProfile() async {
    setState(() {
      isLoading = true;
    });

    var formdata = FormData.fromMap({
      "no_profile_pic": "no Profile",
      "orientation": Orientation,
      "is_incognito": incognito_Tap,
    });

    try {
      EditProfileResponse = await dio.post(
        edit_profile,
        data: formdata,
        options: Options(
          headers: {"Authorization": "Bearer $userToken"},
        ),
      );

      EditProfileData = jsonDecode(EditProfileResponse.toString());

      if (EditProfileData["Status"] == 1) {
        setState(() {
          isLoading = false;
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

  @override
  void initState() {
    GetInformation();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: kbackgroundColor,
      appBar: AppBar(
        backgroundColor: kbackgroundColor,
        automaticallyImplyLeading: false,
        title: RegularText(
          'Profile',
          color: Colors.white,
          fontSize: 18,
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(bottom: isbusiness == 1 || isbusinessUnlimited == 1 ? 50 : 150),
          child: Column(
            children: [
              SizedBox(
                height: 15,
              ),
              Center(
                child: ProfilePic == null
                    ? Container(
                        width: width * .14,
                        height: height * 0.14,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(50), color: Colors.grey, image: DecorationImage(image: AssetImage("assets/images/backPic.png"), fit: BoxFit.cover)))
                    : ClipOval(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(50),
                          child: CachedNetworkImage(
                            imageUrl: "$IMAGE_URL/$ProfilePic",
                            fit: BoxFit.cover,
                            width: width * .14,
                            height: height * 0.14,
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
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
              ),
              SizedBox(
                height: 5,
              ),
              RegularText(
                username ?? "",
                fontSize: 20,
                color: Colors.white,
              ),
              RegularText(
                isbusiness == 1 || isbusinessUnlimited == 1 ? 'Premium Member' : "",
                fontSize: 14,
                color: kPrimaryColor,
              ),
              SizedBox(
                height: 16,
              ),
              ProfileButton(
                text: 'Edit Profile',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditProfileScreen1(
                        username: username,
                      ),
                    ),
                  ).then((onGoBack));
                },
              ),
              ProfileButton(
                text: 'Change Password',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ChangePasswordScreen()),
                  );
                },
              ),

              ProfileButton(
                text: 'Hosting Status',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => HostingStatus_Screen()),
                  );
                },
              ),
              ProfileButton(
                text: 'Invite',
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => InviteFriendScreen()));
                },
              ),
              Container(
                padding: EdgeInsets.fromLTRB(15, 4, 7, 4),
                child: Row(
                  children: [
                    RegularText(
                      'Incognito',
                      fontSize: 18,
                      color: Colors.white,
                    ),
                    Spacer(),
                    Switch(
                      value: isSwitched,
                      onChanged: (value) {
                        setState(() {
                          isSwitched = value;

                          if (isSwitched == true) {
                            incognito_Tap = 1;
                          } else if (isSwitched == false) {
                            incognito_Tap = 0;
                          }
                          EditProfile();

                        });
                      },
                      activeTrackColor: kPrimaryColor,
                      activeColor: Colors.white,
                      inactiveTrackColor: klightGrey,
                    ),
                  ],
                ),
              ),
              ProfileButton(
                text: 'Settings',
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ProfileSettingScreen(
                                useremail: userEmail,
                              )));
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
