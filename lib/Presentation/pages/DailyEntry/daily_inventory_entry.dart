import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:nxbakers/Common/Widgets/reusable_text_widget.dart';
import 'package:nxbakers/Common/common_main.dart';
import 'package:nxbakers/Common/common_page_header.dart';
import 'package:nxbakers/Data/Model/daily_sale.dart';
import 'package:nxbakers/Data/Model/pastry.dart';
import 'package:nxbakers/Presentation/ViewModels/daily_sales_viewmodel.dart';
import 'package:nxbakers/Presentation/ViewModels/pastry_viewmodel.dart';
import 'package:nxbakers/Presentation/pages/DailyEntry/add_daily_entries.dart';
import 'package:nxbakers/Presentation/pages/HomePage/Widgets/display_widget.dart';
import 'package:nxbakers/Presentation/pages/Pastries/pastry_details.dart';
import 'package:provider/provider.dart';

import '../../../Common/AppData.dart';

class DailyInventoryEntry extends StatefulWidget {
  const DailyInventoryEntry({super.key});

  @override
  State<DailyInventoryEntry> createState() => _DailyInventoryEntryState();
}

class _DailyInventoryEntryState extends State<DailyInventoryEntry> {
  String? _selectedYear;
  String? _selectedMonth;
  final FocusNode _dropDownFocusNode = FocusNode();

  List<bool> _expandedStates = [];
  List<String> topSellers = [];

  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    setState(() {
      _selectedYear = "2025";
      _selectedMonth = "February";
    });
  }

  double _getPastryPrice(pastryId, List<Pastry> pastries) {
    List<Pastry> pastry = pastries.where((pastry) => pastry.id! == pastryId).toList();
    return pastry[0].price;
  }

  String _getTopSeller(List<DailySale> entries, List<Pastry> pastries) {
    String topSeller = "";
    int topSoldStock = 0;

    for (DailySale entry in entries) {
      String pastryName = pastries.where((pastry) => pastry.id! == entry.pastryId).first.title;
      if (entry.soldStock > topSoldStock) {
        topSeller = pastryName;
        topSoldStock = entry.soldStock;
      }
    }

    topSellers.add(topSeller);
    return topSeller;
  }

  String _formatShortPeriod(String periodKey) {
    try {
      DateFormat format = DateFormat('dd MMMM yyyy');
      DateTime date = format.parse(periodKey);
      return DateFormat('MMMM d').format(date);
    } catch (e) {
      return periodKey;
    }
  }

  String _calculatePeriodTotal(Map<String, List<DailySale>> dailyEntries, List<Pastry> pastries) {
    double total = 0;
    dailyEntries.forEach((date, entries) {
      for (var entry in entries) {
        total += entry.soldStock * _getPastryPrice(entry.pastryId, pastries);
      }
    });
    return 'R${total.toStringAsFixed(2)}';
  }

  int _calculateGlobalIndex(int periodIndex, int dailyIndex, Map<String, Map<String, List<DailySale>>> groupedData) {
    int globalIndex = 0;
    for (int i = 0; i < periodIndex; i++) {
      String key = groupedData.keys.elementAt(i);
      globalIndex += groupedData[key]!.keys.length;
    }
    return globalIndex + dailyIndex;
  }

  String findMostFrequent(List<String> list) {
    return list.groupListsBy((element) => element).entries.reduce((a, b) => a.value.length > b.value.length ? a : b).key;
  }

  String _getTopSellerForPeriod(Map<String, List<DailySale>> dailyEntriesInPeriod, List<Pastry> pastries) {
    Map<String, int> pastrySales = {};

    dailyEntriesInPeriod.forEach((date, entries) {
      for (DailySale entry in entries) {
        String pastryName = pastries.where((pastry) => pastry.id! == entry.pastryId).firstOrNull?.title ?? "Unknown Pastry";

        pastrySales[pastryName] = (pastrySales[pastryName] ?? 0) + entry.soldStock;
      }
    });

    if (pastrySales.isEmpty) return "No Sales";

    String topSeller = pastrySales.entries.reduce((a, b) => a.value > b.value ? a : b).key;
    return topSeller;
  }

  String _getTopSellerForDate(List<DailySale> entries, List<Pastry> pastries) {
    if (entries.isEmpty) return "No Sales";

    String topSeller = "";
    int topSoldStock = 0;

    for (DailySale entry in entries) {
      String pastryName = pastries.where((pastry) => pastry.id! == entry.pastryId).firstOrNull?.title ?? "Unknown Pastry";

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
      create: (BuildContext context) => DailySalesViewModel()..initialize(),
      child: Consumer<DailySalesViewModel>(builder: (BuildContext context, viewModel, Widget? child) {
        if (_expandedStates.isEmpty && viewModel.dailyEntriesFGroupByDate.isNotEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              setState(() {
                int totalEntries = 0;
                viewModel.dailyEntriesFGroupByDate.forEach((periodKey, dailyEntries) {
                  totalEntries += dailyEntries.length;
                });
                _expandedStates = List<bool>.filled(totalEntries, false);
              });
            }
          });
        }
        return Scaffold(
          floatingActionButton: viewModel.dailyEntriesFGroupByDate.isEmpty
              ? Align(
            alignment: Alignment.center,
            child: FloatingActionButton(
              backgroundColor: Colors.black,
              onPressed: () {
                viewModel.loadTestData();
              },
              child: const Icon(Icons.add, color: Colors.white),
            ),
          )
              : null,
          body: CommonMain(
            child: Column(
              children: [
                /**
                 * Page header
                 */
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
                        addNavPage: const AddDailySales(),
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
                      ReusableTextWidget(
                        text: "Top Sellers",
                        color: const Color(0xff5D3700),
                        size: sFontSize,
                        FW: sFontWeight,
                      ),
                      SizedBox(width: 20.w),
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
                                  builder: (context) => PastryDetails(pastryId: pastry.id ?? 0),
                                );
                              },
                              child: ReusableTextWidget(
                                text: pastry.title,
                                color: Colors.white,
                                size: sFontSize,
                                FW: sFontWeight,
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                /**
                 * Main page content
                 */
                viewModel.dailyEntriesFGroupByDate.isEmpty
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
                    : Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 15.0.w, vertical: 20.h),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(child: Container()),
                            ReusableTextWidget(
                              text: "Filter by",
                              color: const Color(0xff563D19),
                              size: sFontSize,
                              FW: sFontWeight,
                            ),
                            SizedBox(width: 10.w),
                            /**
                             * Filter by months and years
                             */
                            Container(
                              decoration: BoxDecoration(
                                color: const Color(0xffF2EADE),
                                borderRadius: BorderRadius.circular(5.r),
                              ),
                              child: Wrap(
                                children: [
                                  Container(
                                    padding: EdgeInsets.zero,
                                    width: 70.w,
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
                                        value: _selectedMonth,
                                        items: viewModel.listOfMonths.map((month) {
                                          return DropdownMenuItem(
                                            value: month,
                                            child: ReusableTextWidget(
                                              text: month,
                                              color: const Color(0XFF351F00),
                                              size: sFontSize,
                                              FW: sFontWeight,
                                            ),
                                          );
                                        }).toList(),
                                        onChanged: (value) {
                                          setState(() {
                                            _selectedMonth = value;
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
                                        validator: (value) => value == null ? 'Please select a month' : null,
                                      ),
                                    ),
                                  ),
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
                          ],
                        ),
                        SizedBox(height: 20.h),
                        /**
                         * Daily Sales List
                         */
                        Expanded(
                          child: ListView.builder(
                            padding: EdgeInsets.only(bottom: 100.h),
                            itemCount: viewModel.dailyEntriesFGroupByDate.keys.length,
                            itemBuilder: (context, periodIndex) {
                              String periodKey = viewModel.dailyEntriesFGroupByDate.keys.elementAt(periodIndex);
                              Map<String, List<DailySale>> dailyEntriesInPeriod = viewModel.dailyEntriesFGroupByDate[periodKey]!;

                              String periodTopSeller = _getTopSellerForPeriod(dailyEntriesInPeriod, viewModel.pastries);

                              return Column(
                                children: [
                                  /**
                                   * Month Period Summary Header
                                   */
                                  Padding(
                                    padding: EdgeInsets.only(top: 0.h, right: 15.0.w, bottom: 13.h),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Container(),
                                        Wrap(
                                          crossAxisAlignment: WrapCrossAlignment.center,
                                          spacing: 10.w,
                                          children: [
                                            ReusableTextWidget(
                                              text: _calculatePeriodTotal(dailyEntriesInPeriod, viewModel.pastries),
                                              color: const Color(0xff56452D),
                                              size: xsFontSize,
                                              FW: sFontWeight,
                                            ),
                                            Container(
                                              width: 25.w,
                                              height: 1.h,
                                              color: const Color(0xffAA9C88),
                                            ),
                                            ReusableTextWidget(
                                              text: periodTopSeller,
                                              color: const Color(0xff56452D),
                                              size: xsFontSize,
                                              FW: sFontWeight,
                                            ),
                                            Container(
                                              width: 25.w,
                                              height: 1.h,
                                              color: const Color(0xffAA9C88),
                                            ),
                                            ReusableTextWidget(
                                              text: _formatShortPeriod(periodKey),
                                              color: const Color(0xff56452D),
                                              size: xsFontSize,
                                              FW: sFontWeight,
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  /**
                                   * Daily Month Sales
                                   */
                                  ListView.builder(
                                    shrinkWrap: true,
                                    physics: const NeverScrollableScrollPhysics(),
                                    itemCount: dailyEntriesInPeriod.keys.length,
                                    itemBuilder: (context, dailyIndex) {
                                      String dateKey = dailyEntriesInPeriod.keys.elementAt(dailyIndex);
                                      List<DailySale> entriesForDate = dailyEntriesInPeriod[dateKey]!;

                                      int globalIndex = _calculateGlobalIndex(periodIndex, dailyIndex, viewModel.dailyEntriesFGroupByDate);
                                      bool isExpanded = globalIndex < _expandedStates.length ? _expandedStates[globalIndex] : false;

                                      return Container(
                                        width: size.width,
                                        margin: EdgeInsets.only(bottom: 10.h),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFF2EADE),
                                          borderRadius: BorderRadius.circular(8.r),
                                          boxShadow: [
                                            BoxShadow(
                                              color: const Color(0xFF362A1A).withOpacity(0.24),
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
                                              initiallyExpanded: isExpanded,
                                              collapsedShape: OutlineInputBorder(
                                                borderRadius: BorderRadius.circular(8.r),
                                                borderSide: BorderSide.none,
                                              ),
                                              onExpansionChanged: (isExpanded) {
                                                if (globalIndex < _expandedStates.length) {
                                                  setState(() {
                                                    for (int i = 0; i < _expandedStates.length; i++) {
                                                      _expandedStates[i] = false;
                                                    }
                                                    _expandedStates[globalIndex] = isExpanded;
                                                  });
                                                }
                                              },
                                              shape: InputBorder.none,
                                              backgroundColor: Colors.transparent,
                                              title: _buildSummaryItem(dateKey, entriesForDate, viewModel.pastries),
                                              children: [
                                                Divider(
                                                  color: Colors.black12,
                                                  thickness: 5.h,
                                                  height: 3.h,
                                                ),
                                                _buildFilterChips(viewModel.categories),
                                                _buildItemsList(entriesForDate, viewModel.pastries),
                                              ],
                                            ),
                                            isExpanded
                                                ? Container()
                                                : Container(
                                              width: size.width,
                                              height: 5.h,
                                              padding: EdgeInsets.zero,
                                              margin: EdgeInsets.symmetric(horizontal: 5.w),
                                              decoration: BoxDecoration(
                                                color: const Color(0XFF634923).withOpacity(0.22),
                                                borderRadius: BorderRadius.circular(10.r),
                                              ),
                                              child: Center(
                                                child: Icon(
                                                  Icons.keyboard_arrow_down_rounded,
                                                  size: 10.w,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                  SizedBox(height: 17.h),
                                ],
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildFilterChips(categories) {
    List<dynamic> filters = categories.map((category) => category.name).toList();

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
            child: Padding(
              padding: EdgeInsets.zero,
              child: Center(
                child: ReusableTextWidget(
                  text: "all",
                  color: Colors.white,
                  size: xsFontSize,
                  FW: sFontWeight,
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
                  margin: EdgeInsets.only(right: 10.w),
                  child: FilterChip(
                    labelPadding: EdgeInsets.zero,
                    side: BorderSide.none,
                    padding: EdgeInsets.symmetric(horizontal: 10.w),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    label: ReusableTextWidget(
                      text: filter.toLowerCase(),
                      color: Colors.white,
                      size: sFontSize,
                      FW: lFontWeight,
                    ),
                    selected: isSelected,
                    selectedColor: Colors.grey[800],
                    backgroundColor: isSelected ? const Color(0xff7B7B7B) : const Color(0xff3C3C3C),
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

  Widget _buildSummaryItem(String date, List<DailySale> entries, List<Pastry> pastries) {
    String displayDate;
    try {
      final parsedDate = DateTime.parse(date);
      displayDate = DateFormat('EEEE, d MMMM y').format(parsedDate);
    } catch (e) {
      displayDate = date;
    }

    int totalItems = entries.fold(0, (sum, entry) => sum + entry.soldStock);
    double totalSales = entries.fold(0, (sum, entry) => sum + (entry.soldStock * _getPastryPrice(entry.pastryId, pastries)));

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(
              width: 80.w,
              child: ReusableTextWidget(
                text: displayDate,
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
                  subText: totalItems.toString(),
                  headerColor: const Color(0xff6D593D),
                  subTextColor: const Color(0xff553609),
                ),
                DisplayWidget(
                  headerText: "Top Seller",
                  subText: _getTopSellerForDate(entries, pastries),
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
      ],
    );
  }

  Widget _buildItemsList(List<DailySale> entriesForDate, List<Pastry> pastries) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 15.0.w, vertical: 25.h),
      child: ListView(
        scrollDirection: Axis.vertical,
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        children: entriesForDate.map((entry) => _buildListItem(entry, pastries)).toList(),
      ),
    );
  }

  Widget _buildListItem(DailySale entry, List<Pastry> pastries) {
    Pastry? foundPastry;

    try {
      foundPastry = pastries.firstWhere((pastry) => pastry.id == entry.pastryId);
    } catch (e) {
      return _buildPlaceholderListItem(entry);
    }

    final imageBytes = foundPastry.imageBytes;
    final title = foundPastry.title;
    double totalSales = entry.soldStock * _getPastryPrice(entry.pastryId, pastries);

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
        padding: EdgeInsets.fromLTRB(5.w, 5.h, 20.w, 5.h),
        decoration: BoxDecoration(
          color: const Color(0xff000000).withOpacity(0.20),
          borderRadius: BorderRadius.circular(5.r),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 30.w,
              height: 30.h,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xff000000).withOpacity(0.35),
                  width: 1.0.w,
                  style: BorderStyle.solid,
                ),
                image: DecorationImage(
                  image: imageBytes.isEmpty
                      ? const AssetImage("assets/Images/default_pastry_img.jpg") as ImageProvider
                      : MemoryImage(imageBytes),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: ReusableTextWidget(
                text: title ?? "No Pastry Name",
                size: xsFontSize,
                FW: lFontWeight,
                color: Colors.white,
              ),
            ),
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

  Widget _buildPlaceholderListItem(DailySale entry) {
    return Container(
      height: 40.h,
      margin: EdgeInsets.only(bottom: 10.h),
      padding: EdgeInsets.fromLTRB(5.w, 5.h, 20.w, 5.h),
      decoration: BoxDecoration(
        color: const Color(0xff000000).withOpacity(0.20),
        borderRadius: BorderRadius.circular(5.r),
      ),
      child: Row(
        children: [
          Container(
            width: 30.w,
            height: 30.h,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.grey,
            ),
            child: Icon(Icons.warning, size: 15.w, color: Colors.white),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: ReusableTextWidget(
              text: "Pastry ID ${entry.pastryId} not found",
              size: xsFontSize,
              FW: lFontWeight,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatColumn(String header, String subText) {
    return Column(
      children: [
        ReusableTextWidget(
          text: header,
          size: xsFontSize,
          color: const Color(0xff503600),
          FW: lFontWeight,
        ),
        SizedBox(height: 0.h),
        ReusableTextWidget(
          text: subText,
          size: xsFontSize,
          FW: lFontWeight,
          color: Colors.white,
        ),
      ],
    );
  }
}