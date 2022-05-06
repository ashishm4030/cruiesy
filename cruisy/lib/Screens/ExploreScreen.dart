import 'dart:convert';

import 'package:cruisy/Constant/constant.dart';
import 'package:cruisy/Widgets/Text_Widget.dart';
import 'package:custom_info_window/custom_info_window.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:marker_icon/marker_icon.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Explore extends StatefulWidget {
  const Explore({Key? key}) : super(key: key);

  @override
  _ExploreState createState() => _ExploreState();
}

class _ExploreState extends State<Explore> {
  String dropdownValue = 'One';
  var locationLat, locationLong;
  GoogleMapController? _controller;
  CustomInfoWindowController _customInfoWindowController = CustomInfoWindowController();

  LatLng startLocation = LatLng(21.237271, 72.885496);

  Set<Marker> _marker = {};

  var homeScreenResponse;
  var homeScreenData;
  var nearByList = [];
  var imageList = [];

  HomeScreenData() async {
    final prefs = await SharedPreferences.getInstance();
    userToken = prefs.getString('UserToken');
    try {
      homeScreenResponse = await dio.post(
        map_data,
        options: Options(
          headers: {
            'Authorization': 'Bearer $userToken',
          },
        ),
      );

      homeScreenData = jsonDecode(homeScreenResponse.toString());
      if (homeScreenData["Status"] == 1) {
        setState(() {
          nearByList = homeScreenData['info'];
        });
      } else if (homeScreenData["code"] == 306) {
        setState(() {});
      } else {
        setState(() {});
      }
    } on DioError catch (e) {
      setState(() {});
    }
  }

  List title = ["Car", "Group", "Hotel Room", "Glory Hole", "My Place"];
  List image = ["assets/images/Car.png", "assets/images/Groupchat.png", "assets/images/Hotel.png", "assets/images/GloryHole.png", "assets/images/House.png"];
  var potext;
  addMarkers() async {
    for (var i = 0; i < nearByList.length; i++) {
      _marker.add(
        Marker(
          markerId: MarkerId(nearByList[i].toString()),
          position: LatLng(nearByList[i]["lattitude"], nearByList[i]["longitude"]),
          onTap: () {
            showDialog(
              context: context,
              barrierColor: Colors.transparent,
              builder: (ctx) => AlertDialog(
                contentPadding: EdgeInsets.all(10),
                actionsPadding: EdgeInsets.all(0),
                backgroundColor: Colors.transparent,
                elevation: 0,
                content: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 55),
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [BoxShadow(color: Colors.grey, spreadRadius: 0.5, blurRadius: 5, offset: Offset(0.5, 0))],
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: List.generate(
                        5,
                        (index) => Row(
                          children: [
                            SizedBox(
                              width: index == 1 ? 7 : 10,
                            ),
                            Image.asset(
                              image[index],
                              height: index == 1 ? 22 : 18,
                              width: index == 1 ? 22 : 18,
                            ),
                            SizedBox(
                              width: 5,
                            ),
                            RegularText(
                              title[index],
                              fontSize: 16,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
          icon: await MarkerIcon.downloadResizePictureCircle('$IMAGE_URL${nearByList[i]['profile_pic']}', size: 150, addBorder: true),
        ),
      );

      setState(() {});
    }
  }

  @override
  void initState() {
    get();
    super.initState();
  }

  get() async {
    await HomeScreenData();
    await addMarkers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        floatingActionButton: FloatingActionButton(
          backgroundColor: kPrimaryColor,
          onPressed: () {},
          child: Image.asset(
            'assets/images/MyLocation.png',
          ),
        ),
        body: Stack(
          children: [
            GoogleMap(
              zoomGesturesEnabled: true,
              compassEnabled: false,
              zoomControlsEnabled: false,
              myLocationButtonEnabled: false,
              initialCameraPosition: CameraPosition(
                target: startLocation,
                zoom: 14.0,
              ),
              markers: _marker,
              mapType: MapType.normal,
            ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                child: TextField(
                  maxLines: 1,
                  cursorColor: Colors.black,
                  keyboardType: TextInputType.text,
                  style: TextStyle(color: Colors.black, fontSize: 18),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    prefixIcon: GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Icon(
                        Icons.arrow_back,
                        color: Colors.black,
                      ),
                    ),
                    hintText: 'Search city or zip code',
                    hintStyle: TextStyle(color: Colors.black, fontSize: 16),
                    contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 0),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(40),
                      borderSide: BorderSide(color: Colors.white, width: 1.0),
                    ),
                    focusedBorder: kOutlineInputBorderBlack,
                    enabledBorder: kOutlineInputBorderBlack,
                    errorBorder: kOutlineInputBorderBlack,
                    focusedErrorBorder: kOutlineInputBorderBlack,
                  ),
                ),
              ),
            ),
          ],
        ));
  }
}
