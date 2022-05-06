import 'dart:convert';
import 'dart:io';

import 'package:age_calculator/age_calculator.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:cruisy/Accounts/EditProfile_Screen.dart';
import 'package:cruisy/Accounts/Splash_Screen.dart';
import 'package:cruisy/Constant/constant.dart';
import 'package:cruisy/Screens/Store_Screen.dart';
import 'package:cruisy/Widgets/Appbar_Widget.dart';
import 'package:cruisy/Widgets/BottomBar_Widget.dart';
import 'package:cruisy/Widgets/Button_Widget.dart';
import 'package:cruisy/Widgets/Text_Widget.dart';
import 'package:cruisy/Widgets/Textfeild_Widget.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:intl/intl.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:socket_io_client/socket_io_client.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();
  TextEditingController confirmpassword = TextEditingController();
  TextEditingController date = TextEditingController();
  TextEditingController Phone = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;
  var pickedDate;
  bool isshow = false;
  var signUpData;
  var signUpResponse;
  var userData;
  var deviceToken;
  var deviceId;
  var deviceType;
  var jsonData;

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
          'device_token': device_token,
          'device_id': device_id,
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
          isbusiness = 0;
          isbusinessUnlimited = 0;
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) {
                return BottomBar();
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

  SignupUser() async {
    setState(() {
      isshow = false;
      isLoading = true;
    });
    try {
      signUpResponse = await dio.post(sign_up, data: {
        'email_id': email.text,
        'password': password.text,
        "lattitude": latitude,
        "longitude": longitude,
        "device_token": device_token,
        "device_type": device_type,
        "device_id": device_id,
        "date_of_birth": date.text,
        "phone_number": Phone.text,
        "age": eighteenPlus.toString(),
      });

      signUpData = jsonDecode(signUpResponse.toString());

      if (signUpData['Status'] == 1) {
        setState(() {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => EditProfileScreen()));
          setUserData();
          isLoading = false;
          isbusinessUnlimited = 0;
          isbusiness = 0;
        });
        signUpData["info"]['user_id'] == null ? "" : RegisterSocket(signUpData["info"]['user_id']);
        Toasty.showtoast(signUpData['Message']);
      }
      if (signUpData['Status'] == 0) {
        setState(() {
          isshow = true;
          isLoading = false;
        });
        Toasty.showtoast(signUpData['Message']);
      }
    } on DioError catch (e) {
      Toasty.showtoast(signUpData['Message']);
      setState(() {
        isLoading = false;
      });
      setState(() {
        isLoading = false;
      });
    }
  }

  setUserData() async {
    await setPrefData(key: 'UserToken', value: signUpData['UserToken'].toString());
    await setPrefData(key: 'UserId', value: signUpData["info"]['user_id'].toString());
    await setPrefData(key: 'DeviceToken', value: signUpData["info"]['device_token'].toString());
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

  @override
  void initState() {
    getDeviceId();
    getDeviceToken();
    getCurrentLocation();
    super.initState();
  }

  DateDuration? duration;

  var birthdate;
  var eighteenPlus;

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Color(0xff000000),
      appBar: CostumeAppBar(
        text: 'Create Account',
        bool: true,
      ),
      body: ModalProgressHUD(
        inAsyncCall: isLoading,
        opacity: 0,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                CostumeTextFiled(
                  inputFormatters: [
                    FilteringTextInputFormatter.deny(RegExp("[A-Z]")),
                    FilteringTextInputFormatter.deny(RegExp(r'\s')),
                  ],
                  hintcolor: Color(0xff505050),
                  controller: email,
                  isShow: false,
                  hintText: 'Email',
                  suffix: Container(
                    child: email.text.isNotEmpty == !RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(email.text)
                        ? Text(
                            "Invalid email address",
                            style: TextStyle(color: kPrimaryColor, fontSize: 10),
                          )
                        : Text(""),
                  ),
                ),
                CostumeTextFiled(
                    inputFormatters: [
                      FilteringTextInputFormatter.deny(RegExp(r'\s')),
                    ],
                    hintcolor: Color(0xff505050),
                    controller: password,
                    isShow: true,
                    hintText: 'Password',
                    suffix: password.text.length < 8
                        ? Text(
                            "password must be 8 Character",
                            style: TextStyle(color: kPrimaryColor, fontSize: 10),
                          )
                        : password.text != confirmpassword.text
                            ? Text(
                                "Passwords do not match",
                                style: TextStyle(color: kPrimaryColor, fontSize: 10),
                              )
                            : Text("")),
                CostumeTextFiled(
                    inputFormatters: [
                      FilteringTextInputFormatter.deny(RegExp(r'\s')),
                    ],
                    hintcolor: Color(0xff505050),
                    controller: confirmpassword,
                    isShow: true,
                    hintText: 'Confirm Password',
                    suffix: confirmpassword.text.length < 8
                        ? Text(
                            "password must be 8 Character",
                            style: TextStyle(color: kPrimaryColor, fontSize: 10),
                          )
                        : password.text != confirmpassword.text
                            ? Text(
                                "Passwords do not match",
                                style: TextStyle(color: kPrimaryColor, fontSize: 10),
                              )
                            : Text("")),
                CostumeTextFiled(
                  readOnly: true,
                  hintcolor: Color(0xff505050),
                  controller: date,
                  isShow: false,
                  hintText: 'Date of Birth',
                  suffix: date.text.isNotEmpty
                      ? eighteenPlus < 18
                          ? Text(
                              "This app is for people 18+",
                              style: TextStyle(color: kPrimaryColor, fontSize: 10),
                            )
                          : Text("")
                      : Text(""),
                  onTap: () async {
                    pickedDate = await showDatePicker(
                        builder: (context, child) => Theme(
                              data: ThemeData().copyWith(colorScheme: ColorScheme.highContrastLight(primary: kPrimaryColor, onPrimary: Colors.white, onSurface: Colors.black)),
                              child: child!,
                            ),
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(1950),
                        lastDate: DateTime(2101));

                    if (pickedDate != null) {
                      String formattedDate = DateFormat('yyyy-MM-dd').format(pickedDate);

                      setState(() {
                        date.text = formattedDate;
                      });
                      DateTime birthday = DateTime.parse(date.text);
                      duration = AgeCalculator.age(birthday);
                      setState(() {
                        eighteenPlus = duration!.years;
                      });
                    } else {}
                  },
                ),
                TextFormField(
                  cursorColor: kPrimaryColor,
                  controller: Phone,
                  maxLength: 10,
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
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
                SizedBox(
                  height: height * 0.06,
                ),
                email.text.isEmpty ||
                        password.text.isEmpty ||
                        password.text.length > 8 ||
                        confirmpassword.text.isEmpty ||
                        confirmpassword.text.length > 8 ||
                        date.text.isEmpty ||
                        Phone.text.isEmpty ||
                        password.text != confirmpassword.text ||
                        eighteenPlus < 18 ||
                        email.text.isNotEmpty == !RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(email.text)
                    ? DisableButton(text: 'Sign Up')
                    : CostumeButton(
                        onTap: () async {
                          if (validate(
                            isshow: true,
                            email: email.text,
                            password: password.text,
                            confirmpassword: confirmpassword.text,
                            date: date.text,
                          )) await SignupUser();
                        },
                        text: 'Sign Up',
                      ),
                SizedBox(
                  height: height * 0.04,
                ),
                RegularText(
                  'Continue with',
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
      ),
    );
  }

  bool validate({
    required String email,
    required bool isshow,
    required String password,
    required String confirmpassword,
    required String date,
  }) {
    if (email.isEmpty && password.isEmpty && confirmpassword.isEmpty && date.isEmpty) {
      return false;
    } else if (password.isEmpty) {
      setState(() {
        isshow = true;
      });
      return false;
    } else if (email.isEmpty) {
      setState(() {
        isshow = true;
      });
      return false;
    } else if (!RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(email)) {
      return false;
    } else if (confirmpassword.isEmpty) {
      setState(() {
        isshow = true;
      });
      return false;
    } else if (confirmpassword != password) {
      setState(() {
        isshow = true;
      });
      return false;
    } else if (date.isEmpty) {
      setState(() {
        isshow = true;
      });
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
