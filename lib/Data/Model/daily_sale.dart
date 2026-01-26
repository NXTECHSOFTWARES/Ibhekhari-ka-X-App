import 'package:intl/intl.dart';

class DailySale {
  final int? id;
  final int soldStock;
  final int remainingStock;
  final int? pastryLoss;
  final String createdAt; // Stored as "2026-01-22"
  final int pastryId;

  DailySale({
    this.id,
    required this.soldStock,
    required this.remainingStock,
    this.pastryLoss,
    required this.createdAt,
    required this.pastryId,
  });

  factory DailySale.fromJson(Map<String, dynamic> json) {
    return DailySale(
      id: json["id"],
      soldStock: json["sold_stock"],
      remainingStock: json["remaining_stock"],
      pastryLoss: json["pastry_loss"] ?? 0,
      createdAt: json['created_at'] ?? DateFormat('yyyy-MM-dd').format(DateTime.now()),
      pastryId: json["pastry_id"],
    );
  }

  // Helper method to get the date as DateTime
  DateTime get date {
    try {
      return DateTime.parse(createdAt); // Works with "2026-01-22"
    } catch (e) {
      return DateTime.now();
    }
  }

  // Helper to get formatted display date
  String get displayDate {
    try {
      final date = DateTime.parse(createdAt);
      return DateFormat('EEEE, d MMMM y').format(date); // "Monday, 22 January 2026"
    } catch (e) {
      return createdAt;
    }
  }

  // Helper to check if this entry is within a date range
  bool isWithinDateRange(DateTime start, DateTime end) {
    final entryDate = date;
    return entryDate.isAfter(start.subtract(const Duration(seconds: 1))) &&
        entryDate.isBefore(end);
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "sold_stock": soldStock,
      "remaining_stock": remainingStock,
      "pastry_loss": pastryLoss ?? 0,
      "created_at": createdAt,
      "pastry_id": pastryId,
    };
  }

  @override
  String toString() {
    return '''
DailyEntry {
  id: $id,
  soldStock: $soldStock,
  remainingStock: $remainingStock,
  pastry_loss: $pastryLoss,
  createdAt: $createdAt,
  pastryId: $pastryId
}
''';
  }

  DailySale copyWith({
    int? id,
    int? soldStock,
    int? remainingStock,
    String? createdAt,
    int? pastryId,
  }) {
    return DailySale(
      id: id ?? this.id,
      soldStock: soldStock ?? this.soldStock,
      remainingStock: remainingStock ?? this.remainingStock,
      createdAt: createdAt ?? this.createdAt,
      pastryId: pastryId ?? this.pastryId,
    );
  }
}