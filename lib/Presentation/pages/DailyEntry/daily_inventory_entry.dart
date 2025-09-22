import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:nxbakers/Common/Widgets/reusable_text_widget.dart';
import 'package:nxbakers/Common/common_main.dart';
import 'package:nxbakers/Common/common_page_header.dart';
import 'package:nxbakers/Data/Model/daily_entry.dart';
import 'package:nxbakers/Data/Model/pastry.dart';
import 'package:nxbakers/Presentation/ViewModels/daily_entry_viewmodel.dart';
import 'package:nxbakers/Presentation/ViewModels/pastry_viewmodel.dart';
import 'package:nxbakers/Presentation/pages/DailyEntry/add_daily_entries.dart';
import 'package:nxbakers/Presentation/pages/HomePage/Widgets/display_widget.dart';
import 'package:nxbakers/Presentation/pages/Pastries/pastry_details.dart';
import 'package:provider/provider.dart';

class DailyInventoryEntry extends StatefulWidget {
  const DailyInventoryEntry({super.key});

  @override
  State<DailyInventoryEntry> createState() => _DailyInventoryEntryState();
}

class _DailyInventoryEntryState extends State<DailyInventoryEntry> {
  String? _selectedYear;
  final FocusNode _dropDownFocusNode = FocusNode();

  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    setState(() {
      _selectedYear = "2025";
    });
  }

  double _getPastryPrice(pastryId, List<Pastry> pastries) {
    List<Pastry> pastry =
        pastries.where((pastry) => pastry.id! == pastryId).toList();
    return pastry[0].price;
  }

  String _getTopSeller(List<DailyEntry> entries, List<Pastry> pastries) {
    String topSeller = "";
    int topSoldStock = 0;

    for (DailyEntry entry in entries) {
      String pastryName =
          pastries.where((pastry) => pastry.id! == entry.pastryId).first.title;
      if (entry.soldStock > topSoldStock) {
        topSeller = pastryName;
        topSoldStock = entry.soldStock;
      }
    }
    return topSeller;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return ChangeNotifierProvider(
      create: (BuildContext context) => DailyEntryViewModel()..initialize(),
      child: Consumer<DailyEntryViewModel>(builder:
          (BuildContext context, DailyEntryViewModel viewModel, Widget? child) {
        if (viewModel.dailyEntriesFGroupByDate.isEmpty) {
          return CommonMain(
            child: Expanded(
              child: Column(
                children: [
                  Container(
                    height: 85.h,
                    color: const Color(0xffF2EADE),
                    padding: EdgeInsets.only(bottom: 15.h),
                    child: Column(
                      children: [
                        Expanded(child: Container()),
                        CommonPageHeader(
                          pageTitle: "Daily Entries",
                          pageSubTitle: "A List of all sales Entries",
                          addViewModel: ChangeNotifier(),
                          addNavPage: const AddDailyEntries(),
                        ),
                      ],
                    ),
                  ),
                  /**
                   * Tab bar for Top selling Pastries
                   */
                  Container(
                    width: size.width,
                    height: 30.h,
                    padding: EdgeInsets.symmetric(horizontal: 10.w),
                    color: const Color.fromRGBO(0, 0, 0, 0.15),
                    child: Row(
                      children: [
                        const ReusableTextWidget(
                          text: "Top Sellers",
                          color: Color(0xff5D3700),
                          size: 8,
                          FW: FontWeight.w300,
                        ),
                        SizedBox(
                          width: 20.w,
                        ),
                        Expanded(
                          child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: viewModel.pastries.length,
                              itemBuilder: (context, index) {
                                final pastry = viewModel.pastries[index];
                                return TextButton(
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (context) =>
                                          PastryDetails(pastryId: index + 1),
                                    );
                                  },
                                  child: ReusableTextWidget(
                                    text: pastry.title,
                                    color: Colors.white,
                                    size: 8,
                                    FW: FontWeight.w300,
                                  ),
                                );
                              }),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                      child: Center(
                    child: ReusableTextWidget(
                      text: "No Data To Display".toUpperCase(),
                      color: Colors.black,
                      size: 16,
                      FW: FontWeight.w400,
                    ),
                  )),
                ],
              ),
            ),
          );
        } else {
          return CommonMain(
            child: Expanded(
              child: Column(
                children: [
                  Container(
                    height: 85.h,
                    color: const Color(0xffF2EADE),
                    padding: EdgeInsets.only(bottom: 15.h),
                    child: Column(
                      children: [
                        Expanded(child: Container()),
                        CommonPageHeader(
                          pageTitle: "Daily Entries",
                          pageSubTitle: "A List of all sales Entries",
                          addViewModel: ChangeNotifier(),
                          addNavPage: const AddDailyEntries(),
                        ),
                      ],
                    ),
                  ),
                  /**
                 * Tab bar for Top selling Pastries
                 */
                  Container(
                    width: size.width,
                    height: 30.h,
                    padding: EdgeInsets.symmetric(horizontal: 10.w),
                    color: const Color.fromRGBO(0, 0, 0, 0.15),
                    child: Row(
                      children: [
                        const ReusableTextWidget(
                          text: "Top Sellers",
                          color: Color(0xff5D3700),
                          size: 8,
                          FW: FontWeight.w300,
                        ),
                        SizedBox(
                          width: 20.w,
                        ),
                        Expanded(
                          child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: viewModel.pastries.length,
                              itemBuilder: (context, index) {
                                final pastry = viewModel.pastries[index];
                                return TextButton(
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (context) =>
                                          PastryDetails(pastryId: index + 1),
                                    );
                                  },
                                  child: ReusableTextWidget(
                                    text: pastry.title,
                                    color: Colors.white,
                                    size: 8,
                                    FW: FontWeight.w300,
                                  ),
                                );
                              }),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(
                        top: 20.h,
                        left: 5.w,
                        right: 5.w,
                      ),
                      child: Column(
                        children: [
                          Padding(
                            padding: EdgeInsets.only(
                              top: 0.0.h,
                              bottom: 15.0.h,
                              left: 15.0.w,
                              right: 15.0.w,
                            ),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    const ReusableTextWidget(
                                      text: "Daily Sales",
                                      color: Color(0xff573E1A),
                                      size: 14,
                                      FW: FontWeight.w400,
                                    ),
                                    Container(
                                      padding: EdgeInsets.zero,
                                      width: 55.w,
                                      height: 30.h,
                                      // padding: EdgeInsets.symmetric(
                                      //     vertical: 2.h, horizontal: 5.w),
                                      // decoration: BoxDecoration(
                                      //     color: const Color(0xffDADADA),
                                      //     borderRadius: BorderRadius.circular(6.r),
                                      // ),
                                      child: Center(
                                        child: DropdownButtonFormField<String>(
                                          focusNode: _dropDownFocusNode,
                                          elevation: 0,
                                          dropdownColor:
                                              const Color(0xffF2EADE),
                                          style: GoogleFonts.poppins(
                                            fontSize: 10.sp,
                                            color: const Color(0xff351F00),
                                          ),
                                          // hint: const ReusableTextWidget(
                                          //   text: "Please select a year...'",
                                          //   color: Color(0xff515151),
                                          //   size: 8,
                                          //   FW: FontWeight.w200,
                                          // ),
                                          value: _selectedYear,
                                          items: const [
                                            DropdownMenuItem(
                                              value: "2025",
                                              child: ReusableTextWidget(
                                                text: "2025",
                                                color: Color(0XFF351F00),
                                                size: 10,
                                                FW: FontWeight.w300,
                                              ),
                                            ),
                                          ]
                                          // viewModel.categories.map((category) {
                                          //   return DropdownMenuItem(
                                          //     value: category.name,
                                          //     child: Text(category.name),
                                          //   );
                                          // }).toList()
                                          ,
                                          onChanged: (value) {
                                            setState(() {
                                              _selectedYear = value;
                                            });
                                          },
                                          iconSize: 18.w,
                                          icon: const Icon(
                                            Icons.keyboard_arrow_down_rounded,
                                            color: Color(0xff7D6543),
                                          ),
                                          iconEnabledColor:
                                              const Color(0xff7D6543),
                                          focusColor:
                                              _dropDownFocusNode.hasFocus
                                                  ? Colors.white
                                                  : Colors.transparent,
                                          borderRadius:
                                              BorderRadius.circular(6.r),
                                          decoration: InputDecoration(
                                            border: InputBorder.none,
                                            isDense: true,
                                            contentPadding:
                                                EdgeInsets.only(left: 10.w),
                                            enabledBorder: InputBorder.none,
                                            focusedBorder: InputBorder.none,
                                            fillColor: Colors.transparent,
                                            filled: true,
                                          ),
                                          validator: (value) => value == null
                                              ? 'Please select a year'
                                              : null,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: 15.h,
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(),
                                    Wrap(
                                      //mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      crossAxisAlignment:
                                          WrapCrossAlignment.center,
                                      spacing: 10.w,
                                      children: [
                                        const ReusableTextWidget(
                                          text: "R1 204",
                                          color: Color(0xff56452D),
                                          size: 8,
                                          FW: FontWeight.w300,
                                        ),
                                        Container(
                                          width: 25.w,
                                          height: 1.h,
                                          color: const Color(0xffAA9C88),
                                        ),
                                        const ReusableTextWidget(
                                          text: "Snowball",
                                          color: Color(0xff56452D),
                                          size: 8,
                                          FW: FontWeight.w300,
                                        ),
                                        Container(
                                          width: 25.w,
                                          height: 1.h,
                                          color: const Color(0xffAA9C88),
                                        ),
                                        const ReusableTextWidget(
                                          text: "August 10",
                                          color: Color(0xff56452D),
                                          size: 8,
                                          FW: FontWeight.w300,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: ListView.builder(
                                itemCount:
                                    viewModel.dailyEntriesFGroupByDate.length,
                                itemBuilder: (context, index) {
                                  String dateKey = viewModel
                                      .dailyEntriesFGroupByDate.keys
                                      .elementAt(index);
                                  List<DailyEntry> entriesForDate = viewModel
                                      .dailyEntriesFGroupByDate[dateKey]!;

                                  return Container(
                                    width: size.width,
                                    // height: 50.h,
                                    margin: EdgeInsets.only(bottom: 10.h),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF2EADE),
                                      borderRadius: BorderRadius.circular(8.r),
                                      boxShadow: [
                                        BoxShadow(
                                          color: const Color(0xFF362A1A)
                                              .withOpacity(0.24),
                                          spreadRadius: 0,
                                          blurRadius: 4.r,
                                          offset: Offset(0, 2.h),
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      children: [
                                        ExpansionTile(
                                          showTrailingIcon: false,
                                          minTileHeight: 50.h,
                                          collapsedShape: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8.r),
                                              borderSide: BorderSide.none),
                                          onExpansionChanged: (isExpanded) {
                                            setState(() {
                                              _isExpanded = isExpanded;
                                            });
                                          },
                                          shape: InputBorder.none,
                                          backgroundColor: Colors.transparent,
                                          title: _buildSummaryItem(
                                              dateKey,
                                              entriesForDate,
                                              viewModel.pastries),
                                          children: [
                                            Divider(
                                              color: Colors.black12,
                                              thickness: 5.h,
                                              height: 3.h,
                                            ),
                                            _buildFilterChips(
                                                viewModel.categories),
                                            _buildItemsList(entriesForDate,
                                                viewModel.pastries),
                                          ],
                                        ),
                                        _isExpanded
                                            ? Container()
                                            : Container(
                                                width: size.width,
                                                height: 5.h,
                                                margin: EdgeInsets.symmetric(
                                                    horizontal: 8.w),
                                                decoration: BoxDecoration(
                                                  color: const Color(0XFF634923)
                                                      .withOpacity(0.22),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                    10.r,
                                                  ),
                                                ),
                                                child: Icon(
                                                  Icons
                                                      .keyboard_arrow_down_rounded,
                                                  size: 10.w,
                                                ),
                                              ),
                                      ],
                                    ),
                                  );
                                }),
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }
      }),
    );
  }

  Widget _buildFilterChips(categories) {
    List<dynamic> filters =
        categories.map((category) => category.name).toList();

    return Container(
      width: double.infinity,
      height: 50.h,
      padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 0.h),
      child: Row(
        children: [
          Container(
            width: 40.w,
            height: 20.h,
            margin: EdgeInsets.only(right: 10.w),
            decoration: BoxDecoration(
              color: const Color(0xff7B7B7B),
              borderRadius: BorderRadius.circular(100.r),
            ),
            child: const Padding(
              padding: EdgeInsets.zero,
              child: Center(
                child: ReusableTextWidget(
                  text: "all",
                  color: Colors.white,
                  size: 8,
                  FW: FontWeight.w300,
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: filters.map((filter) {
                bool isSelected = filter == 'all';
                return Container(
                  height: 20.h,
                  margin: EdgeInsets.only(
                    right: 10.w,
                  ),
                  child: FilterChip(
                    labelPadding: EdgeInsets.zero,
                    side: BorderSide.none,
                    padding: EdgeInsets.symmetric(horizontal: 10.w),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    label: ReusableTextWidget(
                      text: filter.toLowerCase(),
                      color: Colors.white,
                      size: 8,
                      FW: FontWeight.w400,
                    ),
                    selected: isSelected,
                    selectedColor: Colors.grey[800],
                    backgroundColor: isSelected
                        ? const Color(0xff7B7B7B)
                        : const Color(0xff3C3C3C),
                    onSelected: (bool selected) {
                      // Handle filter selection
                    },
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(100.r),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(
      String date, List<DailyEntry> entries, List<Pastry> pastries) {
    int totalItems = entries.fold(0, (sum, entry) => sum + entry.soldStock);
    String topSeller = _getTopSeller(entries, pastries);
    double totalSales = entries.fold(
        0,
        (sum, entry) =>
            sum +
            (entry.soldStock * _getPastryPrice(entry.pastryId, pastries)));

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(
              width: 100.w,
              child: ReusableTextWidget(
                text: DateFormat('d MMMM y')
                    .format(DateFormat('EEEE, d MMMM y').parse(date)),
                color: const Color(0xFFA1845C),
                size: 8,
                FW: FontWeight.w400,
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
                  subText: topSeller,
                  headerColor: const Color(0xff6D593D),
                  subTextColor: const Color(0xff553609),
                ),
                DisplayWidget(
                  headerText: "Total Sales",
                  subText: "R${totalSales.toStringAsFixed(2)}",
                  headerColor: const Color(0xff6D593D),
                  subTextColor: const Color(0xff553609),
                ),
              ],
            ),
          ],
        ),
        // _isExpanded ? Container(
        //   width: size.width,
        //   height: 50.h,
        //   decoration: BoxDecoration(
        //     borderRadius: BorderRadius.circular(8.r),
        //     color: const Color(0xFF000000).withOpacity(0.1),
        //   ),
        // ) : Container(),
      ],
    );
  }

  Widget _buildItemsList(
      List<DailyEntry> entriesForDate, List<Pastry> pastries) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 15.0.w, vertical: 25.h),
      child: ListView(
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
        children: entriesForDate
            .map((entry) => _buildListItem(entry, pastries))
            .toList(),
      ),
    );
  }

  Widget _buildListItem(DailyEntry entry, List<Pastry> pastries) {
    final imageBytes =
        pastries.firstWhere((pastry) => pastry.id! == entry.id).imageBytes;
    final title = pastries.firstWhere((pastry) => pastry.id! == entry.id).title;
    double totalSales =
        entry.soldStock * _getPastryPrice(entry.pastryId, pastries);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PastryDetails(
              pastryId: entry.pastryId,
            ),
          ),
        );
      },
      child: Container(
        height: 40.h,
        margin: EdgeInsets.only(bottom: 10.h),
        padding: EdgeInsets.fromLTRB(
          5.w,
          5.h,
          20.w,
          5.h,
        ),
        decoration: BoxDecoration(
          color: const Color(0xff000000).withOpacity(0.20),
          borderRadius: BorderRadius.circular(5.r),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Pastry Image
            Container(
              width: 30.w,
              height: 30.h,
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                      color: const Color(0xff000000).withOpacity(0.35),
                      width: 1.0.w,
                      style: BorderStyle.solid),
                  image: DecorationImage(
                    image: MemoryImage(
                      imageBytes,
                    ),
                    fit: BoxFit.cover,
                  )),
            ),
            SizedBox(width: 10.w),
            // Pastry Name
            Expanded(
              child: ReusableTextWidget(
                text: title,
                size: 8,
                FW: FontWeight.w400,
                color: Colors.white,
              ),
            ),
            // Stats
            Wrap(
              spacing: 25.w,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                _buildStatColumn('left', entry.remainingStock.toString()),
                _buildStatColumn('sold', entry.soldStock.toString()),
                _buildStatColumn('sales', "R${totalSales.toStringAsFixed(2)}"),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatColumn(String header, String subText) {
    return Column(
      children: [
        ReusableTextWidget(
          text: header,
          size: 8,
          color: const Color(0xff503600),
          FW: FontWeight.w400,
        ),
        SizedBox(height: 0.h),
        ReusableTextWidget(
          text: subText,
          size: 8,
          FW: FontWeight.w400,
          color: Colors.white,
        ),
      ],
    );
  }
}
