import 'package:community_material_icon/community_material_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nxbakers/Common/AppData.dart';
import 'package:nxbakers/Common/Widgets/reusable_text_widget.dart';
import 'package:nxbakers/Data/Model/pastry.dart';
import 'package:nxbakers/Presentation/ViewModels/pastry_viewmodel.dart';
import 'package:provider/provider.dart';

class InventoryPage extends StatefulWidget {
  const InventoryPage({super.key});

  @override
  State<InventoryPage> createState() => _InventoryPageState();
}

class _InventoryPageState extends State<InventoryPage> {
  final TextEditingController _searchController = TextEditingController();
  final Map<int, bool> _selectedItems = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PastryViewModel>().initialize();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final viewModel = context.watch<PastryViewModel>();

    return Scaffold(
      backgroundColor: const Color(0xffF5E6D2),
      appBar: AppBar(
        backgroundColor: const Color(0xff5C4B32),
        elevation: 0,
        toolbarHeight: 80.h,
        automaticallyImplyLeading: false,
        flexibleSpace: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 15.h),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ReusableTextWidget(
                      text: "OPENING BALANCE:",
                      size: xsFontSize,
                      FW: sFontWeight,
                      color: Colors.white,
                    ),
                    ReusableTextWidget(
                      text: "10 February 2025",
                      size: sFontSize,
                      FW: xlFontWeight,
                      color: const Color(0xffFFE4BD),
                    ),
                  ],
                ),
                SizedBox(height: 5.h),
                Align(
                  alignment: Alignment.centerLeft,
                  child: ReusableTextWidget(
                    text: "R 1 200",
                    size: xlFontSize,
                    FW: xxlFontWeight,
                    color: const Color(0xffFFE4BD),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // Inventory Header
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 15.h),
            color: const Color(0xffF5E6D2),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "INVENTORY",
                  style: GoogleFonts.poppins(
                    fontSize: lFontSize.sp,
                    fontWeight: xxlFontWeight,
                    color: const Color(0xff573E1A),
                  ),
                ),
                Container(
                  width: 30.w,
                  height: 30.h,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xff573E1A),
                  ),
                  child: Icon(
                    Icons.add,
                    size: 18.w,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),

          // Search Bar
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Container(
              height: 40.h,
              decoration: BoxDecoration(
                color: const Color(0xffE8D5BD),
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (value) {
                  viewModel.setSearchQuery(value);
                },
                decoration: InputDecoration(
                  hintText: "Search",
                  hintStyle: GoogleFonts.poppins(
                    fontSize: sFontSize.sp,
                    color: const Color(0xff8B7355),
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    size: 18.w,
                    color: const Color(0xff8B7355),
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 10.h),
                ),
              ),
            ),
          ),

          SizedBox(height: 10.h),

          // Info Text
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(
                "Number Of Stock In Inventory",
                style: GoogleFonts.poppins(
                  fontSize: xsFontSize.sp,
                  color: const Color(0xff8B7355),
                ),
              ),
            ),
          ),

          SizedBox(height: 5.h),

          // Total Count
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(
                "${viewModel.displayedPastries.length}",
                style: GoogleFonts.poppins(
                  fontSize: lFontSize.sp,
                  fontWeight: xxlFontWeight,
                  color: const Color(0xff573E1A),
                ),
              ),
            ),
          ),

          SizedBox(height: 10.h),

          // Instruction Text
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Text(
              "Select To Update Or Add New Pastry If Not Available",
              style: GoogleFonts.poppins(
                fontSize: xsFontSize.sp,
                color: const Color(0xff8B7355),
              ),
            ),
          ),

          SizedBox(height: 15.h),

          // Pastry List
          Expanded(
            child: viewModel.isLoading
                ? const Center(child: CircularProgressIndicator())
                : viewModel.displayedPastries.isEmpty
                ? Center(
              child: Text(
                "No pastries found",
                style: GoogleFonts.poppins(
                  fontSize: sFontSize.sp,
                  color: const Color(0xff8B7355),
                ),
              ),
            )
                : ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              itemCount: viewModel.displayedPastries.length,
              itemBuilder: (context, index) {
                final pastry = viewModel.displayedPastries[index];
                final isSelected = _selectedItems[pastry.id] ?? false;

                return Padding(
                  padding: EdgeInsets.only(bottom: 10.h),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedItems[pastry.id!] = !isSelected;
                      });
                    },
                    child: Container(
                      height: 50.h,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xff573E1A)
                            : const Color(0xffD4C4AC),
                        borderRadius: BorderRadius.circular(25.r),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 15.w),
                      child: Row(
                        children: [
                          // Pastry Image
                          CircleAvatar(
                            radius: 18.r,
                            backgroundImage: pastry.imageBytes.isNotEmpty
                                ? MemoryImage(pastry.imageBytes)
                                : const AssetImage(
                              "assets/Images/default_pastry_img.jpg",
                            ) as ImageProvider,
                          ),
                          SizedBox(width: 15.w),
                          // Pastry Name
                          Expanded(
                            child: Text(
                              pastry.title,
                              style: GoogleFonts.poppins(
                                fontSize: sFontSize.sp,
                                fontWeight: lFontWeight,
                                color: isSelected
                                    ? Colors.white
                                    : const Color(0xff573E1A),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          // Quantity
                          Text(
                            "${pastry.quantity}",
                            style: GoogleFonts.poppins(
                              fontSize: lFontSize.sp,
                              fontWeight: xxlFontWeight,
                              color: isSelected
                                  ? Colors.white
                                  : const Color(0xff573E1A),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Update Stock Button
          Padding(
            padding: EdgeInsets.all(20.w),
            child: GestureDetector(
              onTap: () {
                // Handle update stock action
                final selectedIds = _selectedItems.entries
                    .where((entry) => entry.value)
                    .map((entry) => entry.key)
                    .toList();

                if (selectedIds.isNotEmpty) {
                  // TODO: Navigate to update stock page with selected pastries
                  print("Selected pastry IDs: $selectedIds");
                }
              },
              child: Container(
                height: 50.h,
                decoration: BoxDecoration(
                  color: const Color(0xff5C4B32),
                  borderRadius: BorderRadius.circular(25.r),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.add,
                      color: Colors.white,
                      size: 18.w,
                    ),
                    SizedBox(width: 10.w),
                    Text(
                      "Update Stock",
                      style: GoogleFonts.poppins(
                        fontSize: sFontSize.sp,
                        fontWeight: lFontWeight,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}