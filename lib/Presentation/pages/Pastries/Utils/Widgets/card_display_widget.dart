import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nxbakers/Common/Widgets/reusable_text_widget.dart';

class CardDisplayWidget extends StatelessWidget {
  final String header;
  final String textValue;
  const CardDisplayWidget({super.key, required this.header, required this.textValue});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 5.h,
      direction: Axis.vertical,
      children: [
        ReusableTextWidget(
          text: header,
          color: const Color(0xffA1845C),
          size: 10,
          FW: FontWeight.w400,
        ),
        ReusableTextWidget(
          text: textValue,
          color: const Color(0xff553609),
          size: 10,
          FW: FontWeight.w500,
        ),
      ],
    );
  }
}
