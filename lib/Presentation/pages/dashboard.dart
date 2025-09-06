import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:community_material_icon/community_material_icon.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nxbakers/Presentation/ViewModels/pastry_viewmodel.dart';
import 'package:nxbakers/Presentation/pages/DailyEntry/daily_inventory_entry.dart';
import 'package:nxbakers/Presentation/pages/HomePage/homepage.dart';
import 'package:nxbakers/Presentation/pages/Ingridient/Ingredients.dart';
import 'package:nxbakers/Presentation/pages/Profits/profit.dart';
import 'package:provider/provider.dart';

import 'Pastries/list_of_pastries.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  int _selectedIndex = 0;
  final List<Widget> listOfPages = [
    const Homepage(),
    const DailyInventoryEntry(),
    ChangeNotifierProvider(
        create: (BuildContext context) => PastryViewModel(),
        child: const PastriesPage()),
    const IngredientsPage(),

  ];

  @override
  void initState() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
      body: Stack(
        children: [
          PageView(
            scrollDirection: Axis.horizontal ,
            scrollBehavior: const ScrollBehavior(

            ),
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
                    BottomNavigationBarItem(
                        icon: Icon(CommunityMaterialIcons.home), label: "Home"),
                    BottomNavigationBarItem(
                        icon: Icon(CommunityMaterialIcons.view_list),
                        label: "Pastries"),
                    BottomNavigationBarItem(
                        icon: Icon(CommunityMaterialIcons.clipboard_list),
                        label: "Ingredients"),
                    BottomNavigationBarItem(
                        icon: Icon(CommunityMaterialIcons.chart_line),
                        label: "Profit"),
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
                        onPressed: () {},
                        icon: Icon(
                          CommunityMaterialIcons.plus,
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
}
