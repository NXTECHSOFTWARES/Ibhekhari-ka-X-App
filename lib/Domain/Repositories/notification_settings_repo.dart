import 'package:nxbakers/Data/Database/Local/sql_database_helper.dart';
import 'package:nxbakers/Data/Model/pastry_notification_settings.dart';

class NotificationSettingsRepository {
  static final NotificationSettingsRepository _instance =
  NotificationSettingsRepository._internal();
  factory NotificationSettingsRepository() => _instance;

  final SqlDatabaseHelper _dbHelper = SqlDatabaseHelper();
  NotificationSettingsRepository._internal();

  // Get settings for a specific pastry
  Future<PastryNotificationSettings> getSettings(int pastryId) async {
    try {
      final settingsMap = await _dbHelper.getNotificationSettings(pastryId);

      if (settingsMap != null) {
        return PastryNotificationSettings.fromJson(settingsMap);
      }

      // Return default settings if none exist
      return PastryNotificationSettings(pastryId: pastryId);
    } catch (e) {
      throw Exception('Failed to get notification settings: $e');
    }
  }

  // Save or update settings
  Future<bool> saveSettings(PastryNotificationSettings settings) async {
    try {
      // Check if settings already exist
      final existing = await _dbHelper.getNotificationSettings(settings.pastryId);

      if (existing != null && existing['id'] != null) {

        final result = await _dbHelper.updateNotificationSettings(
          existing['id'],
          settings.toJsonForUpdate(),
        );
        return result > 0;
      } else {

        final result = await _dbHelper.insertNotificationSettings(
          settings.toJsonForInsert(),
        );
        return result > 0;
      }
    } catch (e) {
      throw Exception('Failed to save notification settings: $e');
    }
  }

  // Get all settings
  Future<List<PastryNotificationSettings>> getAllSettings() async {
    try {
      final settingsList = await _dbHelper.getAllNotificationSettings();
      return settingsList
          .map((json) => PastryNotificationSettings.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to get all notification settings: $e');
    }
  }

  // Delete settings
  Future<bool> deleteSettings(int pastryId) async {
    try {
      final result = await _dbHelper.deleteNotificationSettings(pastryId);
      return result > 0;
    } catch (e) {
      throw Exception('Failed to delete notification settings: $e');
    }
  }

  // Get pastries that need notification
  Future<List<Map<String, dynamic>>> getLowStockPastries() async {
    try {
      return await _dbHelper.getLowStockPastriesWithNotifications();
    } catch (e) {
      throw Exception('Failed to get low stock pastries: $e');
    }
  }

  // Update last notification time
  Future<bool> updateLastNotificationTime(int pastryId, DateTime time) async {
    try {
      final settings = await getSettings(pastryId);
      final updated = settings.copyWith(
        lastNotificationTime: time.toIso8601String(),
      );
      return await saveSettings(updated);
    } catch (e) {
      throw Exception('Failed to update notification time: $e');
    }
  }

  // Snooze notification
  Future<bool> snoozeNotification(int pastryId, DateTime until) async {
    try {
      final settings = await getSettings(pastryId);
      final updated = settings.copyWith(
        notificationSnoozedUntil: until.toIso8601String(),
      );
      return await saveSettings(updated);
    } catch (e) {
      throw Exception('Failed to snooze notification: $e');
    }
  }
}