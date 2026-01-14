import 'package:flutter/material.dart';
import 'package:nxbakers/Common/AppData.dart';
import 'package:nxbakers/Data/Model/restock_record.dart';
import 'package:nxbakers/Data/Model/shelf_record.dart';
import 'package:nxbakers/Domain/Repositories/shelf_records_repository.dart';
import 'package:nxbakers/Presentation/ViewModels/restock_viewmodel.dart';

import '../../Data/Model/pastry.dart';
import '../../Domain/Repositories/pastry_repo.dart';

class ShelfViewModel extends ChangeNotifier {
  final ShelfRecordsRepository _shelfRecordsRepository = ShelfRecordsRepository();
  final RestockViewModel _restockViewModel = RestockViewModel();
  final PastryRepository _pastryRepository = PastryRepository();

  // State management
  ViewState _state = ViewState.idle;
  String? _errorMessage;

  Map<String, String> pastryQuantityLevels = {};

  // Store original data separately
  List<ShelfRecord> _availableShelfRecords = [];
  List<ShelfRecord> _outOfStockShelf = [];
  List<ShelfRecord> _shelfRecords = [];

  // Store records grouped by month for display
  final Map<String, List<Map<String, List<ShelfRecord>>>> _recordsByMonth = {};

  final List<String> _listOfYears = [];
  final List<String> _listOfMonths = [];

  // Current filters
  String? _selectedYear;

  // Getters
  List<ShelfRecord> get shelfRecords => _shelfRecords;

  Map<String, List<Map<String, List<ShelfRecord>>>> get recordsByMonth => _recordsByMonth;

  List<ShelfRecord> get availableShelfRecords => _availableShelfRecords;
  List<ShelfRecord> get outOfStockShelf => _outOfStockShelf;

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

  Future<bool> addShelfRecord(RestockRecord restockRecord) async {
    try {
      await _shelfRecordsRepository.addShelfRecord(restockRecord);
      await loadShelfRecords();
      return true;
    } catch (e) {
      _setError('Failed to add baking record <View Model>: $e');
      return false;
    }
  }

  // Delete baking record
  Future<bool> deleteShelfRecord(int id) async {
    _setState(ViewState.loading);

    try {
      final success = await _shelfRecordsRepository.deleteShelfRecord(id);
      if (success) {
        await loadShelfRecords();
        return true;
      } else {
        _setError('Failed to delete shelf Record');
        return false;
      }
    } catch (e) {
      _setError('Failed to delete shelf record: $e');
      return false;
    }
  }

  Future<void> initialize() async {
    await loadShelfRecords();
  }

  Future<void> loadShelfRecords() async {
    _setState(ViewState.loading);
    try {
      List<Map<String, List<ShelfRecord>>> filteredShelfRecordsData = [];

      final shelfRecordsData = await _shelfRecordsRepository.getAllShelfRecords();

      // for (ShelfRecord shelfRecord in shelfRecords) {
      //   bool dateExists = false;
      //
      //   for (var map in filteredShelfRecordsData) {
      //     if (map.containsKey(shelfRecord.createdAt)) {
      //       map[shelfRecord.createdAt]!.add(shelfRecord);
      //       dateExists = true;
      //       break;
      //     }
      //   }
      //
      //   // If date doesn't exist, create a new entry
      //   if (!dateExists) {
      //     final bakingRecordList = [bakingRecord];
      //     filteredBakingData.add({bakingRecord.bakingDate: bakingRecordList});
      //   }
      // }

      // Store original data
      _shelfRecords = shelfRecordsData;
      // _allBakingRecords = filteredBakingData;
      // _bakingRecords = filteredBakingData;

      loadAvailableShelf();
      loadPastryWithHighQuantity();
      _setState(ViewState.success);
    } catch (e) {
      _setError('Failed to load baking records: $e');
    }
  }


  Future<Pastry?> getPastryById(int id) async {
    try {
      Pastry? pastry = await _pastryRepository.getPastryById(id);
      return pastry;
    } catch (e) {
      _setError('Failed to retrieve pastry by id: $e');
    }
    return null;
  }


  // Future<void> loadShelfRecordData() async {
  //   try {
  //     final response = await rootBundle.loadString("assets/baking_records.json");
  //     final data = json.decode(response);
  //
  //     List<BakingRecord> bakingRecordsData = [];
  //
  //     for (var entry in data as List<dynamic>) {
  //       final bakingDate = entry['baking_date'] as String;
  //       final batchItems = entry['batch_items'] as List<dynamic>;
  //
  //       for (var item in batchItems) {
  //         bakingRecordsData.add(BakingRecord.fromJson(item as Map<String, dynamic>, bakingDate));
  //       }
  //     }
  //
  //     // Add all data to the database in a single batch operation
  //     await _bakingRepo.addBatchEntries(bakingRecordsData);
  //
  //     print("Successfully loaded ${bakingRecordsData.length} baking records");
  //   } catch (e) {
  //     print("Error loading baking records: $e");
  //     rethrow;
  //   }
  // }

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

  void loadAvailableShelf() {
    List<ShelfRecord> recordAvailable = [];
    List<ShelfRecord> outOfStock = [];

    for (ShelfRecord record in shelfRecords) {
      if (record.isAvailable) recordAvailable.add(record);
      else {outOfStock.add(record);}
    }
    _availableShelfRecords = recordAvailable;
    _outOfStockShelf = outOfStock;
  }

  void loadPastryWithHighQuantity() {
    Map<String, String> pastryLevel = {};
    int topCurrentQuantity = 0;
    int lowCurrentQuantity = 0;

    for (var record in shelfRecords) {
      if (record.currentStock > topCurrentQuantity) {
        pastryLevel["high"] = record.pastryName;
        topCurrentQuantity = record.currentStock;
      }
      if(record.currentStock < topCurrentQuantity){
        pastryLevel["low"] = record.pastryName;
        lowCurrentQuantity = record.currentStock;
      }
    }

    pastryQuantityLevels = pastryLevel;
  }

  List<String> _sortMonthsList(List<String> months) {
    final monthOrder = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];

    months.sort((a, b) {
      return monthOrder.indexOf(a).compareTo(monthOrder.indexOf(b));
    });

    return months;
  }

  Color getStatusColor(String status){
    switch(status){
      case "fresh":
        return fresh;
      case "expired":
        return expired;
      case "expiringSoon":
        return expiringSoon;
    }
    return outOfStock;
  }

  // Reset filters
  // void resetFilters() {
  //   _selectedYear = null;
  //   _bakingRecords = List.from(_allBakingRecords);
  //   _createListOfAvailableYears();
  //   _createListOfAvailableMonths();
  //   _groupRecordsByMonth();
  //   notifyListeners();
  // }

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
  final RestockViewModel restockViewModel = RestockViewModel();

  // AWAIT the async function to complete before proceeding
  await restockViewModel.loadRestockedRecordData();

  print("Most baked in February: ${restockViewModel.getMostRestockedPastry("February")}");
  print("Total baked in February: ${restockViewModel.calculateTotalMonthRestockedGood("February")}");
}
