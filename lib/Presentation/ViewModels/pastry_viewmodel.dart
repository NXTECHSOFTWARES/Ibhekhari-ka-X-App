import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:nxbakers/Domain/Repositories/daily_entries_repo.dart';
import '../../Data/Model/category.dart';
import '../../Data/Model/pastry.dart';
import '../../Data/Model/recipe.dart';
import '../../Domain/Repositories/pastry_repo.dart';

enum ViewState { idle, loading, error, success }
enum FilterType {
  all,
  available,
  outOfStock,
  lowStock,
  category,
}

enum SortType {
  nameAsc,
  nameDesc,
  priceAsc,
  priceDesc,
  quantityAsc,
  quantityDesc,
  salesAsc,
  salesDesc,
  incomeAsc,
  incomeDesc,
}

class FilterOptions {
  FilterType filterType;
  String? selectedCategory;
  int? lowStockThreshold; // For low stock filter

  FilterOptions({
    this.filterType = FilterType.all,
    this.selectedCategory,
    this.lowStockThreshold = 5,
  });

  bool get isActive => filterType != FilterType.all;

  void reset() {
    filterType = FilterType.all;
    selectedCategory = null;
    lowStockThreshold = 5;
  }
}

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

  FilterOptions _filterOptions = FilterOptions();
  SortType _currentSort = SortType.nameAsc;
  List<Pastry> _displayedPastries = []; // Filtered and sorted pastries

  // Add these getters
  FilterOptions get filterOptions => _filterOptions;
  SortType get currentSort => _currentSort;
  List<Pastry> get displayedPastries => _displayedPastries;

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

  Future<Recipe?> getPastryRecipe() async {
    final response = await rootBundle.loadString("assets/recipes");
    final data = json.decode(response);
    Recipe recipe = data;
    return recipe;
  }

  Future<void> loadPastyDemoData() async {
    final response =
        await rootBundle.loadString("assets/pastry_test_data.json");
    final data = json.decode(response);
    List<Pastry> testDataPastries =
        (data as List<dynamic>).map((pastry) => Pastry.fromJson(pastry)).toList();

    for (Pastry pastry in testDataPastries) {
      bool success = await addPastry(
          title: pastry.title,
          price: pastry.price,
          quantity: pastry.quantity,
          category: pastry.category,
          imageFile: null);
      if (success) {
        print("successfully added Pastry");
      } else {
        _setError("Failed to Added Pastry");
      }
    }
  }

  Future<bool> addPastry({
    required String title,
    required double price,
    required int quantity,
    required String category,
    required File? imageFile,
  }) async {
    Uint8List? imgByte;
    if (imageFile != null) {
      imgByte = await _imageFileToBytes(imageFile);
    } else {
      imgByte = Uint8List(0);
    }

    try {
      final pastry = Pastry(
        title: title,
        price: price,
        quantity: quantity,
        category: category,
        imageBytes: imgByte!,
        createdAt: DateFormat('yyyy-MM-dd').format(DateTime.now()),
      );

      await _repository.addPastry(pastry);
      await loadPastries();
      await initialize();

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

  Future<Pastry?> getPastryById(int id) async {
    try {
      Pastry? pastry = await _repository.getPastryById(id);
      return pastry;
    } catch (e) {
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

  // Load all pastries
  // Future<void> loadPastries() async {
  //   _setState(ViewState.loading);
  //   try {
  //     _pastries = await _repository.getAllPastries();
  //     //_applyFilters();
  //     // await _updateStatistics();
  //     _setState(ViewState.success);
  //   } catch (e) {
  //     _setError('Failed to load pastries: $e');
  //   }
  // }

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
  Future<bool> updatePastryQuantity(int? id, int newQuantity) async {
    try {
      if (newQuantity < 0) {
        _setError('Quantity cannot be negative');
        return false;
      }

      Pastry? pastry = await getPastryById(id!);
      if (pastry!.quantity > 0) {
        newQuantity += pastry.quantity;
      }

      final success = await _repository.updatePastryQuantity(id, newQuantity);
      if (success) {
        await loadPastries();
        return true;
      } else {
        _setError('Failed to update quantity');
        return false;
      }
    } catch (e) {
      _setError('Failed to update quantity: $e');
      return false;
    }
  }

  // Method to calculate sales data for each pastry
  Future<void> _calculateSalesData() async {
    try {
      final dailyEntries = await DailyEntriesRepo().getAllDailyEntries();

      // Create a new list with updated pastries
      List<Pastry> updatedPastries = [];

      for (var pastry in _pastries) {
        // Filter entries for this pastry
        final pastryEntries = dailyEntries
            .where((entry) => entry.pastryId == pastry.id)
            .toList();

        // Calculate total sales (units sold)
        int totalSold = pastryEntries.fold(
            0,
                (sum, entry) => sum + entry.soldStock
        );

        // Calculate total income (units * current price)
        // Note: Uses current price - consider storing historical prices in DailyEntry
        double totalRevenue = totalSold * pastry.price;

        // Create updated pastry with sales data
        updatedPastries.add(pastry.copyWith(
          totalSales: totalSold,
          totalIncome: totalRevenue,
        ));
      }

      // Replace the pastries list with updated one
      _pastries = updatedPastries;

    } catch (e) {
      print('Failed to calculate sales data: $e');
    }
  }


  // Update loadPastries to include sales calculation
  Future<void> loadPastries() async {
    _setState(ViewState.loading);
    try {
      _pastries = await _repository.getAllPastries();
      await _calculateSalesData();
      _applyFiltersAndSort();
      _setState(ViewState.success);
    } catch (e) {
      _setError('Failed to load pastries: $e');
    }
  }

  // Apply filter
  void setFilter(FilterType type, {String? category, int? threshold}) {
    _filterOptions.filterType = type;
    _filterOptions.selectedCategory = category;
    _filterOptions.lowStockThreshold = threshold ?? 5;
    _applyFiltersAndSort();
    notifyListeners();
  }

  // Apply sort
  void setSort(SortType sortType) {
    _currentSort = sortType;
    _applyFiltersAndSort();
    notifyListeners();
  }

  // Clear all filters
  void clearFilters() {
    _filterOptions.reset();
    _currentSort = SortType.nameAsc;
    _applyFiltersAndSort();
    notifyListeners();
  }

  // Main filtering and sorting logic
  void _applyFiltersAndSort() {
    // Start with all pastries
    List<Pastry> filtered = List.from(_pastries);

    // Apply filters
    switch (_filterOptions.filterType) {
      case FilterType.all:
      // No filter
        break;
      case FilterType.available:
        filtered = filtered.where((p) => p.quantity > 0).toList();
        break;
      case FilterType.outOfStock:
        filtered = filtered.where((p) => p.quantity <= 0).toList();
        break;
      case FilterType.lowStock:
        filtered = filtered.where((p) =>
        p.quantity > 0 && p.quantity <= (_filterOptions.lowStockThreshold ?? 5)
        ).toList();
        break;
      case FilterType.category:
        if (_filterOptions.selectedCategory != null) {
          filtered = filtered.where((p) =>
          p.category == _filterOptions.selectedCategory
          ).toList();
        }
        break;
    }

    // Apply search query if exists
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((p) =>
      p.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          p.category.toLowerCase().contains(_searchQuery.toLowerCase())
      ).toList();
    }

    // Apply sorting
    switch (_currentSort) {
      case SortType.nameAsc:
        filtered.sort((a, b) => a.title.compareTo(b.title));
        break;
      case SortType.nameDesc:
        filtered.sort((a, b) => b.title.compareTo(a.title));
        break;
      case SortType.priceAsc:
        filtered.sort((a, b) => a.price.compareTo(b.price));
        break;
      case SortType.priceDesc:
        filtered.sort((a, b) => b.price.compareTo(a.price));
        break;
      case SortType.quantityAsc:
        filtered.sort((a, b) => a.quantity.compareTo(b.quantity));
        break;
      case SortType.quantityDesc:
        filtered.sort((a, b) => b.quantity.compareTo(a.quantity));
        break;
      case SortType.salesAsc:
        filtered.sort((a, b) => (a.totalSales ?? 0).compareTo(b.totalSales ?? 0));
        break;
      case SortType.salesDesc:
        filtered.sort((a, b) => (b.totalSales ?? 0).compareTo(a.totalSales ?? 0));
        break;
      case SortType.incomeAsc:
        filtered.sort((a, b) => (a.totalIncome ?? 0).compareTo(b.totalIncome ?? 0));
        break;
      case SortType.incomeDesc:
        filtered.sort((a, b) => (b.totalIncome ?? 0).compareTo(a.totalIncome ?? 0));
        break;
    }

    _displayedPastries = filtered;
  }


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
  String getStockStatus(Pastry pastry) {
    if (pastry.quantity == null) return 'Unknown';
    if (pastry.quantity! <= 0) return 'Out of Stock';
    if (pastry.quantity! <= 2) return 'Low Stock';
    return 'In Stock';
  }

  Color getStockStatusColor(Pastry pastry) {
    if (pastry.quantity == null) return Colors.grey;
    if (pastry.quantity! <= 0) return Colors.red;
    if (pastry.quantity! <= 5) return Colors.orange;
    return Colors.green;
  }

  void clearError() {
    if (_state == ViewState.error) {
      _state = ViewState.idle;
      _errorMessage = null;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    super.dispose();
  }
}
