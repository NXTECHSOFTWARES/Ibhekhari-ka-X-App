import 'package:flutter/material.dart';
import 'package:nxbakers/Common/AppData.dart';
import 'package:nxbakers/Common/Widgets/reusable_text_widget.dart';

class HeaderTextStyle extends StatelessWidget {
  final String text;

  const HeaderTextStyle({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return ReusableTextWidget(
      text: text,
      color: const Color(0xff351F00),
      size: xlFontSize,
      FW: lFontWeight,
    );
  }
}
