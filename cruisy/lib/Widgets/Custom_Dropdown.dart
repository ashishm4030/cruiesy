import 'package:cruisy/Constant/constant.dart';
import 'package:cruisy/Widgets/Text_Widget.dart';
import 'package:flutter/material.dart';

class CustomDropdown extends StatefulWidget {
  final String? text;
  final String? value;
  final double? width;
  final BoxBorder? border;
  final String? DropdownText;
  final List<String>? select;
  final Function(String?)? onChanged;
  bool PrimeMember;

  CustomDropdown({
    this.text,
    this.DropdownText,
    this.PrimeMember = false,
    this.select,
    this.value,
    this.onChanged,
    this.border,
    this.width,
  });

  @override
  CustomDropdownState createState() => CustomDropdownState();
}

class CustomDropdownState extends State<CustomDropdown> {
  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 0.5,
          color: klightGrey.withOpacity(0.5),
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 15),
          height: height * 0.07,
          width: widget.width,
          decoration: BoxDecoration(
            border: widget.border,
            color: kbackgroundColor,
          ),
          child: DropdownButton<String>(
            dropdownColor: klightGrey,
            focusColor: Colors.black,
            // decoration: InputDecoration(border: InputBorder.none),
            value: widget.value,
            isExpanded: true,
            underline: Container(),
            style: TextStyle(color: Colors.black),
            iconEnabledColor: Colors.black,
            icon: Icon(
              Icons.keyboard_arrow_down_rounded,
              color: Colors.white,
              size: 32,
            ),
            items: widget.select!.map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(
                  value,
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              );
            }).toList(),
            hint: RegularText(widget.DropdownText!, color: Colors.white, fontSize: 18, fontWeight: FontWeight.w500),
            onChanged: widget.onChanged,
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
