import 'package:flutter/material.dart';
import 'package:nxbakers/Common/AppData.dart';
import 'package:nxbakers/Common/Widgets/reusable_text_widget.dart';

class SubHeaderTextStyle extends StatelessWidget {
  final String text;
  const SubHeaderTextStyle({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return ReusableTextWidget(
      text: text,
      color: const Color(0xff634923),
      size: sFontSize,
      FW: sFontWeight,
    );
  }
}
