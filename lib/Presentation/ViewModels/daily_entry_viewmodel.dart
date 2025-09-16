import 'package:flutter/material.dart';
import 'package:nxbakers/Data/Model/pastry.dart';
import 'package:nxbakers/Domain/Repositories/pastry_repo.dart';

enum ViewState { idle, loading, error, success }

class DailyEntryViewModel extends ChangeNotifier{
  final PastryRepository _repository = PastryRepository();

  // State management
  ViewState _state = ViewState.idle;
  String? _errorMessage;

  // Data
  List<Pastry> _pastries = [];

  // Getters
  ViewState get state => _state;
  String? get errorMessage => _errorMessage;
  List<Pastry> get pastries => _pastries;

  bool get isLoading => _state == ViewState.loading;
  bool get hasError => _state == ViewState.error;
  bool get isEmpty => _pastries.isEmpty && _state != ViewState.loading;

  // // Initialize data
  Future<void> initialize() async {
    await loadPastries();
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
       List<Pastry> pastries = await _repository.getAllPastries();
      _pastries = pastries.where((pastry) =>pastry.quantity > 0).toList();
      print("Hallo $_pastries");
      //_applyFilters();
      // await _updateStatistics();
      _setState(ViewState.success);
    } catch (e) {
      _setError('Failed to load pastries: $e');
    }
  }

  //Filter by only available

//


}