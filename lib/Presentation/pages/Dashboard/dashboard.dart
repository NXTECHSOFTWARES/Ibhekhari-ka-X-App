import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:community_material_icon/community_material_icon.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nxbakers/Common/AppData.dart';
import 'package:nxbakers/Common/Widgets/reusable_text_widget.dart';
import 'package:nxbakers/Presentation/ViewModels/pastry_viewmodel.dart';
import 'package:nxbakers/Presentation/pages/DailyEntry/daily_inventory_entry.dart';
import 'package:nxbakers/Presentation/pages/HomePage/homepage.dart';
import 'package:nxbakers/Presentation/pages/Ingridient/Ingredients.dart';
import 'package:nxbakers/Presentation/pages/Pastries/add_new_pastry.dart';
import 'package:nxbakers/Presentation/pages/Pastries/low_stock_details_page.dart';
import 'package:nxbakers/Presentation/pages/Profits/profit.dart';
import 'package:nxbakers/Presentation/pages/Settings/notification_settings_page.dart';
import 'package:provider/provider.dart';

import '../../../Domain/Services/background_task_service.dart';
import '../../ViewModels/daily_entry_viewmodel.dart';
import '../../ViewModels/stats_viewmodel.dart';
import '../DailyEntry/add_daily_entries.dart';
import '../Pastries/pastries.dart';

import '../Statistics/stats_dashboard.dart';
import 'Utils/WIdgets/custom_drawer.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  int _selectedIndex = 0;

  final List<Widget> listOfPages = [
    const Homepage(),
    ChangeNotifierProvider(
      create: (BuildContext context) => DailyEntryViewModel()..initialize(),
      child: const DailyInventoryEntry(),
    ),
    ChangeNotifierProvider(
      create: (context) => StatsViewModel(),
      child: DailySalesStatsPage(),
    ),
    ChangeNotifierProvider(
      create: (BuildContext context) => PastryViewModel()..loadPastries(),
      child: const PastriesPage(),
    ),
  ];

  @override
  void initState() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      drawerScrimColor: Colors.black54,
      floatingActionButtonAnimator: FloatingActionButtonAnimator.scaling,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Container(
        width: 80.w,
        height: 80.h,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(colors: const [
            Color(0xffC99448),
            Color(0xff634923),
          ], radius: 0.45.r),
        ),
        child: IconButton(
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) => ChangeNotifierProvider(
                create: (BuildContext context) => DailyEntryViewModel()..loadPastries(),
                child: const AddDailyEntries(),
              ),
            );
          },
          icon: Icon(
            Icons.add_rounded,
            size: 38.w,
            color: Colors.white,
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
          color: const Color(0xff351F00),
          shape: const CircularNotchedRectangle(),
          notchMargin: 10,
          padding: EdgeInsets.zero,
          clipBehavior: Clip.antiAlias,
          child: Stack(
            children: [
              SizedBox(
                width: size.width,
                height: 80.h,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      width: 80.w,
                      height: 30.h,
                      decoration: BoxDecoration(
                        color: const Color(0xff573E1A).withOpacity(0.25),
                        borderRadius: BorderRadius.only(topRight: Radius.circular(50.r))
                      ),
                    ),
                    Container(
                      width: 80.w,
                      height: 30.h,
                      decoration: BoxDecoration(
                          color: const Color(0xff573E1A).withOpacity(0.25),
                          borderRadius: BorderRadius.only(topLeft: Radius.circular(50.r))
                      ),
                    ),
                  ],
                ),
              ),

              Container(
                padding: EdgeInsets.symmetric(horizontal: 15.0.w),
                width: size.width,
                height: 80.h,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Wrap(
                      spacing: 20.w,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      direction: Axis.horizontal,
                      children: [
                        /**
                         * Home Page
                         */
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedIndex = 0;
                            });
                          },
                          child: Wrap(
                            direction: Axis.vertical,
                            alignment: WrapAlignment.center,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            spacing: 5.h,
                            children: [
                              Container(
                                padding: EdgeInsets.all(5.w),
                                decoration: BoxDecoration(
                                  color: const Color(0xff351F00),
                                  borderRadius: BorderRadius.circular(5.r),
                                  border: Border.all(
                                    color: _selectedIndex == 0 ? const Color(0xffF3D4A9) : const Color(0xffAA9C88),
                                    width: 1.0.w,
                                  ),
                                ),
                                child: Icon(
                                  color: _selectedIndex == 0 ? const Color(0xffF3D4A9) : const Color(0xffAA9C88),
                                  _selectedIndex == 0 ? CommunityMaterialIcons.home : CommunityMaterialIcons.home_outline,
                                  size: 20.w,
                                ),
                              ),
                              // _selectedIndex == 0 ? ReusableTextWidget(text: "Home", color: Colors.white, size: xsFontSize) : const SizedBox()
                            ],
                          ),
                        ),
                        /**
                         * Daily Sales Page
                         */
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedIndex = 1;
                            });
                          },
                          child: Wrap(
                            direction: Axis.vertical,
                            alignment: WrapAlignment.center,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            spacing: 5.h,
                            children: [
                              Container(
                                padding: EdgeInsets.all(5.w),
                                decoration: BoxDecoration(
                                  color: Colors.transparent,
                                  borderRadius: BorderRadius.circular(5.r),
                                  border: Border.all(
                                    color: _selectedIndex == 1 ? const Color(0xffF3D4A9) : const Color(0xffAA9C88),
                                    width: 1.0.w,
                                  ),
                                ),
                                child: Icon(
                                  color: _selectedIndex == 1 ? const Color(0xffF3D4A9) : const Color(0xffAA9C88),
                                  _selectedIndex == 1 ? CommunityMaterialIcons.clipboard_list : CommunityMaterialIcons.clipboard_list_outline,
                                  size: 20.w,
                                ),
                              ),
                            //  _selectedIndex == 1 ? ReusableTextWidget(text: "Sales", color: Colors.white, size: xsFontSize) : const SizedBox()
                            ],
                          ),
                        ),
                        /**
                           * Statistics Page
                         */
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedIndex = 2;
                            });
                          },
                          child: Wrap(
                            direction: Axis.vertical,
                            alignment: WrapAlignment.center,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            spacing: 5.h,
                            children: [
                              Container(
                                padding: EdgeInsets.all(5.w),
                                decoration: BoxDecoration(
                                  color: Colors.transparent,
                                  borderRadius: BorderRadius.circular(5.r),
                                  border: Border.all(
                                    color: _selectedIndex == 2 ? const Color(0xffF3D4A9) : const Color(0xffAA9C88),
                                    width: 1.0.w,
                                  ),
                                ),
                                child: Icon(
                                  color: _selectedIndex == 2 ? const Color(0xffF3D4A9) : const Color(0xffAA9C88),
                                  _selectedIndex == 2 ? CommunityMaterialIcons.chart_line_stacked : CommunityMaterialIcons.chart_line,
                                  size: 20.w,
                                ),
                              ),
                             // _selectedIndex == 2 ? ReusableTextWidget(text: "Sales", color: Colors.white, size: xsFontSize) : const SizedBox()
                            ],
                          ),
                        ),
                      ],
                    ),
                    Wrap(
                      spacing: 20.w,
                      direction: Axis.horizontal,
                      children: [
                        /**
                         * Pastries Page
                         */
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedIndex = 3;
                            });
                          },
                          child: Wrap(
                            direction: Axis.vertical,
                            alignment: WrapAlignment.center,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            spacing: 5.h,
                            children: [
                              Container(
                                padding: EdgeInsets.all(5.w),
                                decoration: BoxDecoration(
                                  color: Colors.transparent,
                                  borderRadius: BorderRadius.circular(5.r),
                                  border: Border.all(
                                    color: _selectedIndex == 4 ? const Color(0xffF3D4A9) : const Color(0xffAA9C88),
                                    width: 1.0.w,
                                  ),
                                ),
                                child: Icon(
                                  color: _selectedIndex == 3 ? const Color(0xffF3D4A9) : const Color(0xffAA9C88),
                                  _selectedIndex == 3 ? CommunityMaterialIcons.cake : Icons.cake_outlined,
                                  size: 20.w,
                                ),
                              ),
                              // _selectedIndex == 0 ? ReusableTextWidget(text: "Home", color: Colors.white, size: xsFontSize) : const SizedBox()
                            ],
                          ),
                        ),
                        /**
                         * Ingredients Page
                         */
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedIndex = 5;
                            });
                          },
                          child: Wrap(
                            direction: Axis.vertical,
                            alignment: WrapAlignment.center,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            spacing: 5.h,
                            children: [
                              Container(
                                padding: EdgeInsets.all(5.w),
                                decoration: BoxDecoration(
                                  color: Colors.transparent,
                                  borderRadius: BorderRadius.circular(5.r),
                                  border: Border.all(
                                    color: _selectedIndex == 5 ? const Color(0xffF3D4A9) : const Color(0xffAA9C88),
                                    width: 1.0.w,
                                  ),
                                ),
                                child: Icon(
                                  color: _selectedIndex == 5 ? const Color(0xffF3D4A9) : const Color(0xffAA9C88),
                                  _selectedIndex == 5 ? Icons.food_bank : Icons.food_bank_outlined,
                                  size: 20.w,
                                ),
                              ),
                              // _selectedIndex == 0 ? ReusableTextWidget(text: "Home", color: Colors.white, size: xsFontSize) : const SizedBox()
                            ],
                          ),
                        ),
                        /**
                         * Account Page
                         */
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedIndex = 6;
                            });
                          },
                          child: Wrap(
                            direction: Axis.vertical,
                            alignment: WrapAlignment.center,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            spacing: 5.h,
                            children: [
                              Container(
                                padding: EdgeInsets.all(5.w),
                                decoration: BoxDecoration(
                                  color: Colors.transparent,
                                  borderRadius: BorderRadius.circular(5.r),
                                  border: Border.all(
                                    color: _selectedIndex == 6 ? const Color(0xffF3D4A9) : const Color(0xffAA9C88),
                                    width: 1.0.w,
                                  ),
                                ),
                                child: Icon(
                                  color: _selectedIndex == 6 ? const Color(0xffF3D4A9) : const Color(0xffAA9C88),
                                  _selectedIndex == 6 ? CommunityMaterialIcons.account : CommunityMaterialIcons.account_outline,
                                  size: 20.w,
                                ),
                              ),
                              // _selectedIndex == 0 ? ReusableTextWidget(text: "Home", color: Colors.white, size: xsFontSize) : const SizedBox()
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          )

          // BottomNavigationBar(
          //   backgroundColor: const Color(0xff351F00),
          //   currentIndex: _selectedIndex,
          //   unselectedItemColor: const Color(0xffAA9C88),
          //   type: BottomNavigationBarType.fixed,
          //   showUnselectedLabels: false,
          //   selectedFontSize: 10.w,
          //   unselectedFontSize: 0,
          //   selectedItemColor: Colors.white,
          //   selectedLabelStyle: GoogleFonts.poppins(fontSize: 10.sp),
          //   onTap: (index) {
          //     setState(() {
          //       _selectedIndex = index;
          //     });
          //   },
          //   items: [
          //      BottomNavigationBarItem(
          //       icon: Icon(_selectedIndex == 0 ? CommunityMaterialIcons.home : CommunityMaterialIcons.home_outline),
          //       label: "Home",
          //     ),
          //     BottomNavigationBarItem(
          //       icon: Icon( _selectedIndex == 1 ? CommunityMaterialIcons.clipboard_list: CommunityMaterialIcons.clipboard_list_outline),
          //       label: "Sales",
          //     ),
          //      BottomNavigationBarItem(
          //       icon: Icon( _selectedIndex == 2 ? CommunityMaterialIcons.chart_line_stacked : CommunityMaterialIcons.chart_line),
          //       label: "Statistics",
          //     ),
          //      BottomNavigationBarItem(
          //       icon: Icon(CommunityMaterialIcons.currency_eur),
          //       label: "Profits",
          //     ),
          //      BottomNavigationBarItem(
          //        icon: Icon( _selectedIndex == 4 ? CommunityMaterialIcons.cash_usd : CommunityMaterialIcons.cash_usd_outline),
          //        label: "Profits",
          //     ),
          //      BottomNavigationBarItem(
          //       icon: Icon(_selectedIndex == 5 ? Icons.food_bank : Icons.food_bank_outlined),
          //       label: "Ingredients",
          //     ),
          //      BottomNavigationBarItem(
          //       icon: Icon(_selectedIndex == 6 ? CommunityMaterialIcons.account_outline : CommunityMaterialIcons.account_outline),
          //       label: "Account",
          //     ),
          //
          //   ],
          // ),
          ),
      body: Stack(
        children: [
          // Use IndexedStack instead of PageView to preserve widget state
          IndexedStack(
            index: _selectedIndex,
            children: listOfPages,
          ),
          // Align(
          //   alignment: Alignment.bottomCenter,
          //   child: Stack(
          //     alignment: AlignmentDirectional.bottomCenter,
          //     children: [
          //       SizedBox(
          //         width: size.width,
          //         height: 130.h,
          //
          //       ),
          //       // Container(
          //       //   width: size.width,
          //       //   height: 80.h,
          //       //   color: const Color(0xff351F00),
          //       // ),
          //       // BottomNavigationBar(
          //       //
          //       //   backgroundColor: const Color(0xff351F00),
          //       //   currentIndex: _selectedIndex,
          //       //   unselectedItemColor: const Color(0xffffffff),
          //       //   type: BottomNavigationBarType.fixed,
          //       //   showUnselectedLabels: false,
          //       //   selectedFontSize: 10.w,
          //       //   unselectedFontSize: 0,
          //       //   selectedLabelStyle: GoogleFonts.poppins(fontSize: 10.sp),
          //       //   onTap: (index) {
          //       //     setState(() {
          //       //       _selectedIndex = index;
          //       //     });
          //       //   },
          //       //   items: const [
          //       //     BottomNavigationBarItem(
          //       //       icon: Icon(CommunityMaterialIcons.home),
          //       //       label: "Home",
          //       //     ),
          //       //     BottomNavigationBarItem(
          //       //       icon: Icon(CommunityMaterialIcons.view_list),
          //       //       label: "Pastries",
          //       //     ),
          //       //     BottomNavigationBarItem(
          //       //       icon: Icon(CommunityMaterialIcons.clipboard_list),
          //       //       label: "Ingredients",
          //       //     ),
          //       //     BottomNavigationBarItem(
          //       //       icon: Icon(CommunityMaterialIcons.chart_line),
          //       //       label: "Statistics",
          //       //     ),
          //       //   ],
          //       // ),
          //       Positioned(
          //         top: -0.h,
          //         child: Container(
          //           width: 80.w,
          //           height: 80.h,
          //           decoration: BoxDecoration(
          //             shape: BoxShape.circle,
          //
          //             gradient: RadialGradient(
          //               colors: const [
          //                 Color(0xffC99448),
          //                 Color(0xff634923),
          //               ],
          //               radius: 0.45.r
          //             ),
          //           ),
          //           child: IconButton(
          //             onPressed: () {
          //               showDialog(
          //                 context: context,
          //                 builder: (context) => ChangeNotifierProvider(
          //                   create: (BuildContext context) => PastryViewModel()..loadPastries(),
          //                   child: const NewPastry(),
          //                 ),
          //               );
          //             },
          //             icon: Icon(
          //               Icons.add_rounded,
          //               size: 38.w,
          //               color: Colors.white,
          //             ),
          //           ),
          //         ),
          //       ),
          //     ],
          //   ),
          // ),
        ],
      ),
    );
  }

  Widget _buildQuickActionsMenu() {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: const Color(0xFFF2EADE),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20.r),
          topRight: Radius.circular(20.r),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.inventory_2, color: Color(0xFF573E1A)),
            title: const Text('Check Low Stock'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const LowStockDetailsPage(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.notifications_active, color: Color(0xFF573E1A)),
            title: const Text('Test Notifications'),
            onTap: () async {
              Navigator.pop(context);
              await BackgroundTaskService().checkNow();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Stock check complete')),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
