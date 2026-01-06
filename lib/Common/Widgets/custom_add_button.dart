import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nxbakers/Common/AppData.dart';
import 'package:nxbakers/Common/Widgets/reusable_text_widget.dart';

class CustomAddButton extends StatelessWidget {
  final String buttonTitle;

  const CustomAddButton({super.key, required this.buttonTitle});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 34.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6.0.r),
        gradient: RadialGradient(
          colors: const [
            Color(0xff634923),
            Color(0xff351F00)
          ],
          radius: 4.r,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 22.w,
            height: 22.h,
            decoration: BoxDecoration(
              gradient: const RadialGradient(
                colors: [
                  Color(0xffAF8850),
                  Color(0xff482B02)
                ],
                radius: 0.6,
              ),
              borderRadius:
              BorderRadius.circular(4.r),
              border: Border.all(
                  color: const Color(0xff3F2808)),
            ),
            child: Center(
              child: Icon(
                Icons.add,
                size: 18.w,
                color: const Color(0xff422B0A),
              ),
            ),
          ),
          SizedBox(width: 25.w),
          Center(
            child: ReusableTextWidget(
              text: buttonTitle.toLowerCase(),
              color: Colors.white,
              size: sFontSize,
              FW: sFontWeight,
            ),
          )
        ],
      ),
    );
  }
}
