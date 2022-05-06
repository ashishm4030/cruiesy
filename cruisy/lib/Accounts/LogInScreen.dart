import 'dart:convert';
import 'dart:io';

import 'package:country_code_picker/country_code_picker.dart';
import 'package:country_code_picker/country_localizations.dart';
import 'package:cruisy/Accounts/EditProfile_Screen.dart';
import 'package:cruisy/Accounts/ForgotPassword_Screen.dart';
import 'package:cruisy/Accounts/SignUp_Screen.dart';
import 'package:cruisy/Accounts/Splash_Screen.dart';
import 'package:cruisy/Constant/GoogleSignIn.dart';
import 'package:cruisy/Constant/constant.dart';
import 'package:cruisy/Screens/Store_Screen.dart';
import 'package:cruisy/Widgets/BottomBar_Widget.dart';
import 'package:cruisy/Widgets/Button_Widget.dart';
import 'package:cruisy/Widgets/Text_Widget.dart';
import 'package:cruisy/Widgets/Textfeild_Widget.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:socket_io_client/socket_io_client.dart';

class LogInScreen extends StatefulWidget {
  const LogInScreen({Key? key}) : super(key: key);

  @override
  _LogInScreenState createState() => _LogInScreenState();
}

class _LogInScreenState extends State<LogInScreen> with SingleTickerProviderStateMixin {
  TabController? _tabController;
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();
  TextEditingController phone = TextEditingController();
  TextEditingController Ppassword = TextEditingController();
  bool isLoading = false;
  var logInResponse;

  var user_Token;
  var jsonData;
  var deviceToken;
  var deviceId;
  var deviceType;
  var userData;
  var updateUserResponse;
  var updateUserData;
  var phonejsonData;
  var logInResponsephone;

  @override
  void initState() {
    getDeviceToken();
    getCurrentLocation();
    getDeviceId();

    _tabController = TabController(length: 2, vsync: this);
    super.initState();
  }

  SignInUser({var e_mail, var Phone}) async {
    setState(() {
      isLoading = true;
    });
    try {
      final logInResponse = await dio.post(
        login,
        data: {
          "email_or_phone": email.text.isNotEmpty ? e_mail : Phone,
          'password': password.text.isNotEmpty ? password.text : Ppassword.text,
          "device_token": device_token,
          "device_type": device_type,
          "device_id": device_id,
          "lattitude": latitude,
          "longitude": longitude,
        },
      );

      jsonData = jsonDecode(logInResponse.toString());
      if (jsonData['Status'] == 1) {
        setState(() {
          setUserData();
          UserIsOnline();
          isLoading = false;
          isbusinessUnlimited = 0;
          isbusiness = 0;
        });

        jsonData["info"]['user_id'] == null ? "" : RegisterSocket(jsonData["info"]['user_id']);
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => BottomBar()));
        Toasty.showtoast(jsonData['Message']);
      } else if (jsonData['Status'] == 0) {
        setState(() {
          isLoading = false;
        });
        Toasty.showtoast(jsonData['Message']);
      } else if (jsonData['Status'] == 2) {
        setState(() {
          isLoading = false;
        });
        Toasty.showtoast(jsonData['Message']);
      }
    } on DioError catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  UserIsOnline() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    user_Token = prefs.getString('UserToken');

    try {
      updateUserResponse = await dio.post(
        update_user_isonline,
        data: {
          'is_online': 1,
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $user_Token',
          },
        ),
      );

      updateUserData = jsonDecode(updateUserResponse.toString());
      if (updateUserData["Status"] == 1) {
        setState(() {});
      } else {}
    } on DioError catch (e) {}
  }

  void loginByThirdParty({
    String? userName,
    String? Email,
    String? thirdPartyID,
    String? profilePic,
    String? loginType,
  }) async {
    await getDeviceId();
    await getDeviceToken();
    setState(() {
      deviceToken = device_token;
      deviceId = device_id;
      deviceType = device_type;
    });
    setState(() {
      isLoading = true;
    });
    Dio dio = Dio();
    try {
      var response = await dio.post(
        login_by_thirdparty,
        data: {
          'email_id': Email,
          'user_name': userName,
          'thirdparty_id': thirdPartyID,
          'login_type': loginType,
          'device_type': Platform.isIOS ? 2 : 1,
          'device_token': deviceToken,
          'device_id': deviceId,
          'lattitude': latitude,
          'longitude': longitude,
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          isLoading = false;
          jsonData = jsonDecode(response.toString());
        });
        if (jsonData['Status'] == 1) {
          setUserData();
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) {
                return EditProfileScreen();
              },
            ),
          );
          Toasty.showtoast(jsonData['Message']);
        } else {
          isLoading = false;
          Toasty.showtoast(jsonData['Message']);
        }
      } else {
        isLoading = false;
        Toasty.showtoast('Something Went Wrong');
      }
    } on DioError catch (e) {
      isLoading = false;
    }
  }

  ClearText() {
    email.clear();
    password.clear();
  }

  ClearText1() {
    phone.clear();
    Ppassword.clear();
  }

  RegisterSocket(var user_Id) {
    socket = io("http://164.92.83.132:8000/", <String, dynamic>{
      "transports": ['websocket']
    });
    socket.on(
        "connect",
        (data) => {
              socket.emit("socket_register", {"user_id": user_Id}),
              socketID = socket.id,
            });
  }

  setUserData() async {
    await setPrefData(key: 'UserToken', value: jsonData['UserToken'].toString());
    await setPrefData(key: 'UserId', value: jsonData["info"]['user_id'].toString());
    await setPrefData(key: 'UserName', value: jsonData["info"]['user_name']);
  }

  List<String> TabText = ['Email', 'Phone'];
  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      supportedLocales: [
        Locale("af"),
        Locale("am"),
        Locale("ar"),
        Locale("az"),
        Locale("be"),
        Locale("bg"),
        Locale("bn"),
        Locale("bs"),
        Locale("ca"),
        Locale("cs"),
        Locale("da"),
        Locale("de"),
        Locale("el"),
        Locale("en"),
        Locale("es"),
        Locale("et"),
        Locale("fa"),
        Locale("fi"),
        Locale("fr"),
        Locale("gl"),
        Locale("ha"),
        Locale("he"),
        Locale("hi"),
        Locale("hr"),
        Locale("hu"),
        Locale("hy"),
        Locale("id"),
        Locale("is"),
        Locale("it"),
        Locale("ja"),
        Locale("ka"),
        Locale("kk"),
        Locale("km"),
        Locale("ko"),
        Locale("ku"),
        Locale("ky"),
        Locale("lt"),
        Locale("lv"),
        Locale("mk"),
        Locale("ml"),
        Locale("mn"),
        Locale("ms"),
        Locale("nb"),
        Locale("nl"),
        Locale("nn"),
        Locale("no"),
        Locale("pl"),
        Locale("ps"),
        Locale("pt"),
        Locale("ro"),
        Locale("ru"),
        Locale("sd"),
        Locale("sk"),
        Locale("sl"),
        Locale("so"),
        Locale("sq"),
        Locale("sr"),
        Locale("sv"),
        Locale("ta"),
        Locale("tg"),
        Locale("th"),
        Locale("tk"),
        Locale("tr"),
        Locale("tt"),
        Locale("uk"),
        Locale("ug"),
        Locale("ur"),
        Locale("uz"),
        Locale("vi"),
        Locale("zh")
      ],
      localizationsDelegates: [
        CountryLocalizations.delegate,
      ],
      home: Scaffold(
        backgroundColor: Color(0xff000000),
        body: ModalProgressHUD(
          inAsyncCall: isLoading,
          opacity: 0,
          child: SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: InkWell(
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => SignUpScreen()));
                      },
                      child: RegularText(
                        'Sign Up',
                        color: kPrimaryColor,
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: height * 0.18,
                ),
                TabBar(
                  labelPadding: EdgeInsets.symmetric(vertical: 10),
                  indicatorColor: Colors.white,
                  unselectedLabelColor: klightGrey,
                  labelColor: kGreyColor,
                  controller: _tabController,
                  tabs: List.generate(
                    TabText.length,
                    (index) => Text(
                      TabText[index],
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
                Expanded(
                  child: TabBarView(controller: _tabController, children: [
                    Container(
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            CostumeTextFiled(
                              hintcolor: Color(0xff505050),
                              controller: email,
                              isShow: false,
                              hintText: 'Email',
                              inputFormatters: [
                                FilteringTextInputFormatter.deny(RegExp("[A-Z]")),
                                FilteringTextInputFormatter.deny(RegExp(r'\s')),
                              ],
                            ),
                            CostumeTextFiled(
                              hintcolor: Color(0xff505050),
                              controller: password,
                              isShow: true,
                              hintText: 'Password',
                              inputFormatters: [
                                FilteringTextInputFormatter.deny(RegExp(r'\s')),
                              ],
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            email.text.isEmpty || password.text.isEmpty
                                ? DisableButton(text: 'Login')
                                : CostumeButton(
                                    onTap: () {
                                      if (validate(email: email.text)) SignInUser(e_mail: email.text);
                                    },
                                    text: 'Login',
                                  ),
                            SizedBox(
                              height: height * 0.02,
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ForgotPasswordScreen(),
                                  ),
                                );
                              },
                              child: RegularText(
                                'Forgot Password?',
                                fontSize: 15,
                                fontFamily: '',
                                color: klightGrey,
                              ),
                            ),
                            SizedBox(
                              height: height * 0.04,
                            ),
                            RegularText(
                              'Continue with',
                              fontSize: 14,
                              fontFamily: '',
                              color: kGreyColor,
                            ),
                            SizedBox(
                              height: height * 0.02,
                            ),
                            SocialButton(
                              color: Colors.black,
                              backgroundcolor: Colors.white,
                              imagePath: 'assets/images/google.png',
                              socialText: 'Sign in with Google',
                              onTap: () {
                                signInWithGoogle().then(
                                  (result) {
                                    if (result != null) {
                                      loginByThirdParty(
                                        userName: gName,
                                        Email: gEmail,
                                        thirdPartyID: googleAuth,
                                        loginType: '0',
                                      );
                                    }
                                  },
                                );
                              },
                            ),
                            SocialButton(
                              color: Colors.white,
                              backgroundcolor: kfbcolor,
                              imagePath: 'assets/images/facebook.png',
                              socialText: 'Sign in with Facebook',
                              onTap: () {
                                socialFBLogin();
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    SingleChildScrollView(
                      child: Column(
                        children: [
                          Container(
                            height: 1,
                            color: klightGrey,
                          ),
                          TextFormField(
                            cursorColor: kPrimaryColor,
                            controller: phone,
                            decoration: InputDecoration(
                              prefixIcon: Container(
                                width: 92,
                                child: Row(
                                  children: [
                                    CountryCodePicker(
                                      initialSelection: '+221',
                                      favorite: ['+221', 'SN'],
                                      textStyle: TextStyle(color: Colors.grey.withOpacity(0.4)),
                                      showFlag: false,
                                    ),
                                    Container(
                                      width: 0.2,
                                      height: 48,
                                      color: Colors.white,
                                    ),
                                  ],
                                ),
                              ),
                              hintText: 'Phone',
                              hintStyle: TextStyle(
                                color: Color(0xff505050),
                              ),
                              enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
                              focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
                            ),
                            keyboardType: TextInputType.phone,
                            inputFormatters: [
                              FilteringTextInputFormatter.deny(RegExp(r'\s')),
                            ],
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                          CostumeTextFiled(
                            hintcolor: Color(0xff505050),
                            controller: Ppassword,
                            isShow: true,
                            hintText: 'Password',
                            inputFormatters: [
                              FilteringTextInputFormatter.deny(RegExp(r'\s')),
                            ],
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          phone.text.isEmpty || Ppassword.text.isEmpty
                              ? DisableButton(text: 'Login')
                              : CostumeButton(
                                  onTap: () async {
                                    SignInUser(Phone: phone.text);
                                    // await SignInUserPhone();
                                  },
                                  text: 'Login',
                                ),
                          SizedBox(
                            height: height * 0.02,
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ForgotPasswordScreen(),
                                ),
                              );
                            },
                            child: RegularText(
                              'Forgot Password?',
                              fontSize: 15,
                              color: klightGrey,
                            ),
                          ),
                          SizedBox(
                            height: height * 0.04,
                          ),
                          RegularText(
                            'Continue with',
                            color: kGreyColor,
                          ),
                          SizedBox(
                            height: height * 0.02,
                          ),
                          SocialButton(
                            color: Colors.black,
                            backgroundcolor: Colors.white,
                            imagePath: 'assets/images/google.png',
                            socialText: 'Sign in with Google',
                            onTap: () {},
                          ),
                          SocialButton(
                            color: Colors.white,
                            backgroundcolor: kfbcolor,
                            imagePath: 'assets/images/facebook.png',
                            socialText: 'Sign in with Facebook',
                            onTap: () {
                              socialFBLogin();
                            },
                          ),
                        ],
                      ),
                    )
                  ]),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  bool validate({required String email}) {
    if (email.isEmpty) {
      Toasty.showtoast('Please Enter Your Email Address');
      return false;
    } else if (!RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(email)) {
      Toasty.showtoast('Please Enter Valid Email Address');
      return false;
    } else {
      return true;
    }
  }

  var userToken;
  var response;

  Future<void> socialFBLogin() async {
    final LoginResult result = await FacebookAuth.instance.login();

    if (result.status == LoginStatus.success) {
      userData = await FacebookAuth.instance.getUserData();

      var fgName = userData['name'];
      var fgEmail = userData['email'];
      var thirdPartyID = userData['id'];
      var profilePhotoUrl = userData['picture']['data']['url'];

      if (thirdPartyID != null || thirdPartyID != '') {
        loginByThirdParty(userName: fgName, Email: fgEmail, thirdPartyID: thirdPartyID, loginType: '1', profilePic: profilePhotoUrl);
      }
    } else {}
  }
}
