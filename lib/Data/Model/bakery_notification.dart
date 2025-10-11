import 'package:flutter/material.dart';

enum NotificationType {
  lowStock,
  outOfStock,
  profitLoss,
  stockLoss,
  breakEven,
  restockSuggestion, // Add this
  reminder, // Add this
  summary, // Add this
  general,
}

class BakeryNotification {
  final String id;
  final NotificationType type;
  final String title;
  final String summary;
  final String? detailedMessage;
  final DateTime createdAt;
  final bool isRead;
  final String? relatedItemId; // For pastry ID, ingredient ID, etc.
  final String? relatedItemName;
  final Map<String, dynamic>? additionalData;

  BakeryNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.summary,
    this.detailedMessage,
    required this.createdAt,
    this.isRead = false,
    this.relatedItemId,
    this.relatedItemName,
    this.additionalData,
  });

  BakeryNotification copyWith({
    String? id,
    NotificationType? type,
    String? title,
    String? summary,
    String? detailedMessage,
    DateTime? createdAt,
    bool? isRead,
    String? relatedItemId,
    String? relatedItemName,
    Map<String, dynamic>? additionalData,
  }) {
    return BakeryNotification(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      summary: summary ?? this.summary,
      detailedMessage: detailedMessage ?? this.detailedMessage,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
      relatedItemId: relatedItemId ?? this.relatedItemId,
      relatedItemName: relatedItemName ?? this.relatedItemName,
      additionalData: additionalData ?? this.additionalData,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.toString(),
      'title': title,
      'summary': summary,
      'detailedMessage': detailedMessage,
      'createdAt': createdAt.toIso8601String(),
      'isRead': isRead,
      'relatedItemId': relatedItemId,
      'relatedItemName': relatedItemName,
      'additionalData': additionalData,
    };
  }

  factory BakeryNotification.fromJson(Map<String, dynamic> json) {
    try {
      return BakeryNotification(
        id: json['id'] ?? '',
        type: NotificationType.values.firstWhere(
              (e) => e.toString() == json['type'],
          orElse: () => NotificationType.general,
        ),
        title: json['title'] ?? '',
        summary: json['summary'] ?? '',
        detailedMessage: json['detailedMessage'],
        createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
        isRead: json['isRead'] ?? false,
        relatedItemId: json['relatedItemId'],
        relatedItemName: json['relatedItemName'],
        additionalData: json['additionalData'],
      );
    } catch (e) {
      print('Error parsing BakeryNotification: $e');
      // Return a default notification instead of crashing
      return BakeryNotification(
        id: 'error_${DateTime.now().millisecondsSinceEpoch}',
        type: NotificationType.general,
        title: 'Error Loading Notification',
        summary: 'There was an error loading this notification',
        createdAt: DateTime.now(),
      );
    }
  }

  IconData getIcon() {
    switch (type) {
      case NotificationType.lowStock:
        return Icons.inventory_2_outlined;
      case NotificationType.outOfStock:
        return Icons.production_quantity_limits;
      case NotificationType.profitLoss:
        return Icons.trending_down;
      case NotificationType.stockLoss:
        return Icons.warning_amber_rounded;
      case NotificationType.breakEven:
        return Icons.show_chart;
      case NotificationType.restockSuggestion: // Add this case
        return Icons.lightbulb_outline;
      case NotificationType.reminder: // Add this case
        return Icons.notifications_active;
      case NotificationType.summary: // Add this case
        return Icons.list_alt;
      case NotificationType.general:
        return Icons.info_outline;
    }
  }

  Color getColor() {
    switch (type) {
      case NotificationType.lowStock:
        return Colors.orange.shade700;
      case NotificationType.outOfStock:
        return Colors.red.shade700;
      case NotificationType.profitLoss:
        return Colors.red.shade600;
      case NotificationType.stockLoss:
        return Colors.orange.shade800;
      case NotificationType.breakEven:
        return Colors.blue.shade700;
      case NotificationType.restockSuggestion: // Add this case
        return Colors.green.shade700;
      case NotificationType.reminder: // Add this case
        return Colors.purple.shade700;
      case NotificationType.summary: // Add this case
        return Colors.deepOrange.shade700;
      case NotificationType.general:
        return Colors.grey.shade700;
    }
  }

  String getTypeLabel() {
    switch (type) {
      case NotificationType.lowStock:
        return "Low Stock Alert";
      case NotificationType.outOfStock:
        return "Out of Stock";
      case NotificationType.profitLoss:
        return "Profit Loss Alert";
      case NotificationType.stockLoss:
        return "Stock Loss Alert";
      case NotificationType.breakEven:
        return "Break-Even Alert";
      case NotificationType.restockSuggestion: // Add this case
        return "Restock Suggestion";
      case NotificationType.reminder: // Add this case
        return "Reminder";
      case NotificationType.summary: // Add this case
        return "Stock Summary";
      case NotificationType.general:
        return "General";
    }
  }
}