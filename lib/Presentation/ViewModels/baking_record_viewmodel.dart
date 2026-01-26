import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:nxbakers/Data/Model/baking_records.dart';
import 'package:nxbakers/Data/Model/shelf_record.dart';
import 'package:nxbakers/Domain/Repositories/baking_repos.dart';
import 'package:nxbakers/Domain/Repositories/shelf_records_repository.dart';
import 'package:nxbakers/Presentation/ViewModels/pastry_viewmodel.dart';

import '../../Data/Model/pastry.dart';
import '../../Domain/Repositories/pastry_repo.dart';

enum ViewState { idle, loading, error, success }

class BakingRecordViewModel extends ChangeNotifier {
  final BakingRepo _bakingRepo = BakingRepo();
  final PastryRepository _pastryRepository = PastryRepository();
  final ShelfRecordsRepository _shelfRecordsRepository = ShelfRecordsRepository();

  // State management
  ViewState _state = ViewState.idle;
  String? _errorMessage;

  // Store original data separately from filtered data
  List<Map<String, List<BakingRecord>>> _allBakingRecords = [];
  List<Map<String, List<BakingRecord>>> _bakingRecords = [];

  // Store records grouped by month for display
  Map<String, List<Map<String, List<BakingRecord>>>> _recordsByMonth = {};

  List<String> _listOfYears = [];
  List<String> _listOfMonths = [];

  // Current filters
  String? _selectedYear;
  String? _selectedMonth;

  // Getters
  List<Map<String, List<BakingRecord>>> get bakingRecords => _bakingRecords;

  Map<String, List<Map<String, List<BakingRecord>>>> get recordsByMonth => _recordsByMonth;

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

  Future<bool> addBakingRecord(BakingRecord bakingRecord) async {
    try {
      final success = await _bakingRepo.addBakingRecord(bakingRecord);
      if (success > 0) print("Successfully added ${bakingRecord.toString()} baking records");
      await loadBakingRecords();
      return true;
    } catch (e) {
      _setError('Failed to add baking record <View Model>: $e');
      return false;
    }
  }

  // Delete baking record
  Future<bool> deleteBakingRecord(int id) async {
    _setState(ViewState.loading);

    try {
      final success = await _bakingRepo.deleteBakingRecord(id);
      if (success) {
        await loadBakingRecords(); // Refresh data
        return true;
      } else {
        _setError('Failed to delete baking Record');
        return false;
      }
    } catch (e) {
      _setError('Failed to delete baking record: $e');
      return false;
    }
  }

  Future<void> initialize() async {
    await loadBakingRecords();
  }

  Future<void> loadBakingRecords() async {
    _setState(ViewState.loading);
    try {
      List<Map<String, List<BakingRecord>>> filteredBakingData = [];

      final bakingRecords = await _bakingRepo.getAllBakingRecords();

      for (BakingRecord bakingRecord in bakingRecords) {
        bool dateExists = false;

        for (var map in filteredBakingData) {
          if (map.containsKey(bakingRecord.bakingDate)) {
            map[bakingRecord.bakingDate]!.add(bakingRecord);
            dateExists = true;
            break;
          }
        }

        // If date doesn't exist, create a new entry
        if (!dateExists) {
          final bakingRecordList = [bakingRecord];
          filteredBakingData.add({bakingRecord.bakingDate: bakingRecordList});
        }
      }

      // Store original data
      _allBakingRecords = filteredBakingData;
      _bakingRecords = filteredBakingData;

      _createListOfAvailableYears();
      _createListOfAvailableMonths();
      _groupRecordsByMonth(); // Pre-group records by month

      _setState(ViewState.success);
    } catch (e) {
      _setError('Failed to load baking records: $e');
    }
  }

  Future<void> printPastries() async {
    List<ShelfRecord> pastry = await _shelfRecordsRepository.getAllShelfRecords();
    final pastryByID = await _pastryRepository.getPastryById(1);

    //print( "PASTRY GOT BY ID\n\n $pastryByID");
    print("");
    print("PASTRY FROM THE LIST\n\n $pastry");
  }

  Future<void> loadBakingRecordData() async {
    _setState(ViewState.loading);
    try {
      final response = await rootBundle.loadString("assets/baking_records.json");
      final data = json.decode(response);

      List<BakingRecord> bakingRecordsData = [];

      for (var entry in data as List<dynamic>) {
        final bakingDate = entry['baking_date'] as String;
        final batchItems = entry['batch_items'] as List<dynamic>;

        for (var item in batchItems) {
          bakingRecordsData.add(BakingRecord.fromJson(item as Map<String, dynamic>, bakingDate));
        }
      }

      // Add all data to the database in a single batch operation
      await _bakingRepo.addBatchEntries(bakingRecordsData);
      loadBakingRecords();
      print("Successfully loaded ${bakingRecordsData.length} baking records");
    } catch (e) {
      print("Error loading baking records: $e");
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

    for (var record in _allBakingRecords) {
      String date = record.keys.first;
      String year = date.split('-').first;
      years.add(year);
    }

    _listOfYears = years.toList()..sort((a, b) => b.compareTo(a)); // Sort descending
  }

  void _createListOfAvailableMonths() {
    Set<String> months = {};

    // Use currently filtered records or all records
    final recordsToUse = _selectedYear != null ? _bakingRecords : _allBakingRecords;

    for (var record in recordsToUse) {
      String date = record.keys.first;
      DateTime dateTime = DateTime.parse(date);
      String month = DateFormat('MMMM').format(dateTime);
      months.add(month);
    }

    _listOfMonths = _sortMonthsList(months.toList());
  }

  List<String> _sortMonthsList(List<String> months) {
    final monthOrder = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];

    months.sort((a, b) {
      return monthOrder.indexOf(a).compareTo(monthOrder.indexOf(b));
    });

    return months;
  }

  void _groupRecordsByMonth() {
    _recordsByMonth.clear();

    for (var record in _bakingRecords) {
      String date = record.keys.first;
      DateTime dateTime = DateTime.parse(date);
      String month = DateFormat('MMMM').format(dateTime);

      if (!_recordsByMonth.containsKey(month)) {
        _recordsByMonth[month] = [];
      }
      _recordsByMonth[month]!.add(record);
    }
  }

  List<Map<String, List<BakingRecord>>> getRecordsForMonth(String month) {
    return _recordsByMonth[month] ?? [];
  }

  void filterRecordsByYear(String year) {
    _selectedYear = year;

    List<Map<String, List<BakingRecord>>> filteredRecordsList = [];

    for (var record in _allBakingRecords) {
      String recordYear = record.keys.first.split('-').first;
      if (recordYear == year) {
        filteredRecordsList.add(record);
      }
    }

    _bakingRecords = filteredRecordsList;
    _createListOfAvailableMonths(); // Update months for the selected year
    _groupRecordsByMonth(); // Re-group by month
    notifyListeners();
  }

  void filterRecordsByMonth(String month) {
    _selectedMonth = month;

    List<Map<String, List<BakingRecord>>> filteredRecordsList = [];

    for (var record in _allBakingRecords) {
      String recordMonth = record.keys.first;
      final formattedMonth = DateFormat("MMMM").format(DateTime.parse(recordMonth));
      print("Hey: Record Month $formattedMonth");
      if (formattedMonth == month) {
        filteredRecordsList.add(record);
      }
    }

    _bakingRecords = filteredRecordsList;
    // _createListOfAvailableMonths(); // Update months for the selected year
    // _groupRecordsByMonth(); // Re-group by month
    notifyListeners();
  }

  int calculateTotalMonthBakedGood(String month) {
    final monthRecords = getRecordsForMonth(month);

    int totalQuantity = 0;
    for (var record in monthRecords) {
      for (BakingRecord bakingRecord in record.values.first) {
        totalQuantity += bakingRecord.quantityBaked;
      }
    }

    return totalQuantity;
  }

  String getMostBakedPastry(String month) {
    final monthRecords = getRecordsForMonth(month);

    if (monthRecords.isEmpty) return "None";

    Map<String, int> pastryQuantity = {};

    // Build the quantity map
    for (var record in monthRecords) {
      for (BakingRecord bakingRecord in record.values.first) {
        pastryQuantity[bakingRecord.pastryName] = (pastryQuantity[bakingRecord.pastryName] ?? 0) + bakingRecord.quantityBaked;
      }
    }

    if (pastryQuantity.isEmpty) return "None";

    // Find the pastry with highest quantity
    String mostBakedPastry = "";
    int maxQuantity = 0;

    pastryQuantity.forEach((pastryName, quantity) {
      if (quantity > maxQuantity) {
        maxQuantity = quantity;
        mostBakedPastry = pastryName;
      }
    });

    return mostBakedPastry;
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
    _bakingRecords = List.from(_allBakingRecords);
    _createListOfAvailableYears();
    _createListOfAvailableMonths();
    _groupRecordsByMonth();
    notifyListeners();
  }

  /// Get how long ago a record was created
  String getRecordAge(String bakingDate) {
    try {
      DateTime recordDate = DateTime.parse(bakingDate);
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
  int getDaysSinceRecord(String bakingDate) {
    try {
      DateTime recordDate = DateTime.parse(bakingDate);
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

  // AWAIT the async function to complete before proceeding
  await bakingRecordViewModel.loadBakingRecords();

  print("Most baked in February: ${bakingRecordViewModel.getMostBakedPastry("February")}");
  print("Total baked in February: ${bakingRecordViewModel.calculateTotalMonthBakedGood("February")}");
}
