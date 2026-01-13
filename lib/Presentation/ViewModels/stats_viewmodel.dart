import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:nxbakers/Data/Model/daily_entry.dart';
import 'package:nxbakers/Data/Model/pastry.dart';
import 'package:nxbakers/Domain/Repositories/daily_entries_repo.dart';
import 'package:nxbakers/Domain/Repositories/pastry_repo.dart';

import '../../Data/Model/stats_model.dart';

class StatsViewModel extends ChangeNotifier {
  final DailyEntriesRepo _dailyEntriesRepo = DailyEntriesRepo();
  final PastryRepository _pastryRepo = PastryRepository();

  List<DailyEntry> _dailyEntries = [];
  List<Pastry> _pastries = [];
  DateTime _selectedDate = DateTime.now();
  TimeFrame _selectedTimeFrame = TimeFrame.week;

  // Getters
  List<DailyEntry> get dailyEntries => _dailyEntries;
  List<Pastry> get pastries => _pastries;
  DateTime get selectedDate => _selectedDate;
  TimeFrame get selectedTimeFrame => _selectedTimeFrame;

  // Load data
  Future<void> loadData() async {
    await _loadPastries();
    await _loadDailyEntries();
    notifyListeners();
  }

  Future<void> _loadPastries() async {
    _pastries = await _pastryRepo.getAllPastries();
  }

  Future<void> _loadDailyEntries() async {
    _dailyEntries = await _dailyEntriesRepo.getAllDailyEntries();
  }

  // Set time frame
  void setTimeFrame(TimeFrame timeFrame) {
    _selectedTimeFrame = timeFrame;
    notifyListeners();
  }

  void setSelectedDate(DateTime date) {
    _selectedDate = date;
    notifyListeners();
  }

  // Core stats calculations
  List<SalesStats> getSalesStats() {
    switch (_selectedTimeFrame) {
      case TimeFrame.week:
        return _getWeeklyStats();
      case TimeFrame.month:
        return _getMonthlyStats();
      case TimeFrame.year:
        return _getYearlyStats();
    }
  }

  List<PastryPerformance> getTopPerformingPastries() {
    final Map<String, PastryPerformance> performanceMap = {};

    // Filter entries based on selected time frame
    final relevantEntries = _getRelevantEntries();

    for (final entry in relevantEntries) {
      final pastry = _pastries.firstWhere((p) => p.id == entry.pastryId);
      final key = pastry.title;

      if (performanceMap.containsKey(key)) {
        final current = performanceMap[key]!;
        performanceMap[key] = PastryPerformance(
          pastryName: key,
          totalSold: current.totalSold + entry.soldStock,
          revenue: current.revenue + (entry.soldStock * pastry.price),
          growthRate: current.growthRate, // You might want more complex growth calculation
          frequency: current.frequency + 1,
        );
      } else {
        performanceMap[key] = PastryPerformance(
          pastryName: key,
          totalSold: entry.soldStock,
          revenue: entry.soldStock * pastry.price,
          growthRate: 0.0,
          frequency: 1,
        );
      }
    }

    return performanceMap.values.toList()
      ..sort((a, b) => b.totalSold.compareTo(a.totalSold));
  }

  List<DailySalesData> getDailySalesComparison() {
    final Map<DateTime, DailySalesData> dailyData = {};
    final relevantEntries = _getRelevantEntries();

    if (relevantEntries.isEmpty) return [];

    // Calculate average for good/bad day classification
    final totalRevenue = relevantEntries.fold<double>(0, (sum, entry) {
      final pastry = _pastries.firstWhere(
            (p) => p.id == entry.pastryId,
        orElse: () => Pastry(
          title: 'Unknown',
          price: 0,
          quantity: 0,
          category: 'Unknown',
          imageBytes: Uint8List(0),
          createdAt: DateTime.now().toIso8601String(), shelfLife: 0,
        ),
      );
      return sum + (entry.soldStock * pastry.price);
    });
    final averageRevenue = totalRevenue / relevantEntries.length;

    for (final entry in relevantEntries) {
      try {
        // Parse the createdAt string to DateTime
        final entryDateTime = DateTime.parse(entry.createdAt);
        // Create a date-only DateTime (remove time component)
        final date = DateTime(entryDateTime.year, entryDateTime.month, entryDateTime.day);

        final pastry = _pastries.firstWhere(
              (p) => p.id == entry.pastryId,
          orElse: () => Pastry(
            title: 'Unknown',
            price: 0,
            quantity: 0,
            category: 'Unknown',
            imageBytes: Uint8List(0),
            createdAt: DateTime.now().toIso8601String(), shelfLife: 0,
          ),
        );
        final revenue = entry.soldStock * pastry.price;

        if (dailyData.containsKey(date)) {
          final current = dailyData[date]!;
          dailyData[date] = DailySalesData(
            date: date,
            revenue: current.revenue + revenue,
            itemsSold: current.itemsSold + entry.soldStock,
            isGoodDay: (current.revenue + revenue) > averageRevenue,
          );
        } else {
          dailyData[date] = DailySalesData(
            date: date,
            revenue: revenue,
            itemsSold: entry.soldStock,
            isGoodDay: revenue > averageRevenue,
          );
        }
      } catch (e) {
        print('Error processing entry ${entry.id}: $e');
        print('CreatedAt value: ${entry.createdAt}');
        continue;
      }
    }

    return dailyData.values.toList()
      ..sort((a, b) => a.date.compareTo(b.date));
  }

  // Helper methods - Simplified version using the new helper methods
  List<DailyEntry> _getRelevantEntries() {
    final now = _selectedDate;

    switch (_selectedTimeFrame) {
      case TimeFrame.week:
        final startOfWeek = DateTime(now.year, now.month, now.day - now.weekday + 1);
        final endOfWeek = startOfWeek.add(const Duration(days: 7));
        return _dailyEntries.where((entry) =>
            entry.isWithinDateRange(startOfWeek, endOfWeek)).toList();

      case TimeFrame.month:
        final startOfMonth = DateTime(now.year, now.month, 1);
        final endOfMonth = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
        return _dailyEntries.where((entry) =>
            entry.isWithinDateRange(startOfMonth, endOfMonth)).toList();

      case TimeFrame.year:
        final startOfYear = DateTime(now.year, 1, 1);
        final endOfYear = DateTime(now.year, 12, 31, 23, 59, 59);
        return _dailyEntries.where((entry) =>
            entry.isWithinDateRange(startOfYear, endOfYear)).toList();
    }
  }


  List<SalesStats> _getWeeklyStats() {
    // Implementation for weekly stats
    final entries = _getRelevantEntries();
    // Your calculation logic here
    return [];
  }

  List<SalesStats> _getMonthlyStats() {
    // Implementation for monthly stats
    return [];
  }

  List<SalesStats> _getYearlyStats() {
    // Implementation for yearly stats
    return [];
  }

  // New stock calculation
  List<Pastry> getNewStock() {
    final oneWeekAgo = DateTime.now().subtract(const Duration(days: 7));
    return _pastries.where((pastry) {
      final created = DateTime.tryParse(pastry.createdAt ?? '');
      return created != null && created.isAfter(oneWeekAgo);
    }).toList();
  }

  // Frequently sold items (items sold more than 3 times in the period)
  List<PastryPerformance> getFrequentlySold() {
    return getTopPerformingPastries()
        .where((performance) => performance.frequency > 3)
        .toList();
  }
}

enum TimeFrame { week, month, year }