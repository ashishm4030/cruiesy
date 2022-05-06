import 'dart:convert';

import 'package:cruisy/Accounts/LogInScreen.dart';
import 'package:cruisy/Constant/constant.dart';
import 'package:cruisy/Widgets/Button_Widget.dart';
import 'package:cruisy/Widgets/Text_Widget.dart';
import 'package:cruisy/Widgets/Textfeild_Widget.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

class ResetPasswordScreen extends StatefulWidget {
  final email;
  final Phoneno;
  const ResetPasswordScreen({Key? key, this.email, this.Phoneno}) : super(key: key);

  @override
  _ResetPasswordScreenState createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  TextEditingController OTP = TextEditingController();
  TextEditingController newpassword = TextEditingController();
  TextEditingController conpassword = TextEditingController();
  bool isLoading = false;
  var resetOtpResponse;
  var resetOtpData;

  ResetOTP() async {
    setState(() {
      isLoading = true;
    });
    try {
      resetOtpResponse = await dio.post(
        forgot_password,
        data: {
          'email_id': widget.email,
        },
      );

      resetOtpData = jsonDecode(resetOtpResponse.toString());

      if (resetOtpData['Status'] == 1) {
        setState(() {
          isLoading = false;
        });
        Toasty.showtoast(resetOtpData['Message']);
      } else {
        setState(() {
          isLoading = false;
        });
        Toasty.showtoast(resetOtpData['Message']);
      }
    } on DioError catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  var resetPasswordResponse;
  var resetPasswordData;

  ResetPassword() async {
    setState(() {
      isLoading = true;
    });
    try {
      resetPasswordResponse = await dio.post(reset_password, data: {
        'email_id': widget.email,
        'phone_number': widget.Phoneno,
        'temp_pass': OTP.text,
        'new_pass': newpassword.text,
      });

      resetPasswordData = jsonDecode(resetPasswordResponse.toString());

      if (resetPasswordData['Status'] == 1) {
        setState(() {
          isLoading = false;
        });
        Toasty.showtoast(resetPasswordData['Message']);
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LogInScreen()));
      }
      if (resetPasswordData['Status'] == 2) {
        setState(() {
          isLoading = false;
        });
        Toasty.showtoast(resetPasswordData['Message']);
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LogInScreen()));
      }
      if (resetPasswordData['Status'] == 0) {
        setState(() {
          isLoading = false;
        });
        Toasty.showtoast(resetPasswordData['Message']);
      }
    } on DioError catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
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
        body: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(
                height: height * 0.2,
              ),
              Center(
                child: RegularText(
                  'Reset Password',
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
                controller: OTP,
                isShow: false,
                hintText: 'Enter OTP',
                input: TextInputType.phone,
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
                inputFormatters: [],
              ),
              SizedBox(
                height: height * 0.03,
              ),
              GestureDetector(
                onTap: () {
                  ResetOTP();
                },
                child: RegularText(
                  "Reset OTP",
                  color: klightGrey,
                ),
              ),
              SizedBox(
                height: height * 0.3,
              ),
              CostumeButton(
                onTap: () async {
                  if (resetvalidate(otp: OTP.text, newpass: newpassword.text, confirmpass: conpassword.text)) await ResetPassword();
                },
                text: 'Submit',
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

  bool resetvalidate({required String otp, required String newpass, required String confirmpass}) {
    if (otp.isEmpty && newpass.isEmpty && confirmpass.isEmpty) {
      Toasty.showtoast('Please Enter Your Credentials');
      return false;
    } else if (otp.isEmpty) {
      Toasty.showtoast('Please Enter Your OTP');
      return false;
    } else if (newpass.isEmpty) {
      Toasty.showtoast('Please Enter Password');
      return false;
    } else if (confirmpass.isEmpty) {
      Toasty.showtoast('Please Enter Confirm Password');
      return false;
    } else if (newpass.length < 8) {
      Toasty.showtoast('Password Must Contains 8 Characters');
      return false;
    } else if (newpass != confirmpass) {
      Toasty.showtoast('Password Must Be Same');
      return false;
    } else {
      return true;
    }
  }
}
