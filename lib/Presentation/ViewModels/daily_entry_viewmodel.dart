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
  List<String> _listOfDailyEntryDates = [];
  List<Category> _categories = [];
  Map<String, List<DailyEntry>> _dailyEntriesFGroupByDate = {};

  // Getters
  ViewState get state => _state;
  String? get errorMessage => _errorMessage;
  List<Pastry> get pastries => _pastries;
  List<DailyEntry> get dailyEntries => _dailyEntries;
  List<String> get listOfDailyEntryDates => _listOfDailyEntryDates;
  List<Category> get categories => _categories;
  Map<String, List<DailyEntry>> get dailyEntriesFGroupByDate =>
      _dailyEntriesFGroupByDate;

  bool get isLoading => _state == ViewState.loading;
  bool get hasError => _state == ViewState.error;
  bool get isEmpty => _pastries.isEmpty && _state != ViewState.loading;

  Future<void> loadTestData() async {
    final response = await rootBundle.loadString("assets/daily_entry_test_data.json");
    final data = json.decode(response);
    List<DailyEntry> entries = data.map((entry) => DailyEntry.fromJson(entry)).toList();

    for (DailyEntry entry in entries) {
      Pastry? pastry = await _pastryRepository.getPastryById(entry.pastryId);

      await addDailyEntry(
        soldStock: entry.soldStock,
        remainingStock: entry.remainingStock,
        pastryId: entry.pastryId,
        pastry: pastry!,
      );
    }
  }

  Future<bool> addDailyEntry({
    required soldStock,
    required remainingStock,
    required pastryId,
    required Pastry pastry,
  }) async {
    _setState(ViewState.loading);

    try {
      bool updateSuccess = await _pastryRepository.updatePastryQuantity(
          pastry.id!, remainingStock);

      if (!updateSuccess) {
        _setError('Failed to update pastry stock');
        return false;
      }

      DailyEntry dailyEntry = DailyEntry(
        soldStock: soldStock,
        remainingStock: remainingStock,
        createdAt: DateFormat('EEEE, d MMMM y').format(DateTime.now()),
        pastryId: pastryId,
      );

      if (!await _dailyEntryRepository.isDailyEntryUniqueUnique(dailyEntry)) {
        updateDailyEntry(dailyEntry);
      } else {
        await _dailyEntryRepository.addDailyEntry(dailyEntry);
      }
      await initialize();
      return true;
    } catch (e) {
      _setError('Failed to add daily entries: $e');
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

  Map<String, List<DailyEntry>> groupDailyEntriesByDate(
      List<DailyEntry> allEntries) {
    Map<String, List<DailyEntry>> groupedEntries = {};

    for (var entry in allEntries) {
      String dateKey = entry.createdAt;

      if (!groupedEntries.containsKey(dateKey)) {
        groupedEntries[dateKey] = [];
      }

      groupedEntries[dateKey]!.add(entry);
    }

    return groupedEntries;
  }

  Future<void> getDailyEntriesDate() async {
    _dailyEntries = await _dailyEntryRepository.getAllDailyEntries();
    _dailyEntriesFGroupByDate = groupDailyEntriesByDate(_dailyEntries);

    List<String> dates =
        _dailyEntries.map((dailyEntry) => dailyEntry.createdAt).toList();
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

  // // Update existing daily entry
  Future<bool> updateDailyEntry(DailyEntry dailyEntry) async {
    _setState(ViewState.loading);

    try {
      final success = await _dailyEntryRepository.updateDailyEntryQuantity(
          dailyEntry.id!, dailyEntry.soldStock, dailyEntry.remainingStock);
      if (success) {
        await loadDailyEntries();
        return true;
      } else {
        return false;
      }
    } catch (e) {
      // _setError('Failed to update pastry: $e');
      return false;
    }
  }
}
