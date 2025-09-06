import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomFilterButton extends StatelessWidget {
  const CustomFilterButton({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return GestureDetector(
      onTap: () {
        showCupertinoModalPopup(
            context: context,
            builder: (context) {
              return HeroMode(
                  child: Container(
                    width: 100.w,
                    height: 150.h,
                    color: Colors.brown,
                  ));
            });
      },
      child: Container(
        width: size.width,
        height: 35.h,
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(),
            const Icon(
              Icons.menu_open,
              color: Color(0xffAA9C88),
            )
          ],
        ),
      ),
    );
  }
}
