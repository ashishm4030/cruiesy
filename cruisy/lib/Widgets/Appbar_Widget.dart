import 'package:cruisy/Constant/constant.dart';
import 'package:flutter/material.dart';

class CostumeAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String text;
  var bool;

  CostumeAppBar({required this.text, this.bool});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: Visibility(
        visible: bool,
        child: InkWell(
          onTap: () {
            Navigator.pop(context);
          },
          child: Icon(
            Icons.arrow_back_outlined,
            color: Colors.white,
          ),
        ),
      ),
      title: Text(
        text,
        style: KAppBarStyle,
      ),
      backgroundColor: Color(0xff000000),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(60);
}
