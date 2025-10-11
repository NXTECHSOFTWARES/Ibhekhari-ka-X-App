import 'dart:convert';
import 'package:nxbakers/Data/Database/Local/sql_database_helper.dart';
import 'package:nxbakers/Data/Model/bakery_notification.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationHistoryService {
  static const String _notificationsKey = 'bakery_notifications';
  static const String _unreadCountKey = 'unread_notification_count';

  final SqlDatabaseHelper _dbHelper = SqlDatabaseHelper();

  // Get all notifications
  Future<List<BakeryNotification>> getAllNotifications() async {
    try {
      final notificationsData = await _dbHelper.getAllNotifications();
      return notificationsData.map((data) => _fromDatabaseMap(data)).toList();
    } catch (e) {
      print('Error getting notifications from database: $e');
      return [];
    }
  }

  // Get unread notifications
  Future<List<BakeryNotification>> getUnreadNotifications() async {
    final allNotifications = await getAllNotifications();
    return allNotifications.where((n) => !n.isRead).toList();
  }

  // Get unread count
  Future<int> getUnreadCount() async {
    return await _dbHelper.getUnreadNotificationsCount();
  }

  // Add a new notification
  Future<void> addNotification(BakeryNotification notification) async {
    try {
      await _dbHelper.insertNotification(_toDatabaseMap(notification));
    } catch (e) {
      print('Error adding notification to database: $e');
      rethrow;
    }
  }

  // Mark notification as read
  Future<void> markAsRead(String notificationId) async {
    try {
      // First get the notification to find its database ID
      final notifications = await getAllNotifications();
      final notification = notifications.firstWhere(
            (n) => n.id == notificationId,
        orElse: () => notifications.firstWhere((n) => n.relatedItemId == notificationId),
      );

      // Get the database record to find the primary key
      final dbNotifications = await _dbHelper.getAllNotifications();
      final dbNotification = dbNotifications.firstWhere(
            (n) => n['notification_id'] == notification.id ||
            n['related_item_id'] == notification.relatedItemId,
      );

      await _dbHelper.markNotificationAsRead(dbNotification['id'] as int);
    } catch (e) {
      print('Error marking notification as read: $e');
      rethrow;
    }
  }

  // Mark all as read
  Future<void> markAllAsRead() async {
    try {
      await _dbHelper.markAllNotificationsAsRead();
    } catch (e) {
      print('Error marking all notifications as read: $e');
      rethrow;
    }
  }

  // Delete notification
  Future<void> deleteNotification(String notificationId) async {
    try {
      final notifications = await getAllNotifications();
      final notification = notifications.firstWhere(
            (n) => n.id == notificationId,
      );

      final dbNotifications = await _dbHelper.getAllNotifications();
      final dbNotification = dbNotifications.firstWhere(
            (n) => n['notification_id'] == notification.id,
      );

      await _dbHelper.deleteNotification(dbNotification['id'] as int);
    } catch (e) {
      print('Error deleting notification: $e');
      rethrow;
    }
  }

  // Delete all notifications
  Future<void> deleteAllNotifications() async {
    try {
      await _dbHelper.deleteAllNotifications();
    } catch (e) {
      print('Error deleting all notifications: $e');
      rethrow;
    }
  }

  // Delete all read notifications
  Future<void> deleteAllReadNotifications() async {
    try {
      await _dbHelper.deleteAllReadNotifications();
    } catch (e) {
      print('Error deleting read notifications: $e');
      rethrow;
    }
  }

  // Helper methods to convert between BakeryNotification and database map
  Map<String, dynamic> _toDatabaseMap(BakeryNotification notification) {
    return {
      'type': notification.type.toString(),
      'title': notification.title,
      'summary': notification.summary,
      'detailed_message': notification.detailedMessage,
      'created_at': notification.createdAt.toIso8601String(),
      'is_read': notification.isRead ? 1 : 0,
      'related_item_id': notification.relatedItemId,
      'related_item_name': notification.relatedItemName,
      'additional_data': notification.additionalData,
      'notification_id': notification.id,
    };
  }

  BakeryNotification _fromDatabaseMap(Map<String, dynamic> data) {
    // Create a mutable copy of the data map
    final mutableData = Map<String, dynamic>.from(data);

    // Parse additional_data safely
    Map<String, dynamic>? additionalData;
    if (mutableData['additional_data'] != null) {
      try {
        if (mutableData['additional_data'] is String) {
          additionalData = Map<String, dynamic>.from(
              jsonDecode(mutableData['additional_data'] as String)
          );
        } else {
          additionalData = Map<String, dynamic>.from(mutableData['additional_data']);
        }
      } catch (e) {
        print('Error parsing additional_data: $e');
        additionalData = {};
      }
    }

    return BakeryNotification(
      id: mutableData['notification_id']?.toString() ?? mutableData['id'].toString(),
      type: NotificationType.values.firstWhere(
            (e) => e.toString() == mutableData['type'],
        orElse: () => NotificationType.general,
      ),
      title: mutableData['title'] ?? '',
      summary: mutableData['summary'] ?? '',
      detailedMessage: mutableData['detailed_message'],
      createdAt: DateTime.parse(mutableData['created_at']),
      isRead: (mutableData['is_read'] as int?) == 1,
      relatedItemId: mutableData['related_item_id']?.toString(),
      relatedItemName: mutableData['related_item_name'],
      additionalData: additionalData,
    );
  }

  // Your existing methods for creating specific notifications...
  Future<void> createLowStockNotification({
    required String pastryId,
    required String pastryName,
    required int currentStock,
    required int threshold,
  }) async {
    final notification = BakeryNotification(
      id: 'low_stock_${pastryId}_${DateTime.now().millisecondsSinceEpoch}',
      type: NotificationType.lowStock,
      title: 'Low Stock Alert',
      summary: '$pastryName is running low ($currentStock units left)',
      detailedMessage: '$pastryName has fallen below the stock threshold of $threshold units. Current stock: $currentStock units. Consider restocking soon.',
      createdAt: DateTime.now(),
      relatedItemId: pastryId,
      relatedItemName: pastryName,
      additionalData: {
        'currentStock': currentStock,
        'threshold': threshold,
      },
    );

    await addNotification(notification);
  }

  // Create out of stock notification
  Future<void> createOutOfStockNotification({
    required String pastryId,
    required String pastryName,
  }) async {
    final notification = BakeryNotification(
      id: 'out_of_stock_${pastryId}_${DateTime.now().millisecondsSinceEpoch}',
      type: NotificationType.outOfStock,
      title: 'Out of Stock',
      summary: '$pastryName is completely out of stock',
      detailedMessage: '$pastryName has no remaining units in stock. Immediate restocking is required to fulfill orders.',
      createdAt: DateTime.now(),
      relatedItemId: pastryId,
      relatedItemName: pastryName,
    );

    await addNotification(notification);
  }

  // Generate demo notifications for testing
  Future<void> generateDemoNotifications() async {
    try {
      final demoNotifications = [
        BakeryNotification(
          id: 'demo_1_${DateTime.now().millisecondsSinceEpoch}',
          type: NotificationType.lowStock,
          title: 'Low Stock Alert',
          summary: 'Chocolate Croissant is running low (3 units left)',
          detailedMessage: 'Chocolate Croissant has fallen below the stock threshold of 5 units. Current stock: 3 units.',
          createdAt: DateTime.now().subtract(const Duration(hours: 2)),
          isRead: false,
          relatedItemName: 'Chocolate Croissant',
        ),
        BakeryNotification(
          id: 'demo_2_${DateTime.now().millisecondsSinceEpoch}',
          type: NotificationType.outOfStock,
          title: 'Out of Stock',
          summary: 'Blueberry Muffin is completely out of stock',
          detailedMessage: 'Blueberry Muffin has no remaining units. Immediate restocking required.',
          createdAt: DateTime.now().subtract(const Duration(hours: 5)),
          isRead: true,
          relatedItemName: 'Blueberry Muffin',
        ),
        BakeryNotification(
          id: 'demo_3_${DateTime.now().millisecondsSinceEpoch}',
          type: NotificationType.profitLoss,
          title: 'Profit Loss Alert',
          summary: 'Red Velvet Cake showing negative profit margin',
          detailedMessage: 'Based on ingredient costs, Red Velvet Cake is currently being sold at a loss. Review pricing or ingredient sourcing.',
          createdAt: DateTime.now().subtract(const Duration(days: 1)),
          isRead: false,
          relatedItemName: 'Red Velvet Cake',
        ),
      ];

      for (final notification in demoNotifications) {
        await addNotification(notification);
      }
    } catch (e) {
      print('Error generating demo notifications: $e');
      rethrow;
    }
  }

  // Add this test method to verify the database is working
  Future<void> testNotificationSystem() async {
    print('Testing notification system...');

    try {
      // Create a test notification
      final testNotification = BakeryNotification(
        id: 'test_${DateTime.now().millisecondsSinceEpoch}',
        type: NotificationType.lowStock,
        title: 'Test Low Stock Alert',
        summary: 'Test Pastry is running low (2 units left)',
        detailedMessage: 'This is a test notification to verify the database is working.',
        createdAt: DateTime.now(),
        relatedItemId: '999',
        relatedItemName: 'Test Croissant',
        additionalData: {
          'currentStock': 2,
          'threshold': 5,
          'test': true,
        },
      );

      // Save to database
      await addNotification(testNotification);
      print('✓ Test notification saved to database');

      // Retrieve from database
      final notifications = await getAllNotifications();
      print('✓ Retrieved ${notifications.length} notifications from database');

      if (notifications.isNotEmpty) {
        print('✓ Latest notification: ${notifications.first.title}');
      } else {
        print('✗ No notifications found in database');
      }

    } catch (e) {
      print('✗ Error testing notification system: $e');
    }
  }
}