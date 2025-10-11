import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:nxbakers/Data/Model/category.dart';
import 'package:nxbakers/Data/Model/daily_entry.dart';
import 'package:nxbakers/Data/Model/pastry.dart';
import 'package:nxbakers/Domain/Repositories/daily_entries_repo.dart';
import 'package:nxbakers/Domain/Repositories/pastry_repo.dart';
import 'package:nxbakers/Presentation/pages/DailyEntry/add_daily_entries.dart';

enum ViewState { idle, loading, error, success }

class DailyEntryViewModel extends ChangeNotifier {
  final PastryRepository _pastryRepository = PastryRepository();
  final DailyEntriesRepo _dailyEntryRepository = DailyEntriesRepo();

  // State management
  ViewState _state = ViewState.idle;
  String? _errorMessage;

  // Data
  List<Pastry> _pastries = [];
  List<DailyEntry> _dailyEntries = [];
  List<String> _listOfDailyEntryYear = [];
  List<Category> _categories = [];
  Map<String, Map<String, List<DailyEntry>>> _dailyEntriesFGroupByDate = {};

  // Getters
  ViewState get state => _state;

  String? get errorMessage => _errorMessage;

  List<Pastry> get pastries => _pastries;

  List<DailyEntry> get dailyEntries => _dailyEntries;

  List<String> get listOfDailyEntryYear => _listOfDailyEntryYear;

  List<Category> get categories => _categories;

  Map<String, Map<String, List<DailyEntry>>> get dailyEntriesFGroupByDate => _dailyEntriesFGroupByDate;

  bool get isLoading => _state == ViewState.loading;

  bool get hasError => _state == ViewState.error;

  bool get isEmpty => _pastries.isEmpty && _state != ViewState.loading;

  Future<void> loadTestData() async {
    try {
      final response = await rootBundle.loadString("assets/daily_entry_test_data.json");
      final Map<String, dynamic> data = json.decode(response);

      // Iterate through each date in the JSON data
      for (String dateKey in data.keys) {
        List<dynamic> entries = (data[dateKey] as List).map((entry) => DailyEntry.fromJson(entry)).toList();

        for (DailyEntry entry in entries) {
          Pastry? pastry = await _pastryRepository.getPastryById(entry.pastryId);

          if (pastry != null) {
            await addDailyEntry(
              soldStock: entry.soldStock,
              remainingStock: entry.remainingStock,
              pastryId: entry.pastryId,
              pastry: pastry,
              createdAt: dateKey,
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

  Future<bool> updatePastryQuantity(DailyEntry dailyEntry) async {
    Pastry? pastry = await _pastryRepository.getPastryById(dailyEntry.pastryId);
    if (pastry != null) {
      bool updateSuccess = await _pastryRepository.updatePastryQuantity(pastry.id!, dailyEntry.remainingStock);

      if (!updateSuccess) {
        _setError('Failed to update pastry stock');
        return false;
      }
    }
    return true;
  }

  Future<bool> addDailyEntry(
      {required int soldStock,
      required int remainingStock,
      required int pastryId,
      required Pastry pastry,
      createdAt}) async {
    _setState(ViewState.loading);

    try {
      DailyEntry dailyEntry = DailyEntry(
        soldStock: soldStock,
        remainingStock: remainingStock,
        createdAt: createdAt != null
            ? DateFormat('EEEE, d MMMM y').format(DateFormat('d MMMM y').parse(createdAt))
            : DateFormat('EEEE, d MMMM y').format(DateTime.now()),
        pastryId: pastryId,
      );

      // Check if an entry already exists for this pastry on this date
      DailyEntry? existingEntry = await _getExistingDailyEntry(dailyEntry);

      if (existingEntry != null) {
        DailyEntry updatedEntry = existingEntry.copyWith(
          soldStock: soldStock,
          remainingStock: remainingStock,
        );

        return await updateDailyEntry(updatedEntry);
      } else {
        await _dailyEntryRepository.addDailyEntry(dailyEntry);
        updatePastryQuantity(dailyEntry);
        await initialize();
        return true;
      }
    } catch (e) {
      print('Failed to add daily entries: $e');
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
      _pastries = pastries.where((pastry) => pastry.quantity > 0).toList();
      _setState(ViewState.success);
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
      _setError('Failed to load daily entries: $e');
    }
  }

  String getPeriodKey(DateTime date) {
    // If day is 10 or later, it belongs to current month's period
    // If day is 1-9, it belongs to previous month's period
    if (date.day >= 10) {
      // Period: 10th of current month to 9th of next month
      return DateFormat('dd MMMM yyyy').format(DateTime(date.year, date.month, 10));
    } else {
      // Period: 10th of previous month to 9th of current month
      DateTime previousMonth = DateTime(date.year, date.month - 1, 10);
      return DateFormat('dd MMMM yyyy').format(previousMonth);
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

  Map<String, Map<String, List<DailyEntry>>> groupDailyEntriesByDate(List<DailyEntry>  entries) {

    final Map<String, Map<String, List<DailyEntry>>> groupedData = {};

    for (DailyEntry entry in entries) {
      // Parse the date string to DateTime
      DateFormat inputFormat = DateFormat('EEEE, d MMMM yyyy');
      DateTime entryDate = inputFormat.parse(entry.createdAt);

      // Get the period key (e.g., "10 May 2025")
      String periodKey = getPeriodKey(entryDate);

      // Get the actual date string for the daily grouping
      String dailyKey = entry.createdAt.split(',').skip(1).join(',').trim();

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
    }

    return groupedData;
  }

  Future<void> getDailyEntriesDate() async {
    _dailyEntries = await _dailyEntryRepository.getAllDailyEntries();
    _dailyEntriesFGroupByDate = groupDailyEntriesByDate(_dailyEntries);

    List<String> dates = _dailyEntries.map((dailyEntry) => dailyEntry.createdAt).toList();
    // print("Dates ${dates.toString()}");
    print("Daily Entries: $_dailyEntriesFGroupByDate");
  }

  Future<void> _loadCategories() async {
    try {
      _categories = await _dailyEntryRepository.getCategories();
      notifyListeners();
    } catch (e) {
      _setError('Failed to load categories: $e');
    }
  }

  Future<DailyEntry?> _getExistingDailyEntry(DailyEntry newEntry) async {
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
  Future<bool> updateDailyEntry(DailyEntry dailyEntry) async {
    _setState(ViewState.loading);

    try {
      // First update the pastry quantity
      updatePastryQuantity(dailyEntry);

      // Then update the daily entry
      final success = await _dailyEntryRepository.updateDailyEntryQuantity(
          dailyEntry.id!, dailyEntry.soldStock, dailyEntry.remainingStock);
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
}
