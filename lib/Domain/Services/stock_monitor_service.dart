import 'package:nxbakers/Data/Model/pastry.dart';
import 'package:nxbakers/Data/Model/pastry_notification_settings.dart';
import 'package:nxbakers/Domain/Repositories/notification_settings_repo.dart';
import 'package:nxbakers/Domain/Repositories/pastry_repo.dart';
import 'package:nxbakers/Domain/Services/notification_service.dart';
import 'package:nxbakers/Domain/Services/restock_calculator.dart';

class StockMonitorService {
  static final StockMonitorService _instance = StockMonitorService._internal();
  factory StockMonitorService() => _instance;
  StockMonitorService._internal();

  final NotificationService _notificationService = NotificationService();
  final NotificationSettingsRepository _settingsRepo = NotificationSettingsRepository();
  final PastryRepository _pastryRepo = PastryRepository();
  final RestockCalculator _calculator = RestockCalculator();

  // Check all pastries for low stock
  Future<List<Pastry>> checkLowStockPastries() async {
    try {
      // Get all pastries
      final pastries = await _pastryRepo.getAllPastries();

      // Get all notification settings
      final allSettings = await _settingsRepo.getAllSettings();

      final lowStockPastries = <Pastry>[];

      for (final pastry in pastries) {
        if (pastry.id == null) continue;

        // Get settings for this pastry
        final settings = allSettings.firstWhere(
              (s) => s.pastryId == pastry.id,
          orElse: () => PastryNotificationSettings(pastryId: pastry.id!),
        );

        // Skip if notifications disabled
        if (!settings.notificationEnabled) continue;

        // Check if stock is at or below threshold
        if (pastry.quantity <= settings.lowStockThreshold) {
          lowStockPastries.add(pastry);

          // Check if we should send notification
          if (await _shouldSendNotification(pastry.id!, settings)) {
            await _sendLowStockNotification(pastry, settings);
          }
        }
      }

      return lowStockPastries;
    } catch (e) {
      print('Error checking low stock pastries: $e');
      return [];
    }
  }

  // Check if notification should be sent
  Future<bool> _shouldSendNotification(
      int pastryId,
      PastryNotificationSettings settings,
      ) async {
    // Check if snoozed
    if (settings.notificationSnoozedUntil != null) {
      final snoozedUntil = DateTime.parse(settings.notificationSnoozedUntil!);
      if (DateTime.now().isBefore(snoozedUntil)) {
        return false; // Still snoozed
      }
    }

    // Check last notification time
    if (settings.lastNotificationTime != null) {
      final lastNotification = DateTime.parse(settings.lastNotificationTime!);
      final nextNotification = lastNotification.add(
        Duration(hours: settings.reminderIntervalHours),
      );

      if (DateTime.now().isBefore(nextNotification)) {
        return false; // Too soon for next notification
      }
    }

    return true;
  }

  // Send low stock notification with recommendation
  Future<void> _sendLowStockNotification(
      Pastry pastry,
      PastryNotificationSettings settings,
      ) async {
    try {
      // Show low stock alert
      await _notificationService.showLowStockNotification(
        id: pastry.id!,
        pastryName: pastry.title,
        currentStock: pastry.quantity,
        threshold: settings.lowStockThreshold,
      );

      // Calculate restock recommendation
      final recommendation = await _calculator.calculateRestock(
        pastry: pastry,
        analysisPeriodDays: settings.analysisPeriodDays,
        coverageDays: [settings.defaultCoverageDays],
      );

      // Show restock recommendation if we have data
      if (recommendation.hasEnoughData) {
        final recommendedQty = recommendation
            .recommendations[settings.defaultCoverageDays] ?? 0;

        if (recommendedQty > 0) {
          await _notificationService.showRestockRecommendation(
            id: pastry.id!,
            pastryName: pastry.title,
            recommendedQuantity: recommendedQty,
            currentStock: pastry.quantity,
          );
        }
      }

      // Schedule reminder
      await _notificationService.scheduleReminderNotification(
        id: pastry.id!,
        pastryName: pastry.title,
        currentStock: pastry.quantity,
        reminderInterval: Duration(hours: settings.reminderIntervalHours),
      );

      // Update last notification time
      await _settingsRepo.updateLastNotificationTime(
        pastry.id!,
        DateTime.now(),
      );
    } catch (e) {
      print('Error sending notification: $e');
    }
  }

  // Send summary notification for multiple items
  Future<void> sendSummaryNotification(List<Pastry> lowStockPastries) async {
    if (lowStockPastries.isEmpty) return;

    try {
      final pastryNames = lowStockPastries.map((p) => p.title).toList();
      await _notificationService.showSummaryNotification(
        pastryNames: pastryNames,
      );
    } catch (e) {
      print('Error sending summary notification: $e');
    }
  }

  // Snooze notification for a pastry
  Future<void> snoozeNotification(int pastryId, Duration duration) async {
    try {
      final snoozeUntil = DateTime.now().add(duration);
      await _settingsRepo.snoozeNotification(pastryId, snoozeUntil);
      await _notificationService.cancelNotification(pastryId);
    } catch (e) {
      print('Error snoozing notification: $e');
    }
  }

  // Dismiss notification (don't remind again until next threshold trigger)
  Future<void> dismissNotification(int pastryId) async {
    try {
      await _notificationService.cancelNotification(pastryId);
      await _notificationService.cancelNotification(pastryId + 1000);
      await _notificationService.cancelNotification(pastryId + 2000);
    } catch (e) {
      print('Error dismissing notification: $e');
    }
  }
}