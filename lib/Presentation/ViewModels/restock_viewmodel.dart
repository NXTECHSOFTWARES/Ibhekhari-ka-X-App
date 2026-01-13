import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:nxbakers/Data/Model/baking_records.dart';
import 'package:nxbakers/Data/Model/restock_record.dart';
import 'package:nxbakers/Domain/Repositories/baking_repos.dart';
import 'package:nxbakers/Domain/Repositories/restock_record_repo.dart';
import 'package:nxbakers/Presentation/ViewModels/pastry_viewmodel.dart';

import '../../Domain/Repositories/pastry_repo.dart';
import 'baking_record_viewmodel.dart';

enum ViewState { idle, loading, error, success }

class RestockViewModel extends ChangeNotifier {

  final RestockRecordRepo _recordRepo = RestockRecordRepo();
  final PastryRepository _pastryRepository = PastryRepository();

  // State management
  ViewState _state = ViewState.idle;
  String? _errorMessage;

  // Store original data separately from filtered data
  List<Map<String, List<RestockRecord>>> _allRestockRecords = [];
  List<Map<String, List<RestockRecord>>> _restockRecords = [];

  // Store records grouped by month for display
  final Map<String, List<Map<String, List<RestockRecord>>>> _recordsByMonth = {};

  List<String> _listOfYears = [];
  List<String> _listOfMonths = [];

  // Current filters
  String? _selectedYear;

  // Getters
  List<Map<String, List<RestockRecord>>> get restockRecords => _restockRecords;
  Map<String, List<Map<String, List<RestockRecord>>>> get recordsByMonth => _recordsByMonth;
  List<String> get listOfYears => _listOfYears;
  List<String> get listOfMonths => _listOfMonths;
  ViewState get state => _state;
  String? get errorMessage => _errorMessage;

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

  Future<void> initialize() async {
    await loadRestockRecords();
  }


  Future<bool> addRestockRecord(RestockRecord restockRecord) async {
    try {
      await _recordRepo.addRestockRecord(restockRecord);
      await loadRestockRecords();
      return true;
    } catch (e) {
      _setError('Failed to add restock record <View Model>: $e');
      return false;
    }
  }

  // Delete restock record
  Future<bool> deleteRestockRecord(int id) async {
    _setState(ViewState.loading);

    try {
      final success = await _recordRepo.deleteRestockRecord(id);
      if (success) {
        await loadRestockRecords(); // Refresh data
        return true;
      } else {
        _setError('Failed to delete restock Record');
        return false;
      }
    } catch (e) {
      _setError('Failed to delete restock record: $e');
      return false;
    }
  }


  Future<void> loadRestockRecords() async {
    _setState(ViewState.loading);
    try {
      List<Map<String, List<RestockRecord>>> filteredRestockData = [];

      final restockRecords = await _recordRepo.getAllRestockRecords();

      for (RestockRecord restockRecord in restockRecords) {
        bool dateExists = false;

        for (var map in filteredRestockData) {
          if (map.containsKey(restockRecord.restockDate)) {
            map[restockRecord.restockDate]!.add(restockRecord);
            dateExists = true;
            break;
          }
        }

        // If date doesn't exist, create a new entry
        if (!dateExists) {
          final restockRecordList = [restockRecord];
          filteredRestockData.add({restockRecord.restockDate: restockRecordList});
        }
      }

      // Store original data
      _allRestockRecords = filteredRestockData;
      _restockRecords = filteredRestockData;

      _createListOfAvailableYears();
      _createListOfAvailableMonths();
      _groupRecordsByMonth(); // Pre-group records by month

      _setState(ViewState.success);
    } catch (e) {
      _setError('Failed to load restock records: $e');
    }
  }

  Future<void> loadRestockedRecordData() async {
    try {
      final response = await rootBundle.loadString("assets/restocking_records.json");
      final data = json.decode(response);

      List<RestockRecord> restockRecordsData = [];

      for (var entry in data as List<dynamic>) {
        final restockDate = entry['date'] as String;
        final batchItems = entry['restocked_items'] as List<dynamic>;

        for (var item in batchItems) {
          restockRecordsData.add(RestockRecord.fromJson(item, restockDate));
        }
      }

      // Add all data to the database in a single batch operation
      await _recordRepo.addBatchEntries(restockRecordsData);

      print("Successfully loaded ${restockRecordsData.length} restock records");
    } catch (e) {
      print("Error loading restock records: $e");
      rethrow;
    }
  }

  // Form validation helpers
  String? validateTitle(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Pastry name is required';
    }
    if (value.trim().length < 2) {
      return 'Pastry name must be at least 2 characters';
    }
    return null;
  }

  String? validateQuantity(String? value) {
    if (value != null && value.trim().isNotEmpty) {
      final quantity = int.tryParse(value);
      if (quantity == null || quantity < 0) {
        return 'Pastries Quantity must be a non-negative number';
      }
    }
    return null;
  }

  void _createListOfAvailableYears() {
    Set<String> years = {};

    for (var record in _allRestockRecords) {
      String date = record.keys.first;
      String year = date.split('-').first;
      years.add(year);
    }

    _listOfYears = years.toList()..sort((a, b) => b.compareTo(a)); // Sort descending
  }

  void _createListOfAvailableMonths() {
    Set<String> months = {};

    // Use currently filtered records or all records
    final recordsToUse = _selectedYear != null ? _restockRecords : _allRestockRecords;

    for (var record in recordsToUse) {
      String date = record.keys.first;
      DateTime dateTime = DateTime.parse(date);
      String month = DateFormat('MMMM').format(dateTime);
      months.add(month);
    }

    _listOfMonths = _sortMonthsList(months.toList());
  }

  List<String> _sortMonthsList(List<String> months) {
    final monthOrder = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];

    months.sort((a, b) {
      return monthOrder.indexOf(a).compareTo(monthOrder.indexOf(b));
    });

    return months;
  }

  void _groupRecordsByMonth() {
    _recordsByMonth.clear();

    for (var record in _restockRecords) {
      String date = record.keys.first;
      DateTime dateTime = DateTime.parse(date);
      String month = DateFormat('MMMM').format(dateTime);

      if (!_recordsByMonth.containsKey(month)) {
        _recordsByMonth[month] = [];
      }
      _recordsByMonth[month]!.add(record);
    }
  }

  List<Map<String, List<RestockRecord>>> getRecordsForMonth(String month) {
    return _recordsByMonth[month] ?? [];
  }

  void filterRecordsByYear(String year) {
    _selectedYear = year;

    List<Map<String, List<RestockRecord>>> filteredRecordsList = [];

    for (var record in _allRestockRecords) {
      String recordYear = record.keys.first.split('-').first;
      if (recordYear == year) {
        filteredRecordsList.add(record);
      }
    }

    _restockRecords = filteredRecordsList;
    _createListOfAvailableMonths(); // Update months for the selected year
    _groupRecordsByMonth(); // Re-group by month
    notifyListeners();
  }

  int calculateTotalMonthRestockedGood(String month) {
    final monthRecords = getRecordsForMonth(month);

    int totalQuantity = 0;
    for (var record in monthRecords) {
      for (RestockRecord restockRecord in record.values.first) {
        totalQuantity += restockRecord.quantityAdded;
      }
    }

    return totalQuantity;
  }

  String getMostRestockedPastry(String month) {
    final monthRecords = getRecordsForMonth(month);

    if (monthRecords.isEmpty) return "None";

    Map<String, int> pastryQuantity = {};

    // Build the quantity map
    for (var record in monthRecords) {
      for (RestockRecord restockRecord in record.values.first) {
        pastryQuantity[restockRecord.pastryName] =
            (pastryQuantity[restockRecord.pastryName] ?? 0) + restockRecord.quantityAdded;
      }
    }

    if (pastryQuantity.isEmpty) return "None";

    // Find the pastry with highest quantity
    String mostRestockedPastry = "";
    int maxQuantity = 0;

    pastryQuantity.forEach((pastryName, quantity) {
      if (quantity > maxQuantity) {
        maxQuantity = quantity;
        mostRestockedPastry = pastryName;
      }
    });

    return mostRestockedPastry;
  }

  // Helper method to get month name and year for display
  String getMonthYearDisplay(String month) {
    if (_selectedYear != null) {
      return "$month $_selectedYear";
    }

    // Find the year from the first record of this month
    final monthRecords = getRecordsForMonth(month);
    if (monthRecords.isNotEmpty) {
      String date = monthRecords.first.keys.first;
      String year = date.split('-').first;
      return "$month $year";
    }

    return month;
  }

  // Reset filters
  void resetFilters() {
    _selectedYear = null;
    _restockRecords = List.from(_allRestockRecords);
    _createListOfAvailableYears();
    _createListOfAvailableMonths();
    _groupRecordsByMonth();
    notifyListeners();
  }

  /// Get how long ago a record was created
  String getRecordAge(String restockDate) {
    try {
      DateTime recordDate = DateTime.parse(restockDate);
      DateTime today = DateTime.now();

      Duration difference = today.difference(recordDate);
      int totalDays = difference.inDays;

      if (totalDays == 0) return "Today";
      if (totalDays == 1) return "1 day ago";
      if (totalDays < 7) return "$totalDays days ago";
      if (totalDays < 30) {
        int weeks = (totalDays / 7).floor();
        return "$weeks ${weeks == 1 ? 'week' : 'weeks'} ago";
      }
      if (totalDays < 365) {
        int months = (totalDays / 30).floor();
        return "$months ${months == 1 ? 'month' : 'months'} ago";
      }

      int years = (totalDays / 365).floor();
      return "$years ${years == 1 ? 'year' : 'years'} ago";
    } catch (e) {
      return "Unknown";
    }
  }

  /// Get exact days since record
  int getDaysSinceRecord(String restockDate) {
    try {
      DateTime recordDate = DateTime.parse(restockDate);
      DateTime today = DateTime.now();
      return today.difference(recordDate).inDays;
    } catch (e) {
      return 0;
    }
  }
}

void main() async {
  // Initialize Flutter binding BEFORE using any Flutter services
  WidgetsFlutterBinding.ensureInitialized();

  // Now you can safely use rootBundle
  final BakingRecordViewModel bakingRecordViewModel = BakingRecordViewModel();
  RestockViewModel restockViewModel = RestockViewModel();

  // AWAIT the async function to complete before proceeding
  await bakingRecordViewModel.loadBakingRecords();
  await restockViewModel.loadRestockedRecordData();

  print("Most baked in February: ${bakingRecordViewModel.getMostBakedPastry("February")}");
  print("Most baked in February: ${restockViewModel.getMostRestockedPastry("February")}");
  print("Total baked in February: ${bakingRecordViewModel.calculateTotalMonthBakedGood("February")}");
}