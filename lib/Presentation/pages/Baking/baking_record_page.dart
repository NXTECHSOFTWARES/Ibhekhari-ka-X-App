import 'package:community_material_icon/community_material_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:nxbakers/Common/AppData.dart';
import 'package:nxbakers/Common/Widgets/add_button.dart';
import 'package:nxbakers/Common/Widgets/reusable_text_widget.dart';
import 'package:nxbakers/Common/color.dart';
import 'package:nxbakers/Common/common_main.dart';
import 'package:nxbakers/Data/Model/baking_records.dart';
import 'package:nxbakers/Presentation/ViewModels/baking_record_viewmodel.dart';
import 'package:nxbakers/Presentation/ViewModels/pastry_viewmodel.dart';
import 'package:nxbakers/Presentation/pages/Inventory/update_or_add_inventory_page.dart';
import 'package:nxbakers/Presentation/pages/Pastries/add_new_pastry_quantity.dart';
import 'package:provider/provider.dart';

import '../Pastries/Utils/Widgets/pastry_settings_bottom_sheet.dart';

class BakingRecordPage extends StatefulWidget {
  const BakingRecordPage({super.key});

  @override
  State<BakingRecordPage> createState() => _BakingRecordPageState();
}

class _BakingRecordPageState extends State<BakingRecordPage> {
  late final BakingRecordViewModel _viewModel;
  String? _selectedYear;
  final FocusNode _dropDownFocusNode = FocusNode();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _viewModel = BakingRecordViewModel();
    setState(() {
      _selectedYear = "2025";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0.w,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: ReusableTextWidget(
          text: "Baking Records",
          color: const Color(0xff351F00),
          size: lFontSize,
          FW: lFontWeight,
        ),
        backgroundColor: const Color(0xffD7CEC2),
        iconTheme: IconThemeData(color: const Color(0xff5D3700), size: 18.w),
        actions: [
          /**
           * Search button
           */
          GestureDetector(
            onTap: () => {},
            child: Container(
              width: 27.w,
              height: 27.w,
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(4.r),
                border: Border.all(
                  width: 1.0.w,
                  color: const Color(0xffAA9C88),
                  style: BorderStyle.solid,
                ),
              ),
              child: Icon(
                color: const Color(0xffAA9C88),
                Icons.search,
                size: 18.w,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(right: 20.0.w, left: 10.w),
            child: AddButton(addNavPage: const UpdateOrAddInventoryPage(), addViewModel: PastryViewModel()),
          )
        ],
      ),
      floatingActionButton: _viewModel.bakingRecords.isEmpty
          ? Align(
        alignment: Alignment.center,
        child: FloatingActionButton(
          backgroundColor: Colors.black,
          onPressed: () {
            _viewModel.loadBakingRecordData();
          },
          child: const Icon(
            Icons.add,
            color: Colors.white,
          ),
        ),
      )
          : null,
      body: CommonMain(
        child: ChangeNotifierProvider(
          create: (BuildContext context) => BakingRecordViewModel()..loadBakingRecords(),
          child: Consumer<BakingRecordViewModel>(
            builder: (BuildContext context, viewModel, Widget? child) {
              return viewModel.bakingRecords.isEmpty
                  ? Expanded(
                      child: Center(
                        child: ReusableTextWidget(
                          text: "No Data To Display".toUpperCase(),
                          color: Colors.black,
                          size: xlFontSize,
                          FW: FontWeight.w400,
                        ),
                      ),
                    )
                  : Column(
                      children: [
                        SizedBox(
                          height: 20.h,
                        ),
                        /**
                   * Filter by years dropdown
                   */
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 15.0.w),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(child: Container()),
                              Container(
                                padding: EdgeInsets.zero,
                                width: 55.w,
                                height: 30.h,
                                child: Center(
                                  child: DropdownButtonFormField<String>(
                                    focusNode: _dropDownFocusNode,
                                    elevation: 0,
                                    dropdownColor: const Color(0xffF2EADE),
                                    style: GoogleFonts.poppins(
                                      fontSize: 10.sp,
                                      color: const Color(0xff351F00),
                                    ),
                                    value: _selectedYear,
                                    items: viewModel.listOfYears.map((year) {
                                      return DropdownMenuItem(
                                        value: year,
                                        child: ReusableTextWidget(
                                          text: year,
                                          color: const Color(0XFF351F00),
                                          size: sFontSize,
                                          FW: sFontWeight,
                                        ),
                                      );
                                    }).toList(),
                                    onChanged: (value) {
                                      setState(() {
                                        _selectedYear = value;
                                        viewModel.filterRecordsByYear(value!);
                                      });
                                    },
                                    iconSize: 18.w,
                                    icon: const Icon(
                                      Icons.keyboard_arrow_down_rounded,
                                      color: Color(0xff7D6543),
                                    ),
                                    iconEnabledColor: const Color(0xff7D6543),
                                    focusColor: _dropDownFocusNode.hasFocus ? Colors.white : Colors.transparent,
                                    borderRadius: BorderRadius.circular(6.r),
                                    decoration: InputDecoration(
                                      border: InputBorder.none,
                                      isDense: true,
                                      contentPadding: EdgeInsets.only(left: 10.w),
                                      enabledBorder: InputBorder.none,
                                      focusedBorder: InputBorder.none,
                                      fillColor: Colors.transparent,
                                      filled: true,
                                    ),
                                    validator: (value) => value == null ? 'Please select a year' : null,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 10.h,
                        ),
                        /**
                   * Builds the Months data - WRAPPED IN EXPANDED
                   */
                        // Replace your ListView.builder section with this:

                        Expanded(
                          child: ListView.builder(
                            itemCount: viewModel.listOfMonths.length,
                            itemBuilder: (BuildContext context, int i) {
                              String month = viewModel.listOfMonths[i];

                              // Get pre-grouped records for this month (no state changes)
                              final monthRecords = viewModel.getRecordsForMonth(month);

                              // Calculate stats for this month
                              final totalBaked = viewModel.calculateTotalMonthBakedGood(month);
                              final mostBaked = viewModel.getMostBakedPastry(month);
                              final monthYearDisplay = viewModel.getMonthYearDisplay(month);

                              return Column(
                                children: [
                                  /**
                             * Months Header Summary (Total Baked Goods, Most Baked, The Month of Record)
                             */
                                  Padding(
                                    padding: EdgeInsets.only(right: 15.0.w, bottom: 0.h),
                                    child: Expanded(
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Container(),
                                          Wrap(
                                            crossAxisAlignment: WrapCrossAlignment.center,
                                            spacing: 5.w,
                                            children: [
                                              /**
                                         * Total Sales for the Period
                                         */
                                              ReusableTextWidget(
                                                text: totalBaked.toString(),
                                                color: const Color(0xff56452D),
                                                size: sFontSize,
                                                FW: sFontWeight,
                                              ),
                                              Container(
                                                width: 25.w,
                                                height: 1.h,
                                                color: const Color(0xffAA9C88),
                                              ),
                                              /**
                                               * Top Seller/ Pastry that was sold the most for the Period
                                               */
                                              ReusableTextWidget(
                                                text: mostBaked,
                                                color: const Color(0xff56452D),
                                                size: sFontSize,
                                                FW: sFontWeight,
                                              ),
                                              Container(
                                                width: 25.w,
                                                height: 1.h,
                                                color: const Color(0xffAA9C88),
                                              ),
                                              /**
                                               * Period Date
                                               */
                                              ReusableTextWidget(
                                                text: monthYearDisplay,
                                                color: const Color(0xff56452D),
                                                size: sFontSize,
                                                FW: sFontWeight,
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Divider(
                                    color: primaryColor,
                                  ),
                                  SizedBox(
                                    height: 10.h,
                                  ),
                                  /**
                             * Builds data of the month
                             */
                                  ListView.builder(
                                      shrinkWrap: true,
                                      physics: const NeverScrollableScrollPhysics(),
                                      padding: EdgeInsets.symmetric(horizontal: 15.w),
                                      itemCount: monthRecords.length,
                                      itemBuilder: (context, index) {
                                        final String bakingRecordDate = monthRecords[index].keys.first;
                                        final bakingDate = DateFormat("dd MMMM yyyy").format(DateTime.parse(bakingRecordDate));

                                        return Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                ReusableTextWidget(
                                                  text: bakingDate,
                                                  color: iconColor,
                                                  size: lFontSize,
                                                  FW: sFontWeight,
                                                ),
                                                ReusableTextWidget(
                                                  text: monthRecords[index].values.first.length == 1 ? "1 Pastry" : "${monthRecords[index].values.first.length.toString()} Pastries",
                                                  color: iconColor,
                                                  size: sFontSize,
                                                  FW: sFontWeight,
                                                ),
                                              ],
                                            ),
                                            SizedBox(height: 10.h),
                                            ListView.builder(
                                              padding: EdgeInsets.only(bottom: 20.h),
                                              shrinkWrap: true,
                                              physics: const NeverScrollableScrollPhysics(),
                                              itemCount: monthRecords[index].values.first.length,
                                              itemBuilder: (BuildContext context, int i) {
                                                final BakingRecord bakingRecord = monthRecords[index].values.first[i];

                                                return Slidable(
                                                  key: Key(bakingRecord.id.toString()),
                                                  endActionPane: ActionPane(motion: const ScrollMotion(), children: [
                                                    SlidableAction(
                                                      onPressed: (context) => _confirmDeletePastry(bakingRecord),
                                                      backgroundColor: Colors.red.shade700,
                                                      foregroundColor: Colors.white,
                                                      icon: CommunityMaterialIcons.delete_outline,
                                                      spacing: 0,
                                                      padding: EdgeInsets.zero,
                                                      label: 'Delete',
                                                    ),
                                                    SlidableAction(
                                                      onPressed: (context) => _showEditBakingRecord(bakingRecord),
                                                      backgroundColor: Colors.blue,
                                                      foregroundColor: Colors.white,
                                                      borderRadius: BorderRadius.only(
                                                        topRight: Radius.circular(6.r),
                                                        bottomRight: Radius.circular(6.r),
                                                      ),
                                                      icon: Icons.edit,
                                                      label: 'Edit',
                                                    ),
                                                  ]),
                                                  child: Container(
                                                    height: 80.h,
                                                    margin: EdgeInsets.only(bottom: 10.h),
                                                    padding: EdgeInsets.all(10.w),
                                                    decoration: BoxDecoration(
                                                      color: primaryColor,
                                                      borderRadius: BorderRadius.circular(10.r),
                                                    ),
                                                    child: Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        Row(
                                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                          crossAxisAlignment: CrossAxisAlignment.center,
                                                          children: [
                                                            ReusableTextWidget(
                                                              text: bakingRecord.pastryName,
                                                              color: iconColor,
                                                              size: xlFontSize,
                                                              FW: sFontWeight,
                                                            ),
                                                            ReusableTextWidget(
                                                              text: viewModel.getRecordAge(bakingRecord.bakingDate),
                                                              color: iconColor,
                                                              size: sFontSize,
                                                              FW: sFontWeight,
                                                            ),
                                                          ],
                                                        ),
                                                        SizedBox(height: 10.h),
                                                        Wrap(
                                                          crossAxisAlignment: WrapCrossAlignment.center,
                                                          direction: Axis.horizontal,
                                                          spacing: 10.w,
                                                          children: [
                                                            ReusableTextWidget(
                                                              text: "Quantity Produced:",
                                                              color: iconColor,
                                                              size: sFontSize,
                                                              FW: sFontWeight,
                                                            ),
                                                            ReusableTextWidget(
                                                              text: bakingRecord.quantityBaked.toString(),
                                                              color: iconColor,
                                                              size: lFontSize,
                                                              FW: xlFontWeight,
                                                            ),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                );
                                              },
                                            ),
                                          ],
                                        );
                                      }),
                                ],
                              );
                            },
                          ),
                        )
                      ],
                    );
            },
          ),
        ),
      ),
    );
  }

  void _showEditBakingRecord(BakingRecord bakingRecord) {
    showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return ChangeNotifierProvider(create: (BuildContext context) => PastryViewModel(), child: Container());
      },
    );
  }

  void _confirmDeletePastry(BakingRecord bakingRecord) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Align(
          alignment: Alignment.center,
          child: ReusableTextWidget(
            text: 'Delete Baking Record',
            size: xxlFontSize,
            color: Colors.brown.shade800,
            FW: lFontWeight,
          ),
        ),
        content: SizedBox(
          height: 70.h,
          child: Column(
            children: [
              ReusableTextWidget(
                text: 'Are you sure you want to delete',
                size: sFontSize,
                color: Colors.brown.shade400,
                FW: sFontWeight,
              ),
              ReusableTextWidget(
                text: bakingRecord.pastryName,
                size: lFontSize,
                color: Colors.brown.shade400,
                FW: lFontWeight,
              ),
              ReusableTextWidget(
                text: DateFormat("dd MMMM yyyy").format(DateTime.parse(bakingRecord.bakingDate)),
                size: lFontSize,
                color: Colors.brown.shade400,
                FW: lFontWeight,
              ),
              ReusableTextWidget(
                text: 'Record?',
                size: sFontSize,
                color: Colors.brown.shade400,
                FW: sFontWeight,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: ReusableTextWidget(
              text: 'Cancel',
              color: Colors.black,
              size: sFontSize,
              FW: lFontWeight,
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await _viewModel.deleteBakingRecord(bakingRecord.id!);
              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      backgroundColor: Colors.white,
                      content: ReusableTextWidget(
                        text:
                            '${DateFormat("dd MMM yyyy").format(DateTime.parse(bakingRecord.bakingDate))} ${bakingRecord.pastryName} Record deleted',
                        color: Colors.black,
                        size: sFontSize,
                        FW: lFontWeight,
                      )),
                );
              }
            },
            child: ReusableTextWidget(
              text: 'Delete',
              color: Colors.black,
              size: sFontSize,
              FW: lFontWeight,
            ),
          ),
        ],
      ),
    );
  }

  String _getSortText(SortType sortType) {
    switch (sortType) {
      case SortType.nameAsc:
        return "Name (A-Z)";
      case SortType.nameDesc:
        return "Name (Z-A)";
      case SortType.priceAsc:
        return "Price (Low-High)";
      case SortType.priceDesc:
        return "Price (High-Low)";
      case SortType.quantityAsc:
        return "Quantity (Low-High)";
      case SortType.quantityDesc:
        return "Quantity (High-Low)";
      case SortType.salesAsc:
        return "Sales (Low-High)";
      case SortType.salesDesc:
        return "Sales (High-Low)";
      case SortType.incomeAsc:
        return "Income (Low-High)";
      case SortType.incomeDesc:
        return "Income (High-Low)";
    }
  }
}
