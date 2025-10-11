import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nxbakers/Common/AppData.dart';
import 'package:nxbakers/Common/Widgets/reusable_text_widget.dart';
import 'package:nxbakers/Common/common_main.dart';
import 'package:nxbakers/Data/Model/pastry.dart';
import 'package:nxbakers/Domain/Services/stock_monitor_service.dart';
import 'package:nxbakers/Presentation/pages/Pastries/Utils/Widgets/pastry_card.dart';
import 'package:nxbakers/Presentation/pages/Pastries/Utils/Widgets/restock_recommendation_dialog.dart';
import 'package:nxbakers/Presentation/pages/Pastries/pastry_details.dart';

class LowStockDetailsPage extends StatefulWidget {
  const LowStockDetailsPage({super.key});

  @override
  State<LowStockDetailsPage> createState() => _LowStockDetailsPageState();
}

class _LowStockDetailsPageState extends State<LowStockDetailsPage> {
  final StockMonitorService _monitor = StockMonitorService();
  List<Pastry> _lowStockPastries = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadLowStockPastries();
  }

  Future<void> _loadLowStockPastries() async {
    final pastries = await _monitor.checkLowStockPastries();
    if (mounted) {
      setState(() {
        _lowStockPastries = pastries;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFF2EADE),
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: const Color(0xFF573E1A),
            size: 24.w,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: ReusableTextWidget(
          text: "Low Stock Items",
          color: const Color(0xFF573E1A),
          size: xlFontSize,
          FW: lFontWeight,
        ),
      ),
      body: CommonMain(
        child: _isLoading
            ? const Center(
          child: CircularProgressIndicator(
            color: Color(0xFF573E1A),
          ),
        )
            : _lowStockPastries.isEmpty
            ? _buildEmptyState()
            : _buildLowStockList(),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.check_circle_outline,
            color: Colors.green.shade600,
            size: 80.w,
          ),
          SizedBox(height: 20.h),
          ReusableTextWidget(
            text: "All Stock Levels Good!",
            color: const Color(0xFF573E1A),
            size: xlFontSize,
            FW: lFontWeight,
          ),
          SizedBox(height: 10.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 40.w),
            child: Text(
              "No pastries are below their stock thresholds.",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: const Color(0xFF8B7355),
                fontSize: lFontSize.sp,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLowStockList() {
    return Column(
      children: [
        // Header Stats
        Container(
          margin: EdgeInsets.all(15.w),
          padding: EdgeInsets.all(20.w),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.orange.shade700,
                Colors.orange.shade600,
              ],
            ),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Row(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: Colors.white,
                size: 40.w,
              ),
              SizedBox(width: 15.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ReusableTextWidget(
                      text: "${_lowStockPastries.length} Items Need Attention",
                      color: Colors.white,
                      size: xlFontSize,
                      FW: lFontWeight,
                    ),
                    SizedBox(height: 5.h),
                    ReusableTextWidget(
                      text: "Restock soon to avoid running out",
                      color: Colors.white.withOpacity(0.9),
                      size: sFontSize,
                      FW: sFontWeight,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // List of low stock pastries
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: 10.w),
            itemCount: _lowStockPastries.length,
            itemBuilder: (context, index) {
              final pastry = _lowStockPastries[index];
              return _buildLowStockItem(pastry);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildLowStockItem(Pastry pastry) {
    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      decoration: BoxDecoration(
        color: const Color(0xFFF2EADE),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: Colors.orange.shade300,
          width: 2,
        ),
      ),
      child: Column(
        children: [
          // Pastry Card
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PastryDetails(pastryId: pastry.id!),
                ),
              );
            },
            child: PastryCard(pastry: pastry),
          ),

          // Action Buttons
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.5),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(12.r),
                bottomRight: Radius.circular(12.r),
              ),
            ),
            child: Row(
              children: [
                // View Recommendations Button
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => RestockRecommendationDialog(
                          pastry: pastry,
                        ),
                      );
                    },
                    icon: Icon(
                      Icons.lightbulb_outline,
                      size: 18.w,
                      color: Colors.white,
                    ),
                    label: ReusableTextWidget(
                      text: "Recommendations",
                      color: Colors.white,
                      size: xsFontSize,
                      FW: lFontWeight,
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF573E1A),
                      padding: EdgeInsets.symmetric(vertical: 10.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                    ),
                  ),
                ),

                SizedBox(width: 10.w),

                // Snooze Button
                OutlinedButton(
                  onPressed: () => _showSnoozeOptions(pastry),
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(
                      horizontal: 15.w,
                      vertical: 10.h,
                    ),
                    side: const BorderSide(
                      color: Color(0xFF573E1A),
                      width: 2,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                  child: Icon(
                    Icons.snooze,
                    color: const Color(0xFF573E1A),
                    size: 20.w,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showSnoozeOptions(Pastry pastry) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
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
            ReusableTextWidget(
              text: "Snooze Notification",
              color: const Color(0xFF573E1A),
              size: xlFontSize,
              FW: lFontWeight,
            ),
            SizedBox(height: 20.h),

            _buildSnoozeOption("1 Hour", Duration(hours: 1), pastry),
            _buildSnoozeOption("4 Hours", Duration(hours: 4), pastry),
            _buildSnoozeOption("1 Day", Duration(days: 1), pastry),
            _buildSnoozeOption("3 Days", Duration(days: 3), pastry),

            SizedBox(height: 10.h),

            TextButton(
              onPressed: () => Navigator.pop(context),
              child: ReusableTextWidget(
                text: "Cancel",
                color: const Color(0xFF573E1A),
                size: lFontSize,
                FW: sFontWeight,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSnoozeOption(String label, Duration duration, Pastry pastry) {
    return Container(
        width: double.infinity,
        margin: EdgeInsets.only(bottom: 10.h),
        child: ElevatedButton(
            onPressed: () async {await _monitor.snoozeNotification(pastry.id!, duration);
            if (mounted) {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: Colors.green.shade700,
                  content: ReusableTextWidget(
                    text: 'Notification snoozed for $label',
                    color: Colors.white,
                    size: sFontSize,
                    FW: sFontWeight,
                  ),
                ),
              );
              // Refresh the list
              _loadLowStockPastries();
            }
            },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            padding: EdgeInsets.symmetric(vertical: 15.h),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.r),
            ),
          ),
          child: ReusableTextWidget(
            text: label,
            color: const Color(0xFF573E1A),
            size: lFontSize,
            FW: lFontWeight,
          ),
        ),
    );
  }
}