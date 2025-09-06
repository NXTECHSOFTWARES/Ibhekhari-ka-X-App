import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../Data/Model/category.dart';
import '../../Data/Model/pastry.dart';
import '../../Domain/Repositories/pastry_repo.dart';

enum ViewState { idle, loading, error, success }

class PastryViewModel extends ChangeNotifier {
  final PastryRepository _repository = PastryRepository();

  //Default pastry image
  final String defaultPastryImageUrl = 'assets/Images/default_pastry_img.jpg';

  // State management
  ViewState _state = ViewState.idle;
  String? _errorMessage;

  // Data
  List<Pastry> _pastries = [];
  List<Category> _categories = [];
  List<Pastry> _filteredPastries = [];

  // Form data
  String _searchQuery = '';
  String? _selectedCategoryFilter;
  bool _showOnlyAvailable = false;

  // Statistics
  int _totalPastries = 0;
  double _totalValue = 0.0;
  Map<String, int> _categoryStats = {};

  // Getters
  ViewState get state => _state;
  String? get errorMessage => _errorMessage;
  List<Pastry> get pastries => _pastries;
  List<Category> get categories => _categories;
  String get searchQuery => _searchQuery;
  String? get selectedCategoryFilter => _selectedCategoryFilter;
  bool get showOnlyAvailable => _showOnlyAvailable;
  int get totalPastries => _totalPastries;
  double get totalValue => _totalValue;
  Map<String, int> get categoryStats => _categoryStats;

  bool get isLoading => _state == ViewState.loading;
  bool get hasError => _state == ViewState.error;
  bool get isEmpty => _pastries.isEmpty && _state != ViewState.loading;

  Uint8List? _defaultImageBytes;

  final List<Pastry> _listOfPastries = [];
  List<Pastry> get listOfPastries => _listOfPastries;

  Future<bool> addPastry({
    required String title,
    required double price,
    required int quantity,
    required String category,
    required File imageFile,
  }) async {


    Uint8List imgByte;
    if (imageFile != null) {
      imgByte = await _imageFileToBytes(imageFile);
    } else {
      imgByte = await _getDefaultImageBytes();
    }

    try {
      final pastry = Pastry(
        title: title,
        price: price,
        quantity: quantity,
        category: category,
        imageBytes: imgByte,
        createdAt: DateFormat('yyyy-MM-dd').format(DateTime.now()),
      );

      await _repository.addPastry(pastry);
      await loadPastries();

      // _listOfPastries.add(Pastry(
      //     title: title,
      //     price: price,
      //     quantity: quantity,
      //     category: category,
      //     imageBytes: imgByte,
      //     createdAt: DateTime.now().toIso8601String()));

      print(List.of([title, price, quantity, category, imgByte]));
      return true;
    } catch (e) {
      _setError('Failed to add pastry: $e');
      return false;
    }
  }

  Future<bool> multipleEntries({
    required String title,
    required double price,
    required int quantity,
    required String category,
    required File imageFile,
  }) async {
    _setState(ViewState.loading);

    try {
      Uint8List imgByte = await convertImageFileToByte(imageFile);

      for (Pastry pastry in _listOfPastries) {
        if (pastry.title.toLowerCase() == title.toLowerCase() &&
            pastry.price == price &&
            pastry.category.toLowerCase() == category.toLowerCase()) {
          pastry.quantity += quantity;
        } else {
          continue;
        }
      }

      _listOfPastries.add(Pastry(
          title: title,
          price: price,
          quantity: quantity,
          category: category,
          imageBytes: imgByte,
          createdAt: DateTime.now().toIso8601String()));
      notifyListeners();
      // await loadPastries();

      print({
        "Pastry Name": _listOfPastries[0].title,
        "Pastry Price": _listOfPastries[0].price,
        "Pastry Quantity": _listOfPastries[0].quantity,
        "Pastry Image": _listOfPastries[0].imageBytes,
        "Pastry Created Date": _listOfPastries[0].createdAt,
      });
      return true;
    } catch (e) {
      _setError('Failed to add pastry to multi pastry list: $e');
      return false;
    }
  }

  Future<void> _loadCategories() async {
    try {
      _categories = await _repository.getCategories();
      notifyListeners();
    } catch (e) {
      _setError('Failed to load categories: $e');
    }
  }

  Future<Pastry?> getPastryById(int id) async{
    try{

      Pastry? pastry = await _repository.getPastryById(id);
      return pastry;
    }catch (e){
      _setError('Failed to retrieve pastry by id: $e');
    }
    return null;
  }

  // Lazy load default image bytes
  Future<Uint8List> _getDefaultImageBytes() async {
    if (_defaultImageBytes != null) return _defaultImageBytes!;

    try {
      final byteData =
          await rootBundle.load('assets/images/default_pastry_img.jpg');
      _defaultImageBytes = byteData.buffer.asUint8List();
      return _defaultImageBytes!;
    } catch (e) {
      print('Failed to load default image: $e');
      _defaultImageBytes = Uint8List(0);
      return _defaultImageBytes!;
    }
  }

  // Convert image file to bytes
  Future<Uint8List> _imageFileToBytes(File imageFile) async {
    try {
      return await imageFile.readAsBytes();
    } catch (e) {
      throw Exception('Failed to read image file: $e');
    }
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

  String? validatePrice(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Pastry Price is required';
    }
    final price = double.tryParse(value);
    if (price == null || price <= 0) {
      return 'Pastry Price must be a positive number';
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

  Future<Uint8List> convertImageFileToByte(File imageFile) async {
    Uint8List imgByte;
    if (imageFile != null) {
      imgByte = await _imageFileToBytes(imageFile);
    } else {
      imgByte = await _getDefaultImageBytes();
    }
    return imgByte;
  }

  // // Initialize data
  Future<void> initialize() async {
    await _loadCategories();
    await loadPastries();
  }

  //
  // // Load all pastries
  Future<void> loadPastries() async {
    _setState(ViewState.loading);
    try {
      //_pastries = _listOfPastries;
      _pastries = await _repository.getAllPastries();
      //_applyFilters();
      // await _updateStatistics();
      _setState(ViewState.success);
    } catch (e) {
      _setError('Failed to load pastries: $e');
    }
  }

  // // Add new pastry
  // Future<bool> addPastry({
  //   required String title,
  //   required int price,
  //   required int quantity,
  //   required String category,
  //   required Uint8List imgUrl,
  // }) async {
  //   _setState(ViewState.loading);
  //
  //   try {
  //     final pastry = Pastry(
  //       title: title,
  //       price: price,
  //       quantity: quantity,
  //       category: category,
  //       imageBytes: imgUrl,
  //       createdAt: DateTime.now().toIso8601String(),
  //     );
  //
  //     await _repository.addPastry(pastry);
  //     await loadPastries();
  //     return true;
  //   } catch (e) {
  //     _setError('Failed to add pastry: $e');
  //     return false;
  //   }
  // }
  //
  // // Update existing pastry
  Future<bool> updatePastry(Pastry updatedPastry) async {
    _setState(ViewState.loading);

    try {
      // Validate pastry first
      if (!_repository.isValidPastry(updatedPastry)) {
        _setError('Invalid pastry data');
        return false;
      }

      // Check title uniqueness (excluding current pastry)
      if (!await _repository.isPastryTitleUnique(
        updatedPastry.title,
        excludeId: updatedPastry.id,
      )) {
        _setError('A pastry with this title already exists');
        return false;
      }

      // // Upload new image if provided
      // if (imageFile != null) {
      //   updatedPastry = updatedPastry.copyWith(
      //     imageBytes: await _repository.uploadImage(imageFile),
      //   );
      // }

      final success = await _repository.updatePastry(updatedPastry);
      if (success) {
        await loadPastries(); // Refresh data
        return true;
      } else {
        _setError('Failed to update pastry');
        return false;
      }
    } catch (e) {
      _setError('Failed to update pastry: $e');
      return false;
    }
  }

  // // Update pastry quantity
  // Future<bool> updatePastryQuantity(int id, int newQuantity) async {
  //   try {
  //     if (newQuantity < 0) {
  //       _setError('Quantity cannot be negative');
  //       return false;
  //     }
  //
  //     // final success = await _repository.updatePastryQuantity(id, newQuantity);
  //     // if (success) {
  //     //   await loadPastries(); // Refresh data
  //     //   return true;
  //     // } else {
  //     //   _setError('Failed to update quantity');
  //     //   return false;
  //     // }
  //   } catch (e) {
  //     _setError('Failed to update quantity: $e');
  //     return false;
  //   }
  // }

  // Delete pastry
  Future<bool> deletePastry(int id) async {
    _setState(ViewState.loading);

    try {
      final success = await _repository.deletePastry(id);
      if (success) {
        await loadPastries(); // Refresh data
        return true;
      } else {
        _setError('Failed to delete pastry');
        return false;
      }
    } catch (e) {
      _setError('Failed to delete pastry: $e');
      return false;
    }
  }

  // Search and filter operations
  void setSearchQuery(String query) {
    _searchQuery = query;
    _applyFilters();
    notifyListeners();
  }

  void setCategoryFilter(String? category) {
    _selectedCategoryFilter = category;
    _applyFilters();
    notifyListeners();
  }

  void setShowOnlyAvailable(bool showOnly) {
    _showOnlyAvailable = showOnly;
    _applyFilters();
    notifyListeners();
  }
  //
  // void clearFilters() {
  //   _searchQuery = '';
  //   _selectedCategoryFilter = null;
  //   _showOnlyAvailable = false;
  //   _applyFilters();
  //   notifyListeners();
  // }
  //
  void _applyFilters() {
    _filteredPastries = _pastries.where((pastry) {
      // Search filter
      bool matchesSearch = _searchQuery.isEmpty ||
          pastry.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          pastry.category.toLowerCase().contains(_searchQuery.toLowerCase());

      // Category filter
      bool matchesCategory = _selectedCategoryFilter == null ||
          pastry.category == _selectedCategoryFilter;

      // Availability filter
      bool matchesAvailability = !_showOnlyAvailable ||
          (pastry.quantity != null && pastry.quantity! > 0);

      return matchesSearch && matchesCategory && matchesAvailability;
    }).toList();
  }
  //
  // // Statistics and analytics
  // Future<void> _updateStatistics() async {
  //   _totalPastries = _pastries.length;
  //   _totalValue = await _repository.getTotalInventoryValue();
  //   _categoryStats = await _repository.getPastriesCountByCategory();
  // }
  //
  // Future<List<Pastry>> getLowStockPastries({int threshold = 5}) async {
  //   try {
  //     return await _repository.getLowStockPastries(threshold: threshold);
  //   } catch (e) {
  //     _setError('Failed to get low stock pastries: $e');
  //     return [];
  //   }
  // }
  //
  // Future<List<Pastry>> getOutOfStockPastries() async {
  //   try {
  //     return await _repository.getOutOfStockPastries();
  //   } catch (e) {
  //     _setError('Failed to get out of stock pastries: $e');
  //     return [];
  //   }
  // }
  //
  // // Bulk operations
  // Future<bool> addMultiplePastries(List<Pastry> pastries) async {
  //   _setState(ViewState.loading);
  //
  //   try {
  //     await _repository.addMultiplePastries(pastries);
  //     await loadPastries(); // Refresh data
  //     return true;
  //   } catch (e) {
  //     _setError('Failed to add multiple pastries: $e');
  //     return false;
  //   }
  // }

  // Future<bool> deleteAllPastries() async {
  //   _setState(ViewState.loading);
  //
  //   try {
  //     await _repository.deleteAllPastries();
  //     await loadPastries(); // Refresh data
  //     return true;
  //   } catch (e) {
  //     _setError('Failed to delete all pastries: $e');
  //     return false;
  //   }
  // }
  //
  // // Utility methods
  // String formatPrice(int priceInCents) {
  //   return '\$${(priceInCents / 100).toStringAsFixed(2)}';
  // }
  //
  // String getStockStatus(Pastry pastry) {
  //   if (pastry.quantity == null) return 'Unknown';
  //   if (pastry.quantity! <= 0) return 'Out of Stock';
  //   if (pastry.quantity! <= 5) return 'Low Stock';
  //   return 'In Stock';
  // }
  //
  // Color getStockStatusColor(Pastry pastry) {
  //   if (pastry.quantity == null) return Colors.grey;
  //   if (pastry.quantity! <= 0) return Colors.red;
  //   if (pastry.quantity! <= 5) return Colors.orange;
  //   return Colors.green;
  // }
  //

  //
  // void clearError() {
  //   if (_state == ViewState.error) {
  //     _state = ViewState.idle;
  //     _errorMessage = null;
  //     notifyListeners();
  //   }
  // }
  //

  @override
  void dispose() {
    super.dispose();
  }
}
