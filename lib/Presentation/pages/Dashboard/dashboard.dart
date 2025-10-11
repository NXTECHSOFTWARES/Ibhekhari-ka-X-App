import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:community_material_icon/community_material_icon.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nxbakers/Presentation/ViewModels/pastry_viewmodel.dart';
import 'package:nxbakers/Presentation/pages/DailyEntry/daily_inventory_entry.dart';
import 'package:nxbakers/Presentation/pages/HomePage/homepage.dart';
import 'package:nxbakers/Presentation/pages/Ingridient/Ingredients.dart';
import 'package:nxbakers/Presentation/pages/Pastries/low_stock_details_page.dart';
import 'package:nxbakers/Presentation/pages/Profits/profit.dart';
import 'package:nxbakers/Presentation/pages/Settings/notification_settings_page.dart';
import 'package:provider/provider.dart';

import '../../../Domain/Services/background_task_service.dart';
import '../../ViewModels/daily_entry_viewmodel.dart';
import '../Pastries/pastries.dart';

import 'Utils/WIdgets/custom_drawer.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  int _selectedIndex = 0;
  // Remove the scaffold key since we don't need programmatic control

  final List<Widget> listOfPages = [
    const Homepage(),
    ChangeNotifierProvider(
      create: (BuildContext context) => DailyEntryViewModel()..initialize(),
      child: const DailyInventoryEntry(),
    ),
    ChangeNotifierProvider(create: (BuildContext context) => PastryViewModel()..loadPastries(), child: const PastriesPage()),
    const IngredientsPage(),
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
      // Customize swipe behavior (optional)
      drawerEdgeDragWidth: MediaQuery.of(context).size.width, // Full screen swipe
      drawerScrimColor: Colors.black54, // Background dim when drawer is open
      // You can also control which gestures open the drawer
      // gestureDetectors: {
      //   const TypeMatcher<HorizontalDragGestureRecognizer>(): (recognizer) {
      //     return recognizer..minFlingVelocity = 100; // Adjust sensitivity
      //   },
      // },

      body: Stack(
        children: [
          PageView(
            scrollDirection: Axis.horizontal,
            scrollBehavior: const ScrollBehavior(),
            children: [listOfPages[_selectedIndex]],
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Stack(
              alignment: AlignmentDirectional.bottomCenter,
              children: [
                Container(
                  width: size.width,
                  height: 130.h,
                  color: Colors.transparent,
                ),
                Container(
                  width: size.width,
                  height: 80.h,
                  color: Colors.black,
                ),
                BottomNavigationBar(
                  backgroundColor: Colors.transparent,
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
                    BottomNavigationBarItem(icon: Icon(CommunityMaterialIcons.home), label: "Home"),
                    BottomNavigationBarItem(icon: Icon(CommunityMaterialIcons.view_list), label: "Pastries"),
                    BottomNavigationBarItem(icon: Icon(CommunityMaterialIcons.clipboard_list), label: "Ingredients"),
                    BottomNavigationBarItem(icon: Icon(CommunityMaterialIcons.chart_line), label: "Profit"),
                  ],
                ),
                Positioned(
                  top: -0.h,
                  child: Container(
                    width: 80.w,
                    height: 80.h,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                    child: IconButton(
                        onPressed: () {
                          // You can keep this as a menu button or change it back to plus
                          // For swipe-only, you might want to keep it as plus for other functionality
                          // Or remove the onPressed entirely if you don't need it
                        },
                        icon: Icon(
                          CommunityMaterialIcons.plus, // Changed back to plus
                          size: 32.w,
                        )),
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
            leading: Icon(Icons.inventory_2, color: Color(0xFF573E1A)),
            title: Text('Check Low Stock'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => LowStockDetailsPage(),
                ),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.notifications_active, color: Color(0xFF573E1A)),
            title: Text('Test Notifications'),
            onTap: () async {
              Navigator.pop(context);
              await BackgroundTaskService().checkNow();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Stock check complete')),
              );
            },
          ),
        ],
      ),
    );
  }
}