import 'dart:convert';
import 'dart:io';

import 'package:age_calculator/age_calculator.dart';
import 'package:cruisy/Constant/constant.dart';
import 'package:cruisy/Widgets/Appbar_Widget.dart';
import 'package:cruisy/Widgets/BottomBar_Widget.dart';
import 'package:cruisy/Widgets/Button_Widget.dart';
import 'package:cruisy/Widgets/Text_Widget.dart';
import 'package:cruisy/Widgets/Textfeild_Widget.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({Key? key}) : super(key: key);

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  TextEditingController DisplayName = TextEditingController();
  TextEditingController Height = TextEditingController();
  TextEditingController Weight = TextEditingController();
  int set = 0;
  bool isSwitched = true;
  File? _image;
  String? fileName;
  final picker = ImagePicker();
  int charLength = 0;
  var EditProfileResponse;
  var EditProfileData;
  var user_Token;
  var user_id;
  var userProfileData;
  var userProfileResponse;
  bool isLoading = false;
  var profileData;
  DateDuration? duration;
  var eighteenPlus;
  var dateofbirth;

  EditProfile() async {
    final prefs = await SharedPreferences.getInstance();
    user_Token = prefs.getString('UserToken');
    print(user_Token);
    print("user_Token");
    setState(() {
      isLoading = true;
    });
    var formdata = FormData.fromMap({
      "no_profile_pic": "no Profile",
      "user_name": DisplayName.text,
      "is_show_age": set,
      "height": Height.text,
      "weight": Weight.text,
      "profile_pic": _image != null ? await MultipartFile.fromFile(_image!.path, filename: _image!.path.split('/').last) : '',
    });
    try {
      EditProfileResponse = await dio.post(
        edit_profile,
        data: formdata,
        options: Options(
          headers: {"Authorization": "Bearer $user_Token"},
        ),
      );
      print(EditProfileResponse);
      EditProfileData = jsonDecode(EditProfileResponse.toString());
      print(EditProfileData);
      if (EditProfileData["Status"] == 1) {
        UserIsOnline();
        setState(() {
          isLoading = false;
          setUserData();
        });
        Toasty.showtoast(EditProfileData["Message"]);

        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => BottomBar()));
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
    }
  }

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
    } on DioError catch (e) {}
  }

  Future getImage() async {
    final pickedFile = await picker.getImage(source: ImageSource.gallery);
    setState(() {
      _image = File(pickedFile!.path);

      if (_image != null) {
        fileName = _image!.path.split('/').last;
      }
    });
  }

  var user_token;
  var updateUserResponse;
  var updateUserData;

  UserIsOnline() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    user_token = prefs.getString('UserToken');

    try {
      updateUserResponse = await dio.post(
        update_user_isonline,
        data: {
          'is_online': 1,
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $user_token',
          },
        ),
      );

      updateUserData = jsonDecode(updateUserResponse.toString());
      if (updateUserData["Status"] == 1) {
        setState(() {});
      } else {}
    } on DioError catch (e) {}
  }

  _onChanged(String value) {
    setState(() {
      charLength = value.length;
    });
  }

  setUserData() async {
    await setPrefData(key: 'UserName', value: EditProfileData["data"]['user_name']);
  }

  @override
  void initState() {
    setState(() {});
    GetInformation();
    getUserToken();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Color(0xff0d0d0d),
      appBar: CostumeAppBar(
        text: 'Edit Profile',
        bool: true,
      ),
      body: ModalProgressHUD(
        inAsyncCall: isLoading,
        opacity: 0,
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                child: Column(
                  children: [
                    RegularText(
                      'Profile Photo',
                      fontFamily: 'Roboto',
                      color: Colors.white,
                    ),
                    GestureDetector(
                      onTap: () {
                        getImage();
                      },
                      child: _image == null
                          ? Container(
                              height: 120,
                              margin: EdgeInsets.symmetric(horizontal: 100, vertical: 12),
                              color: kbackgroundColor,
                              child: Image.asset(
                                'assets/images/add.png',
                                scale: 6,
                              ),
                            )
                          : Container(
                              height: 120,
                              width: 120,
                              margin: EdgeInsets.symmetric(horizontal: 100, vertical: 12),
                              color: kbackgroundColor,
                              child: Image.file(_image!, fit: BoxFit.cover)),
                    ),
                  ],
                ),
              ),
              TextFormField(
                maxLength: 15,
                controller: DisplayName,
                cursorColor: kPrimaryColor,
                onChanged: _onChanged,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  fillColor: Color(0xff0d0d0d),
                  counterText: '',
                  contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 0),
                  filled: true,
                  hintText: 'Display Name',
                  hintStyle: TextStyle(color: Colors.white, fontSize: 14),
                  suffix: Text(
                    "${DisplayName.text.toString().length}/15",
                    style: TextStyle(color: Color(0xff505050)),
                  ),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xff505050)),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xff505050)),
                  ),
                ),
              ),
              DetailsWidget(
                text: 'Others will see this on the grid...',
                color: kbackgroundColor,
                textColor: klightGrey,
              ),
              DetailsWidget(
                fontSize: 14,
                text: 'Stats',
                color: Color(0xff0d0d0d),
                textColor: Colors.white,
              ),
              DetailsWidget(
                text: 'Age',
                color: kbackgroundColor,
                textColor: Colors.white,
                child: Text(
                  eighteenPlus.toString(),
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.normal),
                ),
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
                        "${Height.text.toString().length}/20",
                        style: TextStyle(color: Color(0xff505050)),
                      ),
                      hintText: 'Height',
                      controller: Height,
                    ),
                  ],
                ),
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
                        "${Weight.text.toString().length}/20",
                        style: TextStyle(color: Color(0xff505050)),
                      ),
                      hintText: 'Weight',
                      controller: Weight,
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: height * 0.04,
              ),
              DisplayName.text.isEmpty || Height.text.isEmpty || Weight.text.isEmpty
                  ? DisableButton(
                      text: 'Next',
                    )
                  : CostumeButton(
                      text: 'Next',
                      onTap: () {
                        if (editProfile(DisplayName: DisplayName.text, Height: Height.text, Weight: Weight.text)) EditProfile();
                        // UserIsOnline();
                      },
                    ),
            ],
          ),
        ),
      ),
    );
  }

  bool editProfile({required String DisplayName, required String Height, required String Weight}) {
    if (DisplayName.isEmpty && Height.isEmpty && Weight.isEmpty) {
      Toasty.showtoast('Please Enter Your Credentials');

      return false;
    } else if (DisplayName.isEmpty) {
      Toasty.showtoast('Please Enter Your Display Name');

      return false;
    } else if (_image == null) {
      Toasty.showtoast('Please Select Profile Photo');
      return false;
    } else if (Height.isEmpty) {
      Toasty.showtoast('Please Enter Your Height');
      return false;
    } else if (Weight.isEmpty) {
      Toasty.showtoast('Please Enter Your Weight');
      return false;
    } else {
      return true;
    }
  }
}
