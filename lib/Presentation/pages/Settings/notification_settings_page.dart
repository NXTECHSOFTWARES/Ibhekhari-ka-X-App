import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nxbakers/Common/AppData.dart';
import 'package:nxbakers/Common/Widgets/reusable_text_widget.dart';
import 'package:nxbakers/Common/common_main.dart';
import 'package:nxbakers/Domain/Services/notification_service.dart';
import 'package:nxbakers/Domain/Services/background_task_service.dart';

class NotificationSettingsPage extends StatefulWidget {
  const NotificationSettingsPage({super.key});

  @override
  State<NotificationSettingsPage> createState() => _NotificationSettingsPageState();
}

class _NotificationSettingsPageState extends State<NotificationSettingsPage> {
  final NotificationService _notificationService = NotificationService();
  final BackgroundTaskService _backgroundService = BackgroundTaskService();

  bool _notificationsEnabled = true;
  bool _periodicChecksEnabled = true;

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
          text: "Notification Settings",
          color: const Color(0xFF573E1A),
          size: xlFontSize,
          FW: lFontWeight,
        ),
      ),
      body: CommonMain(
        child: ListView(
          padding: EdgeInsets.all(20.w),
          children: [
            // Master Toggle
            _buildSettingCard(
              icon: Icons.notifications_active,
              title: "Enable Notifications",
              subtitle: "Receive low stock alerts",
              trailing: Switch(
                value: _notificationsEnabled,
                activeColor: const Color(0xFF573E1A),
                onChanged: (value) {
                  setState(() {
                    _notificationsEnabled = value;
                  });
                  if (!value) {
                    _notificationService.cancelAllNotifications();
                  }
                },
              ),
            ),

            SizedBox(height: 15.h),

            // Periodic Checks Toggle
            _buildSettingCard(
              icon: Icons.update,
              title: "Background Checks",
              subtitle: "Check stock levels every 30 minutes",
              trailing: Switch(
                value: _periodicChecksEnabled,
                activeColor: const Color(0xFF573E1A),
                onChanged: (value) {
                  setState(() {
                    _periodicChecksEnabled = value;
                  });
                  if (value) {
                    _backgroundService.startPeriodicStockCheck();
                  } else {
                    _backgroundService.stopPeriodicStockCheck();
                  }
                },
              ),
            ),

            SizedBox(height: 30.h),

            // Actions Section
            ReusableTextWidget(
              text: "Actions",
              color: const Color(0xFF573E1A),
              size: lFontSize,
              FW: lFontWeight,
            ),

            SizedBox(height: 15.h),

            // Test Notification Button
            _buildActionButton(
              icon: Icons.notifications_outlined,
              label: "Send Test Notification",
              onTap: () async {
                await _notificationService.showLowStockNotification(
                  id: 99999,
                  pastryName: "Test Pastry",
                  currentStock: 3,
                  threshold: 5,
                );
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: Colors.green.shade700,
                      content: ReusableTextWidget(
                        text: "Test notification sent!",
                        color: Colors.white,
                        size: sFontSize,
                        FW: sFontWeight,
                      ),
                    ),
                  );
                }
              },
            ),

            SizedBox(height: 10.h),

            // Clear All Notifications Button
            _buildActionButton(
              icon: Icons.clear_all,
              label: "Clear All Notifications",
              color: Colors.red.shade700,
              onTap: () async {
                await _notificationService.cancelAllNotifications();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: ReusableTextWidget(
                        text: "All notifications cleared",
                        color: Colors.white,
                        size: sFontSize,
                        FW: sFontWeight,
                      ),
                    ),
                  );
                }
              },
            ),

            SizedBox(height: 10.h),

            // Check Now Button
            _buildActionButton(
              icon: Icons.refresh,
              label: "Check Stock Levels Now",
              onTap: () async {
                await _backgroundService.checkNow();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: Colors.green.shade700,
                      content: ReusableTextWidget(
                        text: "Stock check complete",
                        color: Colors.white,
                        size: sFontSize,
                        FW: sFontWeight,
                      ),
                    ),
                  );
                }
              },
            ),

            SizedBox(height: 30.h),

            // Info Section
            Container(
              padding: EdgeInsets.all(15.w),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: Colors.blue.shade200,
                  width: 1,
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Colors.blue.shade700,
                    size: 24.w,
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ReusableTextWidget(
                          text: "How it works",
                          color: Colors.blue.shade900,
                          size: lFontSize,
                          FW: lFontWeight,
                        ),
                        SizedBox(height: 5.h),
                        Text(
                          "• Stock levels are checked automatically\n"
                              "• You'll be notified when items reach their threshold\n"
                              "• Recommendations are based on your sales history\n"
                              "• Configure individual pastry settings by swiping left on any item",
                          style: TextStyle(
                            color: Colors.blue.shade700,
                            fontSize: xsFontSize.sp,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Widget trailing,
  }) {
    return Container(
      padding: EdgeInsets.all(15.w),
      decoration: BoxDecoration(
        color: const Color(0xFFF2EADE),
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4.r,
            offset: Offset(0, 2.h),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
              color: const Color(0xFF573E1A).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(
              icon,
              color: const Color(0xFF573E1A),
              size: 24.w,
            ),
          ),
          SizedBox(width: 15.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ReusableTextWidget(
                  text: title,
                  color: const Color(0xFF573E1A),
                  size: lFontSize,
                  FW: lFontWeight,
                ),
                SizedBox(height: 3.h),
                ReusableTextWidget(
                  text: subtitle,
                  color: const Color(0xFF8B7355),
                  size: xsFontSize,
                  FW: sFontWeight,
                ),
              ],
            ),
          ),
          trailing,
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color? color,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 15.h, horizontal: 15.w),
        decoration: BoxDecoration(
          color: const Color(0xFFF2EADE),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: color ?? const Color(0xFF573E1A),
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: color ?? const Color(0xFF573E1A),
              size: 24.w,
            ),
            SizedBox(width: 15.w),
            Expanded(
              child: ReusableTextWidget(
                text: label,
                color: color ?? const Color(0xFF573E1A),
                size: lFontSize,
                FW: lFontWeight,
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: color ?? const Color(0xFF573E1A),
              size: 16.w,
            ),
          ],
        ),
      ),
    );
  }
}