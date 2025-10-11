import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nxbakers/Common/AppData.dart';
import 'package:nxbakers/Common/Widgets/reusable_text_widget.dart';
import 'package:nxbakers/Common/common_main.dart';
import 'package:nxbakers/Data/Model/pastry.dart';
import 'package:nxbakers/Data/Model/pastry_notification_settings.dart';
import 'package:nxbakers/Domain/Repositories/notification_settings_repo.dart';

import 'restock_recommendation_dialog.dart';

class PastrySettingsBottomSheet extends StatefulWidget {
  final Pastry pastry;

  const PastrySettingsBottomSheet({
    super.key,
    required this.pastry,
  });

  @override
  State<PastrySettingsBottomSheet> createState() =>
      _PastrySettingsBottomSheetState();
}

class _PastrySettingsBottomSheetState extends State<PastrySettingsBottomSheet> {
  final NotificationSettingsRepository _repo = NotificationSettingsRepository();

  bool _isLoading = true;
  bool _isSaving = false;

  // Settings values
  bool _notificationEnabled = true;
  double _stockThreshold = 5;
  int _reminderInterval = 2;
  int _coverageDays = 2;
  int _analysisPeriod = 14;

  // Reminder interval options
  final List<int> _reminderOptions = [1, 2, 4, 6, 8, 12, 24];

  // Coverage days options
  final List<int> _coverageOptions = [1, 2, 3, 5, 7];

  // Analysis period options
  final List<int> _analysisOptions = [7, 14, 30];

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final settings = await _repo.getSettings(widget.pastry.id!);

      setState(() {
        _notificationEnabled = settings.notificationEnabled;
        _stockThreshold = settings.lowStockThreshold.toDouble();
        _reminderInterval = settings.reminderIntervalHours;
        _coverageDays = settings.defaultCoverageDays;
        _analysisPeriod = settings.analysisPeriodDays;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load settings: $e')),
        );
      }
    }
  }

  Future<void> _saveSettings() async {
    setState(() {
      _isSaving = true;
    });

    try {
      final settings = PastryNotificationSettings(
        pastryId: widget.pastry.id!,
        lowStockThreshold: _stockThreshold.toInt(),
        notificationEnabled: _notificationEnabled,
        reminderIntervalHours: _reminderInterval,
        defaultCoverageDays: _coverageDays,
        analysisPeriodDays: _analysisPeriod,
      );

      final success = await _repo.saveSettings(settings);

      if (success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Colors.green.shade700,
              content: ReusableTextWidget(
                text: 'Settings saved successfully',
                color: Colors.white,
                size: sFontSize,
                FW: sFontWeight,
              ),
            ),
          );
          Navigator.pop(context);
        }
      } else {
        throw Exception('Failed to save');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red.shade700,
            content: Text('Failed to save settings: $e'),
          ),
        );
      }
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Container(
        height: 300.h,
        decoration: BoxDecoration(
          color: const Color(0xFFF2EADE),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20.r),
            topRight: Radius.circular(20.r),
          ),
        ),
        child: const Center(
          child: CircularProgressIndicator(
            color: Color(0xFF573E1A),
          ),
        ),
      );
    }

    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: const Color(0xFFF2EADE),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20.r),
          topRight: Radius.circular(20.r),
        ),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 20.h,),
                    ReusableTextWidget(
                      text: "Notification Settings",
                      color: const Color(0xFF573E1A),
                      size: xlFontSize,
                      FW: lFontWeight,
                    ),
                    SizedBox(height: 5.h),
                    ReusableTextWidget(
                      text: widget.pastry.title,
                      color: const Color(0xFF8B7355),
                      size: lFontSize,
                      FW: sFontWeight,
                    ),
                  ],
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                  color: const Color(0xFF573E1A),
                ),
              ],
            ),

            SizedBox(height: 25.h),

            // Enable Notifications Toggle
            _buildToggleSection(),

            if (_notificationEnabled) ...[
              SizedBox(height: 25.h),

              // Stock Threshold Slider
              _buildStockThresholdSection(),

              SizedBox(height: 25.h),

              // Reminder Interval
              _buildReminderIntervalSection(),

              SizedBox(height: 25.h),

              // Coverage Days
              _buildCoverageDaysSection(),

              SizedBox(height: 25.h),

              // Analysis Period
              _buildAnalysisPeriodSection(),
            ],

            SizedBox(height: 30.h),

            if (_notificationEnabled) ...[
              SizedBox(height: 20.h),

              // View Recommendations Button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => RestockRecommendationDialog(
                        pastry: widget.pastry,
                        analysisPeriodDays: _analysisPeriod,
                      ),
                    );
                  },
                  icon: Icon(
                    Icons.lightbulb_outline,
                    color: const Color(0xFF573E1A),
                    size: 20.w,
                  ),
                  label: ReusableTextWidget(
                    text: "View Restock Recommendations",
                    color: const Color(0xFF573E1A),
                    size: sFontSize,
                    FW: lFontWeight,
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    side: const BorderSide(color: Color(0xFF573E1A), width: 2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                ),
              ),
            ],

            SizedBox(height: 20.h),

            // Save Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _saveSettings,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  padding: EdgeInsets.symmetric(vertical: 15.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
                child: _isSaving
                    ? SizedBox(
                  height: 20.h,
                  width: 20.w,
                  child: const CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
                    : ReusableTextWidget(
                  text: "Save Settings",
                  color: Colors.white,
                  size: lFontSize,
                  FW: lFontWeight,
                ),
              ),
            ),

            SizedBox(height: 10.h),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleSection() {
    return Container(
      padding: EdgeInsets.all(15.w),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          Icon(
            Icons.notifications_active,
            color: _notificationEnabled
                ? const Color(0xFF573E1A)
                : Colors.grey,
            size: 24.w,
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ReusableTextWidget(
                  text: "Enable Notifications",
                  color: const Color(0xFF573E1A),
                  size: lFontSize,
                  FW: lFontWeight,
                ),
                SizedBox(height: 3.h),
                ReusableTextWidget(
                  text: "Get alerts when stock is low",
                  color: const Color(0xFF8B7355),
                  size: xsFontSize,
                  FW: sFontWeight,
                ),
              ],
            ),
          ),
          Switch(
            value: _notificationEnabled,
            onChanged: (value) {
              setState(() {
                _notificationEnabled = value;
              });
            },
            activeColor: const Color(0xFF573E1A),
          ),
        ],
      ),
    );
  }

  Widget _buildStockThresholdSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ReusableTextWidget(
              text: "Stock Alert Threshold",
              color: const Color(0xFF573E1A),
              size: lFontSize,
              FW: lFontWeight,
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: const Color(0xFF573E1A),
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: ReusableTextWidget(
                text: "${_stockThreshold.toInt()} units",
                color: Colors.white,
                size: sFontSize,
                FW: lFontWeight,
              ),
            ),
          ],
        ),
        SizedBox(height: 8.h),
        ReusableTextWidget(
          text: "Alert me when stock reaches this level",
          color: const Color(0xFF8B7355),
          size: xsFontSize,
          FW: sFontWeight,
        ),
        SizedBox(height: 12.h),
        SliderTheme(
          data: SliderThemeData(
            activeTrackColor: const Color(0xFF573E1A),
            inactiveTrackColor: const Color(0xFF573E1A).withOpacity(0.3),
            thumbColor: const Color(0xFF573E1A),
            overlayColor: const Color(0xFF573E1A).withOpacity(0.2),
            valueIndicatorColor: const Color(0xFF573E1A),
            valueIndicatorTextStyle: TextStyle(
              color: Colors.white,
              fontSize: 10.0.sp,
            ),
          ),
          child: Slider(
            value: _stockThreshold,
            min: 1,
            max: 50,
            divisions: 49,
            label: _stockThreshold.toInt().toString(),
            onChanged: (value) {
              setState(() {
                _stockThreshold = value;
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _buildReminderIntervalSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ReusableTextWidget(
          text: "Reminder Interval",
          color: const Color(0xFF573E1A),
          size: lFontSize,
          FW: lFontWeight,
        ),
        SizedBox(height: 8.h),
        ReusableTextWidget(
          text: "How often to remind if not resolved",
          color: const Color(0xFF8B7355),
          size: xsFontSize,
          FW: sFontWeight,
        ),
        SizedBox(height: 12.h),
        Wrap(
          spacing: 10.w,
          runSpacing: 10.h,
          children: _reminderOptions.map((hours) {
            final isSelected = _reminderInterval == hours;
            return GestureDetector(
              onTap: () {
                setState(() {
                  _reminderInterval = hours;
                });
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFF573E1A)
                      : Colors.white.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFF573E1A)
                        : Colors.transparent,
                    width: 2,
                  ),
                ),
                child: ReusableTextWidget(
                  text: hours == 1 ? "1 hour" : "$hours hours",
                  color: isSelected ? Colors.white : const Color(0xFF573E1A),
                  size: sFontSize,
                  FW: isSelected ? lFontWeight : sFontWeight,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildCoverageDaysSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ReusableTextWidget(
          text: "Default Stock Coverage",
          color: const Color(0xFF573E1A),
          size: lFontSize,
          FW: lFontWeight,
        ),
        SizedBox(height: 8.h),
        ReusableTextWidget(
          text: "Recommended restock for how many days",
          color: const Color(0xFF8B7355),
          size: xsFontSize,
          FW: sFontWeight,
        ),
        SizedBox(height: 12.h),
        Wrap(
          spacing: 10.w,
          runSpacing: 10.h,
          children: _coverageOptions.map((days) {
            final isSelected = _coverageDays == days;
            return GestureDetector(
              onTap: () {
                setState(() {
                  _coverageDays = days;
                });
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFF573E1A)
                      : Colors.white.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFF573E1A)
                        : Colors.transparent,
                    width: 2,
                  ),
                ),
                child: ReusableTextWidget(
                  text: days == 1 ? "1 day" : "$days days",
                  color: isSelected ? Colors.white : const Color(0xFF573E1A),
                  size: sFontSize,
                  FW: isSelected ? lFontWeight : sFontWeight,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildAnalysisPeriodSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ReusableTextWidget(
          text: "Sales Analysis Period",
          color: const Color(0xFF573E1A),
          size: lFontSize,
          FW: lFontWeight,
        ),
        SizedBox(height: 8.h),
        ReusableTextWidget(
          text: "Calculate average sales from last X days",
          color: const Color(0xFF8B7355),
          size: xsFontSize,
          FW: sFontWeight,
        ),
        SizedBox(height: 12.h),
        Row(
          children: _analysisOptions.map((days) {
            final isSelected = _analysisPeriod == days;
            return Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _analysisPeriod = days;
                  });
                },
                child: Container(
                  margin: EdgeInsets.only(right: days == _analysisOptions.last ? 0 : 10.w),
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFF573E1A)
                        : Colors.white.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFF573E1A)
                          : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: ReusableTextWidget(
                      text: "$days days",
                      color: isSelected ? Colors.white : const Color(0xFF573E1A),
                      size: sFontSize,
                      FW: isSelected ? lFontWeight : sFontWeight,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}