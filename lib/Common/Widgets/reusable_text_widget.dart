import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class ReusableTextWidget extends StatelessWidget {
  final String text;
  final Color color;
  final FontWeight? FW;
  final int size;

  const ReusableTextWidget(
      {super.key,
      required this.text,
      required this.color,
      this.FW,
      required this.size});

  @override
  Widget build(BuildContext context) {
    return Text(
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        text,
        style: GoogleFonts.roboto(
            color: color, fontSize: size.sp, fontWeight: FW));
  }
}
