import 'package:flutter/material.dart';
import 'package:nxbakers/Common/Widgets/reusable_text_widget.dart';

class DisplayWidget extends StatelessWidget {
  final String headerText;
  final String subText;

  const DisplayWidget({super.key, required this.headerText, required this.subText});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      direction: Axis.vertical,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        ReusableTextWidget(
          text: headerText,
          size: 10,
          FW: FontWeight.normal,
          color: const Color(0xff351F00),
        ),
        ReusableTextWidget(
          text: subText,
          size: 10,
          FW: FontWeight.w400,
          color: const Color(0xff6D6457),
        ),
      ],
    );
  }
}
