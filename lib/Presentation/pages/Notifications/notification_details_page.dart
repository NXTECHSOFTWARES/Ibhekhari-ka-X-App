import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nxbakers/Common/AppData.dart';
import 'package:nxbakers/Common/Widgets/reusable_text_widget.dart';
import 'package:nxbakers/Common/common_main.dart';
import 'package:nxbakers/Data/Model/bakery_notification.dart';
import 'package:nxbakers/Data/Model/pastry.dart';
import 'package:nxbakers/Domain/Services/notification_history_service.dart';
import 'package:nxbakers/Domain/Services/restock_calculator.dart';
import 'package:nxbakers/Presentation/pages/Pastries/Utils/Widgets/restock_recommendation_dialog.dart';
import 'package:intl/intl.dart';

class NotificationDetailsPage extends StatefulWidget {
  final BakeryNotification notification;

  const NotificationDetailsPage({
    super.key,
    required this.notification,
  });

  @override
  State<NotificationDetailsPage> createState() => _NotificationDetailsPageState();
}

class _NotificationDetailsPageState extends State<NotificationDetailsPage> {
  final NotificationHistoryService _notificationHistoryService = NotificationHistoryService();
  final RestockCalculator _restockCalculator = RestockCalculator();

  bool _isLoadingRestock = false;
  RestockRecommendation? _restockRecommendation;
  Pastry? _relatedPastry;

  @override
  void initState() {
    super.initState();
    _markAsReadIfNeeded();
    _loadRestockData();
  }

  Future<void> _markAsReadIfNeeded() async {
    if (!widget.notification.isRead) {
      await _notificationHistoryService.markAsRead(widget.notification.id);
    }
  }

  Future<void> _loadRestockData() async {
    // Only load restock data for low stock notifications
    if (widget.notification.type != NotificationType.lowStock) return;

    final relatedItemId = widget.notification.relatedItemId;
    if (relatedItemId == null) return;

    setState(() {
      _isLoadingRestock = true;
    });

    try {
      // TODO: Load the actual pastry from your database
      // For now, create a mock pastry based on notification data
      final currentStock = widget.notification.additionalData?['currentStock'] as int? ?? 0;

      // Load default image bytes
      final defaultImageBytes = await _loadDefaultImageBytes();

      _relatedPastry = Pastry(
        id: int.tryParse(relatedItemId) ?? 0,
        title: widget.notification.relatedItemName ?? 'Unknown Pastry',
        price: 0.0,
        quantity: currentStock,
        category: 'Unknown',
        imageBytes: defaultImageBytes, // Use the loaded default image
        createdAt: DateTime.now().toString(),
      );

      // Calculate restock recommendation
      _restockRecommendation = await _restockCalculator.calculateRestock(
        pastry: _relatedPastry!,
        analysisPeriodDays: 14,
      );
    } catch (e) {
      print('Error loading restock data: $e');
    } finally {
      setState(() {
        _isLoadingRestock = false;
      });
    }
  }

// Add this helper method to load default image bytes
  Future<Uint8List> _loadDefaultImageBytes() async {
    try {
      final byteData = await rootBundle.load('assets/Images/default_pastry_img.jpg');
      return byteData.buffer.asUint8List();
    } catch (e) {
      print('Failed to load default image: $e');
      // Return empty Uint8List as fallback
      return Uint8List(0);
    }
  }

  void _showRestockRecommendation() {
    if (_relatedPastry == null) return;

    showDialog(
      context: context,
      builder: (context) => RestockRecommendationDialog(
        pastry: _relatedPastry!,
      ),
    );
  }

  Future<void> _deleteNotification() async {
    await _notificationHistoryService.deleteNotification(widget.notification.id);
    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.green.shade700,
          content: ReusableTextWidget(
            text: 'Notification deleted',
            color: Colors.white,
            size: sFontSize,
            FW: sFontWeight,
          ),
        ),
      );
    }
  }

  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFFF2EADE),
        title: ReusableTextWidget(
          text: 'Delete Notification',
          size: xxlFontSize,
          color: const Color(0xFF573E1A),
          FW: lFontWeight,
        ),
        content: Text(
          'Are you sure you want to delete this notification?',
          style: TextStyle(
            color: const Color(0xFF8B7355),
            fontSize: sFontSize.sp,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: ReusableTextWidget(
              text: 'Cancel',
              color: const Color(0xFF573E1A),
              size: sFontSize,
              FW: sFontWeight,
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteNotification();
            },
            child: ReusableTextWidget(
              text: 'Delete',
              color: Colors.red.shade700,
              size: sFontSize,
              FW: lFontWeight,
            ),
          ),
        ],
      ),
    );
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
          text: "Notification Details",
          color: const Color(0xFF573E1A),
          size: xlFontSize,
          FW: lFontWeight,
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.delete_outline,
              color: Colors.red.shade700,
              size: 24.w,
            ),
            onPressed: _confirmDelete,
          ),
        ],
      ),
      body: CommonMain(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Section
              _buildHeaderSection(),

              SizedBox(height: 30.h),

              // Notification Content
              _buildContentSection(),

              // Restock Recommendation Section (for low stock notifications)
              if (widget.notification.type == NotificationType.lowStock) ...[
                SizedBox(height: 30.h),
                _buildRestockSection(),
              ],

              // Action Buttons
              SizedBox(height: 40.h),
              _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Icon
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: widget.notification.getColor().withOpacity(0.1),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(
              widget.notification.getIcon(),
              color: widget.notification.getColor(),
              size: 32.w,
            ),
          ),
          SizedBox(width: 16.w),

          // Title and Type
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ReusableTextWidget(
                  text: widget.notification.title,
                  color: const Color(0xFF573E1A),
                  size: xxlFontSize,
                  FW: lFontWeight,
                ),
                SizedBox(height: 8.h),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color: widget.notification.getColor().withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: ReusableTextWidget(
                    text: widget.notification.getTypeLabel(),
                    color: widget.notification.getColor(),
                    size: sFontSize,
                    FW: lFontWeight,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContentSection() {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Summary
          ReusableTextWidget(
            text: "Summary",
            color: const Color(0xFF573E1A),
            size: lFontSize,
            FW: lFontWeight,
          ),
          SizedBox(height: 8.h),
          Text(
            widget.notification.summary,
            style: TextStyle(
              color: const Color(0xFF8B7355),
              fontSize: sFontSize.sp,
              height: 1.5,
            ),
          ),

          SizedBox(height: 20.h),

          // Detailed Message
          if (widget.notification.detailedMessage != null) ...[
            ReusableTextWidget(
              text: "Details",
              color: const Color(0xFF573E1A),
              size: lFontSize,
              FW: lFontWeight,
            ),
            SizedBox(height: 8.h),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: const Color(0xFFF2EADE),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Text(
                widget.notification.detailedMessage!,
                style: TextStyle(
                  color: const Color(0xFF573E1A),
                  fontSize: sFontSize.sp,
                  height: 1.5,
                ),
              ),
            ),
            SizedBox(height: 20.h),
          ],

          // Date and Time
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: const Color(0xFFF2EADE),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 16.w,
                  color: const Color(0xFF573E1A),
                ),
                SizedBox(width: 8.w),
                ReusableTextWidget(
                  text: _formatDateDetailed(widget.notification.createdAt),
                  color: const Color(0xFF573E1A),
                  size: sFontSize,
                  FW: sFontWeight,
                ),
              ],
            ),
          ),

          // Related Item
          if (widget.notification.relatedItemName != null) ...[
            SizedBox(height: 12.h),
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: const Color(0xFFF2EADE),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.label,
                    size: 16.w,
                    color: const Color(0xFF573E1A),
                  ),
                  SizedBox(width: 8.w),
                  ReusableTextWidget(
                    text: 'Related Item: ${widget.notification.relatedItemName}',
                    color: const Color(0xFF573E1A),
                    size: sFontSize,
                    FW: sFontWeight,
                  ),
                ],
              ),
            ),
          ],

          // Additional Data
          if (widget.notification.additionalData != null &&
              widget.notification.additionalData!.isNotEmpty) ...[
            SizedBox(height: 20.h),
            ReusableTextWidget(
              text: "Additional Information",
              color: const Color(0xFF573E1A),
              size: lFontSize,
              FW: lFontWeight,
            ),
            SizedBox(height: 12.h),
            ...widget.notification.additionalData!.entries.map((entry) {
              return Container(
                margin: EdgeInsets.only(bottom: 8.h),
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: const Color(0xFFF2EADE),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ReusableTextWidget(
                      text: _formatKey(entry.key),
                      color: const Color(0xFF8B7355),
                      size: sFontSize,
                      FW: sFontWeight,
                    ),
                    ReusableTextWidget(
                      text: entry.value.toString(),
                      color: const Color(0xFF573E1A),
                      size: sFontSize,
                      FW: lFontWeight,
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ],
      ),
    );
  }

  Widget _buildRestockSection() {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.lightbulb_outline,
                color: Colors.orange.shade700,
                size: 24.w,
              ),
              SizedBox(width: 12.w),
              ReusableTextWidget(
                text: "Restock Recommendation",
                color: const Color(0xFF573E1A),
                size: lFontSize,
                FW: lFontWeight,
              ),
            ],
          ),
          SizedBox(height: 16.h),

          if (_isLoadingRestock)
            Center(
              child: Column(
                children: [
                  CircularProgressIndicator(
                    color: const Color(0xFF573E1A),
                  ),
                  SizedBox(height: 16.h),
                  ReusableTextWidget(
                    text: "Analyzing sales data...",
                    color: const Color(0xFF8B7355),
                    size: sFontSize,
                    FW: sFontWeight,
                  ),
                ],
              ),
            )
          else if (_restockRecommendation != null && _restockRecommendation!.hasEnoughData)
            _buildRestockInfo()
          else
            _buildNoRestockData(),
        ],
      ),
    );
  }

  Widget _buildRestockInfo() {
    final rec = _restockRecommendation!;
    final quickRec = rec.recommendations[3] ?? 0; // 3-day recommendation

    return Column(
      children: [
        // Quick Recommendation
        Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: Colors.green.shade50,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: Colors.green.shade200,
              width: 2,
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.recommend,
                color: Colors.green.shade700,
                size: 24.w,
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ReusableTextWidget(
                      text: "Quick Recommendation",
                      color: Colors.green.shade800,
                      size: sFontSize,
                      FW: lFontWeight,
                    ),
                    SizedBox(height: 4.h),
                    ReusableTextWidget(
                      text: quickRec > 0
                          ? "Add $quickRec units for 3-day coverage"
                          : "Current stock is sufficient",
                      color: Colors.green.shade700,
                      size: xsFontSize,
                      FW: sFontWeight,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 16.h),

        // Detailed Recommendations Button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _showRestockRecommendation,
            icon: Icon(
              Icons.insights,
              size: 20.w,
              color: Colors.white,
            ),
            label: ReusableTextWidget(
              text: "View Detailed Recommendations",
              color: Colors.white,
              size: sFontSize,
              FW: lFontWeight,
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF573E1A),
              padding: EdgeInsets.symmetric(vertical: 15.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNoRestockData() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: Colors.orange.shade200,
          width: 2,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            color: Colors.orange.shade700,
            size: 24.w,
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ReusableTextWidget(
                  text: "Need More Data",
                  color: Colors.orange.shade800,
                  size: sFontSize,
                  FW: lFontWeight,
                ),
                SizedBox(height: 4.h),
                ReusableTextWidget(
                  text: "Collect more sales data for personalized recommendations",
                  color: Colors.orange.shade700,
                  size: xsFontSize,
                  FW: sFontWeight,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        // Restock Button (only for low stock notifications)
        if (widget.notification.type == NotificationType.lowStock &&
            _relatedPastry != null)
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _showRestockRecommendation,
              icon: Icon(
                Icons.add_shopping_cart,
                size: 20.w,
                color: Colors.white,
              ),
              label: ReusableTextWidget(
                text: "Get Restock Recommendations",
                color: Colors.white,
                size: sFontSize,
                FW: lFontWeight,
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade700,
                padding: EdgeInsets.symmetric(vertical: 15.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
            ),
          ),

        if (widget.notification.type == NotificationType.lowStock &&
            _relatedPastry != null)
          SizedBox(height: 12.h),

        // Delete Button
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _confirmDelete,
            icon: Icon(
              Icons.delete_outline,
              size: 20.w,
              color: Colors.red.shade700,
            ),
            label: ReusableTextWidget(
              text: "Delete Notification",
              color: Colors.red.shade700,
              size: sFontSize,
              FW: lFontWeight,
            ),
            style: OutlinedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 15.h),
              side: BorderSide(
                color: Colors.red.shade700,
                width: 2,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _formatDateDetailed(DateTime date) {
    return DateFormat('EEEE, MMMM d, yyyy \'at\' h:mm a').format(date);
  }

  String _formatKey(String key) {
    return key
        .replaceAllMapped(
      RegExp(r'([A-Z])'),
          (match) => ' ${match.group(0)}',
    )
        .trim()
        .split(' ')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }
}