import 'package:community_material_icon/community_material_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nxbakers/Common/common_main.dart';
import 'package:nxbakers/Common/Widgets/reusable_text_widget.dart';
import 'package:nxbakers/Domain/Services/notification_history_service.dart';
import 'package:nxbakers/Domain/Services/notification_service.dart';
import 'package:nxbakers/Presentation/ViewModels/pastry_viewmodel.dart';
import 'package:nxbakers/Presentation/pages/HomePage/Widgets/display_widget.dart';
import 'package:nxbakers/Presentation/pages/Notifications/notifications.dart';
import 'package:provider/provider.dart';

import '../../../Common/AppData.dart';
import '../Inventory/inventory_page.dart';
import '../Pastries/add_new_pastry.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  final NotificationHistoryService _notificationHistoryService = NotificationHistoryService();
  final NotificationService _notificationService = NotificationService();
  int _unreadCount = 0;

  @override
  void initState() {
    super.initState();
    _loadUnreadCount();
  }

  Future<void> _loadUnreadCount() async {
    final count = await _notificationHistoryService.getUnreadCount();
    if (mounted) {
      setState(() {
        _unreadCount = count;
      });
    }
  }
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
         */
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
                /**
                 * Bakery Shop Name -
                 */
                Container(
                  width: 195.w,
                  height: 40.h,
                  decoration: BoxDecoration(
                      color: const Color(0xffF5E6D2),
                      borderRadius: BorderRadius.circular(30.r)),
                  child: Row(
                    children: [
                      // Only the CircleAvatar is clickable
                      GestureDetector(
                        onTap: () {
                          Scaffold.of(context).openDrawer();
                        },
                        child: Padding(
                          padding:
                          EdgeInsets.fromLTRB(0.0.w, 5.0.w, 20.0.w, 5.0.w),
                          child: const CircleAvatar(
                            backgroundImage: AssetImage(
                                "assets/Images/default_pastry_img.jpg"),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          "bread & cake bakery",
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.playfair(
                            fontWeight: xxlFontWeight,
                            fontSize: lFontSize.sp,
                            color: const Color(0xff573E1A),
                          ),
                        ),
                      )
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
                      onTap: () async {
                        await Navigator.push(context, MaterialPageRoute(builder: (context) => const NotificationsPage()));
                        _loadUnreadCount();
                      },
                      child: Badge(
                        isLabelVisible: _unreadCount > 0,
                        label: ReusableTextWidget(
                          text: _unreadCount > 99 ? "99+" : "$_unreadCount",
                          color: Colors.white,
                          size: xsFontSize,
                          FW: sFontWeight,
                        ),
                        backgroundColor: Colors.orange,
                        child: Container(
                          width: 30.w,
                          height: 30.h,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(0xff5C4B32),
                          ),
                          child: Icon(
                                CommunityMaterialIcons.bell,
                                size: 15.w,
                                color: Colors.white,
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
                  /**
                   * Opening Balance Design
                   */
                  Container(
                    height: 40.h,
                    padding:
                    EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                    decoration: BoxDecoration(
                      color: const Color(0xff42321C),
                      borderRadius: BorderRadius.circular(6.r),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        /**
                         * Opening Balance
                         */

                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ReusableTextWidget(
                              text: "OPENING BALANCE:",
                              size: xsFontSize,
                              FW: sFontWeight,
                              color: Colors.white,
                            ),
                            ReusableTextWidget(
                              text: "R 1 200",
                              size: lFontSize,
                              FW: xlFontWeight,
                              color: const Color(0xffFFE4BD),
                            ),
                          ],
                        ),
                        /*
                      * Opening Date
                      * */
                        ReusableTextWidget(
                          text: "10 February 2025",
                          size: sFontSize,
                          FW: xlFontWeight,
                          color: const Color(0xffFFE4BD),
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
                      DisplayWidget(
                        headerText: "SALES",
                        subText: "R10 000",
                        headerColor: const Color(0xff351F00),
                        subTextColor: const Color(0xff6D6457),
                      ),
                      DisplayWidget(
                          headerText: "INCOME",
                          subText: "R1 000",
                          headerColor: const Color(0xff351F00),
                          subTextColor: const Color(0xff6D6457)),
                      DisplayWidget(
                          headerText: "EXPENSES",
                          subText: "R2 500",
                          headerColor: const Color(0xff351F00),
                          subTextColor: const Color(0xff6D6457)),
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
                      // Navigate to Inventory Page
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChangeNotifierProvider(
                            create: (_) => PastryViewModel(),
                            child: const InventoryPage(),
                          ),
                        ),
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
                   * BUTTON FOR ADDING INGREDIENTS
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
            ),
            ElevatedButton(onPressed: (){
              _notificationService.testNotificationNavigation();

            }, child: Text("load notification test data"))
          ],
        ),
      ),
    );
  }
}