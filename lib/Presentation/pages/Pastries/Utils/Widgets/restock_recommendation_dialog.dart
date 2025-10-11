import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nxbakers/Common/AppData.dart';
import 'package:nxbakers/Common/Widgets/reusable_text_widget.dart';
import 'package:nxbakers/Data/Model/pastry.dart';
import 'package:nxbakers/Domain/Services/restock_calculator.dart';

class RestockRecommendationDialog extends StatefulWidget {
  final Pastry pastry;
  final int analysisPeriodDays;

  const RestockRecommendationDialog({
    super.key,
    required this.pastry,
    this.analysisPeriodDays = 14,
  });

  @override
  State<RestockRecommendationDialog> createState() =>
      _RestockRecommendationDialogState();
}

class _RestockRecommendationDialogState
    extends State<RestockRecommendationDialog> {
  final RestockCalculator _calculator = RestockCalculator();

  bool _isLoading = true;
  RestockRecommendation? _recommendation;
  int? _selectedDays;
  int _customDays = 1;

  @override
  void initState() {
    super.initState();
    _loadRecommendations();
  }

  Future<void> _loadRecommendations() async {
    final rec = await _calculator.calculateRestock(
      pastry: widget.pastry,
      analysisPeriodDays: widget.analysisPeriodDays,
      coverageDays: [1, 2, 3, 5, 7],
    );

    setState(() {
      _recommendation = rec;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFFF2EADE),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Container(
        padding: EdgeInsets.all(20.w),
        constraints: BoxConstraints(maxHeight: 600.h),
        child: _isLoading ? _buildLoading() : _buildContent(),
      ),
    );
  }

  Widget _buildLoading() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const CircularProgressIndicator(
          color: Color(0xFF573E1A),
        ),
        SizedBox(height: 20.h),
        ReusableTextWidget(
          text: "Analyzing sales data...",
          color: const Color(0xFF573E1A),
          size: sFontSize,
          FW: sFontWeight,
        ),
      ],
    );
  }

  Widget _buildContent() {
    if (_recommendation == null || !_recommendation!.hasEnoughData) {
      return _buildNoDataContent();
    }

    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(
                Icons.inventory_2_outlined,
                color: const Color(0xFF573E1A),
                size: 28.w,
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ReusableTextWidget(
                      text: "Restock Recommendation",
                      color: const Color(0xFF573E1A),
                      size: xlFontSize,
                      FW: lFontWeight,
                    ),
                    ReusableTextWidget(
                      text: widget.pastry.title,
                      color: const Color(0xFF8B7355),
                      size: sFontSize,
                      FW: sFontWeight,
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
                color: const Color(0xFF573E1A),
              ),
            ],
          ),

          SizedBox(height: 20.h),

          // Current Status
          _buildStatusCard(),

          SizedBox(height: 20.h),

          // Recommendations
          ReusableTextWidget(
            text: "Recommended Quantities",
            color: const Color(0xFF573E1A),
            size: lFontSize,
            FW: lFontWeight,
          ),
          SizedBox(height: 12.h),

          ..._buildRecommendationCards(),

          SizedBox(height: 15.h),

          // Custom Days Input
          _buildCustomInput(),

          SizedBox(height: 20.h),

          // Action Buttons
          if (_selectedDays != null) ...[
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // TODO: Navigate to add stock page with pre-filled quantity
                  Navigator.pop(context, {
                    'days': _selectedDays,
                    'quantity': _recommendation!.recommendations[_selectedDays],
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  padding: EdgeInsets.symmetric(vertical: 15.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
                child: ReusableTextWidget(
                  text: "Add Stock Now",
                  color: Colors.white,
                  size: sFontSize,
                  FW: lFontWeight,
                ),
              ),
            ),
            SizedBox(height: 10.h),
          ],

          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () => Navigator.pop(context),
              child: ReusableTextWidget(
                text: "Close",
                color: const Color(0xFF573E1A),
                size: sFontSize,
                FW: sFontWeight,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoDataContent() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.info_outline,
          color: Colors.orange.shade700,
          size: 48.w,
        ),
        SizedBox(height: 20.h),
        ReusableTextWidget(
          text: "Not Enough Sales Data",
          color: const Color(0xFF573E1A),
          size: xlFontSize,
          FW: xlFontWeight,
        ),
        SizedBox(height: 10.h),
        Text(
          "We need at least 3 days of sales data to provide accurate recommendations.\n\nCurrent data: ${_recommendation?.daysOfData ?? 0} days",
          textAlign: TextAlign.center,
          style: TextStyle(
            color: const Color(0xFF8B7355),
            fontSize: sFontSize.sp,
          ),
        ),
        SizedBox(height: 20.h),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: ReusableTextWidget(
            text: "Close",
            color: const Color(0xFF573E1A),
            size: sFontSize,
            FW: lFontWeight,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusCard() {
    return Container(
      padding: EdgeInsets.all(15.w),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStatusItem(
                "Current Stock",
                "${_recommendation!.currentStock} units",
                Icons.inventory,
              ),
              Container(
                width: 1.w,
                height: 40.h,
                color: const Color(0xFF8B7355).withOpacity(0.3),
              ),
              _buildStatusItem(
                "Avg Daily Sales",
                "${_recommendation!.averageDailySales.toStringAsFixed(1)} units",
                Icons.trending_up,
              ),
            ],
          ),
          SizedBox(height: 10.h),
          Divider(color: const Color(0xFF8B7355).withOpacity(0.3)),
          SizedBox(height: 10.h),
          ReusableTextWidget(
            text: "Based on last ${_recommendation!.daysOfData} days of sales",
            color: const Color(0xFF8B7355),
            size: xsFontSize,
            FW: sFontWeight,
          ),
        ],
      ),
    );
  }

  Widget _buildStatusItem(String label, String value, IconData icon) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: const Color(0xFF573E1A), size: 24.w),
          SizedBox(height: 5.h),
          ReusableTextWidget(
            text: label,
            color: const Color(0xFF8B7355),
            size: xsFontSize,
            FW: sFontWeight,
          ),
          SizedBox(height: 3.h),
          ReusableTextWidget(
            text: value,
            color: const Color(0xFF573E1A),
            size: sFontSize,
            FW: lFontWeight,
          ),
        ],
      ),
    );
  }

  List<Widget> _buildRecommendationCards() {
    final cards = <Widget>[];

    for (final entry in _recommendation!.recommendations.entries) {
      final days = entry.key;
      final quantity = entry.value;
      final isSelected = _selectedDays == days;

      cards.add(
        GestureDetector(
          onTap: () {
            setState(() {
              _selectedDays = days;
            });
          },
          child: Container(
            margin: EdgeInsets.only(bottom: 10.h),
            padding: EdgeInsets.all(15.w),
            decoration: BoxDecoration(
              color: isSelected
                  ? const Color(0xFF573E1A)
                  : Colors.white.withOpacity(0.5),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(
                color: isSelected
                    ? const Color(0xFF573E1A)
                    : Colors.transparent,
                width: 2,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(10.w),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Colors.white.withOpacity(0.2)
                        : const Color(0xFF573E1A).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: ReusableTextWidget(
                    text: "$days",
                    color: isSelected ? Colors.white : const Color(0xFF573E1A),
                    size: xlFontSize,
                    FW: lFontWeight,
                  ),
                ),
                SizedBox(width: 15.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ReusableTextWidget(
                        text: "$days Day${days > 1 ? 's' : ''} Coverage",
                        color: isSelected
                            ? Colors.white
                            : const Color(0xFF573E1A),
                        size: sFontSize,
                        FW: lFontWeight,
                      ),
                      SizedBox(height: 3.h),
                      ReusableTextWidget(
                        text: quantity > 0
                            ? "Add $quantity units → Total: ${_recommendation!.currentStock + quantity}"
                            : "Current stock sufficient",
                        color: isSelected
                            ? Colors.white.withOpacity(0.9)
                            : const Color(0xFF8B7355),
                        size: xsFontSize,
                        FW: sFontWeight,
                      ),
                    ],
                  ),
                ),
                if (isSelected)
                  Icon(
                    Icons.check_circle,
                    color: Colors.white,
                    size: 24.w,
                  ),
              ],
            ),
          ),
        ),
      );
    }

    return cards;
  }

  Widget _buildCustomInput() {
    return Container(
      padding: EdgeInsets.all(15.w),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ReusableTextWidget(
            text: "Custom Coverage Period",
            color: const Color(0xFF573E1A),
            size: sFontSize,
            FW: lFontWeight,
          ),
          SizedBox(height: 10.h),
          Row(
            children: [
              Expanded(
                child: TextField(
                  keyboardType: TextInputType.number,
                  style: TextStyle(
                    color: const Color(0xFF573E1A),
                    fontSize: sFontSize.sp,
                  ),
                  decoration: InputDecoration(
                    hintText: "Enter days",
                    hintStyle: TextStyle(
                      color: const Color(0xFF8B7355),
                      fontSize: xsFontSize.sp,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.r),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 15.w,
                      vertical: 12.h,
                    ),
                  ),
                  onChanged: (value) {
                    final days = int.tryParse(value);
                    if (days != null && days > 0) {
                      setState(() {
                        _customDays = days;
                      });
                    }
                  },
                ),
              ),
              SizedBox(width: 10.w),
              ElevatedButton(
                onPressed: () {
                  final needed = (_recommendation!.averageDailySales * _customDays).ceil() -
                      _recommendation!.currentStock;
                  setState(() {
                    _selectedDays = _customDays;
                    _recommendation!.recommendations[_customDays] = needed > 0 ? needed : 0;
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF573E1A),
                  padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
                child: ReusableTextWidget(
                  text: "Calculate",
                  color: Colors.white,
                  size: sFontSize,
                  FW: lFontWeight,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}