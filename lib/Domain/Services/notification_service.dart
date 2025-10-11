import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:nxbakers/Common/AppData.dart';
import 'package:nxbakers/Common/Widgets/reusable_text_widget.dart';
import 'package:nxbakers/Data/Model/bakery_notification.dart';
import 'package:nxbakers/Presentation/pages/Notifications/notification_details_page.dart';
import 'package:nxbakers/Presentation/pages/Notifications/notifications.dart';
import 'package:nxbakers/main.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:permission_handler/permission_handler.dart';

import 'notification_history_service.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();

  factory NotificationService() => _instance;

  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  final NotificationHistoryService _historyService = NotificationHistoryService(); // Add this

  bool _isInitialized = false;

  // Initialize notification service
  Future<void> initialize() async {
    if (_isInitialized) return;

    // Initialize timezone
    tz.initializeTimeZones();

    // Android initialization settings
    const AndroidInitializationSettings androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS initialization settings
    const DarwinInitializationSettings iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    _isInitialized = true;
  }

  // Request notification permissions
  Future<bool> requestPermissions() async {
    if (await Permission.notification.isDenied) {
      final status = await Permission.notification.request();
      return status.isGranted;
    }
    return true;
  }

  // Show restock recommendation notification
  Future<void> showRestockRecommendation({
    required int id,
    required String pastryName,
    required int recommendedQuantity,
    required int currentStock,
  }) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'restock_channel',
      'Restock Recommendations',
      channelDescription: 'Smart restock suggestions',
      importance: Importance.max,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      color: Color(0xFFFF9800),
      enableVibration: true,
      playSound: true,
      styleInformation: BigTextStyleInformation(
        '',
        contentTitle: '💡 Restock Suggestion',
        summaryText: 'Tap to view details',
      ),
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      id + 1000,
      '💡 Time to Restock: $pastryName',
      'Current: $currentStock units. We recommend adding $recommendedQuantity units based on your sales.',
      notificationDetails,
      payload: 'restock:$id:$pastryName',
    );

    // Save to notification history
    await _saveToHistory(
      type: NotificationType.restockSuggestion,
      title: 'Time to Restock: $pastryName',
      summary: 'Current: $currentStock units. Recommended: $recommendedQuantity units.',
      detailedMessage:
          'Based on your recent sales patterns, we recommend restocking $pastryName with $recommendedQuantity units. Current stock level is $currentStock units.',
      relatedItemId: id.toString(),
      relatedItemName: pastryName,
      additionalData: {
        'currentStock': currentStock,
        'recommendedQuantity': recommendedQuantity,
      },
    );
  }

  // Schedule reminder notification (Android 14+ compatible)
  Future<void> scheduleReminderNotification({
    required int id,
    required String pastryName,
    required int currentStock,
    required Duration reminderInterval,
  }) async {
    try {
      const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        'reminder_channel',
        'Stock Reminders',
        channelDescription: 'Reminder notifications for low stock',
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
        color: Color(0xFFFF5722),
      );

      const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const NotificationDetails notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      // Use inexact scheduling for Android 14+ compatibility
      await _notifications.zonedSchedule(
        id + 2000,
        '🔔 Reminder: Low Stock',
        '$pastryName still needs restocking ($currentStock units left)',
        tz.TZDateTime.now(tz.local).add(reminderInterval),
        notificationDetails,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle, // Changed from exact
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        payload: 'reminder:$id:$pastryName',
      );

      // Save scheduled reminder to history
      await _saveToHistory(
        type: NotificationType.reminder,
        title: 'Reminder: Low Stock',
        summary: '$pastryName still needs restocking ($currentStock units left)',
        detailedMessage:
            'This is a reminder that $pastryName still has low stock with only $currentStock units remaining. Please consider restocking soon.',
        relatedItemId: id.toString(),
        relatedItemName: pastryName,
        additionalData: {
          'currentStock': currentStock,
          'scheduledFor': DateTime.now().add(reminderInterval).toIso8601String(),
        },
      );
    } catch (e) {
      print('Error scheduling reminder: $e');
      // Fallback: Show immediate notification if scheduling fails
      await showLowStockNotification(
        id: id,
        pastryName: pastryName,
        currentStock: currentStock,
        threshold: 5, // Default threshold
      );
    }
  }

  // Show summary notification (multiple low stock items)
  Future<void> showSummaryNotification({
    required List<String> pastryNames,
  }) async {
    final inboxLines = pastryNames.take(5).map((name) => '• $name').toList();

    final AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'summary_channel',
      'Stock Summary',
      channelDescription: 'Summary of all low stock items',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      color: const Color(0xFFD32F2F),
      styleInformation: InboxStyleInformation(
        inboxLines,
        contentTitle: '⚠️ ${pastryNames.length} Items Need Attention',
        summaryText: 'Tap to view all',
      ),
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      9999,
      '⚠️ ${pastryNames.length} Items Low on Stock',
      pastryNames.join(', '),
      notificationDetails,
      payload: 'summary',
    );

    // Save summary to history
    await _saveToHistory(
      type: NotificationType.summary,
      title: '${pastryNames.length} Items Low on Stock',
      summary: pastryNames.join(', '),
      detailedMessage:
          'The following items are currently low on stock:\n\n${pastryNames.map((name) => '• $name').join('\n')}\n\nPlease review and restock as needed.',
      additionalData: {
        'itemCount': pastryNames.length,
        'items': pastryNames,
      },
    );
  }

  // Cancel specific notification
  Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
  }

  // Cancel all notifications
  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }

  // Get pending notifications
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _notifications.pendingNotificationRequests();
  }

  // Show immediate notification
  Future<void> showLowStockNotification({
    required int id,
    required String pastryName,
    required int currentStock,
    required int threshold,
  }) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'low_stock_channel',
      'Low Stock Alerts',
      channelDescription: 'Notifications for low stock pastries',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      color: Color(0xFF573E1A),
      enableVibration: true,
      playSound: true,
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    // Enhanced payload with notification ID
    final notificationId = DateTime.now().millisecondsSinceEpoch.toString();
    final payload = 'low_stock:$id:$pastryName:$notificationId';

    await _notifications.show(
      id,
      '⚠️ Low Stock Alert',
      '$pastryName is running low! Only $currentStock units left.',
      notificationDetails,
      payload: payload,
    );

    // Save to notification history with the same ID
    await _saveToHistory(
      id: notificationId,
      // Pass the ID so we can find it later
      type: NotificationType.lowStock,
      title: 'Low Stock Alert',
      summary: '$pastryName is running low! Only $currentStock units left.',
      detailedMessage:
          'Stock for $pastryName has fallen to $currentStock units, which is at or below the threshold of $threshold units. Consider restocking soon to avoid running out.',
      relatedItemId: id.toString(),
      relatedItemName: pastryName,
      additionalData: {
        'currentStock': currentStock,
        'threshold': threshold,
        'notificationId': notificationId,
      },
    );
  }

// Update _saveToHistory to accept ID
  Future<void> _saveToHistory({
    String? id,
    required NotificationType type,
    required String title,
    required String summary,
    String? detailedMessage,
    String? relatedItemId,
    String? relatedItemName,
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      final notification = BakeryNotification(
        id: id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        type: type,
        title: title,
        summary: summary,
        detailedMessage: detailedMessage,
        relatedItemId: relatedItemId?.toString(),
        relatedItemName: relatedItemName,
        additionalData: additionalData,
        createdAt: DateTime.now(),
        isRead: false,
      );

      await _historyService.addNotification(notification);
    } catch (e) {
      print('Error saving notification to history: $e');
    }
  }

  /// Enhanced notification tap handler with navigation
  void _onNotificationTapped(NotificationResponse response) async {
    final payload = response.payload;
    print('Notification tapped with payload: $payload');

    if (payload != null) {
      // Parse the payload for navigation
      final parts = payload.split(':');
      if (parts.length >= 3) {
        final type = parts[0]; // low_stock, restock, reminder, summary
        final pastryId = parts[1];
        final pastryName = parts.length > 2 ? parts[2] : '';

        // Mark notification as read in history
        await _markNotificationAsRead(type, pastryId);

        // Navigate to notification details page
        _navigateToNotificationDetails(type, pastryId, pastryName);
      } else if (payload == 'summary') {
        // Handle summary notification
        _navigateToNotificationsPage();
      }
    } else {
      // If no specific payload, navigate to general notifications page
      _navigateToNotificationsPage();
    }
  }

// Navigate to specific notification details
  void _navigateToNotificationDetails(type, String pastryId, String pastryName) {
    // We need to find the actual notification from history
    // For now, we'll navigate to notifications page and show a snackbar
    // In a real app, you'd pass the specific notification ID

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final context = navigatorKey.currentState?.overlay?.context;
      if (context != null) {
        // Navigate to notifications page first
        Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => NotificationDetailsPage(
                  notification: BakeryNotification(id: pastryId, type: type, title: pastryName, summary: "summary", createdAt: DateTime.now()),
                )));

        // Show a message about which notification was tapped
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.green.shade700,
            content: ReusableTextWidget(
              text: 'Opening notification for $pastryName',
              color: Colors.white,
              size: sFontSize,
              FW: sFontWeight,
            ),
          ),
        );
      }
    });
  }

// Navigate to general notifications page
  void _navigateToNotificationsPage() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final context = navigatorKey.currentState?.overlay?.context;
      if (context != null) {
        Navigator.of(context).push(MaterialPageRoute(builder: (context) => const NotificationsPage()));
      }
    });
  }

// Enhanced method to mark notification as read
  Future<void> _markNotificationAsRead(String type, String pastryId) async {
    try {
      // Find the notification based on type and pastry ID
      final notifications = await _historyService.getAllNotifications();

      // Look for the most recent matching notification
      final notification = notifications.firstWhere(
        (n) {
          final matchesType = n.type.toString().contains(type);
          final matchesPastry = n.relatedItemId == pastryId || n.relatedItemName?.contains(pastryId) == true;
          return matchesType && matchesPastry;
        },
        orElse: () => notifications.isNotEmpty
            ? notifications.first
            : BakeryNotification(
                id: 'temp',
                type: NotificationType.general,
                title: 'Temp',
                summary: 'Temp',
                createdAt: DateTime.now(),
              ),
      );

      if (notification.id != 'temp') {
        await _historyService.markAsRead(notification.id);
      }
    } catch (e) {
      print('Error marking notification as read: $e');
    }
  }

  // Test method to simulate notification tap
  Future<void> testNotificationNavigation() async {
    print('🧪 Testing notification navigation...');

    // Simulate a notification tap
    _onNotificationTapped(const NotificationResponse(
      payload: 'low_stock:4:Long Doughnuts:1760054705636',
      id: 1,
      actionId: null,
      input: null, notificationResponseType: NotificationResponseType.selectedNotification,
    ));
  }
}
