import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nxbakers/Common/AppData.dart';
import 'package:nxbakers/Common/Widgets/reusable_text_widget.dart';
import 'package:nxbakers/Data/Model/pastry.dart';
import 'package:nxbakers/Domain/Services/stock_monitor_service.dart';

class LowStockBanner extends StatefulWidget {
  final VoidCallback onViewDetails;

  const LowStockBanner({
    super.key,
    required this.onViewDetails,
  });

  @override
  State<LowStockBanner> createState() => _LowStockBannerState();
}

class _LowStockBannerState extends State<LowStockBanner> {
  final StockMonitorService _monitor = StockMonitorService();
  List<Pastry> _lowStockPastries = [];
  bool _isVisible = true;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkLowStock();
  }

  Future<void> _checkLowStock() async {
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
    if (_isLoading || _lowStockPastries.isEmpty || !_isVisible) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: EdgeInsets.fromLTRB(5.w, 0.w ,5.w ,10.h),
      padding: EdgeInsets.all(15.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.orange.shade700,
            Colors.orange.shade600,
          ],
        ),
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withOpacity(0.3),
            blurRadius: 8.r,
            offset: Offset(0, 4.h),
          ),
        ],
      ),
      child: Row(
        children: [
          // Warning Icon
          Container(
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.warning_amber_rounded,
              color: Colors.white,
              size: 28.w,
            ),
          ),

          SizedBox(width: 15.w),

          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ReusableTextWidget(
                  text: "${_lowStockPastries.length} ${_lowStockPastries.length == 1 ? 'Item Needs' : 'Items Need'} Restocking",
                  color: Colors.white,
                  size: lFontSize,
                  FW: lFontWeight,
                ),
                SizedBox(height: 3.h),
                ReusableTextWidget(
                  text: _lowStockPastries
                      .take(2)
                      .map((p) => p.title)
                      .join(', ') +
                      (_lowStockPastries.length > 2
                          ? ' and ${_lowStockPastries.length - 2} more'
                          : ''),
                  color: Colors.white.withOpacity(0.9),
                  size: xsFontSize,
                  FW: sFontWeight,
                ),
              ],
            ),
          ),

          SizedBox(width: 10.w),

          // Action Buttons
          Column(
            children: [
              // View Details Button
              GestureDetector(
                onTap: widget.onViewDetails,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 6.h,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: ReusableTextWidget(
                    text: "View",
                    color: Colors.orange.shade700,
                    size: xsFontSize,
                    FW: lFontWeight,
                  ),
                ),
              ),

              SizedBox(height: 5.h),

              // Dismiss Button
              GestureDetector(
                onTap: () {
                  setState(() {
                    _isVisible = false;
                  });
                },
                child: Icon(
                  Icons.close,
                  color: Colors.white,
                  size: 18.w,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}