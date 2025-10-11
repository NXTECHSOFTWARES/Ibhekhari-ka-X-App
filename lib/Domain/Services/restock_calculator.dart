import 'package:nxbakers/Data/Model/daily_entry.dart';
import 'package:nxbakers/Data/Model/pastry.dart';
import 'package:nxbakers/Domain/Repositories/daily_entries_repo.dart';

class RestockRecommendation {
  final int currentStock;
  final double averageDailySales;
  final int daysOfData;
  final Map<int, int> recommendations; // days -> quantity needed
  final bool hasEnoughData;

  RestockRecommendation({
    required this.currentStock,
    required this.averageDailySales,
    required this.daysOfData,
    required this.recommendations,
    required this.hasEnoughData,
  });
}

class RestockCalculator {
  final DailyEntriesRepo _repo = DailyEntriesRepo();

  // Calculate restock recommendations for a pastry
  Future<RestockRecommendation> calculateRestock({
    required Pastry pastry,
    required int analysisPeriodDays,
    List<int> coverageDays = const [1, 2, 3, 5, 7],
  }) async {
    try {
      // Get historical sales data
      final allEntries = await _repo.getAllDailyEntries();

      // Filter entries for this pastry within the analysis period
      final cutoffDate = DateTime.now().subtract(
        Duration(days: analysisPeriodDays),
      );

      final relevantEntries = allEntries.where((entry) {
        if (entry.pastryId != pastry.id) return false;

        try {
          final entryDate = _parseDate(entry.createdAt);
          return entryDate.isAfter(cutoffDate);
        } catch (e) {
          return false;
        }
      }).toList();

      // Calculate average daily sales
      final salesData = _calculateAverageSales(relevantEntries);

      // Generate recommendations for different coverage periods
      final recommendations = <int, int>{};
      for (final days in coverageDays) {
        final needed = _calculateNeededStock(
          currentStock: pastry.quantity,
          averageDailySales: salesData['average']!,
          coverageDays: days,
        );
        recommendations[days] = needed;
      }

      return RestockRecommendation(
        currentStock: pastry.quantity,
        averageDailySales: salesData['average']!,
        daysOfData: salesData['daysWithSales']!.toInt(),
        recommendations: recommendations,
        hasEnoughData: salesData['daysWithSales']! >= 3,
      );
    } catch (e) {
      // Return default recommendation if calculation fails
      return RestockRecommendation(
        currentStock: pastry.quantity,
        averageDailySales: 0,
        daysOfData: 0,
        recommendations: {},
        hasEnoughData: false,
      );
    }
  }

  // Calculate average daily sales from entries
  Map<String, double> _calculateAverageSales(List<DailyEntry> entries) {
    if (entries.isEmpty) {
      return {'average': 0, 'total': 0, 'daysWithSales': 0};
    }

    // Group entries by date
    final Map<String, int> salesByDate = {};
    for (final entry in entries) {
      final dateKey = _getDateKey(entry.createdAt);
      salesByDate[dateKey] = (salesByDate[dateKey] ?? 0) + entry.soldStock;
    }

    // Calculate average (only from days with sales)
    final totalSales = salesByDate.values.fold(0, (sum, sales) => sum + sales);
    final daysWithSales = salesByDate.length.toDouble();
    final average = daysWithSales > 0 ? (totalSales / daysWithSales).toDouble() : 0.0;

    return {
      'average': average,
      'total': totalSales.toDouble(),
      'daysWithSales': daysWithSales,
    };
  }

  // Calculate how much stock is needed
  int _calculateNeededStock({
    required int currentStock,
    required double averageDailySales,
    required int coverageDays,
  }) {
    final totalNeeded = (averageDailySales * coverageDays).ceil();
    final toAdd = totalNeeded - currentStock;

    // Don't recommend negative numbers
    return toAdd > 0 ? toAdd : 0;
  }

  // Parse date string to DateTime
  DateTime _parseDate(String dateStr) {
    // Handle format: "Wednesday, 12 February 2025"
    try {
      final parts = dateStr.split(',');
      if (parts.length >= 2) {
        final datePart = parts[1].trim();
        return DateTime.parse(datePart);
      }
    } catch (e) {
      // Fallback
    }
    return DateTime.now();
  }

  // Get date key (without time) for grouping
  String _getDateKey(String dateStr) {
    try {
      final date = _parseDate(dateStr);
      return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateStr;
    }
  }

  // Get restock recommendations as formatted string
  String getRecommendationText(RestockRecommendation rec, int days) {
    if (!rec.hasEnoughData) {
      return "Not enough sales data (need at least 3 days)";
    }

    final needed = rec.recommendations[days] ?? 0;
    final total = rec.currentStock + needed;

    if (needed <= 0) {
      return "Current stock sufficient for $days day${days > 1 ? 's' : ''}";
    }

    return "Add $needed units (Total: $total for $days day${days > 1 ? 's' : ''})";
  }
}