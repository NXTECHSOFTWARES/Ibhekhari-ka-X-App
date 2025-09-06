import 'package:community_material_icon/community_material_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nxbakers/Common/common_main.dart';
import 'package:nxbakers/Common/Widgets/reusable_text_widget.dart';
import 'package:nxbakers/Presentation/ViewModels/pastry_viewmodel.dart';
import 'package:nxbakers/Presentation/pages/HomePage/Widgets/display_widget.dart';
import 'package:nxbakers/Presentation/pages/Notifications/notifications.dart';
import 'package:provider/provider.dart';

import '../Pastries/add_new_pastry.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        bottom: PreferredSize(
          preferredSize: Size(size.width, 8.h),
          child: Container(),
        ),
        flexibleSpace:
            /**
         * App bar
         * */
            Container(
          width: size.width,
          height: 95.h,
          padding: EdgeInsets.only(top: 40.h, bottom: 15.h),
          color: const Color(0xffB7A284),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.0.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 195.w,
                  height: 40.h,
                  decoration: BoxDecoration(
                      color: const Color(0xffF5E6D2),
                      borderRadius: BorderRadius.circular(30.r)),
                  child: Row(
                    children: [
                      Padding(
                        padding:
                            EdgeInsets.fromLTRB(5.0.w, 5.0.w, 20.0.w, 5.0.w),
                        child: const CircleAvatar(
                          backgroundImage: AssetImage(
                              "assets/Images/default_pastry_img.jpg"),
                        ),
                      ),
                      Expanded(
                          child: Text(
                        "bread & cake bakery",
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.playfair(
                            fontWeight: FontWeight.w800,
                            fontSize: 12.sp,
                            color: const Color(0xff573E1A)),
                      ))
                    ],
                  ),
                ),
                Wrap(
                  spacing: 10.w,
                  children: [
                    GestureDetector(
                      child: Container(
                        width: 30.w,
                        height: 30.h,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xff5C4B32),
                        ),
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          onPressed: () {},
                          icon: Center(
                            child: Icon(
                              Icons.search,
                              size: 15.w,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                    /**
                     * Notification Button
                     */
                    GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(
                            context,  '/notifications'
                        );
                      },
                      child: Badge(
                        isLabelVisible: true,
                        label: const Text("2"),
                        backgroundColor: Colors.orange,
                        textColor: const Color(0xffffffff),
                        textStyle: GoogleFonts.poppins(fontSize: 8.sp),
                        //  padding: EdgeInsets.all(0.w),
                        child: Container(
                          width: 30.w,
                          height: 30.h,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(0xff5C4B32),
                          ),
                          child: IconButton(
                            padding: EdgeInsets.zero,
                            onPressed: () {},
                            icon: Center(
                              child: Icon(
                                CommunityMaterialIcons.bell,
                                size: 15.w,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      body: CommonMain(
        child: Column(
          children: [
            /**
             * Opening Record
             * */
            Container(
              height: 100.h,
              padding: EdgeInsets.fromLTRB(20.w, 15.h, 15.w, 8.h),
              color: const Color(0xffF2EADE),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    height: 40.h,
                    padding:
                        EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                    decoration: BoxDecoration(
                      color: const Color(0xff42321C),
                      borderRadius: BorderRadius.circular(6.r),
                    ),
                    child: const Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        //Opening Balance
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          // direction: Axis.vertical,
                          // spacing: 10.h,
                          children: [
                            ReusableTextWidget(
                              text: "OPENING BALANCE:",
                              size: 8,
                              FW: FontWeight.w300,
                              color: Colors.white,
                            ),
                            ReusableTextWidget(
                              text: "R 1 200",
                              size: 12,
                              FW: FontWeight.w500,
                              color: Color(0xffFFE4BD),
                            ),
                          ],
                        ),
                        /*
                      * Opening Date
                      * */
                        ReusableTextWidget(
                          text: "10 February 2025",
                          size: 10,
                          FW: FontWeight.w500,
                          color: Color(0xffFFE4BD),
                        ),
                      ],
                    ),
                  ),
                  /*
                   * Sales, Income, Expenses
                  * */
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      DisplayWidget(headerText: "SALES", subText: "R10 000"),
                      DisplayWidget(headerText: "INCOME", subText: "R1 000"),
                      DisplayWidget(headerText: "EXPENSES", subText: "R2 500"),
                    ],
                  )
                ],
              ),
            ),

            /**
             * Main feature buttons
             */
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 10.w,
                vertical: 15.h,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  /**
                   * Design BEGIN
                   */
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6.r),
                    child: Container(
                      width: 30.w,
                      height: 50.h,
                      color: const Color(0xff402E14).withOpacity(0.6),
                    ),
                  ),

                  /**
                   * Button FOR ADDING RECIPES
                   */
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10.r),
                    child: Container(
                      width: 74.w,
                      height: 60.h,
                      color: const Color(0xff402E14).withOpacity(0.8),
                      child: Center(
                        child: Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          spacing: 5.h,
                          direction: Axis.vertical,
                          children: [
                            Icon(
                              CommunityMaterialIcons.plus,
                              color: Colors.white,
                              size: 16.w,
                            ),
                            Text(
                              "RECIPE",
                              style: GoogleFonts.poppins(
                                  color: Colors.white, fontSize: 8.sp),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),

                  /**
                   * BUTTON FOR ADDING NEW INVENTORY
                   */
                  GestureDetector(
                    onTap: () {
                      showDialog<void>(
                        context: context,
                        //barrierDismissible: barrierDismissible,
                        // false = user must tap button, true = tap outside dialog
                        builder: (BuildContext dialogContext) {
                          return ChangeNotifierProvider(
                              create: (BuildContext context) =>
                                  PastryViewModel(),
                              child: const NewPastry());
                        },
                      );
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10.r),
                      child: Container(
                        width: 92.w,
                        height: 70.h,
                        color: const Color(0xff402E14),
                        child: Center(
                          child: Wrap(
                            crossAxisAlignment: WrapCrossAlignment.center,
                            spacing: 5.h,
                            direction: Axis.vertical,
                            children: [
                              Icon(
                                CommunityMaterialIcons.plus,
                                color: Colors.white,
                                size: 24.w,
                              ),
                              Text(
                                "INVENTORY",
                                style: GoogleFonts.poppins(
                                    color: Colors.white, fontSize: 10.sp),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  /**
                   * Button FOR ADDING INGREDIENTS
                   */
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10.r),
                    child: Container(
                      width: 74.w,
                      height: 60.h,
                      color: const Color(0xff402E14).withOpacity(0.8),
                      child: Center(
                        child: Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          spacing: 5.h,
                          direction: Axis.vertical,
                          children: [
                            Icon(
                              CommunityMaterialIcons.plus,
                              color: Colors.white,
                              size: 16.w,
                            ),
                            Text(
                              "INGREDIENT",
                              style: GoogleFonts.poppins(
                                  color: Colors.white, fontSize: 8.sp),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),

                  /**
                   * Design END
                   */
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6.r),
                    child: Container(
                      width: 30.w,
                      height: 50.h,
                      color: const Color(0xff402E14).withOpacity(0.6),
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
