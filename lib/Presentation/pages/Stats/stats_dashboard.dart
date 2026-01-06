import 'dart:math';

import 'package:community_material_icon/community_material_icon.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nxbakers/Common/Widgets/reusable_text_widget.dart';
import 'package:nxbakers/Common/common_main.dart';
import 'package:nxbakers/Common/common_page_header.dart';
import 'package:nxbakers/Presentation/ViewModels/stats_viewmodel.dart';
import 'package:nxbakers/Presentation/pages/Stats/pastry_Stat.dart';
import 'package:provider/provider.dart';

import '../../../Common/AppData.dart';
import '../../../Common/color.dart';

class DailySalesStatsPage extends StatefulWidget {
  DailySalesStatsPage({Key? key}) : super(key: key);

  @override
  State<DailySalesStatsPage> createState() => _DailySalesStatsPageState();
}

class _DailySalesStatsPageState extends State<DailySalesStatsPage> with SingleTickerProviderStateMixin {
  late TabController tabController;

  final FocusNode _focusNode = FocusNode();
  final FocusNode _dropDownFocusNode = FocusNode();

  String? _selectedFilter;

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    tabController.dispose();
    _focusNode.dispose();
  }

  // Pastry data
  final Map<int, String> pastryNames = {
    0: 'Chocolate Cupcakes',
    1: 'Vanilla Cupcakes',
    2: 'Cinnamon Rolls',
    3: 'Snowball',
    4: 'Bran Muffins',
  };

  final Map<int, Color> pastryColors = {
    0: const Color(0xff8B4513), // Brown for Chocolate
    1: const Color(0xffFFF8DC), // Cream for Vanilla
    2: const Color(0xffD2691E), // Cinnamon color
    3: const Color(0xff87CEEB), // Sky blue for Snowball
    4: const Color(0xffCD853F), // Peru/tan for Bran
  };

  // Sales data for February 2025
  final Map<String, List<Map<String, dynamic>>> salesData = {
    "2025-02-11": [
      {"sold_stock": 0, "pastry_id": 0},
      {"sold_stock": 0, "pastry_id": 1},
      {"sold_stock": 8, "pastry_id": 2}
    ],
    "2025-02-12": [
      {"sold_stock": 9, "pastry_id": 0},
      {"sold_stock": 2, "pastry_id": 1},
      {"sold_stock": 1, "pastry_id": 2}
    ],
    "2025-02-13": [
      {"sold_stock": 6, "pastry_id": 0},
      {"sold_stock": 0, "pastry_id": 1},
      {"sold_stock": 2, "pastry_id": 2},
      {"sold_stock": 2, "pastry_id": 3}
    ],
    "2025-02-14": [
      {"sold_stock": 2, "pastry_id": 0},
      {"sold_stock": 7, "pastry_id": 1},
      {"sold_stock": 4, "pastry_id": 2},
      {"sold_stock": 5, "pastry_id": 3}
    ],
    "2025-02-15": [
      {"sold_stock": 6, "pastry_id": 1},
      {"sold_stock": 2, "pastry_id": 2},
      {"sold_stock": 3, "pastry_id": 3}
    ],
    "2025-02-16": [
      {"sold_stock": 6, "pastry_id": 1},
      {"sold_stock": 8, "pastry_id": 3}
    ],
    "2025-02-17": [
      {"sold_stock": 6, "pastry_id": 3}
    ],
    "2025-02-18": [
      {"sold_stock": 2, "pastry_id": 0},
      {"sold_stock": 8, "pastry_id": 1},
      {"sold_stock": 2, "pastry_id": 2},
      {"sold_stock": 7, "pastry_id": 3},
      {"sold_stock": 9, "pastry_id": 4}
    ],
    "2025-02-19": [
      {"sold_stock": 6, "pastry_id": 0},
      {"sold_stock": 6, "pastry_id": 1},
      {"sold_stock": 2, "pastry_id": 2},
      {"sold_stock": 7, "pastry_id": 3},
      {"sold_stock": 6, "pastry_id": 4}
    ],
    "2025-02-20": [
      {"sold_stock": 13, "pastry_id": 0},
      {"sold_stock": 2, "pastry_id": 1},
      {"sold_stock": 3, "pastry_id": 2},
      {"sold_stock": 5, "pastry_id": 3},
      {"sold_stock": 3, "pastry_id": 4}
    ],
    "2025-02-21": [
      {"sold_stock": 9, "pastry_id": 0},
      {"sold_stock": 1, "pastry_id": 1},
      {"sold_stock": 2, "pastry_id": 2},
      {"sold_stock": 2, "pastry_id": 3}
    ],
    "2025-02-22": [
      {"sold_stock": 0, "pastry_id": 0},
      {"sold_stock": 0, "pastry_id": 1},
      {"sold_stock": 9, "pastry_id": 3},
      {"sold_stock": 0, "pastry_id": 4}
    ],
    "2025-02-23": [
      {"sold_stock": 8, "pastry_id": 0},
      {"sold_stock": 4, "pastry_id": 1},
      {"sold_stock": 8, "pastry_id": 3},
      {"sold_stock": 19, "pastry_id": 4}
    ],
    "2025-02-24": [
      {"sold_stock": 8, "pastry_id": 0},
      {"sold_stock": 1, "pastry_id": 1},
      {"sold_stock": 8, "pastry_id": 4}
    ],
    "2025-02-25": [
      {"sold_stock": 2, "pastry_id": 0},
      {"sold_stock": 2, "pastry_id": 1},
      {"sold_stock": 1, "pastry_id": 2},
      {"sold_stock": 0, "pastry_id": 3},
      {"sold_stock": 10, "pastry_id": 4}
    ],
    "2025-02-26": [
      {"sold_stock": 4, "pastry_id": 0},
      {"sold_stock": 4, "pastry_id": 2},
      {"sold_stock": 1, "pastry_id": 3},
      {"sold_stock": 12, "pastry_id": 4}
    ],
    "2025-02-27": [
      {"sold_stock": 9, "pastry_id": 0},
      {"sold_stock": 1, "pastry_id": 2},
      {"sold_stock": 8, "pastry_id": 3},
      {"sold_stock": 5, "pastry_id": 4}
    ],
    "2025-02-28": [
      {"sold_stock": 2, "pastry_id": 0},
      {"sold_stock": 4, "pastry_id": 2},
      {"sold_stock": 9, "pastry_id": 3},
      {"sold_stock": 1, "pastry_id": 4}
    ]
  };

  // App styling
  final Color graphPrimaryColor = const Color(0xff634923);

  final Color secondary_color = Colors.grey.shade600;

  List<LineChartBarData> _buildLineChartData() {
    Map<int, List<FlSpot>> pastrySpots = {};

    // Initialize spots for each pastry
    for (int pastryId in pastryNames.keys) {
      pastrySpots[pastryId] = [];
    }

    // Sort dates and process
    List<String> sortedDates = salesData.keys.toList()..sort();

    for (int dayIndex = 0; dayIndex < sortedDates.length; dayIndex++) {
      String date = sortedDates[dayIndex];
      int day = int.parse(date.split('-')[2]);

      // Get sales for this day
      List<Map<String, dynamic>> daySales = salesData[date]!;

      // Create a map of sold stock by pastry_id for this day
      Map<int, int> soldByPastry = {};
      for (var sale in daySales) {
        soldByPastry[sale['pastry_id']] = sale['sold_stock'];
      }

      // Add spots for each pastry (0 if no sales that day)
      for (int pastryId in pastryNames.keys) {
        int sold = soldByPastry[pastryId] ?? 0;
        pastrySpots[pastryId]!.add(FlSpot(day.toDouble(), sold.toDouble()));
      }
    }

    // Convert to LineChartBarData
    return pastrySpots.entries.map((entry) {
      int pastryId = entry.key;
      List<FlSpot> spots = entry.value;

      return LineChartBarData(
        spots: spots,
        isCurved: true,
        color: pastryColors[pastryId],
        barWidth: 1.2.w,
        isStrokeCapRound: true,
        preventCurveOverShooting: true,
        dotData: FlDotData(
          show: true,
          getDotPainter: (spot, percent, barData, index) {
            return FlDotCirclePainter(
              radius: 2.r,
              color: pastryColors[pastryId]!,
              strokeWidth: 0.5.w,
              strokeColor: Colors.white,
            );
          },
        ),
        belowBarData: BarAreaData(
          show: true,
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              primaryColor.withOpacity(0.5),
              const Color(0xff000000).withOpacity(0.2),
            ],
          ),
        ),
      );
    }).toList();
  }

  // Calculate performance metrics
  Map<int, Map<String, dynamic>> _calculatePerformanceMetrics() {
    Map<int, Map<String, dynamic>> metrics = {};

    for (int pastryId in pastryNames.keys) {
      List<int> allSales = [];
      Map<String, int> dailySales = {};

      // Collect all sales data for this pastry
      salesData.forEach((date, sales) {
        for (var sale in sales) {
          if (sale['pastry_id'] == pastryId) {
            int sold = sale['sold_stock'];
            allSales.add(sold);
            dailySales[date] = sold;
          }
        }
      });

      if (allSales.isEmpty) {
        metrics[pastryId] = {
          'total_sales': 0,
          'average_daily': 0.0,
          'best_day': {'date': 'N/A', 'quantity': 0},
          'worst_day': {'date': 'N/A', 'quantity': 0},
          'days_active': 0,
          'consistency': 0.0,
        };
        continue;
      }

      // Total sales
      int totalSales = allSales.reduce((a, b) => a + b);

      // Days active (days where sales > 0)
      int daysActive = allSales.where((s) => s > 0).length;

      // Average daily sales
      double averageDaily = daysActive > 0 ? totalSales / daysActive : 0.0;

      // Best and worst days
      String bestDate = '';
      int bestQuantity = 0;
      String worstDate = '';
      int worstQuantity = 999;

      dailySales.forEach((date, quantity) {
        if (quantity > 0) {
          if (quantity > bestQuantity) {
            bestQuantity = quantity;
            bestDate = date;
          }
          if (quantity < worstQuantity) {
            worstQuantity = quantity;
            worstDate = date;
          }
        }
      });

      // Sales consistency (standard deviation)
      double mean = averageDaily;
      double variance = 0;
      List<int> activeSales = allSales.where((s) => s > 0).toList();
      if (activeSales.isNotEmpty) {
        for (int sale in activeSales) {
          variance += pow(sale - mean, 2);
        }
        variance /= activeSales.length;
      }
      double consistency = sqrt(variance);

      metrics[pastryId] = {
        'total_sales': totalSales,
        'average_daily': averageDaily,
        'best_day': {'date': bestDate.isNotEmpty ? bestDate.split('-')[2] : 'N/A', 'quantity': bestQuantity},
        'worst_day': {'date': worstDate.isNotEmpty ? worstDate.split('-')[2] : 'N/A', 'quantity': worstQuantity},
        'days_active': daysActive,
        'consistency': consistency,
      };
    }

    return metrics;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Consumer<StatsViewModel>(
      builder: (BuildContext context, StatsViewModel viewModel, Widget? child) {
        return Scaffold(
          body: CommonMain(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 85.h,
                  color: const Color(0xffF2EADE),
                  padding: EdgeInsets.only(bottom: 15.h),
                  child: Column(
                    children: [
                      Expanded(child: Container()),
                      const CommonPageHeader(
                        pageTitle: "Statistics",
                        pageSubTitle: "Keep track of business performance",
                      ),
                    ],
                  ),
                ),
                /**
                 * TOP-BAR for Different Business Assets Performance
                 */
                Container(
                  width: size.width,
                  height: 30.h,
                  padding: EdgeInsets.symmetric(horizontal: 10.w),
                  color: const Color.fromRGBO(0, 0, 0, 0.15),
                  child: TabBar(
                    labelPadding: EdgeInsets.zero,
                    controller: tabController,
                    labelColor: const Color(0xff5D3700),
                    indicatorColor: Colors.transparent,
                    indicatorPadding: EdgeInsets.zero,
                    labelStyle: GoogleFonts.poppins(
                      fontSize: lFontSize.sp,
                      fontWeight: lFontWeight,
                    ),
                    unselectedLabelColor: Colors.white,
                    unselectedLabelStyle: GoogleFonts.poppins(
                      fontSize: sFontSize.sp,
                      fontWeight: sFontWeight,
                    ),
                    tabs: const [
                      Tab(text: 'Daily Sales'),
                      Tab(text: 'Pastries'),
                      Tab(text: 'Ingredients'),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.only(top: 20.h),
                  width: MediaQuery.of(context).size.width,
                  height: 700.h,
                  child: TabBarView(
                    controller: tabController,
                    children: [
                      _buildDailySales(),
                      PastryStats(),
                    ],
                  ),
                ),
                /**
                 * Main page content
                 */
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDailySales() {
    return Expanded(
      child: ListView(
        padding: EdgeInsets.only(left: 10.w, right: 10.w, bottom: 100.h),
        physics: const AlwaysScrollableScrollPhysics(),
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
        children: [
          ReusableTextWidget(
            text: "Best Performance",
            color: graphPrimaryColor,
            size: lFontSize,
            FW: lFontWeight,
          ),
          SizedBox(
            height: 10.h,
          ),
          /**
           * Showing The Top performer Sales for that day
           * CARD----
           * */
          Container(
            padding: EdgeInsets.all(10.0.w),
            height: 80.h,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.r),
              color: primaryColor,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ReusableTextWidget(
                      text: "Highest Revenue Day".toUpperCase(),
                      color: graphPrimaryColor,
                      size: sFontSize,
                    ),
                    ReusableTextWidget(
                      text: "Lowest revenue day".toUpperCase(),
                      color: graphPrimaryColor,
                      size: sFontSize,
                    )
                  ],
                ),
                SizedBox(
                  height: 10.h,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 5.w,
                      children: [
                        ReusableTextWidget(
                          text: "R1 204",
                          color: const Color(0xff56452D),
                          size: sFontSize,
                          FW: sFontWeight,
                        ),
                        Container(
                          width: 25.w,
                          color: const Color(0xffAA9C88).withOpacity(0.5),
                          height: 1.h,
                        ),
                        ReusableTextWidget(
                          text: "20 May",
                          color: const Color(0xff56452D),
                          size: sFontSize,
                          FW: sFontWeight,
                        ),
                      ],
                    ),
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 5.w,
                      children: [
                        ReusableTextWidget(
                          text: "R1 204",
                          color: const Color(0xff56452D),
                          size: sFontSize,
                          FW: sFontWeight,
                        ),
                        Container(
                          width: 25.w,
                          color: const Color(0xffAA9C88).withOpacity(0.5),
                          height: 1.h,
                        ),
                        ReusableTextWidget(
                          text: "20 May",
                          color: const Color(0xff56452D),
                          size: sFontSize,
                          FW: sFontWeight,
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(
                  height: 5.h,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ReusableTextWidget(
                      text: "Day",
                      color: const Color(0xff6D6457),
                      FW: sFontWeight,
                      size: sFontSize,
                    ),
                    ReusableTextWidget(
                      text: "Day",
                      color: const Color(0xff6D6457),
                      size: sFontSize,
                      FW: sFontWeight,
                    )
                  ],
                ),
              ],
            ),
          ),
          SizedBox(
            height: 20.h,
          ),
          ReusableTextWidget(
            text: "Statistic Graph",
            color: graphPrimaryColor,
            size: lFontSize,
            FW: lFontWeight,
          ),
          SizedBox(
            height: 10.h,
          ),
          /**
           * Chart Container
           */
          Container(
            height: 440.h,
            padding: EdgeInsets.all(15.w),
            decoration: BoxDecoration(
              color: primaryColor,
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Column(
              children: [
                ReusableTextWidget(
                  text: 'Daily Sales Statistics Graph',
                  size: lFontSize,
                  FW: xlFontWeight,
                  color: const Color(0xFF573E1A),
                ),
                SizedBox(height: 10.h),
                /**
                 * Dropdown Button for filtering the graph
                 */
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Container(),
                    ),

                    /**
                     * Dropdown Button to filter the graph
                     */
                    SizedBox(
                      width: 55.w,
                      height: 30.h,
                      child: DropdownButtonFormField<String>(
                        alignment: Alignment.center,
                        isExpanded: true,
                        focusNode: _dropDownFocusNode,
                        elevation: 0,
                        dropdownColor: const Color(0xffD8C6AD),
                        style: GoogleFonts.poppins(fontSize: sFontSize.sp, color: const Color(0xff7D6543), fontWeight: sFontWeight),
                        value: _selectedFilter,
                        items: ["Day", "Week", "Month"].map((value) {
                          return DropdownMenuItem(
                            value: value,
                            child: ReusableTextWidget(
                              text: value,
                              color: const Color(0xff351F00),
                              size: sFontSize,
                              FW: sFontWeight,
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedFilter = value;
                          });
                        },
                        hint: ReusableTextWidget(
                          text: "Month",
                          size: sFontSize,
                          FW: sFontWeight,
                          color: const Color(0xff7D6543),
                        ),
                        iconSize: 20.w,
                        icon: const Icon(Icons.keyboard_arrow_down_rounded),
                        iconEnabledColor: const Color(0xff7D6543),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          isDense: true,
                          hintStyle: GoogleFonts.poppins(
                            fontSize: 8.sp,
                            fontWeight: FontWeight.w200,
                            color: const Color(0xff515151),
                          ),
                          // hintText: "select category",
                        ),
                      ),
                    ),
                  ],
                ),
                Expanded(
                  child: LineChart(
                    curve: Curves.easeInOut,
                    LineChartData(
                      backgroundColor: const Color(0xff000000).withOpacity(0.1),
                      gridData: FlGridData(
                        show: false,
                        drawVerticalLine: false,
                        horizontalInterval: 2,
                        verticalInterval: 2,
                        getDrawingHorizontalLine: (value) {
                          return FlLine(
                            color: Colors.grey.shade300,
                            strokeWidth: 1,
                          );
                        },
                        getDrawingVerticalLine: (value) {
                          return FlLine(
                            color: Colors.grey.shade300,
                            strokeWidth: 1,
                          );
                        },
                      ),
                      titlesData: FlTitlesData(
                        show: true,
                        rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        bottomTitles: AxisTitles(
                          axisNameWidget: ReusableTextWidget(
                            text: 'Day',
                            size: lFontSize,
                            FW: lFontWeight,
                            color: graphPrimaryColor,
                          ),
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 30.sp,
                            interval: 2,
                            getTitlesWidget: (value, meta) {
                              return ReusableTextWidget(
                                text: value.toInt().toString(),
                                size: sFontSize,
                                FW: lFontWeight,
                                color: secondary_color,
                              );
                            },
                          ),
                        ),
                        leftTitles: AxisTitles(
                          axisNameWidget: ReusableTextWidget(
                            text: 'Sales',
                            size: lFontSize,
                            FW: lFontWeight,
                            color: graphPrimaryColor,
                          ),
                          sideTitles: SideTitles(
                            showTitles: true,
                            interval: 2,
                            reservedSize: 40,
                            getTitlesWidget: (value, meta) {
                              return ReusableTextWidget(
                                text: value.toInt().toString(),
                                size: sFontSize,
                                FW: lFontWeight,
                                color: secondary_color,
                              );
                            },
                          ),
                        ),
                      ),
                      borderData: FlBorderData(
                        show: false,
                        border: Border.all(color: Colors.grey.shade400),
                      ),
                      minX: 11,
                      maxX: 28,
                      minY: 0,
                      maxY: 28,
                      lineBarsData: _buildLineChartData(),
                      lineTouchData: LineTouchData(
                        touchTooltipData: LineTouchTooltipData(
                          tooltipBgColor: graphPrimaryColor.withOpacity(0.9),
                          getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
                            return touchedBarSpots.map((barSpot) {
                              final pastryId = touchedBarSpots.indexOf(barSpot);
                              return LineTooltipItem(
                                '${pastryNames[pastryId]}\n${barSpot.y.toInt()} sold',
                                TextStyle(
                                  fontFamily: 'poppins',
                                  color: Colors.white,
                                  fontWeight: lFontWeight,
                                  fontSize: sFontSize.toDouble(),
                                ),
                              );
                            }).toList();
                          },
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 10.h,
                ),
                // const Divider(),
                // SizedBox(height: 10.h),
                // Legend
                Container(
                  width: MediaQuery.of(context).size.width,
                  padding: EdgeInsets.all(10.w),
                  decoration: BoxDecoration(
                    color: const Color.fromRGBO(0, 0, 0, 0.1),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ReusableTextWidget(
                        text: 'Pastry Legend',
                        size: lFontSize,
                        FW: lFontWeight,
                        color: graphPrimaryColor,
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 16,
                        runSpacing: 8,
                        children: pastryNames.entries.map((entry) {
                          return Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 20,
                                height: 20,
                                decoration: BoxDecoration(
                                  color: pastryColors[entry.key],
                                  shape: BoxShape.circle,
                                  border: Border.all(color: primaryColor, width: 2.w),
                                ),
                              ),
                              const SizedBox(width: 6),
                              ReusableTextWidget(
                                text: entry.value,
                                size: sFontSize,
                                FW: lFontWeight,
                                color: Colors.black,
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 20.h,
          ),

          /**
           * Header
           */
          ReusableTextWidget(
            text: "Highlights",
            color: graphPrimaryColor,
            size: lFontSize,
            FW: lFontWeight,
          ),
          SizedBox(
            height: 10.h,
          ),
          Container(
            padding: EdgeInsets.all(10.0.w),
            height: 80.h,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.r),
              color: primaryColor,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ReusableTextWidget(
                  text: "Most common top seller".toUpperCase(),
                  color: graphPrimaryColor,
                  size: sFontSize,
                ),
                SizedBox(
                  height: 10.h,
                ),
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 5.w,
                  children: [
                    ReusableTextWidget(
                      text: "Snowball",
                      color: const Color(0xff56452D),
                      size: sFontSize,
                      FW: sFontWeight,
                    ),
                    Container(
                      width: 25.w,
                      color: const Color(0xffAA9C88).withOpacity(0.5),
                      height: 1.h,
                    ),
                    ReusableTextWidget(
                      text: "20 times",
                      color: const Color(0xff56452D),
                      size: sFontSize,
                      FW: sFontWeight,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
