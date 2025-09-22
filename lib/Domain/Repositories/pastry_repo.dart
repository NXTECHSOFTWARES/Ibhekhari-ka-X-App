import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:nxbakers/Data/Model/daily_entry.dart';
import '../../Data/Database/Local/sql_database_helper.dart';
import '../../Data/Model/category.dart';
import '../../Data/Model/pastry.dart';

class PastryRepository {
  static final PastryRepository _instance = PastryRepository._internal();
  factory PastryRepository() => _instance;

  final SqlDatabaseHelper _dbHelper = SqlDatabaseHelper();
  List<Category>? _cachedCategories;
  PastryRepository._internal();

  final String defaultImage = "assets/Images/default_pastry_img.jpg";

  static Future<Uint8List> getDefaultImageBytes() async {
    try {
      final ByteData data =
          await rootBundle.load('assets/Images/default_pastry_img.jpg');
      return data.buffer.asUint8List();
    } catch (e) {
      // Fallback to generated placeholder
      throw Exception('Default Image Not Found');
    }
  }

  Future<int> addPastry(Pastry pastry) async {

    try {
      // Validate pastry before adding
      if (!isValidPastry(pastry)) {
        print("Hallo there!");
        throw Exception('Invalid pastry data');
      }

      // Check for unique title
      final isUnique = await isPastryTitleUnique(pastry.title);
      if (!isUnique) {
        throw Exception('Pastry with this title already exists');
      }

      return await _dbHelper.insertPastry(pastry.toJson());
    } catch (e) {
      throw Exception('Failed to add pastry: $e');
    }

  }

  // Category operations
  Future<List<Category>> getCategories() async {
    if (_cachedCategories != null) return _cachedCategories!;

    try {
      final response = await rootBundle.loadString('assets/categories.json');
      final data = json.decode(response);
      _cachedCategories = (data['categories'] as List)
          .map((categoryJson) => Category.fromJson(categoryJson))
          .toList();
      return _cachedCategories!;
    } catch (e) {
      print('Failed to load categories from JSON: $e');
      _cachedCategories = [
        Category(id: 1, name: 'Cake'),
        Category(id: 2, name: 'Cookie'),
        Category(id: 3, name: 'Bread'),
        Category(id: 4, name: 'Donut'),
        Category(id: 5, name: 'Muffin'),
        Category(id: 6, name: 'Croissant'),
      ];
      return _cachedCategories!;
    }
  }

// Enhanced validation methods
  bool isValidPastry(Pastry pastry) {
    return pastry.title.trim().isNotEmpty &&
        pastry.price > 0 &&
        pastry.category.trim().isNotEmpty &&
        pastry.quantity != 0;
  }

  Future<bool> isPastryTitleUnique(String title, {int? excludeId}) async {
    if (title.trim().isEmpty) return false;

    final pastries = await getAllPastries();
    final trimmedTitle = title.trim();

    return !pastries.any((pastry) =>
        pastry.title.trim().toLowerCase() == trimmedTitle.toLowerCase() &&
        pastry.id != excludeId);
  }



// // Get all pastries with proper image handling
  Future<List<Pastry>> getAllPastries() async {
    try {
      final pastryMaps = await _dbHelper.getPastries();
      return pastryMaps.map((map) {
        final pastry = Pastry.fromJson(map);
        return pastry;
      }).toList();
    } catch (e) {
      throw Exception('Failed to get pastries: $e');
    }
  }

  // Enhanced Pastry CRUD operations with image bytes support
  // Future<int> addPastry(Pastry pastry, {File? imageFile}) async {
  //   try {
  //     // Validate pastry before adding
  //     if (!isValidPastry(pastry)) {
  //       throw Exception('Invalid pastry data');
  //     }
  //
  //     // Check for unique title
  //     final isUnique = await isPastryTitleUnique(pastry.title);
  //     if (!isUnique) {
  //       throw Exception('Pastry with this title already exists');
  //     }
  //
  //     Uint8List imageBytes;
  //
  //     if (imageFile != null) {
  //       imageBytes = await _imageFileToBytes(imageFile);
  //     } else if (pastry.imageBytes == null) {
  //       imageBytes = await _getDefaultImageBytes();
  //     } else {
  //       imageBytes = pastry.imageBytes as Uint8List?;
  //     }
  //
  //     final pastryWithImage = pastry.copyWith(imageBytes: imageBytes);
  //     return await _dbHelper.insertPastry(pastryWithImage.toJson());
  //   } catch (e) {
  //     throw Exception('Failed to add pastry: $e');
  //   }
  // }
  //
  Future<bool> updatePastry(Pastry pastry) async {
    try {
      if (pastry.id == null) throw Exception('Cannot update pastry without ID');

      // Validate pastry before updating
      if (!isValidPastry(pastry)) {
        throw Exception('Invalid pastry data');
      }

      // Check for unique title (excluding current pastry)
      final isUnique = await isPastryTitleUnique(pastry.title, excludeId: pastry.id);
      if (!isUnique) {
        throw Exception('Pastry with this title already exists');
      }

      final result = await _dbHelper.updatePastry(pastry.id!, pastry.toJson());
      return result > 0;
    } catch (e) {
      throw Exception('Failed to update pastry: $e');
    }
  }



  // Get single pastry by ID
  Future<Pastry?> getPastryById(int id) async {
    try {
      final pastryMap = await _dbHelper.getPastry(id);
      if (pastryMap == null) return null;

      final pastry = Pastry.fromJson(pastryMap);
      return pastry;
    } catch (e) {
      throw Exception('Failed to get pastry: $e');
    }
  }

  // Future<List<Pastry>> getPastriesByCategory(String category) async {
  //   try {
  //     final pastryMaps = await _dbHelper.getPastriesByCategory(category);
  //     final defaultBytes = await _getDefaultImageBytes();
  //
  //     return pastryMaps.map((map) {
  //       final pastry = Pastry.fromJson(map);
  //       return pastry.imageBytes == null || pastry.imageBytes!.isEmpty
  //           ? pastry.copyWith(imageBytes: defaultBytes)
  //           : pastry;
  //     }).toList();
  //   } catch (e) {
  //     throw Exception('Failed to get pastries by category: $e');
  //   }
  // }
  //
  Future<bool> updatePastryQuantity(int id, int newQuantity) async {
    try {
      if (newQuantity < 0) {
        throw Exception('Quantity cannot be negative');
      }

      final result = await _dbHelper.updatePastryQuantity(id, newQuantity);
      return result > 0;
    } catch (e) {
      throw Exception('Failed to update pastry quantity: $e');
    }
  }

  Future<bool> deletePastry(int id) async {
    try {
      final result = await _dbHelper.deletePastry(id);
      return result > 0;
    } catch (e) {
      throw Exception('Failed to delete pastry: $e');
    }
  }

  // Business logic methods
  Future<List<Pastry>> getAvailablePastries() async {
    final pastries = await getAllPastries();
    return pastries.where((pastry) =>
    pastry.quantity == null || pastry.quantity! > 0).toList();
  }

  Future<List<Pastry>> getLowStockPastries({int threshold = 2}) async {
    if (threshold < 0) {
      throw ArgumentError('Threshold must be non-negative');
    }

    final pastries = await getAllPastries();
    return pastries.where((pastry) =>
    pastry.quantity <= threshold &&
        pastry.quantity > 0).toList();
  }

  Future<List<Pastry>> getOutOfStockPastries() async {
    final pastries = await getAllPastries();
    return pastries.where((pastry) =>
    pastry.quantity <= 0).toList();
  }

  // Future<Map<String, int>> getPastriesCountByCategory() async {
  //   final pastries = await getAllPastries();
  //   final Map<String, int> categoryCounts = <String, int>{};
  //
  //   for (final pastry in pastries) {
  //     final category = pastry.category;
  //     categoryCounts[category] = (categoryCounts[category] ?? 0) + 1;
  //   }
  //
  //   return categoryCounts;
  // }
  //
  // Future<double> getTotalInventoryValue() async {
  //   final pastries = await getAllPastries();
  //   double total = 0;
  //
  //   for (final pastry in pastries) {
  //     final quantity = pastry.quantity ?? 0;
  //     if (quantity > 0) {
  //       total += (pastry.price * quantity) / 100; // Convert from cents to dollars
  //     }
  //   }
  //
  //   return total;
  // }
  //
  // // Search functionality with input validation
  // Future<List<Pastry>> searchPastries(String query) async {
  //   if (query.trim().isEmpty) {
  //     return getAllPastries(); // Return all if empty query
  //   }
  //
  //   final pastries = await getAllPastries();
  //   final lowercaseQuery = query.trim().toLowerCase();
  //
  //   return pastries.where((pastry) =>
  //   pastry.title.toLowerCase().contains(lowercaseQuery) ||
  //       pastry.category.toLowerCase().contains(lowercaseQuery)).toList();
  // }
  //
  // // Bulk operations with better error handling
  // Future<List<String>> addMultiplePastries(List<Pastry> pastries) async {
  //   final List<String> errors = [];
  //
  //   for (int i = 0; i < pastries.length; i++) {
  //     try {
  //       await addPastry(pastries[i]);
  //     } catch (e) {
  //       errors.add('Pastry ${i + 1}: $e');
  //     }
  //   }
  //
  //   return errors;
  // }
  //
  // Future<void> deleteAllPastries() async {
  //   try {
  //     final pastries = await getAllPastries();
  //     for (final pastry in pastries) {
  //       if (pastry.id != null) {
  //         await deletePastry(pastry.id!);
  //       }
  //     }
  //   } catch (e) {
  //     throw Exception('Failed to delete all pastries: $e');
  //   }
  // }
  //

  // // Utility method to clear cache
  // void clearCache() {
  //   _cachedCategories = null;
  //   _defaultImageBytes = null;
  // }
  //
  // Get statistics
  Future<Map<String, dynamic>> getInventoryStatistics() async {
    final pastries = await getAllPastries();
    final total = pastries.length;
    final available = pastries.where((p) => (p.quantity ?? 0) > 0).length;
    final outOfStock = pastries.where((p) => (p.quantity ?? 0) <= 0).length;
    // final totalValue = await getTotalInventoryValue();

    return {
      'totalPastries': total,
      'availablePastries': available,
      'outOfStockPastries': outOfStock,
      //'totalInventoryValue': totalValue,
    };
  }
}
