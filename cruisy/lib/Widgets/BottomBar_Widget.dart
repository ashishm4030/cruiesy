import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cruisy/Constant/ads.dart';
import 'package:cruisy/Constant/constant.dart';
import 'package:cruisy/Screens/Favorites_Screen.dart';
import 'package:cruisy/Screens/Home_Screen.dart';
import 'package:cruisy/Screens/Messages_Screen.dart';
import 'package:cruisy/Screens/Profile_Scren.dart';
import 'package:cruisy/Screens/Store_Screen.dart';
import 'package:cruisy/Widgets/Text_Widget.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BottomBar extends StatefulWidget {
  const BottomBar({Key? key}) : super(key: key);

  @override
  _BottomBarState createState() => _BottomBarState();
}

var ProfilePic;

class _BottomBarState extends State<BottomBar> {
  int ButtonSelector = 2;
  var user_Token;
  var user_id;
  var userProfileResponse;
  var userProfileData;
  var profileData;
  late BannerAd _ad;
  bool _isAdLoaded = false;

  List<Widget> screen = [
    ProfileScreen(),
    MessagesScreen(),
    HomeScreen(),
    FavoritesScreen(),
    StoreScreen(),
  ];

  List<String> BottomIcon = [
    'assets/images/profile.png',
    'assets/images/Chats.png',
    'assets/images/Rectangle.png',
    'assets/images/Favourites.png',
    'assets/images/Store.png',
  ];


  List<String> Title = [
    'Profile',
    'Chats',
    'Home',
    'Favorites',
    'Store',
  ];

  GetInformation() async {
    final prefs = await SharedPreferences.getInstance();
    user_Token = prefs.getString('UserToken');
    user_id = prefs.getString('UserId');
    print("userId");
    print(user_id);
    print(user_Token);
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

  var updateUserResponse;
  var updateUserData;
  var user_token;

  UserIsOnlinein() async {
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
        setState(() {

        });
      } else {

      }
    } on DioError catch (e) {

    }
  }

  Future<bool> UserIsOnline() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    user_token = prefs.getString('UserToken');

    try {
      updateUserResponse = await dio.post(
        update_user_isonline,
        data: {
          'is_online': 0,
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $user_token',
          },
        ),
      );

      updateUserData = jsonDecode(updateUserResponse.toString());
      if (updateUserData["Status"] == 1) {
        setState(() {

        });
      } else {
        setState(() {

        });
      }
    } on DioError catch (e) {

      print(e.response);
    }
    return true;
  }

  AddLoad() async {
    _ad = BannerAd(
      adUnitId: AdHelper.bannerAdUnitId,
      size: AdSize.banner,
      request: AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) {
          setState(() {
            _isAdLoaded = true;
          });
        },
        onAdFailedToLoad: (ad, error) {

          ad.dispose();

        },
      ),
    );
    await _ad.load();
  }

  @override
  void initState() {
    AddLoad();
    UserIsOnlinein();
    GetInformation();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    return WillPopScope(
      onWillPop: () async {
        return UserIsOnline();
      },
      child: Scaffold(
        extendBody: true,
        bottomNavigationBar: Container(
          padding: EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: kbackgroundColor,
          ),
          height: isbusiness == 1 || isbusinessUnlimited == 1 ? 80 : 135,
          child: Stack(
            children: [
              Container(
                height: 80,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(
                    5,
                    (index) => InkWell(
                      onTap: () {
                        setState(() {
                          ButtonSelector = index;
                        });
                      },
                      child: Column(
                        children: [

                          index == 0
                              ? Container(
                                  height: 22,
                                  width: 22,
                                  decoration: BoxDecoration(shape: BoxShape.circle, color: klightGrey),
                                  child: ClipOval(
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
                                        ),
                                      ),
                                    ),
                                  ),
                                )
                              : Image.asset(
                                  BottomIcon[index],
                                  color: ButtonSelector == index ? kPrimaryColor : klightGrey,
                                  scale: 4.5,
                                ),
                          SizedBox(
                            height: index == 2 || index == 0 ? 11 : 6,
                          ),
                          // Spacer(),
                          RegularText(
                            Title[index],
                            color: ButtonSelector == index ? kPrimaryColor : klightGrey,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              isbusiness == 1 || isbusinessUnlimited == 1
                  ? Container()
                  : Positioned(
                      bottom: 0,
                      child: Container(
                        margin: EdgeInsets.symmetric(horizontal: 20),
                        height: _ad.size.height.toDouble(),
                        width: 330 ,
                        child: AdWidget(ad: _ad),
                      ),
                    )
            ],
          ),
        ),
        body: screen[ButtonSelector],
      ),
    );
  }
}

class ProfileButton extends StatelessWidget {
  final text;
  final Function()? onTap;
  const ProfileButton({Key? key, this.text, this.onTap}) : super(key: key);

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
            color: kbackgroundColor,
            padding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
            child: Row(
              children: [
                RegularText(
                  text,
                  fontSize: 17,
                  color: Colors.white,
                ),
                Spacer(),
                Icon(
                  Icons.arrow_forward,
                  color: Colors.white,
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
