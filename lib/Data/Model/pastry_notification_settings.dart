class PastryNotificationSettings {
  final int? id;
  final int pastryId;
  final int lowStockThreshold;
  final bool notificationEnabled;
  final int reminderIntervalHours;
  final int defaultCoverageDays;
  final int analysisPeriodDays;
  final String? lastNotificationTime;
  final String? notificationSnoozedUntil;

  PastryNotificationSettings({
    this.id,
    required this.pastryId,
    this.lowStockThreshold = 5,
    this.notificationEnabled = true,
    this.reminderIntervalHours = 2,
    this.defaultCoverageDays = 2,
    this.analysisPeriodDays = 14,
    this.lastNotificationTime,
    this.notificationSnoozedUntil,
  });

  // CopyWith method
  PastryNotificationSettings copyWith({
    int? id,
    int? pastryId,
    int? lowStockThreshold,
    bool? notificationEnabled,
    int? reminderIntervalHours,
    int? defaultCoverageDays,
    int? analysisPeriodDays,
    String? lastNotificationTime,
    String? notificationSnoozedUntil,
  }) {
    return PastryNotificationSettings(
      id: id ?? this.id,
      pastryId: pastryId ?? this.pastryId,
      lowStockThreshold: lowStockThreshold ?? this.lowStockThreshold,
      notificationEnabled: notificationEnabled ?? this.notificationEnabled,
      reminderIntervalHours: reminderIntervalHours ?? this.reminderIntervalHours,
      defaultCoverageDays: defaultCoverageDays ?? this.defaultCoverageDays,
      analysisPeriodDays: analysisPeriodDays ?? this.analysisPeriodDays,
      lastNotificationTime: lastNotificationTime ?? this.lastNotificationTime,
      notificationSnoozedUntil: notificationSnoozedUntil ?? this.notificationSnoozedUntil,
    );
  }

  // ToJson - with database-safe versions
  Map<String, dynamic> toJson() {
    return {
      'pastry_id': pastryId,
      'low_stock_threshold': lowStockThreshold,
      'notification_enabled': notificationEnabled ? 1 : 0,
      'reminder_interval_hours': reminderIntervalHours,
      'default_coverage_days': defaultCoverageDays,
      'analysis_period_days': analysisPeriodDays,
      'last_notification_time': lastNotificationTime,
      'notification_snoozed_until': notificationSnoozedUntil,
    };
  }

// Separate method for updates (excludes id)
  Map<String, dynamic> toJsonForUpdate() {
    return {
      'low_stock_threshold': lowStockThreshold,
      'notification_enabled': notificationEnabled ? 1 : 0,
      'reminder_interval_hours': reminderIntervalHours,
      'default_coverage_days': defaultCoverageDays,
      'analysis_period_days': analysisPeriodDays,
      'last_notification_time': lastNotificationTime,
      'notification_snoozed_until': notificationSnoozedUntil,
    };
  }

// Separate method for inserts (includes pastry_id but not id)
  Map<String, dynamic> toJsonForInsert() {
    return {
      'pastry_id': pastryId,
      'low_stock_threshold': lowStockThreshold,
      'notification_enabled': notificationEnabled ? 1 : 0,
      'reminder_interval_hours': reminderIntervalHours,
      'default_coverage_days': defaultCoverageDays,
      'analysis_period_days': analysisPeriodDays,
      'last_notification_time': lastNotificationTime,
      'notification_snoozed_until': notificationSnoozedUntil,
    };
  }

  // FromJson
  factory PastryNotificationSettings.fromJson(Map<String, dynamic> json) {
    return PastryNotificationSettings(
      id: json['id'],
      pastryId: json['pastry_id'],
      lowStockThreshold: json['low_stock_threshold'] ?? 5,
      notificationEnabled: json['notification_enabled'] == 1,
      reminderIntervalHours: json['reminder_interval_hours'] ?? 2,
      defaultCoverageDays: json['default_coverage_days'] ?? 2,
      analysisPeriodDays: json['analysis_period_days'] ?? 14,
      lastNotificationTime: json['last_notification_time'],
      notificationSnoozedUntil: json['notification_snoozed_until'],
    );
  }

  @override
  String toString() {
    return 'PastryNotificationSettings(id: $id, pastryId: $pastryId, threshold: $lowStockThreshold, enabled: $notificationEnabled)';
  }
}