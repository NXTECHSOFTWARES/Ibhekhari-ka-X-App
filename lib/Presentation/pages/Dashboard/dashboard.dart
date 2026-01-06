import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:community_material_icon/community_material_icon.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
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
import '../Pastries/pastries.dart';

import '../Stats/stats_dashboard.dart';
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
      create: (BuildContext context) => PastryViewModel()..loadPastries(),
      child: const PastriesPage(),
    ),
    ChangeNotifierProvider(
      create: (context) => StatsViewModel(),
      child: DailySalesStatsPage(),
    )
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
      drawerScrimColor: Colors.black54,
      body: Stack(
        children: [
          // Use IndexedStack instead of PageView to preserve widget state
          IndexedStack(
            index: _selectedIndex,
            children: listOfPages,
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Stack(
              alignment: AlignmentDirectional.bottomCenter,
              children: [
                Container(
                  width: size.width,
                  height: 130.h,

                ),
                Container(
                  width: size.width,
                  height: 80.h,
                  color: const Color(0xff351F00),
                ),
                BottomNavigationBar(
                  backgroundColor: const Color(0xff351F00),
                  currentIndex: _selectedIndex,
                  unselectedItemColor: const Color(0xffffffff),
                  type: BottomNavigationBarType.fixed,
                  showUnselectedLabels: false,
                  selectedFontSize: 10.w,
                  unselectedFontSize: 0,
                  selectedLabelStyle: GoogleFonts.poppins(fontSize: 10.sp),
                  onTap: (index) {
                    setState(() {
                      _selectedIndex = index;
                    });
                  },
                  items: const [
                    BottomNavigationBarItem(
                      icon: Icon(CommunityMaterialIcons.home),
                      label: "Home",
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(CommunityMaterialIcons.view_list),
                      label: "Pastries",
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(CommunityMaterialIcons.clipboard_list),
                      label: "Ingredients",
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(CommunityMaterialIcons.chart_line),
                      label: "Statistics",
                    ),
                  ],
                ),
                Positioned(
                  top: -0.h,
                  child: Container(
                    width: 80.w,
                    height: 80.h,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,

                      gradient: RadialGradient(
                        colors: const [
                          Color(0xffC99448),
                          Color(0xff634923),
                        ],
                        radius: 0.45.r
                      ),
                    ),
                    child: IconButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => ChangeNotifierProvider(
                            create: (BuildContext context) => PastryViewModel()..loadPastries(),
                            child: const NewPastry(),
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
                ),
              ],
            ),
          ),
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
