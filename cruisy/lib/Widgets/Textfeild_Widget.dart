import 'package:cruisy/Constant/constant.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CostumeTextFiled extends StatelessWidget {
  final String? hintText;
  final bool isShow;
  final Function(String)? onChanged;
  final TextEditingController? controller;
  final List<TextInputFormatter>? inputFormatters;
  final Function()? onTap;
  final Function? Validate;
  final Widget? prefix;
  final int? maxLength;
  var icon;
  bool readOnly;
  var suffix;
  final TextInputType? input;
  var validator;
  final Color? backcolor;
  final Color? hintcolor;
  double? fontSize;
  FocusNode? focusNode;

  CostumeTextFiled(
      {required this.isShow,
      this.icon,
      this.readOnly = false,
      this.suffix,
      this.input,
      this.hintText,
      this.onChanged,
      this.controller,
      this.inputFormatters,
      this.onTap,
      this.Validate,
      this.validator,
      this.prefix,
      this.backcolor,
      this.maxLength,
      this.hintcolor,
      this.fontSize,
      this.focusNode});
  bool color = false;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 0.5,
          color: klightGrey.withOpacity(0.6),
        ),
        TextFormField(
          readOnly: readOnly,
          autofocus: false,
          focusNode: focusNode,
          cursorColor: kPrimaryColor,
          validator: validator,
          onTap: onTap,
          inputFormatters: inputFormatters,
          onChanged: onChanged,
          keyboardType: input,
          obscureText: isShow,
          maxLength: maxLength,
          obscuringCharacter: '*',
          style: TextStyle(color: Colors.white),
          controller: controller,
          decoration: InputDecoration(
            counterText: '',
            hintText: hintText,
            prefix: prefix,
            contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 0),
            suffixIcon: icon,
            suffix: suffix,
            fillColor: backcolor,
            filled: true,
            hintStyle: TextStyle(color: hintcolor, fontSize: fontSize),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Color(0xff505050)),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Color(0xff505050)),
            ),
          ),
        ),
      ],
    );
  }
}
