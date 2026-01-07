import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nxbakers/Common/Widgets/reusable_text_widget.dart';

class PastryStats extends StatelessWidget {
  PastryStats({Key? key}) : super(key: key);

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
  final Color primaryColor = const Color(0xff634923);
  final Color secondaryColor = Colors.grey.shade600;
  final Color availableStatus = Colors.green;
  final Color middleStatus = const Color(0xffFD9602);
  final int xlFontSize = 16;
  final int lFontSize = 12;
  final int sFontSize = 10;
  final int xsFontSize = 8;
  final FontWeight xxlFontWeight = FontWeight.w800;
  final FontWeight xlFontWeight = FontWeight.w500;
  final FontWeight lFontWeight = FontWeight.w400;
  final FontWeight sFontWeight = FontWeight.w300;

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
        'best_day': {
          'date': bestDate.isNotEmpty ? bestDate.split('-')[2] : 'N/A',
          'quantity': bestQuantity
        },
        'worst_day': {
          'date': worstDate.isNotEmpty ? worstDate.split('-')[2] : 'N/A',
          'quantity': worstQuantity
        },
        'days_active': daysActive,
        'consistency': consistency,
      };
    }

    return metrics;
  }

  Widget _buildPerformanceCard(
      int pastryId, Map<String, dynamic> metrics, BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: pastryColors[pastryId]!, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with pastry name and color indicator
          Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: pastryColors[pastryId],
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  pastryNames[pastryId]!,
                  style: TextStyle(
                    fontSize: xlFontSize.toDouble(),
                    fontWeight: xxlFontWeight,
                    color: primaryColor,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: pastryColors[pastryId]!.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${metrics['total_sales']} Total',
                  style: TextStyle(
                    fontSize: lFontSize.toDouble(),
                    fontWeight: xlFontWeight,
                    color: pastryColors[pastryId],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Metrics Grid
          Row(
            children: [
              Expanded(
                child: _buildMetricItem(
                  'Avg Daily',
                  '${metrics['average_daily'].toStringAsFixed(1)}',
                  Icons.trending_up,
                  availableStatus,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMetricItem(
                  'Days Active',
                  '${metrics['days_active']}',
                  Icons.calendar_today,
                  middleStatus,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: _buildMetricItem(
                  'Best Day',
                  'Feb ${metrics['best_day']['date']} (${metrics['best_day']['quantity']})',
                  Icons.star,
                  Colors.amber,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMetricItem(
                  'Worst Day',
                  'Feb ${metrics['worst_day']['date']} (${metrics['worst_day']['quantity']})',
                  Icons.arrow_downward,
                  Colors.red.shade400,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Consistency indicator
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.show_chart,
                  size: 16,
                  color: secondaryColor,
                ),
                const SizedBox(width: 8),
                Text(
                  'Sales Consistency: ',
                  style: TextStyle(
                    fontSize: sFontSize.toDouble(),
                    fontWeight: lFontWeight,
                    color: secondaryColor,
                  ),
                ),
                Text(
                  metrics['consistency'] < 2
                      ? 'Very Stable'
                      : metrics['consistency'] < 4
                      ? 'Stable'
                      : 'Variable',
                  style: TextStyle(
                    fontSize: sFontSize.toDouble(),
                    fontWeight: xlFontWeight,
                    color: metrics['consistency'] < 2
                        ? availableStatus
                        : metrics['consistency'] < 4
                        ? middleStatus
                        : Colors.red.shade400,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricItem(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: color),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: xsFontSize.toDouble(),
                  fontWeight: sFontWeight,
                  color: secondaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: sFontSize.toDouble(),
              fontWeight: xlFontWeight,
              color: color,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final performanceMetrics = _calculatePerformanceMetrics();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Expanded(
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          shrinkWrap: true,
          padding: EdgeInsets.only(left:10.w, right:10.w, bottom: 80.h, top: 20.h),
          children: [
            // Section Title
            ReusableTextWidget(text:
              'Pastry Performance Overview',
              size: lFontSize,
                FW: xlFontWeight,
                color: primaryColor,
            ),
            SizedBox(height: 20.h),

            // Performance Cards
            ...pastryNames.keys.map((pastryId) {
              return _buildPerformanceCard(
                pastryId,
                performanceMetrics[pastryId]!,
                context,
              );
            }).toList(),

          ],
        ),
      ),
    );
  }
}