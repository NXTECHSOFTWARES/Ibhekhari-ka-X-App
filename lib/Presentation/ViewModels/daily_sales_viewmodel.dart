import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:nxbakers/Data/Model/category.dart';
import 'package:nxbakers/Data/Model/daily_sale.dart';
import 'package:nxbakers/Data/Model/pastry.dart';
import 'package:nxbakers/Domain/Repositories/daily_entries_repo.dart';
import 'package:nxbakers/Domain/Repositories/pastry_repo.dart';
import 'package:nxbakers/Domain/Repositories/shelf_records_repository.dart';
import 'package:nxbakers/Presentation/pages/DailyEntry/add_daily_entries.dart';

enum ViewState { idle, loading, error, success }

class DailySalesViewModel extends ChangeNotifier {
  final ShelfRecordsRepository _shelfRecordsRepository = ShelfRecordsRepository();
  final PastryRepository _pastryRepository = PastryRepository();
  final DailyEntriesRepo _dailyEntryRepository = DailyEntriesRepo();

  // State management
  ViewState _state = ViewState.idle;
  String? _errorMessage;

  // Data
  List<Pastry> _pastries = [];
  List<DailySale> _dailyEntries = [];
  List<String> _listOfDailySalesYear = [];
  List<String> _listOfMonths = [];
  List<String> _listOfYears = [];
  List<Category> _categories = [];
  Map<String, Map<String, List<DailySale>>> _dailySalesFGroupByDate = {};

  // Getters
  ViewState get state => _state;

  String? get errorMessage => _errorMessage;

  List<Pastry> get pastries => _pastries;

  List<DailySale> get dailyEntries => _dailyEntries;

  List<String> get listOfDailyEntryYear => _listOfDailySalesYear;

  List<Category> get categories => _categories;

  Map<String, Map<String, List<DailySale>>> get dailyEntriesFGroupByDate => _dailySalesFGroupByDate;

  bool get isLoading => _state == ViewState.loading;

  bool get hasError => _state == ViewState.error;

  bool get isEmpty => _pastries.isEmpty && _state != ViewState.loading;

  List<String>  get listOfMonths => _listOfMonths;
  List<String>  get listOfYears => _listOfMonths;


  // Current filters
  String? _selectedYear;
  String? _selectedMonth;


  Future<void> loadTestData() async {
    try {
      final response = await rootBundle.loadString("assets/daily_sales_test_data.json");
      final Map<String, dynamic> data = json.decode(response);

      // Iterating through each date in the JSON data
      for (String dateKey in data.keys) {

        DateTime parsedDate;
        try {
          parsedDate = DateFormat('d MMMM y', 'en_US').parse(dateKey);
        } catch (e) {
          final parts = dateKey.split(' ');
          final day = int.parse(parts[0]);
          final year = int.parse(parts[2]);
          final monthMap = {
            'January': 1, 'February': 2, 'March': 3, 'April': 4,
            'May': 5, 'June': 6, 'July': 7, 'August': 8,
            'September': 9, 'October': 10, 'November': 11, 'December': 12,
          };
          final month = monthMap[parts[1]]!;
          parsedDate = DateTime(year, month, day);
        }

        // Format as ISO date for storage
        String isoDate = DateFormat('yyyy-MM-dd').format(parsedDate);

        List<dynamic> entries = data[dateKey] as List;

        for (var entryJson in entries) {
          DailySale entry = DailySale.fromJson(entryJson);

          Pastry? pastry = await _pastryRepository.getPastryById(entry.pastryId);

          if (pastry != null) {
            await addDailyEntry(
              soldStock: entry.soldStock,
              remainingStock: entry.remainingStock,
              pastryId: entry.pastryId,
              pastry: pastry,
              createdAt: isoDate, // Pass ISO format: "2025-02-10"
            );
          } else {
            print('Warning: Pastry with ID ${entry.pastryId} not found for date $dateKey. Skipping entry.');
          }
        }
      }
    } catch (e) {
      print('Failed to load test data: $e');
    }
  }

  // Future<bool> updatePastryQuantity(DailySale dailyEntry) async {
  //   Pastry? pastry = await _pastryRepository.getPastryById(dailyEntry.pastryId);
  //   if (pastry != null) {
  //     bool updateSuccess = await _pastryRepository.updatePastryQuantity(pastry.id!, dailyEntry.remainingStock);
  //
  //     if (!updateSuccess) {
  //       _setError('Failed to update pastry stock');
  //       return false;
  //     }
  //   }
  //   return true;
  // }

  Future<bool> addDailyEntry({
    required int soldStock,
    required int remainingStock,
    required int pastryId,
    required Pastry pastry,
    String? createdAt,
  }) async {
    _setState(ViewState.loading);

    try {
      // Store date in ISO format
      String isoDate = createdAt ?? DateFormat('yyyy-MM-dd').format(DateTime.now());

      DailySale dailyEntry = DailySale(
        soldStock: soldStock,
        remainingStock: remainingStock,
        createdAt: isoDate, // Store as "2026-01-22"
        pastryId: pastryId,
      );

      // Check if an entry already exists for this pastry on this date
      DailySale? existingEntry = await _getExistingDailyEntry(dailyEntry);

      if (existingEntry != null) {
        DailySale updatedEntry = existingEntry.copyWith(
          soldStock: soldStock,
          remainingStock: remainingStock,
        );

        return await updateDailyEntry(updatedEntry);
      } else {
        await _dailyEntryRepository.addDailyEntry(dailyEntry);
        await _shelfRecordsRepository.updateShelfRecordQuantity(remainingStock, pastryId);
        await initialize();
        return true;
      }
    } catch (e, stackTrace) {
      print('Failed to add daily sales: $e');
      print('Stack trace: $stackTrace');
      return false;
    }
  }

  // // Initialize data
  Future<void> initialize() async {
    await loadPastries();
    await loadDailyEntries();
    await _loadCategories();
    await getDailyEntriesDate();
  }

  // Private helper methods
  void _setState(ViewState newState) {
    _state = newState;
    if (newState != ViewState.error) {
      _errorMessage = null;
    }
    notifyListeners();
  }

  void _setError(String message) {
    _state = ViewState.error;
    _errorMessage = message;
    notifyListeners();
  }

  // Load all pastries
  Future<void> loadPastries() async {
    _setState(ViewState.loading);
    try {
      List<Pastry> pastries = await _pastryRepository.getAllPastries();
      _pastries = pastries;
      _setState(ViewState.success);
      notifyListeners();
    } catch (e) {
      _setError('Failed to load pastries: $e');
    }
  }

  // Load all daily entries
  Future<void> loadDailyEntries() async {
    _setState(ViewState.loading);
    try {
      _dailyEntries = await _dailyEntryRepository.getAllDailyEntries();
      _setState(ViewState.success);
    } catch (e) {
      _setError('Failed to load daily sales: $e');
    }
  }

  String getPeriodKey(DateTime date) {
    // If day is 10 or later, it belongs to current month's period
    // If day is 1-9, it belongs to previous month's period
    if (date.day >= 10) {
      // Period: 10th of current month to 9th of next month
      return DateFormat('d MMMM yyyy').format(DateTime(date.year, date.month, 10)); // Changed 'dd' to 'd'
    } else {
      // Period: 10th of previous month to 9th of current month
      DateTime previousMonth = DateTime(date.year, date.month - 1, 10);
      return DateFormat('d MMMM yyyy').format(previousMonth); // Changed 'dd' to 'd'
    }
  }

  //
  // Map<String, List<DailyEntry>>  groupCommonDailyEntriesByDate(List<DailyEntry> allEntries) {
  //
  //   Map<String, List<DailyEntry>> groupedEntries = {};
  //
  //   for (var entry in allEntries) {
  //     String dateKey = entry.createdAt;
  //
  //     if (!groupedEntries.containsKey(dateKey)) {
  //       groupedEntries[dateKey] = [];
  //     }
  //
  //     groupedEntries[dateKey]!.add(entry);
  //
  //   }
  //
  //   //groupDailyEntriesByDate(groupedEntries);
  //   return groupedEntries;
  // }

  Map<String, Map<String, List<DailySale>>> groupDailyEntriesByDate(List<DailySale> entries) {
    final Map<String, Map<String, List<DailySale>>> groupedData = {};

    for (DailySale entry in entries) {
      try {
        // Parse the ISO date string (e.g., "2025-02-12")
        DateTime entryDate = DateTime.parse(entry.createdAt);

        // Get the period key (e.g., "10 February 2025")
        String periodKey = getPeriodKey(entryDate);

        // Create the display date key (e.g., "Wednesday, 12 February 2025")
        String dailyKey = DateFormat('EEEE, d MMMM y').format(entryDate);

        // Initialize the period if it doesn't exist
        if (!groupedData.containsKey(periodKey)) {
          groupedData[periodKey] = {};
        }

        // Initialize the daily list if it doesn't exist
        if (!groupedData[periodKey]!.containsKey(dailyKey)) {
          groupedData[periodKey]![dailyKey] = [];
        }

        // Add the entry to the daily list
        groupedData[periodKey]![dailyKey]!.add(entry);
      } catch (e) {
        print('Error parsing date for entry: ${entry.createdAt}');
        print('Error: $e');
      }
    }

    return groupedData;
  }

  Future<void> getDailyEntriesDate() async {
    _dailyEntries = await _dailyEntryRepository.getAllDailyEntries();
    _dailySalesFGroupByDate = groupDailyEntriesByDate(_dailyEntries);

    List<String> dates = _dailyEntries.map((dailyEntry) => dailyEntry.createdAt).toList();
    // print("Dates ${dates.toString()}");
    // print("Daily sales: $_dailySalesFGroupByDate");
  }

  Future<void> _loadCategories() async {
    try {
      _categories = await _dailyEntryRepository.getCategories();
      notifyListeners();
    } catch (e) {
      _setError('Failed to load categories: $e');
    }
  }

  Future<DailySale?> _getExistingDailyEntry(DailySale newEntry) async {
    final entries = await _dailyEntryRepository.getAllDailyEntries();
    try {
      return entries.firstWhere(
        (entry) => entry.pastryId == newEntry.pastryId && entry.createdAt == newEntry.createdAt,
      );
    } catch (e) {
      return null;
    }
  }

  // // Update existing daily entry
  Future<bool> updateDailyEntry(DailySale dailyEntry) async {
    _setState(ViewState.loading);

    try {
      // First update the pastry quantity
      //updatePastryQuantity(dailyEntry);

      // Then update the daily entry
      final success = await _dailyEntryRepository.updateDailyEntryQuantity(dailyEntry.id!, dailyEntry.soldStock, dailyEntry.remainingStock);
      if (success) {
        await initialize();
        return true;
      } else {
        _setError('Failed to update daily entry');
        return false;
      }
    } catch (e) {
      _setError('Failed to update daily entry: $e');
      return false;
    }
  }

  // void filterDailySalesByMonth(String month) {
  //   _selectedMonth = month;
  //
  //   List<Map<String, List<DailySale>>> filterDailySales = [];
  //
  //   for (var record in dailyEntries) {
  //     final recordMonth = record.date;
  //     final formattedMonth = DateFormat("MMMM").format(recordMonth);
  //     print("Hey: Record Month $formattedMonth");
  //     if (formattedMonth == month) {
  //       filteredRecordsList.add(record);
  //     }
  //   }
  //
  //   _bakingRecords = filteredRecordsList;
  //   // _createListOfAvailableMonths(); // Update months for the selected year
  //   // _groupRecordsByMonth(); // Re-group by month
  //   notifyListeners();
  // }
}
