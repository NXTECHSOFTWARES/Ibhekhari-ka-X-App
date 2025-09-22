import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class SqlDatabaseHelper {
  static final SqlDatabaseHelper _instance = SqlDatabaseHelper._internal();
  factory SqlDatabaseHelper() => _instance;
  SqlDatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'nxbakersDB.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  // Add this method to debug your table structure
  Future<void> debugTableSchema() async {
    final db = await database; // Your database instance
    final result = await db.rawQuery('PRAGMA table_info(pastries)');
    print('Table columns:');
    for (var column in result) {
      print('${column['name']} - ${column['type']}');
    }
  }

// Call this in your initState or wherever you initialize the database

  Future<void> _onCreate(Database db, int version) async {
    // Pastry table creation
    await db.execute('''
      CREATE TABLE pastries (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        price REAL NOT NULL,
        quantity INTEGER NOT NULL,
        category TEXT NOT NULL,
        imageBytes BLOB NOT NULL,
        created_at TEXT NOT NULL,
         is_deleted INTEGER DEFAULT 0
      )
    ''');

    // Daily Entry table creation
    await db.execute('''
      CREATE TABLE dailyEntries (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        sold_stock INTEGER NOT NULL,
        remaining_stock INTEGER NOT NULL,
        created_at TEXT NOT NULL,
        pastry_id INTEGER NOT NULL,
        FOREIGN KEY (pastry_id) REFERENCES pastries(id) ON DELETE RESTRICT
      )
    ''');

    // Pastry Stock Update table creation
    await db.execute('''
      CREATE TABLE newStock(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        current_quantity INTEGER NOT NULL,
        new_quantity INTEGER NOT NULL,
        created_at  TEXT NOT NULL,
        pastry_id INTEGER  NOT NULL,
        FOREIGN KEY (pastry_id) REFERENCES pastries(id) ON DELETE RESTRICT
      )
    ''');
  }

  // CRUD Operations for Pastries
  // Future<int> insertPastry(Map<String, dynamic> pastry) async {
  //   final db = await database;
  //   return await db.insert('pastries', pastry);
  // }

  Future<int> insertPastry(Map<String, dynamic> pastry) async {
    final db = await database;
    return await db.insert('pastries', pastry);
  }

Future<int> insertDailyEntry(Map<String, dynamic> dailyEntry) async {
    final db = await database;
    return await db.insert('dailyEntries', dailyEntry);
  }

  Future<int> updatePastry(int id, Map<String, dynamic> pastry) async {
    final db = await database;
    return await db.update(
      'pastries',
      pastry,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Map<String, dynamic>>> getPastries() async {
    final db = await database;
    return await db.query('pastries', orderBy: 'created_at DESC');
  }

  Future<List<Map<String, dynamic>>> getDailyEntries() async {
    final db = await database;
    return await db.query('dailyEntries', orderBy: 'created_at DESC');
  }

  Future<Map<String, dynamic>?> getPastry(int id) async {
    final db = await database;
    List<Map<String, dynamic>> result = await db.query(
      'pastries',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    return result.isNotEmpty ? result.first : null;
  }

Future<Map<String, dynamic>?> getDailyEntry(int id) async {
    final db = await database;
    List<Map<String, dynamic>> result = await db.query(
      'dailyEntries',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    return result.isNotEmpty ? result.first : null;
  }

  Future<List<Map<String, dynamic>>> getPastriesByCategory(
      String category) async {
    final db = await database;
    return await db.query(
      'pastries',
      where: 'category = ?',
      whereArgs: [category],
      orderBy: 'created_at DESC',
    );
  }

  Future<List<Map<String, dynamic>>> getDailyEntriesMyDate(
      String dateEntry) async {
    final db = await database;
    return await db.query(
      'dailyEntries',
      where: 'created_at = ?',
      whereArgs: [dateEntry],
      orderBy: 'created_at DESC',
    );
  }

  // Future<int> updatePastry(int id, Map<String, dynamic> pastry) async {
  //   final db = await database;
  //   return await db.update(
  //     'pastries',
  //     pastry,
  //     where: 'id = ?',
  //     whereArgs: [id],
  //   );
  // }

  Future<int> deletePastry(int id) async {
    final db = await database;
    return await db.delete(
      'pastries',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> updatePastryQuantity(int id, int newQuantity) async {
    final db = await database;
    return await db.update(
      'pastries',
      {'quantity': newQuantity},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> updateDailyEntryQuantity(int id, int soldStock, int remainingStock) async {
    final db = await database;
    return await db.update(
      'dailyEntries',
      {
        'sold_stock': soldStock,
        'remaining_stock': remainingStock,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
