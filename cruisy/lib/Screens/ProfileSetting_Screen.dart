import 'dart:convert';

import 'package:cruisy/Accounts/LogInScreen.dart';
import 'package:cruisy/Constant/GoogleSignIn.dart';
import 'package:cruisy/Constant/constant.dart';
import 'package:cruisy/Screens/BLockUser_Screen.dart';
import 'package:cruisy/Widgets/Text_Widget.dart';
import 'package:cruisy/Widgets/Textfeild_Widget.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class ProfileSettingScreen extends StatefulWidget {
  final useremail;
  const ProfileSettingScreen({Key? key, this.useremail}) : super(key: key);

  @override
  _ProfileSettingScreenState createState() => _ProfileSettingScreenState();
}

class _ProfileSettingScreenState extends State<ProfileSettingScreen> {
  TextEditingController AboutMe = TextEditingController();
  String _url = 'https://www.google.co.in/';
  String url = 'https://www.google.co.in/';
  var jsonData;
  var user_Token;
  bool isLoading = false;
  var EditProfileResponse;
  var EditProfileData;
  var getData;
  bool _is_Receive_Taps = false;
  bool _is_Sound = false;
  bool _is_Vibrations = false;
  bool _is_Mark_Recently_Chatted = false;
  bool _is_Keep_Phone_Awake = false;
  bool _is_Explore_Searches = false;
  bool _is_Show_Distance = false;
  int? Receive_Tap;
  int? Sound;
  int? Vibrations;
  int Mark_Recently_Chatted = 0;
  int Keep_Phone_Awake = 0;
  int Explore_Searches = 0;
  int Show_Distance = 0;
  var edtAccountResponse;
  var edtAccountData;
  var user_id;
  var userProfileResponse;
  var userProfileData;
  var profileData;
  var ReceiveTap;
  var editdata;
  var vibrations;
  var sound;
  var markk;
  var keep;
  var Show;
  var Exploree;
  int charLength = 0;

  Logout() async {
    final prefs = await SharedPreferences.getInstance();
    user_Token = prefs.getString('UserToken');

    try {
      final response = await dio.post(
        log_out,
        data: {
          'device_id': device_id,
        },
        options: Options(
          headers: {'Authorization': 'Bearer $user_Token'},
        ),
      );

      jsonData = jsonDecode(response.toString());

      if (jsonData['Status'] == 1) {
        setState(() {
          UserIsOnline();
          clearPrefData();
          signOutGoogle();
          signOut();
        });
        Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => LogInScreen()), (route) => false);
        Toasty.showtoast(
          jsonData['Message'],
        );
        if (jsonData['Status'] == 0) {
          Toasty.showtoast(
            jsonData['Message'],
          );
        }
      } else {
        Toasty.showtoast('Something Went Wrong');
      }
    } on DioError catch (e) {
      print(e.response);
    }
  }

  signOut() async {
    final FirebaseAuth _auth = FirebaseAuth.instance;

    try {
      await FirebaseAuth.instance.signOut();
      await _auth.signOut();
    } catch (e) {
      Toasty.showtoast("Error signing out. Try again.");
    }
    await UserIsOnline();
  }

  DeleteProfile() async {
    final prefs = await SharedPreferences.getInstance();
    user_Token = prefs.getString('UserToken');

    try {
      final response = await dio.post(
        delete_profile,
        data: {
          'is_delete': 1,
        },
        options: Options(
          headers: {'Authorization': 'Bearer $user_Token'},
        ),
      );

      jsonData = jsonDecode(response.toString());

      if (jsonData['Status'] == 1) {
        UserIsOnline();
        await clearPrefData();
        Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => LogInScreen()), (route) => false);
        Toasty.showtoast(
          jsonData['Message'],
        );
        if (jsonData['Status'] == 0) {
          Toasty.showtoast(
            jsonData['Message'],
          );
        }
      } else {
        Toasty.showtoast('Something Went Wrong');
      }
    } on DioError catch (e) {
      print(e.response);
    }
  }

  EditAccountTapData() async {

    setState(() {
      isLoading = true;
    });
    try {
      EditProfileResponse = await dio.post(
        edit_account_setting,
        data: {
          'receive_taps': _is_Receive_Taps == false ? '0' : '1',
          'sound': _is_Sound == false ? '0' : '1',
          'vibrations': _is_Vibrations == false ? '0' : '1',
          'mark_recently_chatted': _is_Mark_Recently_Chatted == false ? '0' : '1',
          'keep_phone_awake': _is_Keep_Phone_Awake == false ? '0' : '1',
          'show_me_in_explore_searches': _is_Explore_Searches == false ? '0' : '1',
          'is_show_distance': _is_Show_Distance == false ? '0' : '1',
          "about_us": AboutMe.text,
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $user_token',
          },
        ),
      );

      EditProfileData = jsonDecode(EditProfileResponse.toString());

      if (EditProfileData["Status"] == 1) {
        setState(() {
          isLoading = false;

          Navigator.pop(context);
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

  _onChanged(String value) {
    setState(() {
      charLength = value.length;
    });
  }

  var updateUserResponse;
  var updateUserData;
  var usertokenn;

  UserIsOnline() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    usertokenn = prefs.getString('UserToken');

    try {

      updateUserResponse = await dio.post(
        update_user_isonline,
        data: {
          'is_online': 0,
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $user_Token',
          },
        ),
      );

      updateUserData = jsonDecode(updateUserResponse.toString());
      if (updateUserData["Status"] == 1) {
        setState(() {

        });
      } else {

      }
    } on DioError catch (e) {

      print(e.response);

    }
  }

  getAccountTapData() async {

    setState(() {
      isLoading = true;
    });
    try {
      var response = await dio.post(
        edit_account_setting,
        options: Options(
          headers: {
            'Authorization': 'Bearer $user_token',
          },
        ),
      );
      getData = jsonDecode(response.toString());

      if (getData["Status"] == 1) {
        setState(() {
          isLoading = false;
          AboutMe = TextEditingController(text: getData['data']["about_us"]);

          ReceiveTap = getData['data']['receive_taps'].toString();
          sound = getData['data']['sound'].toString();
          vibrations = getData['data']['vibrations'].toString();
          markk = getData['data']['mark_recently_chatted'].toString();
          keep = getData['data']['keep_phone_awake'].toString();
          Exploree = getData['data']['show_me_in_explore_searches'].toString();
          Show = getData['data']['is_show_distance'].toString();
          if (ReceiveTap == "1") {
            setState(() {
              _is_Receive_Taps = true;
            });
          } else {
            setState(() {
              _is_Receive_Taps = false;
            });
          }
          if (sound == "1") {
            setState(() {
              _is_Sound = true;
            });
          } else {
            setState(() {
              _is_Sound = false;
            });
          }
          if (vibrations == "1") {
            setState(() {
              _is_Vibrations = true;
            });
          } else {
            setState(() {
              _is_Vibrations = false;
            });
          }
          if (markk == "1") {
            setState(() {
              _is_Mark_Recently_Chatted = true;
            });
          } else {
            setState(() {
              _is_Mark_Recently_Chatted = false;
            });
          }
          if (keep == "1") {
            setState(() {
              _is_Keep_Phone_Awake = true;
            });
          } else {
            setState(() {
              _is_Keep_Phone_Awake = false;
            });
          }
          if (Exploree == "1") {
            setState(() {
              _is_Explore_Searches = true;
            });
          } else {
            setState(() {
              _is_Explore_Searches = false;
            });
          }
          if (Show == "1") {
            setState(() {
              _is_Show_Distance = true;
            });
          } else {
            setState(() {
              _is_Show_Distance = false;
            });
          }
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
  }

  @override
  void initState() {

    getDeviceId();
    get();
    super.initState();
  }

  get() async {
    await getUserToken();
    await getAccountTapData();
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    return WillPopScope(
      onWillPop: () {
        return EditAccountTapData();
      },
      child: Scaffold(
        backgroundColor: kbackgroundColor,
        appBar: AppBar(
          backgroundColor: kbackgroundColor,
          automaticallyImplyLeading: false,
          title: RegularText(
            'Settings',
            color: Colors.white,
            fontSize: 18,
          ),
          leading: GestureDetector(
              onTap: () {
                EditAccountTapData();
              },
              child: Icon(Icons.arrow_back)),
        ),
        body: ModalProgressHUD(
          inAsyncCall: isLoading,
          opacity: 0,
          child: SingleChildScrollView(
            child: Column(
              children: [
                ProfileSettingButton(
                  text: 'Account',
                  visible: false,
                  text1: '',
                  FontSize: 14,
                  color: Color(0xff0d0d0d),
                ),
                ProfileSettingButton(
                  text: 'Upgrade',
                  visible: false,
                  text1: '',
                ),
                ProfileSettingButton(
                  text: 'Email',
                  visible: true,
                  text1: widget.useremail ?? "",
                ),
                ProfileSettingButton(
                  text: 'Password',
                  visible: false,
                  text1: '',
                ),
                ProfileSettingButton(
                  text: 'Restore Purchase',
                  visible: false,
                  text1: '',
                ),
                ProfileSettingButton(
                  text: 'Account',
                  visible: false,
                  text1: '',
                  color: Color(0xff0d0d0d),
                  FontSize: 14,
                ),
                ToggleButton(
                  text: 'Receive Taps',
                  isSwitched: _is_Receive_Taps,
                  onChanged: (value) {
                    setState(() {
                      _is_Receive_Taps = value;
                      if (_is_Receive_Taps == true) {
                        Receive_Tap = 1;
                      } else if (_is_Receive_Taps == false) {
                        Receive_Tap = 0;
                      }

                    });
                  },
                ),
                ToggleButton(
                  text: 'Sound',
                  isSwitched: _is_Sound,
                  onChanged: (value) {
                    setState(() {
                      _is_Sound = value;
                      if (_is_Sound == true) {
                        Sound = 1;
                      } else if (_is_Sound == false) {
                        Sound = 0;
                      }

                    });
                  },
                ),
                ToggleButton(
                  text: 'Vibrations',
                  isSwitched: _is_Vibrations,
                  onChanged: (value) {
                    setState(() {
                      _is_Vibrations = value;
                      if (_is_Vibrations == true) {
                        Vibrations = 1;
                      } else if (_is_Vibrations == false) {
                        Vibrations = 0;
                      }


                    });
                  },
                ),

                ProfileSettingButton(
                  text: 'Security and Privacy',
                  visible: false,
                  text1: '',
                  color: Color(0xff0d0d0d),
                  FontSize: 14,
                ),

                ProfileSettingButton(
                  text: 'Pin',
                  visible: false,
                  text1: '',
                ),
                ProfileSettingButton(
                  text: 'Fingerprint Authentication',
                  visible: false,
                  text1: '',
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => BlockUserScreen()));
                  },
                  child: ProfileSettingButton(
                    text: 'Block Users',
                    visible: false,
                    text1: '',
                  ),
                ),

                ProfileSettingButton(
                  text: 'Account',
                  visible: false,
                  text1: '',
                  color: Color(0xff0d0d0d),
                  FontSize: 14,
                ),

                ToggleButton(
                  text: 'Show Me in Explore Searches',
                  isSwitched: _is_Explore_Searches,
                  onChanged: (value) {
                    setState(() {
                      _is_Explore_Searches = value;

                      if (_is_Explore_Searches == true) {
                        Explore_Searches = 1;
                      } else if (_is_Explore_Searches == false) {
                        Explore_Searches = 0;
                      }

                    });
                  },
                ),
                ToggleButton(
                  text: 'Show Distance',
                  isSwitched: _is_Show_Distance,
                  onChanged: (value) {
                    setState(() {
                      _is_Show_Distance = value;
                      if (_is_Show_Distance == true) {
                        Show_Distance = 1;
                      } else if (_is_Show_Distance == false) {
                        Show_Distance = 0;
                      }

                    });
                  },
                ),
                Container(
                  width: width,
                  color: Color(0xff0d0d0d),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CostumeTextFiled(
                        fontSize: 14,
                        hintcolor: Colors.grey,
                        maxLength: 100,
                        isShow: false,
                        onChanged: _onChanged,
                        backcolor: kbackgroundColor,
                        suffix: Text(
                          "${AboutMe.text.toString().length}/100",
                          style: TextStyle(color: Color(0xff505050)),
                        ),
                        hintText: 'Enter About Us',
                        controller: AboutMe,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                        child: RegularText(
                          'About Us',
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                ProfileSettingButton(
                  text: 'Feature Request',
                  visible: false,
                  text1: '',
                ),
                ProfileSettingButton(
                  text: 'Help',
                  visible: false,
                  text1: '',
                ),
                ProfileSettingButton(
                  text: 'Community Guidelines',
                  visible: false,
                  text1: '',
                ),
                ProfileSettingButton(
                  text: 'Terms of Service',
                  onTap: _launchURL,
                  visible: false,
                  text1: '',
                ),
                ProfileSettingButton(
                  onTap: launchURL,
                  text: 'Privacy Policy',
                  visible: false,
                  text1: '',
                ),
                ProfileSettingButton(
                  text: 'Advertise',
                  visible: false,
                  text1: '',
                ),
                Container(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  color: Color(0xff0d0d0d),
                  child: Column(
                    children: [
                      LogoutButton(
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20.0))),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  RegularText(
                                    'Are You Sure You Want to Logout?',
                                    letterSpacing: 1,
                                    fontSize: 16,
                                  ),
                                  SizedBox(
                                    height: height * 0.03,
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: [
                                      GestureDetector(
                                        onTap: () {
                                          Navigator.pop(context);
                                        },
                                        child: Container(
                                          height: height * 0.04,
                                          width: width * 0.3,
                                          decoration: BoxDecoration(border: Border.all(color: Colors.black), borderRadius: BorderRadius.circular(8)),
                                          child: Center(
                                            child: RegularText(
                                              "No",
                                              color: Colors.black,
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        width: width * 0.02,
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          Logout();
                                        },
                                        child: Container(
                                          height: height * 0.04,
                                          width: width * 0.3,
                                          decoration: BoxDecoration(color: Colors.white, border: Border.all(color: Colors.black), borderRadius: BorderRadius.circular(8)),
                                          child: Center(
                                            child: RegularText(
                                              "Yes",
                                              color: Colors.black,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            ),
                          );
                        },
                        text: 'Log Out',
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      LogoutButton(
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20.0))),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  RegularText(
                                    'Are You Sure You Want to Delete?',
                                    letterSpacing: 1,
                                    fontSize: 16,
                                  ),
                                  SizedBox(
                                    height: height * 0.03,
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: [
                                      GestureDetector(
                                        onTap: () {
                                          Navigator.pop(context);
                                        },
                                        child: Container(
                                          height: height * 0.04,
                                          width: width * 0.3,
                                          decoration: BoxDecoration(border: Border.all(color: Colors.black), borderRadius: BorderRadius.circular(8)),
                                          child: Center(
                                            child: RegularText(
                                              "No",
                                              color: Colors.black,
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        width: width * 0.02,
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          DeleteProfile();
                                        },
                                        child: Container(
                                          height: height * 0.04,
                                          width: width * 0.3,
                                          decoration: BoxDecoration(color: Colors.white, border: Border.all(color: Colors.black), borderRadius: BorderRadius.circular(8)),
                                          child: Center(
                                            child: RegularText(
                                              "Yes",
                                              color: Colors.black,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            ),
                          );
                        },
                        text: 'Delete Profile',
                      ),
                      SizedBox(
                        height: 10,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _launchURL() async {
    if (await launch(_url)) throw 'Could not launch $_url';
  }

  void launchURL() async {
    if (await launch(url)) throw 'Could not launch $url';
  }
}

class ProfileSettingButton extends StatelessWidget {
  final text;
  final text1;
  bool visible;
  final double FontSize;
  final Color? color;
  final Function()? onTap;
  ProfileSettingButton({
    Key? key,
    this.text,
    this.onTap,
    this.visible = false,
    this.text1,
    this.color = kbackgroundColor,
    this.FontSize = 17,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 0.5,
          color: klightGrey.withOpacity(0.5),
        ),
        GestureDetector(
          onTap: onTap,
          child: Container(
            color: color,
            padding: FontSize == 14 ? EdgeInsets.symmetric(horizontal: 15, vertical: 17) : EdgeInsets.symmetric(horizontal: 15, vertical: 15),
            child: Row(
              children: [
                RegularText(
                  text,
                  fontSize: FontSize,
                  color: Colors.white,
                ),
                Spacer(),
                Visibility(
                  visible: visible,
                  child: RegularText(
                    text1,
                    fontSize: 15,
                    color: Colors.white,
                  ),
                ),
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
  }
}

class ToggleButton extends StatelessWidget {
  final String text;
  final bool isSwitched;
  final ValueChanged<bool>? onChanged;
  ToggleButton({required this.text, this.isSwitched = false, this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.only(left: 15, right: 7, top: 4, bottom: 4),
          child: Row(
            children: [
              RegularText(
                text,
                fontSize: 17,
                color: Colors.white,
              ),
              Spacer(),
              Switch(
                value: isSwitched,
                onChanged: onChanged,
                activeTrackColor: kPrimaryColor,
                inactiveTrackColor: klightGrey,
                activeColor: Colors.white,
              ),
            ],
          ),
        ),
        Container(
          height: 0.5,
          color: klightGrey.withOpacity(0.5),
        ),
      ],
    );
  }
}

class LogoutButton extends StatelessWidget {
  final String text;
  final Function()? onTap;
  const LogoutButton({Key? key, required this.text, this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        margin: EdgeInsets.symmetric(horizontal: 15),
        decoration: BoxDecoration(color: kbackgroundColor, borderRadius: BorderRadius.circular(7), border: Border.all(color: Colors.white, width: 2)),
        padding: EdgeInsets.symmetric(vertical: 10),
        child: Center(
          child: RegularText(
            text,
            color: Colors.white,
            fontSize: 18,
          ),
        ),
      ),
    );
  }
}
