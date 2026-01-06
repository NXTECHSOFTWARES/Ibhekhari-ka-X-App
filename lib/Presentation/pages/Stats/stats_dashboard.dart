import 'package:community_material_icon/community_material_icon.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nxbakers/Common/Widgets/reusable_text_widget.dart';
import 'package:nxbakers/Common/common_main.dart';
import 'package:nxbakers/Common/common_page_header.dart';
import 'package:nxbakers/Presentation/ViewModels/stats_viewmodel.dart';
import 'package:provider/provider.dart';

import '../../../Common/AppData.dart';
import '../../../Common/color.dart';

class DailySalesStatsPage extends StatefulWidget {
  DailySalesStatsPage({Key? key}) : super(key: key);

  @override
  State<DailySalesStatsPage> createState() => _DailySalesStatsPageState();
}

class _DailySalesStatsPageState extends State<DailySalesStatsPage> {
  String? _selectedFilter;

  final FocusNode _focusNode = FocusNode();
  final FocusNode _dropDownFocusNode = FocusNode();

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
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
        barWidth: 3,
        isStrokeCapRound: true,
        dotData: FlDotData(
          show: true,
          getDotPainter: (spot, percent, barData, index) {
            return FlDotCirclePainter(
              radius: 4,
              color: pastryColors[pastryId]!,
              strokeWidth: 2,
              strokeColor: Colors.white,
            );
          },
        ),
        belowBarData: BarAreaData(show: false),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Consumer<StatsViewModel>(
      builder: (BuildContext context, StatsViewModel viewModel, Widget? child) {
        return Scaffold(
          body: CommonMain(
            child: SingleChildScrollView(
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
                   * Tab bar for Different Business Asset Performance
                   */
                  Container(
                    width: size.width,
                    height: 30.h,
                    padding: EdgeInsets.symmetric(horizontal: 10.w),
                    color: const Color.fromRGBO(0, 0, 0, 0.15),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ReusableTextWidget(
                          text: "Daily Sales",
                          color: const Color(0xff5D3700),
                          size: sFontSize,
                          FW: lFontWeight,
                        ),
                        ReusableTextWidget(
                          text: "Pastries",
                          color: Colors.white,
                          size: sFontSize,
                          FW: sFontWeight,
                        ),
                        ReusableTextWidget(
                          text: "Ingredients",
                          color: Colors.white,
                          size: sFontSize,
                          FW: sFontWeight,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 20.h,
                  ),
                  /**
                   * Main page content
                   */
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10.w),
                    child: Column(
                      children: [
                        /**
                         * Showing The Top performer Sales for that day
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
                                    text: "Best Of Sales",
                                    color: graphPrimaryColor,
                                    size: lFontSize,
                                  ),
                                  ReusableTextWidget(
                                    text: "Least Of Sales",
                                    color: graphPrimaryColor,
                                    size: lFontSize,
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

                        // Chart
                        Container(
                          height: 440.h,
                          padding: const EdgeInsets.all(16),
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
                                  LineChartData(
                                    gridData: FlGridData(
                                      show: false,
                                      drawVerticalLine: true,
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
                                          FW: xlFontWeight,
                                          color: graphPrimaryColor,
                                        ),
                                        sideTitles: SideTitles(
                                          showTitles: true,
                                          reservedSize: 30,
                                          interval: 2,
                                          getTitlesWidget: (value, meta) {
                                            return Text(
                                              value.toInt().toString(),
                                              style: TextStyle(
                                                fontSize: sFontSize.toDouble(),
                                                fontWeight: lFontWeight,
                                                color: secondary_color,
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                      leftTitles: AxisTitles(
                                        axisNameWidget: Text(
                                          'Sales',
                                          style: TextStyle(
                                            fontSize: lFontSize.toDouble(),
                                            fontWeight: xlFontWeight,
                                            color: graphPrimaryColor,
                                          ),
                                        ),
                                        sideTitles: SideTitles(
                                          showTitles: true,
                                          interval: 2,
                                          reservedSize: 40,
                                          getTitlesWidget: (value, meta) {
                                            return Text(
                                              value.toInt().toString(),
                                              style: TextStyle(
                                                fontSize: sFontSize.toDouble(),
                                                fontWeight: lFontWeight,
                                                color: secondary_color,
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                    borderData: FlBorderData(
                                      show: true,
                                      border: Border.all(color: Colors.grey.shade400),
                                    ),
                                    minX: 11,
                                    maxX: 28,
                                    minY: 0,
                                    maxY: 20,
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
                                                color: Colors.white,
                                                fontWeight: xlFontWeight,
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
                              const Divider(),
                              SizedBox(height: 10.h),
                              // Legend
                              Container(
                                decoration: BoxDecoration(
                                  // color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
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
                                                border: Border.all(color: Colors.white, width: 2),
                                              ),
                                            ),
                                            const SizedBox(width: 6),
                                            ReusableTextWidget(
                                              text: entry.value,
                                              size: sFontSize,
                                              FW: lFontWeight,
                                              color: secondary_color,
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
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
