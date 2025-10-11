import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:nxbakers/Common/AppData.dart';
import 'package:nxbakers/Common/Widgets/reusable_text_widget.dart';
import 'package:nxbakers/Common/common_main.dart';

import 'package:nxbakers/Data/Model/bakery_notification.dart';
import 'package:nxbakers/Domain/Services/notification_history_service.dart';
import 'package:intl/intl.dart';
import 'package:community_material_icon/community_material_icon.dart';

import 'notification_details_page.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  final NotificationHistoryService _notificationHistoryService = NotificationHistoryService();
  List<BakeryNotification> _notifications = [];
  bool _isLoading = true;
  bool _hasError = false;
  String _filterType = 'all';

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _hasError = false;
      });
    }

    try {
      final notifications = await _notificationHistoryService.getAllNotifications();
      print('Hallo, just loaded my notifications $notifications');
      if (mounted) {
        setState(() {
          _notifications = notifications;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading notifications: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
        });
      }
    }
  }

  List<BakeryNotification> get _filteredNotifications {
    switch (_filterType) {
      case 'unread':
        return _notifications.where((n) => !n.isRead).toList();
      case 'read':
        return _notifications.where((n) => n.isRead).toList();
      default:
        return _notifications;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFB7A284),
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
          text: "Notifications",
          color: const Color(0xFF573E1A),
          size: xlFontSize,
          FW: lFontWeight,
        ),
        actions: [
          if (_notifications.isNotEmpty)
            PopupMenuButton<String>(
              icon: Icon(
                Icons.more_vert,
                color: const Color(0xFF573E1A),
                size: 24.w,
              ),
              color: const Color(0xFFF2EADE),
              onSelected: (value) async {
                switch (value) {
                  case 'mark_all_read':
                    await _notificationHistoryService.markAllAsRead();
                    _loadNotifications();
                    break;
                  case 'delete_read':
                    _confirmDeleteAllRead();
                    break;
                  case 'delete_all':
                    _confirmDeleteAll();
                    break;
                  case 'add_demo':
                    await _notificationHistoryService.generateDemoNotifications();
                    _loadNotifications();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: Colors.green.shade700,
                        content: ReusableTextWidget(
                          text: 'Demo notifications added',
                          color: Colors.white,
                          size: sFontSize,
                          FW: sFontWeight,
                        ),
                      ),
                    );
                    break;
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'mark_all_read',
                  child: Row(
                    children: [
                      Icon(Icons.done_all, color: const Color(0xFF573E1A), size: 20.w),
                      SizedBox(width: 10.w),
                      ReusableTextWidget(
                        text: 'Mark all as read',
                        color: const Color(0xFF573E1A),
                        size: sFontSize,
                        FW: sFontWeight,
                      ),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'delete_read',
                  child: Row(
                    children: [
                      Icon(Icons.delete_sweep, color: Colors.orange.shade700, size: 20.w),
                      SizedBox(width: 10.w),
                      ReusableTextWidget(
                        text: 'Delete all read',
                        color: const Color(0xFF573E1A),
                        size: sFontSize,
                        FW: sFontWeight,
                      ),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'delete_all',
                  child: Row(
                    children: [
                      Icon(Icons.delete_forever, color: Colors.red.shade700, size: 20.w),
                      SizedBox(width: 10.w),
                      ReusableTextWidget(
                        text: 'Delete all',
                        color: Colors.red.shade700,
                        size: sFontSize,
                        FW: sFontWeight,
                      ),
                    ],
                  ),
                ),
                const PopupMenuDivider(),
                PopupMenuItem(
                  value: 'add_demo',
                  child: Row(
                    children: [
                      Icon(Icons.add_circle_outline, color: Colors.blue.shade700, size: 20.w),
                      SizedBox(width: 10.w),
                      ReusableTextWidget(
                        text: 'Add demo data',
                        color: const Color(0xFF573E1A),
                        size: sFontSize,
                        FW: sFontWeight,
                      ),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
      body: CommonMain(
        child: _isLoading
            ? const Center(
          child: CircularProgressIndicator(
            color: Color(0xFF573E1A),
          ),
        )
            : Column(
          children: [
            // Filter Chips
            _buildFilterChips(),

            // Stats Banner
            if (_notifications.isNotEmpty) _buildStatsBanner(),

            // Notifications List
            Expanded(
              child: _filteredNotifications.isEmpty
                  ? _buildEmptyState()
                  : _buildNotificationsList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 10.h),
      child: Row(
        children: [
          _buildFilterChip('All', 'all'),
          SizedBox(width: 8.w),
          _buildFilterChip('Unread', 'unread'),
          SizedBox(width: 8.w),
          _buildFilterChip('Read', 'read'),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _filterType == value;
    return ChoiceChip(
      label: ReusableTextWidget(
        text: label,
        color: isSelected ? Colors.white : const Color(0xFF573E1A),
        size: xsFontSize,
        FW: sFontWeight,
      ),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          setState(() {
            _filterType = value;
          });
        }
      },
      selectedColor: const Color(0xFF573E1A),
      backgroundColor: Colors.white,
      side: BorderSide(
        color: isSelected ? const Color(0xFF573E1A) : const Color(0xFF8B7355).withOpacity(0.3),
      ),
    );
  }

  Widget _buildStatsBanner() {
    final unreadCount = _notifications.where((n) => !n.isRead).length;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 15.w, vertical: 5.h),
      padding: EdgeInsets.all(15.w),
      decoration: BoxDecoration(
        color: const Color(0xFF573E1A),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            icon: Icons.notifications_active,
            label: 'Unread',
            value: unreadCount.toString(),
          ),
          Container(
            width: 1.w,
            height: 30.h,
            color: Colors.white.withOpacity(0.3),
          ),
          _buildStatItem(
            icon: Icons.check_circle_outline,
            label: 'Read',
            value: (_notifications.length - unreadCount).toString(),
          ),
          Container(
            width: 1.w,
            height: 30.h,
            color: Colors.white.withOpacity(0.3),
          ),
          _buildStatItem(
            icon: Icons.inbox,
            label: 'Total',
            value: _notifications.length.toString(),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 24.w),
        SizedBox(height: 5.h),
        ReusableTextWidget(
          text: value,
          color: const Color(0xFFFFE4BD),
          size: xlFontSize,
          FW: lFontWeight,
        ),
        ReusableTextWidget(
          text: label,
          color: Colors.white.withOpacity(0.8),
          size: xsFontSize,
          FW: sFontWeight,
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    if (_hasError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              color: Colors.red.shade700,
              size: 80.w,
            ),
            SizedBox(height: 20.h),
            ReusableTextWidget(
              text: 'Failed to load notifications',
              color: Colors.red.shade700,
              size: xlFontSize,
              FW: lFontWeight,
            ),
            SizedBox(height: 10.h),
            ElevatedButton(
              onPressed: _loadNotifications,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF573E1A),
              ),
              child: ReusableTextWidget(
                text: 'Try Again',
                color: Colors.white,
                size: sFontSize,
                FW: sFontWeight,
              ),
            ),
          ],
        ),
      );
    }

    String message;
    IconData icon;

    switch (_filterType) {
      case 'unread':
        message = 'No unread notifications';
        icon = Icons.check_circle_outline;
        break;
      case 'read':
        message = 'No read notifications';
        icon = Icons.inbox_outlined;
        break;
      default:
        message = 'No notifications yet';
        icon = Icons.notifications_none;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: const Color(0xFF8B7355),
            size: 80.w,
          ),
          SizedBox(height: 20.h),
          ReusableTextWidget(
            text: message,
            color: const Color(0xFF573E1A),
            size: xlFontSize,
            FW: lFontWeight,
          ),
          SizedBox(height: 10.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 40.w),
            child: Text(
              _filterType == 'all'
                  ? "You're all caught up! Notifications will appear here."
                  : "Try switching to a different filter.",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: const Color(0xFF8B7355),
                fontSize: sFontSize.sp,
              ),
            ),
          ),
          SizedBox(height: 20.h),
          ElevatedButton(
            onPressed: () async {
              try {
                await _notificationHistoryService.generateDemoNotifications();
                _loadNotifications();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: Colors.green.shade700,
                      content: ReusableTextWidget(
                        text: 'Demo notifications added',
                        color: Colors.white,
                        size: sFontSize,
                        FW: sFontWeight,
                      ),
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: Colors.red.shade700,
                      content: ReusableTextWidget(
                        text: 'Failed to add demo data: $e',
                        color: Colors.white,
                        size: sFontSize,
                        FW: sFontWeight,
                      ),
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF573E1A),
            ),
            child: ReusableTextWidget(
              text: 'Add Demo Data',
              color: Colors.white,
              size: sFontSize,
              FW: sFontWeight,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationsList() {
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
      itemCount: _filteredNotifications.length,
      itemBuilder: (context, index) {
        final notification = _filteredNotifications[index];
        return _buildNotificationCard(notification);
      },
    );
  }

  Widget _buildNotificationCard(BakeryNotification notification) {
    return Slidable(
      key: Key(notification.id),
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        children: [
          SlidableAction(
            onPressed: (context) async {
              await _notificationHistoryService.deleteNotification(notification.id);
              _loadNotifications();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: Colors.red.shade700,
                    content: ReusableTextWidget(
                      text: 'Notification deleted',
                      color: Colors.white,
                      size: sFontSize,
                      FW: sFontWeight,
                    ),
                  ),
                );
              }
            },
            backgroundColor: Colors.red.shade700,
            foregroundColor: Colors.white,
            icon: CommunityMaterialIcons.delete_outline,
            label: 'Delete',
          ),
          if (!notification.isRead)
            SlidableAction(
              onPressed: (context) async {
                await _notificationHistoryService.markAsRead(notification.id);
                _loadNotifications();
              },
              backgroundColor: Colors.green.shade700,
              foregroundColor: Colors.white,
              icon: Icons.done,
              label: 'Mark Read',
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(12.r),
                bottomRight: Radius.circular(12.r),
              ),
            ),
        ],
      ),
      child: GestureDetector(
        onTap: () => _showNotificationDetails(notification),
        child: Container(
          margin: EdgeInsets.only(bottom: 10.h),
          decoration: BoxDecoration(
            color: notification.isRead
                ? const Color(0xFFF2EADE)
                : Colors.white,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: notification.isRead
                  ? Colors.transparent
                  : notification.getColor().withOpacity(0.3),
              width: 2,
            ),
            boxShadow: notification.isRead
                ? []
                : [
              BoxShadow(
                color: notification.getColor().withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.all(15.w),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon
                Container(
                  padding: EdgeInsets.all(10.w),
                  decoration: BoxDecoration(
                    color: notification.getColor().withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Icon(
                    notification.getIcon(),
                    color: notification.getColor(),
                    size: 24.w,
                  ),
                ),
                SizedBox(width: 12.w),

                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: ReusableTextWidget(
                              text: notification.title,
                              color: const Color(0xFF573E1A),
                              size: lFontSize,
                              FW: lFontWeight,
                            ),
                          ),
                          if (!notification.isRead)
                            Container(
                              width: 8.w,
                              height: 8.w,
                              decoration: BoxDecoration(
                                color: notification.getColor(),
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                      SizedBox(height: 4.h),

                      // Type Label
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                        decoration: BoxDecoration(
                          color: notification.getColor().withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                        child: ReusableTextWidget(
                          text: notification.getTypeLabel(),
                          color: notification.getColor(),
                          size: xsFontSize,
                          FW: sFontWeight,
                        ),
                      ),

                      SizedBox(height: 8.h),

                      // Summary
                      ReusableTextWidget(
                        text: notification.summary,
                        color: const Color(0xFF8B7355),
                        size: sFontSize,
                        FW: sFontWeight,
                      ),

                      SizedBox(height: 8.h),

                      // Date and Related Item
                      Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 14.w,
                            color: const Color(0xFF8B7355).withOpacity(0.7),
                          ),
                          SizedBox(width: 4.w),
                          Expanded(
                            child: ReusableTextWidget(
                              text: _formatDate(notification.createdAt),
                              color: const Color(0xFF8B7355).withOpacity(0.7),
                              size: xsFontSize,
                              FW: sFontWeight,
                            ),
                          ),
                          if (notification.relatedItemName != null) ...[
                            Icon(
                              Icons.label_outline,
                              size: 14.w,
                              color: const Color(0xFF8B7355).withOpacity(0.7),
                            ),
                            SizedBox(width: 4.w),
                            Flexible(
                              child: ReusableTextWidget(
                                text: notification.relatedItemName!,
                                color: const Color(0xFF8B7355).withOpacity(0.7),
                                size: xsFontSize,
                                FW: sFontWeight,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),

                // Arrow icon
                Icon(
                  Icons.chevron_right,
                  color: const Color(0xFF8B7355).withOpacity(0.5),
                  size: 20.w,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Replace the entire _showNotificationDetails method with this:
  void _showNotificationDetails(BakeryNotification notification) async {
    // Mark as read when opened
    if (!notification.isRead) {
      await _notificationHistoryService.markAsRead(notification.id);
      _loadNotifications();
    }

    // Navigate to full-screen details page
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NotificationDetailsPage(
          notification: notification,
        ),
      ),
    );
  }

  void _confirmDeleteAll() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFFF2EADE),
        title: ReusableTextWidget(
          text: 'Delete All Notifications',
          size: xxlFontSize,
          color: const Color(0xFF573E1A),
          FW: lFontWeight,
        ),
        content: Text(
          'Are you sure you want to delete all notifications? This action cannot be undone.',
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
            onPressed: () async {
              await _notificationHistoryService.deleteAllNotifications();
              if (mounted) {
                Navigator.pop(context);
                _loadNotifications();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: Colors.red.shade700,
                    content: ReusableTextWidget(
                      text: 'All notifications deleted',
                      color: Colors.white,
                      size: sFontSize,
                      FW: sFontWeight,
                    ),
                  ),
                );
              }
            },
            child: ReusableTextWidget(
              text: 'Delete All',
              color: Colors.red.shade700,
              size: sFontSize,
              FW: lFontWeight,
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteAllRead() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFFF2EADE),
        title: ReusableTextWidget(
          text: 'Delete Read Notifications',
          size: xxlFontSize,
          color: const Color(0xFF573E1A),
          FW: lFontWeight,
        ),
        content: Text(
          'Are you sure you want to delete all read notifications?',
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
            onPressed: () async {
              await _notificationHistoryService.deleteAllReadNotifications();
              if (mounted) {
                Navigator.pop(context);
                _loadNotifications();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: Colors.orange.shade700,
                    content: ReusableTextWidget(
                      text: 'Read notifications deleted',
                      color: Colors.white,
                      size: sFontSize,
                      FW: sFontWeight,
                    ),
                  ),
                );
              }
            },
            child: ReusableTextWidget(
              text: 'Delete',
              color: Colors.orange.shade700,
              size: sFontSize,
              FW: lFontWeight,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return DateFormat('MMM d, yyyy').format(date);
    }
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