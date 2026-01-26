import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:nxbakers/Data/Database/Local/sql_database_helper.dart';
import 'package:nxbakers/Data/Model/daily_sale.dart';

import '../../Data/Model/category.dart';

class DailyEntriesRepo{
  static final DailyEntriesRepo _instance = DailyEntriesRepo._internal();
  factory DailyEntriesRepo() => _instance;
  List<Category>? _cachedCategories;

  final SqlDatabaseHelper _dbHelper = SqlDatabaseHelper();
  DailyEntriesRepo._internal();

  Future<int> addDailyEntry(DailySale dailyEntry) async {

    try {
      if( await isDailyEntryUnique(dailyEntry)){

      };
      return await _dbHelper.insertDailyEntry(dailyEntry.toJson());
    } catch (e) {
      throw Exception('Failed to add daily entry: $e');
    }

  }

  Future<List<DailySale>> getAllDailyEntries() async {
    try {
      final dailyEntriesMaps = await _dbHelper.getDailyEntries();
      return dailyEntriesMaps.map((map) {
        final dailyEntries = DailySale.fromJson(map);
        return dailyEntries;
      }).toList();
    } catch (e) {
      throw Exception('Failed to get daily entries: $e');
    }
  }

  Future<List<DailySale>> getDailyEntryByDate(String entryDate) async {
    try {
      final dailyEntriesMaps = await _dbHelper.getDailyEntriesMyDate(entryDate);
      return dailyEntriesMaps.map((map) {
        final dailyEntriesByDate = DailySale.fromJson(map);
        return dailyEntriesByDate;
      }).toList();
    } catch (e) {
      throw Exception('Failed to get daily entries by date: $e');
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
        Category(id: 7, name: 'Cupcake'),
      ];
      return _cachedCategories!;
    }
  }

  Future<bool> isDailyEntryUnique(DailySale dailyEntry) async {
    final entries = await getAllDailyEntries();
    return !entries.any((entry) =>
    dailyEntry.pastryId == entry.pastryId &&
        dailyEntry.createdAt == entry.createdAt); // Check date instead of ID
  }

  Future<bool> updateDailyEntryQuantity(int id, int soldStock, remainingStock) async {
    try {

      final result = await _dbHelper.updateDailyEntryQuantity(id, soldStock, remainingStock);
      return result > 0;

    } catch (e) {
      throw Exception('Failed to update pastry quantity: $e');
    }
  }
}