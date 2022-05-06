import 'package:cruisy/Constant/constant.dart';
import 'package:cruisy/Widgets/Appbar_Widget.dart';
import 'package:cruisy/Widgets/Text_Widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_share/flutter_share.dart';

class InviteFriendScreen extends StatefulWidget {
  const InviteFriendScreen({Key? key}) : super(key: key);

  @override
  _InviteFriendScreenState createState() => _InviteFriendScreenState();
}

class _InviteFriendScreenState extends State<InviteFriendScreen> {
  List<String> images1 = [
    'assets/images/p1.JPEG',
    'assets/images/p2.JPEG',
    'assets/images/p3.JPEG',
    'assets/images/p4.JPEG',
    'assets/images/p5.JPEG',
    'assets/images/p6.JPEG',
    'assets/images/p1.JPEG',
    'assets/images/p2.JPEG',
    'assets/images/p3.JPEG',
    'assets/images/p4.JPEG',
    'assets/images/p5.JPEG',
    'assets/images/p6.JPEG',
  ];

  Future<void> share() async {
    await FlutterShare.share(
      title: 'Example share',
      text: 'Invite Your Friends',
      linkUrl: 'https://flutter.dev/',
      chooserTitle: 'Example Chooser Title',
    );
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: GestureDetector(
        onTap: () {
          share();
        },
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 19),
          height: 50,
          width: double.infinity,
          decoration: BoxDecoration(
            color: kPrimaryColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(child: RegularText('Invite Friends', color: Colors.white, fontSize: 18)),
        ),
      ),
      backgroundColor: kbackgroundColor,
      appBar: CostumeAppBar(
        text: 'Invite Friends',
        bool: true,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 12),
        child: Column(
          children: [
            Center(
              child: RegularText(
                ' Invite Friends and get\n Premium for a Month',
                color: Colors.white,
                fontSize: 22,
              ),
            ),
            SizedBox(
              height: height * 0.02,
            ),
            Row(
              children: [
                RegularText(
                  'Invites · 15',
                  color: Colors.white,
                  fontSize: 13,
                ),
                Spacer(),
                RegularText(
                  '4 Pending',
                  color: kPrimaryColor,
                  fontSize: 13,
                ),
              ],
            ),
            SizedBox(
              height: height * 0.015,
            ),
            Expanded(
              child: Container(
                child: GridView.builder(
                  itemCount: images1.length,
                  reverse: false, //default
                  // controller: ScrollController(),
                  primary: false,
                  shrinkWrap: true,
                  padding: EdgeInsets.all(5.0),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    mainAxisSpacing: 10.0,
                    crossAxisSpacing: 17.0,
                  ),
                  itemBuilder: (BuildContext context, int index) {
                    return Stack(
                      children: [
                        Container(
                          height: height,
                          width: width,
                          decoration: BoxDecoration(shape: BoxShape.circle),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(50),
                            child: Image.asset(
                              images1[index],
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Positioned(
                          right: 4,
                          bottom: 5,
                          child: Image.asset(
                            'assets/images/Tick.png',
                            scale: 5,
                          ),
                        )
                      ],
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
