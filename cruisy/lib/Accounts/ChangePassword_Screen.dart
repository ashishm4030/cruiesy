import 'dart:convert';

import 'package:cruisy/Constant/constant.dart';
import 'package:cruisy/Widgets/Appbar_Widget.dart';
import 'package:cruisy/Widgets/Button_Widget.dart';
import 'package:cruisy/Widgets/Text_Widget.dart';
import 'package:cruisy/Widgets/Textfeild_Widget.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({Key? key}) : super(key: key);

  @override
  _ChangePasswordScreenState createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  TextEditingController currPassword = TextEditingController();
  TextEditingController newpassword = TextEditingController();
  TextEditingController conpassword = TextEditingController();
  bool isLoading = false;
  var user_Token;

  var ChangePasswordJsonData;
  ChangePassword() async {
    final prefs = await SharedPreferences.getInstance();
    user_Token = prefs.getString('UserToken');

    setState(() {
      isLoading = true;
    });
    try {
      final response = await dio.post(change_password,
          data: {
            'password': currPassword.text,
            'new_pass': newpassword.text,
          },
          options: Options(
            headers: {'Authorization': 'Bearer $user_Token'},
          ));

      ChangePasswordJsonData = jsonDecode(response.toString());

      if (ChangePasswordJsonData['Status'] == 1) {
        setState(() {
          isLoading = false;
        });
        Navigator.pop(context);
        Toasty.showtoast(ChangePasswordJsonData['Message']);
      } else if (ChangePasswordJsonData['Status'] == 0) {
        setState(() {
          isLoading = false;
        });
        Toasty.showtoast(ChangePasswordJsonData['Message']);
      } else if (ChangePasswordJsonData['Status'] == 3) {
        setState(() {
          isLoading = false;
        });
        Toasty.showtoast(ChangePasswordJsonData['Message']);
      }
    } on DioError catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    getUserToken();
    getDeviceId();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    return ModalProgressHUD(
      inAsyncCall: isLoading,
      opacity: 0,
      child: Scaffold(
        backgroundColor: kbackgroundColor,
        appBar: CostumeAppBar(
          text: '',
          bool: true,
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(
                height: height * 0.1,
              ),
              Center(
                child: RegularText(
                  "Change Password",
                  fontSize: 22,
                  color: Colors.white,
                ),
              ),
              SizedBox(
                height: height * 0.05,
              ),
              Container(
                height: 0.5,
                color: klightGrey.withOpacity(0.6),
              ),
              CostumeTextFiled(
                hintcolor: Color(0xff505050),
                controller: currPassword,
                isShow: false,
                hintText: 'Enter Current Password',
                inputFormatters: [],
              ),
              SizedBox(
                height: height * 0.02,
              ),
              Container(
                height: 0.5,
                color: klightGrey.withOpacity(0.6),
              ),
              CostumeTextFiled(
                hintcolor: Color(0xff505050),
                controller: newpassword,
                isShow: true,
                hintText: 'Enter New Password',
                inputFormatters: [],
              ),
              SizedBox(
                height: height * 0.02,
              ),
              Container(
                height: 0.5,
                color: klightGrey.withOpacity(0.6),
              ),
              CostumeTextFiled(
                hintcolor: Color(0xff505050),
                controller: conpassword,
                isShow: true,
                hintText: 'Enter Confirm Password',
                // keyboardType: TextInputType.phone,
                inputFormatters: [],
              ),
              SizedBox(
                height: height * 0.3,
              ),
              conpassword.text.isEmpty || newpassword.text.isEmpty || currPassword.text.isEmpty
                  ? DisableButton(text: "Save")
                  : CostumeButton(
                      onTap: () async {
                        if (_validate(
                          currentPassword: currPassword.text,
                          newPassword: newpassword.text,
                          confirmNewPassword: conpassword.text,
                        )) await ChangePassword();
                      },
                      text: 'Save',
                    ),
              SizedBox(
                height: height * 0.02,
              ),
            ],
          ),
        ),
      ),
    );
  }

  _validate({
    required String currentPassword,
    required String newPassword,
    required String confirmNewPassword,
  }) {
    if (newPassword.length < 8) {
      Toasty.showtoast('New Password must be 8 character');
      return false;
    } else if (confirmNewPassword.length < 8) {
      Toasty.showtoast('Confirm New Password must be 8 character');
      return false;
    } else if (confirmNewPassword.length < 8 != newPassword.length < 8) {
      Toasty.showtoast('Password dose not match');
      return false;
    } else if (confirmNewPassword != newPassword) {
      Toasty.showtoast("Password dose not match");
      return false;
    } else {
      return true;
    }
  }
}
