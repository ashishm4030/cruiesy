import 'package:cruisy/Constant/constant.dart';
import 'package:cruisy/Widgets/Text_Widget.dart';
import 'package:flutter/material.dart';

class CostumeButton extends StatelessWidget {
  final String text;
  var onTap;

  CostumeButton({required this.text, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Align(
        alignment: Alignment.center,
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 20),
          height: 50,
          decoration: BoxDecoration(color: kPrimaryColor, borderRadius: BorderRadius.circular(10)),
          child: Center(
              child: RegularText(
            text,
            color: Colors.white,
            fontFamily: '',
            fontSize: 18,
          )),
        ),
      ),
    );
  }
}

class DisableButton extends StatelessWidget {
  final String text;
  const DisableButton({Key? key, required this.text}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Align(
        alignment: Alignment.center,
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 20),
          height: 50,
          decoration: BoxDecoration(color: Color(0xff111232), borderRadius: BorderRadius.circular(10)),
          child: Center(
            child: RegularText(
              text,
              color: klightGrey,
              fontSize: 18,
            ),
          ),
        ),
      ),
    );
  }
}

class SocialButton extends StatelessWidget {
  final String imagePath;
  final String socialText;
  final Color? color;
  final Color? backgroundcolor;
  var onTap;

  SocialButton({
    required this.imagePath,
    required this.socialText,
    this.onTap,
    this.color,
    this.backgroundcolor,
  });
  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 15, left: 20, right: 20),
        padding: EdgeInsets.symmetric(horizontal: 40),
        height: height * 0.062,
        decoration: BoxDecoration(
          color: backgroundcolor,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              imagePath,
              height: height * 0.035,
            ),
            // Spacer(),
            SizedBox(width: 30),
            RegularText(
              socialText,
              color: color,
              fontFamily: '',
            )
          ],
        ),
      ),
    );
  }
}

class DetailsWidget extends StatelessWidget {
  final String text;
  var onTap;
  Widget? child;
  Color color;
  Color textColor;
  double fontSize;

  DetailsWidget({required this.text, this.onTap, this.child, required this.color, required this.textColor, this.fontSize = 17});

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 15),
            width: width,
            decoration: BoxDecoration(
              color: color,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                RegularText(
                  text,
                  fontSize: fontSize,
                  color: textColor,
                ),
                Container(
                  child: child,
                ),
              ],
            ),
          ),
          Container(
            height: 0.5,
            color: klightGrey.withOpacity(0.6),
          ),
        ],
      ),
    );
  }
}
