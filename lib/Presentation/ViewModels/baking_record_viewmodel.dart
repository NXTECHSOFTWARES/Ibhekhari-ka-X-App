import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:get/get_common/get_reset.dart';
import 'package:intl/intl.dart';
import 'package:nxbakers/Data/Model/baking_records.dart';
import 'package:nxbakers/Domain/Repositories/baking_repos.dart';
import 'package:nxbakers/Presentation/ViewModels/pastry_viewmodel.dart';

import '../../Domain/Repositories/pastry_repo.dart';

enum ViewState { idle, loading, error, success }

class BakingRecordViewModel extends ChangeNotifier {
  final BakingRepo _bakingRepo = BakingRepo();
  final PastryRepository _pastryRepository = PastryRepository();

  // State management
  ViewState _state = ViewState.idle;
  String? _errorMessage;

  List<Map<String, List<BakingRecord>>> _bakingRecords = [];
  List<Map<String, List<BakingRecord>>> _monthBakingRecords = [];
  List<String> _listOfYears = [];
  List<String> _listOfMonths = [];

  List<Map<String, List<BakingRecord>>> get bakingRecords => _bakingRecords;

  List<Map<String, List<BakingRecord>>> get monthBakingRecords => _monthBakingRecords;

  List<String> get listOfYears => _listOfYears;

  List<String> get listOfMonths => _listOfMonths;

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
      await _bakingRepo.addBakingRecord(bakingRecord);
      loadBakingRecords();
      return true;
    } catch (e) {
      _setError('Failed to add baking record <View Model>: $e');
      return false;
    }
  }

  // Delete pastry
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
    loadBakingRecords();
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

      _bakingRecords = filteredBakingData;

      createListOfAvailableYears();
      createListOfAvailableMonths();

      _setState(ViewState.success);
      notifyListeners();
    } catch (e) {
      _setError('Failed to load pastries: $e');
    }
  }

  Future<void> loadBakingRecordData() async {
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

      // Updating Pastry Quantity with freshly baked goods
      // for(BakingRecord bakingRecord in bakingRecordsData){
      //   await _pastryRepository.updatePastryQuantity(bakingRecord.pastryId, bakingRecord.quantityBaked);
      //   print("Successfully updated Pastry Quantity");
      // }

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

  Future<void> createListOfAvailableYears() async {
    for (int i = 0; i < bakingRecords.length; i++) {
      String year = bakingRecords[i].keys.first.split('-').first;
      if (!_listOfYears.contains(year)) {
        _listOfYears.add(year);
      }
    }
  }

  Future<void> createListOfAvailableMonths() async {
    for (int i = 0; i < bakingRecords.length; i++) {
      String formatedDate = DateFormat('dd MMMM yyyy').format(DateTime.parse(bakingRecords[i].keys.first));
      String month = formatedDate.split(' ')[1];
      if (!_listOfMonths.contains(month)) {
        _listOfMonths.add(month);
      }
    }
  }

  Future<void> filterRecordsByYear(String year) async {
    List<Map<String, List<BakingRecord>>> filteredRecordsList = [];

    for (int x = 0; x < bakingRecords.length; x++) {
      Map<String, List<BakingRecord>> bakingRecord = bakingRecords[x];
      if (bakingRecord.keys.first == year) {
        filteredRecordsList.add(bakingRecord);
      }
    }
    _bakingRecords = filteredRecordsList;
    loadBakingRecords();
    notifyListeners();
  }

  Future<void> filterRecordsByMonths(String month) async {
    List<Map<String, List<BakingRecord>>> filteredRecordsList = [];

    for (int x = 0; x < bakingRecords.length; x++) {
      Map<String, List<BakingRecord>> bakingRecord = bakingRecords[x];
      String formatedDate = DateFormat('dd MMMM yyyy').format(DateTime.parse(bakingRecord.keys.first));
      String _month = formatedDate.split(' ')[1];
      if (_month == month) {
        filteredRecordsList.add(bakingRecord);
      }
    }

    _monthBakingRecords = filteredRecordsList;
    notifyListeners();
    loadBakingRecords();
  }

  int calculateTotalMonthBakedGood(String month) {
    filterRecordsByMonths(month);
    int totalQuantity = 0;
    for (int i = 0; i < _monthBakingRecords.length; i++) {
      for (BakingRecord record in _monthBakingRecords[i].values.first) {
        totalQuantity += record.quantityBaked;
      }
    }
    return totalQuantity;
  }

  String getMostBakedPastry(String month){
    filterRecordsByMonths(month);

    Map<String, int> pastryQuantity = {};

    String mostBakedPastry = "";
    int? currQuantity = 0;

    for (int i = 0; i < _monthBakingRecords.length; i++) {
      for (BakingRecord record in _monthBakingRecords[i].values.first) {
        if(!pastryQuantity.containsKey(record.pastryName)){
          pastryQuantity[record.pastryName] = record.quantityBaked;
        }
        else{
          pastryQuantity[record.pastryName] = pastryQuantity[record.pastryName]! + record.quantityBaked;
        }
      }
    }

    for (int i = 0; i < pastryQuantity.length; i++) {
        if(pastryQuantity[pastryQuantity.keys.first]! > currQuantity!){
          mostBakedPastry = pastryQuantity.keys.first;
          currQuantity = pastryQuantity[pastryQuantity.keys.first];
        }

    }

    return mostBakedPastry;
  }

}

void main() async {
  // Initialize Flutter binding BEFORE using any Flutter services
  WidgetsFlutterBinding.ensureInitialized();

  // Now you can safely use rootBundle
  final BakingRecordViewModel bakingRecordViewModel = BakingRecordViewModel();
//  final PastryViewModel pastryViewModel = PastryViewModel();

  // AWAIT the async function to complete before proceeding
  await bakingRecordViewModel.loadBakingRecords();
  //await pastryViewModel.initialize();
// print("jks");
  print("${bakingRecordViewModel.getMostBakedPastry("February")} hey");
  // print("${pastryViewModel.pastries}");
}
