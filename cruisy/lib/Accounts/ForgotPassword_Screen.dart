import 'dart:convert';

import 'package:country_code_picker/country_code_picker.dart';
import 'package:cruisy/Accounts/ResetPassword_Screem.dart';
import 'package:cruisy/Constant/constant.dart';
import 'package:cruisy/Widgets/Button_Widget.dart';
import 'package:cruisy/Widgets/Text_Widget.dart';
import 'package:cruisy/Widgets/Textfeild_Widget.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({Key? key}) : super(key: key);

  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> with SingleTickerProviderStateMixin {
  TextEditingController email = TextEditingController();
  TextEditingController phone = TextEditingController();
  TabController? _tabController;
  bool isLoading = false;

  @override
  void initState() {
    _tabController = TabController(length: 2, vsync: this);
    super.initState();
  }

  var forgotPasswordResponse;
  var forgotPasswordData;

  ForgotPassword() async {
    setState(() {
      isLoading = true;
    });
    try {
      forgotPasswordResponse = await dio.post(
        forgot_password,
        data: {
          'email_id': email.text,
          "phone_number": phone.text,
        },
      );

      forgotPasswordData = jsonDecode(forgotPasswordResponse.toString());

      if (forgotPasswordData['Status'] == 1) {
        setState(() {
          isLoading = false;
        });
        Toasty.showtoast(forgotPasswordData['Message']);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ResetPasswordScreen(
              email: email.text,
              Phoneno: phone.text,
            ),
          ),
        );
      }
      if (forgotPasswordData['Status'] == 3) {
        setState(() {
          isLoading = false;
        });
        Toasty.showtoast(forgotPasswordData['Message']);
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => ResetPasswordScreen(
                      email: email.text,
                      Phoneno: phone.text,
                    )));
      } else {
        setState(() {
          isLoading = false;
        });
        Toasty.showtoast(forgotPasswordData['Message']);
      }
    } on DioError catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  List<String> TabText = ['Email', 'Phone'];
  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    return ModalProgressHUD(
      inAsyncCall: isLoading,
      opacity: 0,
      child: Scaffold(
        backgroundColor: kbackgroundColor,
        body: Column(
          children: [
            SizedBox(
              height: height * 0.2,
            ),
            RegularText(
              "Forgot Password",
              fontSize: 22,
              color: Colors.white,
            ),
            SizedBox(
              height: height * 0.05,
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
                          inputFormatters: [],
                        ),
                        SizedBox(
                          height: height * 0.45,
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Container(
                          height: 1,
                          color: klightGrey.withOpacity(0.5),
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
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(
                          height: height * 0.45,
                        ),
                      ],
                    ),
                  ),
                ),
              ]),
            ),
            email.text.isEmpty && phone.text.isEmpty
                ? DisableButton(text: "Send")
                : CostumeButton(
                    onTap: () async {
                      await ForgotPassword();
                    },
                    text: 'Send',
                  ),
            SizedBox(
              height: height * 0.05,
            ),
          ],
        ),
      ),
    );
  }

  bool forgotvalidate({required String email}) {
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
}
