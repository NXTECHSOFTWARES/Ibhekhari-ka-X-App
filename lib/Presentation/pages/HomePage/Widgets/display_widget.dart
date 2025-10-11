import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nxbakers/Common/AppData.dart';
import 'package:nxbakers/Common/Widgets/reusable_text_widget.dart';

class DisplayWidget extends StatelessWidget {
  final String headerText;
  final String subText;
  final Color headerColor;
  final Color subTextColor;

  const DisplayWidget({super.key, required this.headerText, required this.subText, required this.headerColor, required this.subTextColor});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      direction: Axis.vertical,
      crossAxisAlignment: WrapCrossAlignment.center,
      alignment: WrapAlignment.center,
      spacing: 5.h,
      children: [
        ReusableTextWidget(
          text: headerText,
          size: xsFontSize,
          FW: sFontWeight,
          color: headerColor,
        ),
        ReusableTextWidget(
          text: subText,
          size: sFontSize,
          FW: lFontWeight,
          color: subTextColor,
        ),
      ],
    );
  }
}
