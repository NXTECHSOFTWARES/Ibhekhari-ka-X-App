import 'package:community_material_icon/community_material_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nxbakers/Common/common_main.dart';
import 'package:nxbakers/Common/Widgets/reusable_text_widget.dart';
import 'package:nxbakers/Data/Model/daily_entry.dart';
import 'package:nxbakers/Data/Model/pastry.dart';
import 'package:nxbakers/Domain/Services/notification_history_service.dart';
import 'package:nxbakers/Domain/Services/notification_service.dart';
import 'package:nxbakers/Presentation/ViewModels/daily_entry_viewmodel.dart';
import 'package:nxbakers/Presentation/ViewModels/pastry_viewmodel.dart';
import 'package:nxbakers/Presentation/pages/DailyEntry/add_daily_entries.dart';
import 'package:nxbakers/Presentation/pages/DailyEntry/daily_inventory_entry.dart';
import 'package:nxbakers/Presentation/pages/HomePage/Widgets/display_widget.dart';
import 'package:nxbakers/Presentation/pages/Notifications/notifications.dart';
import 'package:nxbakers/Presentation/pages/Pastries/pastry_details.dart';
import 'package:nxbakers/Presentation/pages/baking_record_page.dart';
import 'package:provider/provider.dart';

import '../../../Common/AppData.dart';
import '../../../Common/color.dart';
import '../Inventory/update_or_add_inventory_page.dart';
import '../Pastries/add_new_pastry.dart';
import 'Widgets/stats_graph.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  final NotificationHistoryService _notificationHistoryService = NotificationHistoryService();
  final NotificationService _notificationService = NotificationService();
  int _unreadCount = 0;

  Future<void> _loadUnreadCount() async {
    final count = await _notificationHistoryService.getUnreadCount();
    if (mounted) {
      setState(() {
        _unreadCount = count;
      });
    }
  }

  List<double> _extractSalesData(DailyEntryViewModel viewModel) {
    if (viewModel.dailyEntriesFGroupByDate.isEmpty) {
      return [0, 0, 0, 0, 0, 0, 0, 0];
    }

    // Get the last period
    String periodKey = viewModel.dailyEntriesFGroupByDate.keys.last;
    Map<String, List<DailyEntry>> entries = viewModel.dailyEntriesFGroupByDate[periodKey]!;

    // Convert to list of daily totals
    return entries.values.map((dailyEntries) {
      return dailyEntries.fold(0.0, (sum, entry) => sum + entry.soldStock.toDouble());
    }).toList();
  }

  double _getPastryPrice(pastryId, List<Pastry> pastries) {
    List<Pastry> pastry = pastries.where((pastry) => pastry.id! == pastryId).toList();
    return pastry[0].price;
  }

  String _calculatePeriodTotal(Map<String, List<DailyEntry>> dailyEntries, List<Pastry> pastries) {
    double total = 0;
    dailyEntries.forEach((date, entries) {
      for (var entry in entries) {
        total += entry.soldStock * _getPastryPrice(entry.pastryId, pastries); // Adjust this based on your DailyEntry model
      }
    });
    return 'R${total.toStringAsFixed(2)}';
  }

  String _getTopSellerForPeriod(Map<String, List<DailyEntry>> dailyEntriesInPeriod, List<Pastry> pastries) {
    Map<String, int> pastrySales = {};

    dailyEntriesInPeriod.forEach((date, entries) {
      for (DailyEntry entry in entries) {
        String pastryName = pastries.where((pastry) => pastry.id! == entry.pastryId).firstOrNull?.title ?? "Unknown Pastry";

        pastrySales[pastryName] = (pastrySales[pastryName] ?? 0) + entry.soldStock;
      }
    });

    if (pastrySales.isEmpty) return "No Sales";

    // Find pastry with highest total sales
    String topSeller = pastrySales.entries.reduce((a, b) => a.value > b.value ? a : b).key;
    return topSeller;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
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
                 * Bakery Shop Name :-
                 */
                Container(
                  width: 195.w,
                  height: 40.h,
                  decoration: BoxDecoration(color: const Color(0xffF5E6D2), borderRadius: BorderRadius.circular(30.r)),
                  child: Row(
                    children: [
                      // Only the CircleAvatar is clickable
                      GestureDetector(
                        onTap: () {
                          Scaffold.of(context).openDrawer();
                        },
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(0.0.w, 5.0.w, 20.0.w, 5.0.w),
                          child: const CircleAvatar(
                            backgroundImage: AssetImage("assets/Images/default_pastry_img.jpg"),
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
        child: Container(
          width: size.width,
          height: size.height,
          color: const Color.fromRGBO(242, 234, 222, 1.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /**
               * Opening Record
               * */
              Container(
                height: 100.h,
                padding: EdgeInsets.fromLTRB(15.w, 15.h, 15.w, 8.h),
                color: const Color(0xffF2EADE),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    /**
                     * Opening Balance Design
                     */
                    Container(
                      height: 40.h,
                      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
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
                            headerText: "INCOME", subText: "R1 000", headerColor: const Color(0xff351F00), subTextColor: const Color(0xff6D6457)),
                        DisplayWidget(
                            headerText: "EXPENSES", subText: "R2 500", headerColor: const Color(0xff351F00), subTextColor: const Color(0xff6D6457)),
                      ],
                    )
                  ],
                ),
              ),
              /**
               * Main feature buttons
               */
              Container(
                width: size.width,
                padding: EdgeInsets.symmetric(
                  horizontal: 10.w,
                  vertical: 15.h,
                ),
                color: const Color(0xffE6DED3),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    /**
                     * Design BEGIN
                     */
                    GestureDetector(
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) =>  Container())),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(6.r),
                        child: Container(
                          width: 60.w,
                          height: 50.h,
                          color: const Color(0xff402E14).withOpacity(0.6),
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
                                  style: GoogleFonts.poppins(color: Colors.white, fontSize: 8.sp),
                                )
                              ],
                            ),
                          ),
                        ),
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
                                "INGREDIENTS",
                                style: GoogleFonts.poppins(color: Colors.white, fontSize: 8.sp),
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
                        showDialog(
                            context: context,
                            builder: (context) => ChangeNotifierProvider(
                                create: (BuildContext context) => PastryViewModel()..loadPastries(), child: const UpdateOrAddInventoryPage()));
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
                                  "RESTOCK",
                                  style: GoogleFonts.poppins(color: Colors.white, fontSize: 10.sp),
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
                                "FRESH BAKED",
                                style: GoogleFonts.poppins(color: Colors.white, fontSize: 8.sp),
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
                        width: 60.w,
                        height: 50.h,
                        color: const Color(0xff402E14).withOpacity(0.6),
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
                                "PASTRY",
                                style: GoogleFonts.poppins(color: Colors.white, fontSize: 8.sp),
                              )
                            ],
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
              Container(
                height: 30.h,
                color: Colors.black.withOpacity(0.15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context)=>  Container())),
                      child: ReusableTextWidget(
                        text: "Baking records",
                        color: iconColor,
                        size: sFontSize,
                        FW: lFontWeight,
                      ),
                    ),
                    TextButton(
                      onPressed: () {},
                      child: ReusableTextWidget(
                        text: "Restock records",
                        color: const Color(0xff553609),
                        size: sFontSize,
                        FW: lFontWeight,
                      ),
                    ),
                    TextButton(
                      onPressed: () {},
                      child: ReusableTextWidget(
                        text: "shelf life",
                        color: const Color(0xff553609),
                        size: sFontSize,
                        FW: lFontWeight,
                      ),
                    )
                  ],
                ),
              ),
              /**
               * Daily Entry Header
               */
              Expanded(
                child: ListView(
                  children: [
                    /**
                     * Daily Entry Header
                     */
                    Padding(
                      padding: EdgeInsets.fromLTRB(15.0.w, 15.0.h, 15.h, 10.h),
                      child: ReusableTextWidget(
                        text: "Daily Entry",
                        color: const Color(0xff573E1A),
                        size: xlFontSize,
                        FW: lFontWeight,
                      ),
                    ),
                    /**
                     * Daily Entry Recent Entry summary
                     */
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 20.h),
                      color: const Color(0xffE6DED3),
                      child: Container(
                        padding: EdgeInsets.fromLTRB(20.w, 10.h, 20.w, 3.5.h),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF2EADE),
                          borderRadius: BorderRadius.circular(8.r),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF362A1A).withOpacity(0.24),
                              spreadRadius: 0,
                              blurRadius: 3.r,
                              offset: Offset(0, 2.h),
                            ),
                          ],
                        ),
                        child: ChangeNotifierProvider(
                          create: (BuildContext context) => DailyEntryViewModel()..initialize(),
                          child: Consumer<DailyEntryViewModel>(
                            builder: (BuildContext context, DailyEntryViewModel viewModel, Widget? child) {
                              if (viewModel.isLoading) {
                                return const Center(child: CircularProgressIndicator());
                              }

                              if (viewModel.dailyEntriesFGroupByDate.isEmpty) {
                                return Expanded(
                                  child: Center(
                                    child: Wrap(
                                      alignment: WrapAlignment.center,
                                      crossAxisAlignment: WrapCrossAlignment.center,
                                      spacing: 30.w,
                                      children: [
                                        Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            ReusableTextWidget(
                                              text: "No daily sales records available".toUpperCase(),
                                              color: Colors.black,
                                              size: sFontSize,
                                              FW: FontWeight.w400,
                                            ),
                                            ReusableTextWidget(
                                              text: "please add new sales",
                                              color: primaryColor,
                                              size: xsFontSize,
                                              FW: FontWeight.w400,
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }
                              return _buildSummaryItem(viewModel);
                            },
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 15.h,
                    ),
                    /**
                     * Pastries Header
                     */
                    Padding(
                      padding: EdgeInsets.fromLTRB(15.0.w, 0.0.h, 15.h, 10.h),
                      child: ReusableTextWidget(
                        text: "Pastries",
                        color: const Color(0xff573E1A),
                        size: xlFontSize,
                        FW: lFontWeight,
                      ),
                    ),
                    /**
                     * Top 10 Pastries
                     */
                    ChangeNotifierProvider(
                      create: (BuildContext context) => PastryViewModel()..initialize(),
                      child: Consumer<PastryViewModel>(
                        builder: (BuildContext context, viewModel, Widget? child) {
                          return Container(
                            height: 135.h,
                            color: Colors.transparent,
                            padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 0.h),
                            child: viewModel.pastries.isEmpty
                                ? Expanded(
                                    child: Center(
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          ReusableTextWidget(
                                            text: "No PASTRIES AVAILABLE".toUpperCase(),
                                            color: Colors.black,
                                            size: lFontSize,
                                            FW: FontWeight.w400,
                                          ),
                                          ReusableTextWidget(
                                            text: "please add new pastries",
                                            color: primaryColor,
                                            size: sFontSize,
                                            FW: FontWeight.w400,
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                                : ListView.builder(
                                    shrinkWrap: true,
                                    padding: EdgeInsets.only(bottom: 10.w),
                                    physics: const AlwaysScrollableScrollPhysics(),
                                    scrollDirection: Axis.horizontal,
                                    itemCount: viewModel.pastries.length,
                                    itemBuilder: (context, index) {
                                      Pastry pastry = viewModel.pastries[index];
                                      return GestureDetector(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => PastryDetails(pastryId: pastry.id!),
                                            ),
                                          );
                                        },
                                        child: Container(
                                          margin: EdgeInsets.only(right: 15.w),
                                          width: 80.w,
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            children: [
                                              Container(
                                                height: 80.h,
                                                decoration: BoxDecoration(
                                                  image: DecorationImage(
                                                    image: pastry.imageBytes.isEmpty
                                                        ? const AssetImage("assets/Images/default_pastry_img.jpg") as ImageProvider
                                                        : MemoryImage(pastry.imageBytes!),
                                                    fit: BoxFit.cover,
                                                  ),
                                                  borderRadius: BorderRadius.circular(
                                                    10.r,
                                                  ),
                                                  border: Border.all(
                                                    width: 1.0.w,
                                                    color: const Color(0xff6D593D),
                                                  ),
                                                ),
                                              ),
                                              SizedBox(height: 5.h),
                                              ReusableTextWidget(
                                                text: pastry.title,
                                                color: const Color(0xff5D3700),
                                                size: sFontSize,
                                                FW: lFontWeight,
                                              ),
                                              ReusableTextWidget(
                                                text: "R${pastry.price.toStringAsFixed(2)}",
                                                color: iconColor,
                                                size: lFontSize,
                                                FW: xlFontWeight,
                                              )
                                            ],
                                          ),
                                        ),
                                      );
                                    }),
                          );
                        },
                      ),
                    ),
                    Container(
                      width: size.width,
                      height: 10.h,
                      color: const Color(0xffE6DED3),
                    ),
                    SizedBox(
                      height: 0.h,
                    ),
                    /**
                     * Statistics Header
                     */
                    Padding(
                      padding: EdgeInsets.fromLTRB(15.0.w, 15.0.h, 15.h, 5.h),
                      child: ReusableTextWidget(
                        text: "Statistics",
                        color: const Color(0xff573E1A),
                        size: xlFontSize,
                        FW: lFontWeight,
                      ),
                    ),
                    /**
                     * Statistics Graph
                     */
                    ChangeNotifierProvider(
                      create: (BuildContext context) => DailyEntryViewModel()..initialize(),
                      child: Consumer<DailyEntryViewModel>(
                        builder: (context, viewModel, child) {
                          List<double> salesData = _extractSalesData(viewModel);
                          final List<double> sampleData = [50, 75, 95, 110, 125, 115, 95, 75, 60, 70, 90, 115, 130, 125, 105, 85];

                          return DailyEntryStatsGraph(
                            dataPoints: sampleData,
                          );
                        },
                      ),
                    ),
                    SizedBox(
                      height: 10.h,
                    ),
                    Container(
                      width: size.width,
                      height: 10.h,
                      color: const Color(0xffE6DED3),
                    ),
                    /**
                     * Top Sellers Header
                     */
                    Padding(
                      padding: EdgeInsets.fromLTRB(15.0.w, 15.0.h, 15.h, 10.h),
                      child: ReusableTextWidget(
                        text: "Top Sellers",
                        color: const Color(0xff573E1A),
                        size: xlFontSize,
                        FW: lFontWeight,
                      ),
                    ),
                    /**
                     * Top 3 pastries making high profit
                     */
                    ChangeNotifierProvider(
                      create: (BuildContext context) => PastryViewModel()..initialize(),
                      child: Consumer(
                        builder: (BuildContext context, PastryViewModel viewModel, Widget? child) {
                          return Container(
                            width: size.width,
                            height: 115.h,
                            //  color: Colors.black,
                            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 15.h),
                            color: const Color(0xffE6DED3),
                            child: viewModel.pastries.isEmpty
                                ? Expanded(
                                    child: Center(
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          ReusableTextWidget(
                                            text: "No PASTRIES AVAILABLE".toUpperCase(),
                                            color: Colors.black,
                                            size: lFontSize,
                                            FW: FontWeight.w400,
                                          ),
                                          ReusableTextWidget(
                                            text: "please add new pastries",
                                            color: primaryColor,
                                            size: sFontSize,
                                            FW: FontWeight.w400,
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                                : ListView.builder(
                                    physics: const AlwaysScrollableScrollPhysics(),
                                    scrollDirection: Axis.horizontal,
                                    shrinkWrap: true,
                                    itemCount: 3,
                                    itemBuilder: (context, index) {
                                      final Pastry pastry = viewModel.pastries[index];
                                      return Container(
                                        width: 170.w,
                                        height: 86.h,
                                        margin: EdgeInsets.only(right: 10.w),
                                        decoration: BoxDecoration(
                                          color: const Color(0xffF2EADE),
                                          borderRadius: BorderRadius.circular(10.r),
                                        ),
                                        child: Column(
                                          children: [
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Container(
                                                  //width: 54.w,
                                                  height: 15.h,
                                                  margin: EdgeInsets.only(top: 5.h, left: 5.w),
                                                  padding: EdgeInsets.symmetric(horizontal: 3.w),
                                                  decoration: BoxDecoration(
                                                    borderRadius: BorderRadius.circular(15.r),
                                                    color: const Color(0xffCEC7BD),
                                                  ),
                                                  child: Row(
                                                    children: [
                                                      ReusableTextWidget(
                                                        text: pastry.title,
                                                        color: Colors.white,
                                                        size: 6,
                                                        FW: lFontWeight,
                                                      ),
                                                      SizedBox(
                                                        width: 5.w,
                                                      ),
                                                      CircleAvatar(
                                                        backgroundColor: Colors.white,
                                                        radius: 5.r,
                                                        child: Center(
                                                          child: ReusableTextWidget(
                                                            text: index.toString(),
                                                            color: const Color(0xff351F00),
                                                            size: 4,
                                                            FW: lFontWeight,
                                                          ),
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                )
                                              ],
                                            ),
                                            Expanded(
                                                child: Padding(
                                              padding: EdgeInsets.symmetric(horizontal: 10.0.w, vertical: 8.h),
                                              child: Row(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Row(
                                                    children: [
                                                      Wrap(
                                                        spacing: 5.h,
                                                        direction: Axis.vertical,
                                                        children: [
                                                          ReusableTextWidget(
                                                            text: "Price",
                                                            color: const Color(0xff351F00),
                                                            size: xsFontSize - 2,
                                                            FW: sFontWeight,
                                                          ),
                                                          ReusableTextWidget(
                                                            text: "Sales",
                                                            color: const Color(0xff351F00),
                                                            size: xsFontSize - 2,
                                                            FW: sFontWeight,
                                                          ),
                                                        ],
                                                      ),
                                                      SizedBox(
                                                        width: 25.w,
                                                      ),
                                                      Wrap(
                                                        spacing: 5.h,
                                                        direction: Axis.vertical,
                                                        children: [
                                                          ReusableTextWidget(
                                                            text: "R${pastry.price}0",
                                                            color: const Color(0xffAA9C88),
                                                            size: xsFontSize,
                                                            FW: lFontWeight,
                                                          ),
                                                          ReusableTextWidget(
                                                            text: "R11 200",
                                                            color: const Color(0xffAA9C88),
                                                            size: xsFontSize,
                                                            FW: lFontWeight,
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                  Padding(
                                                    padding: EdgeInsets.only(right: 25.w),
                                                    child: Column(
                                                      children: [
                                                        ReusableTextWidget(
                                                          text: "Sold",
                                                          color: const Color(0xff5D3700),
                                                          size: sFontSize,
                                                          FW: sFontWeight,
                                                        ),
                                                        SizedBox(
                                                          height: 2.h,
                                                        ),
                                                        ReusableTextWidget(
                                                          text: "1120",
                                                          color: const Color(0xffAA9C88),
                                                          size: xsFontSize,
                                                          FW: lFontWeight,
                                                        ),
                                                      ],
                                                    ),
                                                  )
                                                ],
                                              ),
                                            )),
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Container(
                                                  width: 84.w,
                                                  height: 20.h,
                                                  decoration: BoxDecoration(
                                                      color: Colors.black.withOpacity(0.35),
                                                      borderRadius:
                                                          BorderRadius.only(bottomLeft: Radius.circular(20.r), topRight: Radius.circular(50.r))),
                                                  child: Padding(
                                                    padding: EdgeInsets.symmetric(horizontal: 10.w),
                                                    child: Row(
                                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                      children: [
                                                        ReusableTextWidget(
                                                          text: "Profit",
                                                          color: const Color(0xffF2EADE),
                                                          size: xsFontSize - 2,
                                                          FW: sFontWeight,
                                                        ),
                                                        ReusableTextWidget(
                                                          text: "R5 600",
                                                          color: Colors.white,
                                                          size: xsFontSize,
                                                          FW: lFontWeight,
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                )
                                              ],
                                            )
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                          );
                        },
                      ),
                    ),
                    SizedBox(
                      height: 40.h,
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryItem(DailyEntryViewModel viewModel) {
    if (viewModel.dailyEntriesFGroupByDate.isEmpty) {
      return const SizedBox.shrink();
    }

    String periodKey = viewModel.dailyEntriesFGroupByDate.keys.last;
    Map<String, List<DailyEntry>> dailyEntriesInPeriod = viewModel.dailyEntriesFGroupByDate[periodKey]!;
    List<DailyEntry> entriesForDate = dailyEntriesInPeriod[periodKey]!;
    int totalItems = entriesForDate.fold(0, (sum, entry) => sum + entry.soldStock);

    // Calculate top seller for this period
    String periodTopSeller = _getTopSellerForPeriod(dailyEntriesInPeriod, viewModel.pastries);

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: 80.w,
              child: ReusableTextWidget(
                // text: DateFormat('d MMMM y').format(DateFormat('EEEE, d MMMM y').parse(date)),
                text: periodKey,
                color: const Color(0xFFA1845C),
                size: xsFontSize,
                FW: lFontWeight,
              ),
            ),
            Wrap(
              spacing: 20.w,
              children: [
                DisplayWidget(
                  headerText: "Total Sold",
                  subText: totalItems.toString(), // Actual count
                  headerColor: const Color(0xff6D593D),
                  subTextColor: const Color(0xff553609),
                ),
                DisplayWidget(
                  headerText: "Top Seller",
                  subText: periodTopSeller,
                  headerColor: const Color(0xff6D593D),
                  subTextColor: const Color(0xff553609),
                ),
                DisplayWidget(
                  headerText: "Total Sales",
                  subText: _calculatePeriodTotal(dailyEntriesInPeriod, viewModel.pastries),
                  headerColor: const Color(0xff6D593D),
                  subTextColor: const Color(0xff553609),
                ),
              ],
            ),
          ],
        ),
        SizedBox(
          height: 5.h,
        ),
        Container(
          width: double.infinity,
          height: 5.h,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8.r),
            color: const Color(0xFF000000).withOpacity(0.1),
          ),
        ),
      ],
    );
  }
}
