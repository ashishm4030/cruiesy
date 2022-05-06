import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:age_calculator/age_calculator.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cruisy/Constant/constant.dart';
import 'package:cruisy/Screens/ProfileSetting_Screen.dart';
import 'package:cruisy/Screens/Store_Screen.dart';
import 'package:cruisy/Widgets/BottomBar_Widget.dart';
import 'package:cruisy/Widgets/Custom_Dropdown.dart';
import 'package:cruisy/Widgets/Text_Widget.dart';
import 'package:cruisy/Widgets/Textfeild_Widget.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:images_picker/images_picker.dart';
import 'package:intl/intl.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EditProfileScreen1 extends StatefulWidget {
  final username;
  const EditProfileScreen1({Key? key, this.username}) : super(key: key);

  @override
  _EditProfileScreen1State createState() => _EditProfileScreen1State();
}

class _EditProfileScreen1State extends State<EditProfileScreen1> {
  TextEditingController AboutMe = TextEditingController();
  TextEditingController Height = TextEditingController();
  TextEditingController Weight = TextEditingController();
  TextEditingController DisplayName = TextEditingController();
  TextEditingController Date = TextEditingController();
  int charLength = 0;
  int age_Tap = 0;
  int tattoos_Tap = 0;
  int piercings_Tap = 0;
  int NSFW_pics_Tap = 0;
  bool _is_show_age = false;
  bool _is_tattoos = false;
  bool _is_piercings = false;
  bool _is_NSFW_pics = false;
  File? _image;
  File? _image1;
  String? fileName;
  var Orientationn;
  var HIV;
  var Position;
  var Ethnicity;
  var RelationStatus;
  var BodyType;
  var BodyHair;
  var CockSize;
  var pickedDate;
  var user_Token;
  var user_id;
  var userProfileResponse;
  var userProfileData;
  var profileData;
  var Multipic;
  bool isLoading = false;
  var EditProfileResponse;
  var EditProfileData;
  var edtAccountData;
  var dateofbirth;

  final multiPicker = ImagePicker();

  List images = [];
  List imagePathList = [];

  final picker = ImagePicker();

  Future getImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    setState(() {
      _image = File(pickedFile!.path);

      if (_image != null) {
        fileName = _image!.path.split('/').last;
      }
    });
  }

  _onChanged(String value) {
    setState(() {
      charLength = value.length;
    });
  }

  var imageList = [];
  DateDuration? duration;
  var eighteenPlus;
  var bothListImage = [];

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

          DisplayName = TextEditingController(text: profileData["user_name"]);
          Height = TextEditingController(text: profileData["height"]);
          Weight = TextEditingController(text: profileData["weight"]);
          AboutMe = TextEditingController(text: profileData["about_me"]);
          Date = TextEditingController(text: profileData["last_tested_date"].toString().split("T")[0]);
          dateofbirth = profileData["date_of_birth"].toString().split("T")[0];
          DateTime birthday = DateTime.parse(dateofbirth);
          duration = AgeCalculator.age(birthday);
          setState(() {
            eighteenPlus = duration!.years;
          });

          ProfilePic = profileData["profile_pic"];

          Multipic = profileData["user_image"];

          age_Tap = profileData['is_show_age'];

          if (age_Tap == 1) {
            _is_show_age = true;
          } else {
            _is_show_age = false;
          }
          tattoos_Tap = profileData['tattoos'];

          if (tattoos_Tap == 1) {
            _is_tattoos = true;
          } else {
            _is_tattoos = false;
          }

          piercings_Tap = profileData['piercings'];

          if (piercings_Tap == 1) {
            _is_piercings = true;
          } else {
            _is_piercings = false;
          }

          NSFW_pics_Tap = profileData['accept_NSFW_pics'];

          if (NSFW_pics_Tap == 1) {
            _is_NSFW_pics = true;
          } else {
            _is_NSFW_pics = false;
          }

          BodyType = profileData['body_type'];
          BodyHair = profileData['body_hair'];
          CockSize = profileData['cock_size'].toString();
          Position = profileData['position'];
          Ethnicity = profileData['ethnicity'];
          RelationStatus = profileData['relationship_status'];
          Orientationn = profileData['orientation'];
          HIV = profileData['HIV_status'];
        });
        await ankitnet();
      }
      if (userProfileData['Status'] == 0) {
        Toasty.showtoast(userProfileData['Message']);
      }
    } on DioError catch (e) {}
  }

  EditProfile() async {
    setState(() {
      isLoading = true;
    });

    var formdata = FormData.fromMap({
      "no_profile_pic": "no Profile",
      "user_name": DisplayName.text,
      "about_me": AboutMe.text,
      "is_show_age": age_Tap,
      "body_type": BodyType,
      "body_hair": BodyHair,
      "position": Position,
      "ethnicity": Ethnicity,
      "orientation": Orientationn,
      "tattoos": tattoos_Tap,
      "piercings": piercings_Tap,
      "accept_NSFW_pics": NSFW_pics_Tap,
      "HIV_status": HIV,
      "last_tested_date": pickedDate,
      "relationship_status": RelationStatus,
      "weight": Weight.text,
      "height": Height.text,
      "profile_pic": _image != null ? await MultipartFile.fromFile(_image!.path, filename: _image!.path.split('/').last) : '',
    });

    for (var i = 0; i < imagePathList.length; i++) {
      var fileName = imagePathList[i].toString().split('/').last;

      formdata.files.addAll([
        MapEntry("image", await MultipartFile.fromFileSync("${imagePathList[i]}", filename: fileName)),
      ]);
    }
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
    }
  }

  ankitnet() {
    if (Multipic.isNotEmpty) {
      for (var i in Multipic) {
        setState(() {
          bothListImage.add(multiimagesankit(type: 1, image: "${i["image"]}", id: "${i["image_id"]}"));
        });
      }
    }

    for (var i in bothListImage) {}
  }

  ankitpic(List image) {
    if (image.isNotEmpty) {
      for (var js in image) {
        setState(() {
          bothListImage.add(multiimagesankit(type: 2, image: "${js}"));
        });
      }
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
    final width = MediaQuery.of(context).size.width;
    return WillPopScope(
      onWillPop: () {
        return EditProfile();
      },
      child: Scaffold(
        backgroundColor: kbackgroundColor,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          title: RegularText(
            'Edit Profile',
            fontSize: 18,
          ),
          leading: GestureDetector(
              onTap: () {
                EditProfile();
              },
              child: Icon(Icons.arrow_back)),
        ),
        body: ModalProgressHUD(
          inAsyncCall: isLoading,
          opacity: 0,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 15),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                          child: GridView.builder(
                        shrinkWrap: true,
                        padding: EdgeInsets.zero,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: bothListImage.isEmpty ? 2 : bothListImage.length + 2,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisSpacing: 5,
                          mainAxisExtent: 100,
                          childAspectRatio: 10,
                          crossAxisCount: 3,
                          mainAxisSpacing: 5,
                        ),
                        itemBuilder: (context, index) {
                          return index == 0
                              ? GestureDetector(
                                  onTap: () {
                                    getImage();
                                  },
                                  child: _image != null
                                      ? ClipRRect(
                                          borderRadius: BorderRadius.circular(10),
                                          child: Image.file(
                                            _image!,
                                            fit: BoxFit.cover,
                                            height: 100,
                                            width: 100,
                                          ),
                                        )
                                      : ClipRRect(
                                          borderRadius: BorderRadius.circular(10),
                                          child: CachedNetworkImage(
                                            imageUrl: "$IMAGE_URL/$ProfilePic",
                                            fit: BoxFit.cover,
                                            height: 100,
                                            width: 100,
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
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                )
                              : index == bothListImage.length + 1
                                  ? InkWell(
                                      splashColor: Colors.transparent,
                                      highlightColor: Colors.transparent,
                                      onTap: () {
                                        getMultiImages();
                                      },
                                      child: Container(
                                        alignment: Alignment.center,
                                        child: RegularText(
                                          "+ Add",
                                          color: Colors.white,
                                          fontFamily: "Regular",
                                          fontSize: 13,
                                        ),
                                        height: 120,
                                        decoration: BoxDecoration(color: Colors.grey.withOpacity(0.2), borderRadius: BorderRadius.circular(10)),
                                      ),
                                    )
                                  : ClipRRect(
                                      borderRadius: BorderRadius.circular(8.0),
                                      child: Container(
                                        child: GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              images.removeAt(index - 1);
                                            });
                                          },
                                          child: bothListImage[index - 1].type == 1
                                              ? CachedNetworkImage(
                                                  imageUrl: "$IMAGE_URL${bothListImage[index - 1].image}",
                                                  fit: BoxFit.cover,
                                                  height: 150,
                                                  width: 150,
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
                                                      ),
                                                    ],
                                                  ),
                                                )
                                              : Image.file(
                                                  File(bothListImage[index - 1].image),
                                                  height: 100,
                                                  width: 100,
                                                  fit: BoxFit.cover,
                                                ),
                                        ),
                                      ),
                                    );
                        },
                      )),
                    ],
                  ),
                ),
                ProfileSettingButton(
                  text: 'Display Name',
                  visible: false,
                  text1: '',
                  color: Color(0xff0d0d0d),
                  FontSize: 14,
                ),
                CostumeTextFiled(
                  fontSize: 14,
                  hintcolor: Colors.grey,
                  maxLength: 20,
                  controller: DisplayName,
                  isShow: false,
                  backcolor: kbackgroundColor,
                  hintText: 'Enter Your Name',
                  onChanged: _onChanged,
                  suffix: Text(
                    "${DisplayName.text.toString().length}/20",
                    style: TextStyle(color: Color(0xff505050)),
                  ),
                ),
                ProfileSettingButton(
                  text: 'About Me',
                  visible: false,
                  text1: '',
                  color: Color(0xff0d0d0d),
                  FontSize: 14,
                ),
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
                  hintText: 'Down to Earth',
                  controller: AboutMe,
                ),
                ProfileSettingButton(
                  text: 'Stats',
                  visible: false,
                  text1: '',
                  color: Color(0xff0d0d0d),
                  FontSize: 14,
                ),

                ProfileSettingButton(
                  text: 'Age',
                  visible: true,
                  text1: eighteenPlus.toString(),
                ),
                ProfileSettingButton(
                  text: 'Enter Your Height',
                  visible: false,
                  text1: '',
                  color: Color(0xff0d0d0d),
                  FontSize: 14,
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
                ProfileSettingButton(
                  text: 'Enter Your Weight',
                  visible: false,
                  text1: '',
                  color: Color(0xff0d0d0d),
                  FontSize: 14,
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
                CustomDropdown(
                  value: BodyType,
                  onChanged: (value) {
                    setState(() {
                      BodyType = value;
                    });
                  },
                  select: ['Bear', 'Muscle', 'Guy Next Door', 'Jock', 'Geek', 'Leather', 'Discreet', 'College', 'Otter', 'Military', 'Twink', 'Bisexual', 'Transgender'],
                  DropdownText: 'Body Type',
                  text: '',
                ),
                CustomDropdown(
                  value: BodyHair,
                  onChanged: (value) {
                    setState(() {
                      BodyHair = value;
                    });
                  },
                  select: ['Naturally Smooth', 'Light Hairy', 'Hairy', 'Very Hair', 'Shaved'],
                  DropdownText: 'Body Hair',
                  text: '',
                ),
                ToggleButton(
                  text: 'Tattoos',
                  isSwitched: _is_tattoos,
                  onChanged: (value) {
                    setState(() {
                      _is_tattoos = value;
                      if (_is_tattoos == true) {
                        tattoos_Tap = 1;
                      } else if (_is_tattoos == false) {
                        tattoos_Tap = 0;
                      }
                    });
                  },
                ),
                ToggleButton(
                  text: 'Piercings',
                  isSwitched: _is_piercings,
                  onChanged: (value) {
                    setState(() {
                      _is_piercings = value;
                      if (_is_piercings == true) {
                        piercings_Tap = 1;
                      } else if (_is_piercings == false) {
                        piercings_Tap = 0;
                      }
                    });
                  },
                ),
                Container(
                  height: 20,
                  color: Color(0xff0d0d0d),
                ),
                // CustomDropdown(
                //   value: CockSize,
                //   onChanged: (value) {
                //     print(value);
                //     setState(() {
                //       CockSize = value;
                //     });
                //   },
                //   select: ['1', '2', '3', '4', '5', '6', '7', '8', '9', '10', '11', '12', '13', '14'],
                //   DropdownText: 'Cock Size',
                //   text: '',
                // ),
                CustomDropdown(
                  value: Position,
                  onChanged: (value) {
                    setState(() {
                      Position = value;
                    });
                  },
                  select: ['Top', 'Bottom', 'Verse'],
                  DropdownText: 'Position',
                  text: '',
                ),
                CustomDropdown(
                  value: Ethnicity,
                  onChanged: (value) {
                    setState(() {
                      Ethnicity = value;
                    });
                  },
                  select: ['Caucasian', 'Latin Black', 'Asian', 'Mediterranean', 'Arab', 'Mixed', 'Other'],
                  DropdownText: 'Ethnicity',
                  text: '',
                ),
                CustomDropdown(
                  value: RelationStatus,
                  onChanged: (value) {
                    setState(() {
                      RelationStatus = value;
                    });
                  },
                  select: ['Single', "married"],
                  DropdownText: 'Relationship Status',
                  text: '',
                ),

                ProfileSettingButton(
                  text: 'Expectations',
                  visible: false,
                  text1: '',
                  color: Color(0xff0d0d0d),
                  FontSize: 14,
                ),
                CostumeTextFiled(
                  fontSize: 14,
                  hintcolor: Colors.white,
                  maxLength: 100,
                  isShow: false,
                  onChanged: _onChanged,
                  backcolor: kbackgroundColor,
                  hintText: 'Looking For',
                ),
                CostumeTextFiled(
                  fontSize: 14,
                  hintcolor: Colors.white,
                  maxLength: 100,
                  isShow: false,
                  onChanged: _onChanged,
                  backcolor: kbackgroundColor,
                  hintText: 'Meet At',
                ),
                ToggleButton(
                  text: 'Accept NSFW Pics',
                  isSwitched: _is_NSFW_pics,
                  onChanged: (value) {
                    setState(() {
                      isbusiness == 1 || isbusinessUnlimited == 1 ? _is_NSFW_pics = value : Toasty.showtoast("please Purchase");
                      if (_is_NSFW_pics == true) {
                        NSFW_pics_Tap = 1;
                      } else if (_is_NSFW_pics == false) {
                        NSFW_pics_Tap = 0;
                      }
                    });
                  },
                ),

                ProfileSettingButton(
                  text: 'Identity',
                  visible: false,
                  text1: '',
                  color: Color(0xff0d0d0d),
                  FontSize: 14,
                ),

                // CustomDropdown(
                //   value: Orientationn,
                //   onChanged: (value) {
                //     print(value);
                //     setState(() {
                //       Orientationn = value;
                //     });
                //   },
                //   select: ['Straight', 'Gay', 'Bisexual', 'Transgender'],
                //   DropdownText: 'Orientation',
                //   text: '',
                // ),
                CostumeTextFiled(
                  fontSize: 14,
                  hintcolor: Colors.white,
                  maxLength: 100,
                  isShow: false,
                  onChanged: _onChanged,
                  backcolor: kbackgroundColor,
                  hintText: 'Pronouns',
                ),
                ProfileSettingButton(
                  text: 'Sexual Health',
                  visible: false,
                  text1: '',
                  color: Color(0xff0d0d0d),
                  FontSize: 14,
                ),

                CustomDropdown(
                  value: HIV,
                  onChanged: (value) {
                    setState(() {
                      HIV = value;
                    });
                  },
                  select: ['Positive', 'Negative'],
                  DropdownText: 'HIV Status',
                  text: '',
                ),
                CostumeTextFiled(
                  readOnly: true,
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
                      String formattedDate1 = DateFormat('yyyy-MM-dd').format(pickedDate);

                      setState(() {
                        Date.text = formattedDate1;
                      });
                    } else {}
                  },
                  fontSize: 14,
                  hintcolor: Colors.white,
                  isShow: false,
                  controller: Date,
                  onChanged: _onChanged,
                  backcolor: kbackgroundColor,
                  hintText: 'Last Tested Date',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  bool showImage = false;

  Future getMultiImages() async {
    List<Media>? res = await ImagesPicker.pick(
      count: 5,
      pickType: PickType.image,
    );
    if (res != null) {
      for (var i in res) {
        setState(() {
          images.add(File(i.path));
          imagePathList.add(i.path);
        });
      }
    }
    ankitpic(imagePathList);
  }
}

class multiimagesankit {
  final type;
  final id;
  final image;
  multiimagesankit({this.id, this.type, this.image});
}
