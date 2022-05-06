import 'package:age_calculator/age_calculator.dart';
import 'package:cruisy/Constant/constant.dart';
import 'package:cruisy/Widgets/Appbar_Widget.dart';
import 'package:cruisy/Widgets/Button_Widget.dart';
import 'package:cruisy/Widgets/Text_Widget.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

class AgeCheckScreen extends StatefulWidget {
  const AgeCheckScreen({Key? key}) : super(key: key);

  @override
  _AgeCheckScreenState createState() => _AgeCheckScreenState();
}

class _AgeCheckScreenState extends State<AgeCheckScreen> {
  String _selectedDate = '';

  var date;
  var birthdate;
  var eighteenPlus;

  DateDuration? duration;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: kbackgroundColor,
      appBar: CostumeAppBar(
        text: 'Age Check',
        bool: true,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          RegularText(
            'Which year were you born?',
            color: Colors.white,
            fontSize: 20,
          ),
          SizedBox(
            height: 10,
          ),
          RegularText(
            'You have to be 18+ to use this app',
            color: eighteenPlus == null
                ? kPrimaryColor
                : eighteenPlus > 18
                    ? Colors.white
                    : kPrimaryColor,
          ),
          SizedBox(
            height: 15,
          ),
          eighteenPlus == null
              ? DisableButton(text: 'LogIn')
              : eighteenPlus > 18
                  ? CostumeButton(
                      onTap: () {},
                      text: 'Login',
                    )
                  : DisableButton(text: 'LogIn'),
          SizedBox(
            height: 15,
          ),
          SizedBox(
            height: height * 0.4,
            child: SfDateRangePicker(
              view: DateRangePickerView.year,
              backgroundColor: Colors.white,
              onSelectionChanged: (value) {
                date = value.value.toString().split(" ")[0];

                DateTime birthday = DateTime.parse(date);
                duration = AgeCalculator.age(birthday);
                setState(() {
                  eighteenPlus = duration!.years;
                });
              },
              selectionMode: DateRangePickerSelectionMode.single,
              initialSelectedRange: PickerDateRange(DateTime.now().subtract(const Duration(days: 4)), DateTime.now().add(const Duration(days: 3))),
            ),
          ),
        ],
      ),
    );
  }
}
