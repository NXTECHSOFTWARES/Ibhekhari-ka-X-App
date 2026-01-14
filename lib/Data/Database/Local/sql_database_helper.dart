import 'dart:async';
import 'dart:convert';
import 'package:nxbakers/Data/Model/baking_records.dart';
import 'package:nxbakers/Data/Model/pastry.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class SqlDatabaseHelper {
  static final SqlDatabaseHelper _instance = SqlDatabaseHelper._internal();

  factory SqlDatabaseHelper() => _instance;

  SqlDatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'nxbakers.db');
    //deleteDatabase(path);
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
    // Baking Records table creation
    await db.execute('''
    CREATE TABLE IF NOT EXISTS baking_records(
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    baking_date TEXT NOT NULL,
    quantity_baked INTEGER NOT NULL,
    pastry_id INTEGER NOT NULL,
    pastry_name TEXT NOT NULL,
    FOREIGN KEY (pastry_id) REFERENCES pastries(id) ON DELETE RESTRICT
    )
    ''');

    // Restock Records table creation
    await db.execute('''
    CREATE TABLE IF NOT EXISTS restock_records(
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    restock_date TEXT NOT NULL,
    quantity_added INTEGER NOT NULL,
    pastry_id INTEGER NOT NULL,
    pastry_name TEXT NOT NULL,
    FOREIGN KEY (pastry_id) REFERENCES pastries(id) ON DELETE RESTRICT
    )
    ''');

    // shelf Records table creation
    await db.execute('''
    CREATE TABLE IF NOT EXISTS shelf_records(
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    last_restocked_date TEXT NOT NULL,
    current_stock INTEGER NOT NULL,
    quantity_added INTEGER NOT NULL,
    shelf_life INTEGER NOT NULL,
    pastry_id INTEGER NOT NULL,
    is_available INTEGER NOT NULL,
    pastry_name TEXT NOT NULL,
    status TEXT NOT NULL,
     price REAL NOT NULL,
     imageBytes BLOB NOT NULL,
    FOREIGN KEY (pastry_id) REFERENCES pastries(id) ON DELETE RESTRICT
    )
    ''');

    // Pastry table creation
    await db.execute('''
      CREATE TABLE pastries (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        price REAL NOT NULL,
        shelf_life INTEGER NOT NULL,
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

    // Create pastry_notification_settings table
    await db.execute('''
    CREATE TABLE pastry_notification_settings(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      pastry_id INTEGER NOT NULL,
      low_stock_threshold INTEGER DEFAULT 5,
      notification_enabled INTEGER DEFAULT 1,
      reminder_interval_hours INTEGER DEFAULT 2,
      default_coverage_days INTEGER DEFAULT 2,
      analysis_period_days INTEGER DEFAULT 14,
      last_notification_time TEXT,
      notification_snoozed_until TEXT,
      FOREIGN KEY (pastry_id) REFERENCES pastries(id) ON DELETE CASCADE
    )
  ''');

    // NOTIFICATIONS TABLE
    await db.execute('''
      CREATE TABLE notifications(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        type TEXT NOT NULL,
        title TEXT NOT NULL,
        summary TEXT NOT NULL,
        detailed_message TEXT,
        created_at TEXT NOT NULL,
        is_read INTEGER DEFAULT 0,
        related_item_id TEXT,
        related_item_name TEXT,
        additional_data TEXT,
        notification_id TEXT UNIQUE
      )
    ''');
    // Add the notification settings table for users upgrading from version 1
    await db.execute('''
        CREATE TABLE IF NOT EXISTS pastry_notification_settings(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          pastry_id INTEGER NOT NULL,
          low_stock_threshold INTEGER DEFAULT 5,
          notification_enabled INTEGER DEFAULT 1,
          reminder_interval_hours INTEGER DEFAULT 2,
          default_coverage_days INTEGER DEFAULT 2,
          analysis_period_days INTEGER DEFAULT 14,
          last_notification_time TEXT,
          notification_snoozed_until TEXT,
          FOREIGN KEY (pastry_id) REFERENCES pastries(id) ON DELETE CASCADE
        )
      ''');

    // Add notifications table
    await db.execute('''
        CREATE TABLE IF NOT EXISTS notifications(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          type TEXT NOT NULL,
          title TEXT NOT NULL,
          summary TEXT NOT NULL,
          detailed_message TEXT,
          created_at TEXT NOT NULL,
          is_read INTEGER DEFAULT 0,
          related_item_id TEXT,
          related_item_name TEXT,
          additional_data TEXT,
          notification_id TEXT UNIQUE
        )
      ''');
  }

  // CRUD Operations for Pastries
  // Future<int> insertPastry(Map<String, dynamic> pastry) async {
  //   final db = await database;
  //   return await db.insert('pastries', pastry);
  // }

  // ==================== PASTRY NOTIFICATION SETTINGS ====================

// Insert notification settings
  Future<int> insertNotificationSettings(Map<String, dynamic> settings) async {
    final db = await database;

    // Create a copy without id for insert
    final insertData = Map<String, dynamic>.from(settings);
    insertData.remove('id');

    return await db.insert(
      'pastry_notification_settings',
      insertData,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

// Get notification settings for a pastry
  Future<Map<String, dynamic>?> getNotificationSettings(int pastryId) async {
    final db = await database;
    final List<Map<String, dynamic>> results = await db.query(
      'pastry_notification_settings',
      where: 'pastry_id = ?',
      whereArgs: [pastryId],
    );

    if (results.isNotEmpty) {
      return results.first;
    }
    return null;
  }

// Get all notification settings
  Future<List<Map<String, dynamic>>> getAllNotificationSettings() async {
    final db = await database;
    return await db.query('pastry_notification_settings');
  }

// Update notification settings
  Future<int> updateNotificationSettings(int id, Map<String, dynamic> settings) async {
    final db = await database;

    final updateData = Map<String, dynamic>.from(settings);
    updateData.remove('id');

    return await db.update(
      'pastry_notification_settings',
      updateData,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

// Delete notification settings
  Future<int> deleteNotificationSettings(int pastryId) async {
    final db = await database;
    return await db.delete(
      'pastry_notification_settings',
      where: 'pastry_id = ?',
      whereArgs: [pastryId],
    );
  }

// Get pastries with low stock and notifications enabled
  Future<List<Map<String, dynamic>>> getLowStockPastriesWithNotifications() async {
    final db = await database;
    return await db.rawQuery('''
    SELECT p.*, pns.*
    FROM pastries p
    INNER JOIN pastry_notification_settings pns ON p.id = pns.pastry_id
    WHERE p.quantity <= pns.low_stock_threshold
    AND pns.notification_enabled = 1
  ''');
  }

  //______________________________________ BAKING RECORDS______________________________________________________________________________________________

  Future<int> insertBakingRecord(Map<String, dynamic> baking) async {
    final db = await database;
    return await db.insert('baking_records', baking);
  }

  Future<List<Map<String, dynamic>>> getAllBakingRecords() async {
    final db = await database;
    return await db.query('baking_records');
  }

  Future<int> deleteBakingRecord(int id) async {
    final db = await database;
    return await db.delete(
      'baking_records',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  //______________________________________ RESTOCK RECORDS______________________________________________________________________________________________

  Future<int> insertRestockRecord(Map<String, dynamic> newStock) async {
    final db = await database;
    return await db.insert('restock_records', newStock);
  }

  Future<List<Map<String, dynamic>>> getAllRestockRecords() async {
    final db = await database;
    return await db.query('restock_records');
  }

  Future<int> deleteRestockRecord(int id) async {
    final db = await database;
    return await db.delete(
      'restock_records',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  //______________________________________ SHELF RECORDS______________________________________________________________________________________________

  Future<int> insertShelfRecord(Map<String, dynamic> newShelfStock) async {
    final db = await database;
    return await db.insert('shelf_records', newShelfStock);
  }

  Future<List<Map<String, dynamic>>> getAllShelfRecords() async {
    final db = await database;
    return await db.query('shelf_records');
  }

  Future<Map<String, dynamic>> getShelfRecordById(int id) async {
    final db = await database;
    List<Map<String, dynamic>> result = await db.query(
      'shelf_records',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    return result.first;
  }

  Future<Map<String, dynamic>?> getShelfRecordByPastryId(int pastryId) async {
    final db = await database;
    List<Map<String, dynamic>> result = await db.query(
      'shelf_records',
      where: 'pastry_id = ?',
      whereArgs: [pastryId],
      limit: 1,
    );
    return result.isNotEmpty ? result.first : null;
  }

  Future<int> updateShelfRecord(int shelfID, Map<String, dynamic> shelfRecord) async {
    final db = await database;
    return db.update("shelf_records", where: 'id = ?', whereArgs: [shelfID], shelfRecord);
  }

  Future<int> deleteShelfRecord(int id) async {
    final db = await database;
    return await db.delete(
      'shelf_records',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  //____________________________________PASTRIES RECORDS______________________________________________________________________________________________

  Future<int> insertPastry(Map<String, dynamic> pastry) async {
    final db = await database;
    return await db.insert('pastries', pastry);
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
    return await db.query('pastries');
  }

  Future<List<Map<String, dynamic>>> getPastriesByCategory(String category) async {
    final db = await database;
    return await db.query(
      'pastries',
      where: 'category = ?',
      whereArgs: [category],
      orderBy: 'created_at DESC',
    );
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
    final result = await db.update(
      'pastries',
      {'quantity': newQuantity},
      where: 'id = ?',
      whereArgs: [id],
    );

    return result;
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

  //================================ DAILY SALES ===========================================================
  Future<int> insertDailyEntry(Map<String, dynamic> dailyEntry) async {
    final db = await database;
    return await db.insert('dailyEntries', dailyEntry);
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

  Future<List<Map<String, dynamic>>> getDailyEntries() async {
    final db = await database;
    return await db.query('dailyEntries', orderBy: 'created_at DESC');
  }

  Future<List<Map<String, dynamic>>> getDailyEntriesMyDate(String dateEntry) async {
    final db = await database;
    return await db.query(
      'dailyEntries',
      where: 'created_at = ?',
      whereArgs: [dateEntry],
      orderBy: 'created_at DESC',
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

  // ==================== NOTIFICATIONS CRUD OPERATIONS ====================

  // Insert a notification
  Future<int> insertNotification(Map<String, dynamic> notification) async {
    final db = await database;

    // Convert additional_data map to JSON string
    final insertData = Map<String, dynamic>.from(notification);
    if (insertData['additional_data'] != null) {
      insertData['additional_data'] = jsonEncode(insertData['additional_data']);
    }

    return await db.insert(
      'notifications',
      insertData,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Get all notifications (most recent first)
  Future<List<Map<String, dynamic>>> getAllNotifications() async {
    final db = await database;
    final results = await db.query(
      'notifications',
      orderBy: 'created_at DESC',
    );

    // Parse additional_data from JSON string back to map safely
    return results.map((notification) {
      // Create a mutable copy
      final mutableNotification = Map<String, dynamic>.from(notification);

      if (mutableNotification['additional_data'] != null && mutableNotification['additional_data'] is String) {
        try {
          mutableNotification['additional_data'] = jsonDecode(mutableNotification['additional_data'] as String);
        } catch (e) {
          print('Error parsing additional_data: $e');
          mutableNotification['additional_data'] = {};
        }
      }
      return mutableNotification;
    }).toList();
  }

  // Get unread notifications count
  Future<int> getUnreadNotificationsCount() async {
    final db = await database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM notifications WHERE is_read = 0');
    return result.first['count'] as int? ?? 0;
  }

  // Get notifications by type
  Future<List<Map<String, dynamic>>> getNotificationsByType(String type) async {
    final db = await database;
    final results = await db.query(
      'notifications',
      where: 'type = ?',
      whereArgs: [type],
      orderBy: 'created_at DESC',
    );

    return results.map((notification) {
      final mutableNotification = Map<String, dynamic>.from(notification);

      if (mutableNotification['additional_data'] != null && mutableNotification['additional_data'] is String) {
        try {
          mutableNotification['additional_data'] = jsonDecode(mutableNotification['additional_data'] as String);
        } catch (e) {
          print('Error parsing additional_data: $e');
          mutableNotification['additional_data'] = {};
        }
      }
      return mutableNotification;
    }).toList();
  }

// Search notifications by title or summary
  Future<List<Map<String, dynamic>>> searchNotifications(String query) async {
    final db = await database;
    final results = await db.rawQuery('''
    SELECT * FROM notifications 
    WHERE title LIKE ? OR summary LIKE ? 
    ORDER BY created_at DESC
  ''', ['%$query%', '%$query%']);

    return results.map((notification) {
      final mutableNotification = Map<String, dynamic>.from(notification);

      if (mutableNotification['additional_data'] != null && mutableNotification['additional_data'] is String) {
        try {
          mutableNotification['additional_data'] = jsonDecode(mutableNotification['additional_data'] as String);
        } catch (e) {
          print('Error parsing additional_data: $e');
          mutableNotification['additional_data'] = {};
        }
      }
      return mutableNotification;
    }).toList();
  }

  // Mark notification as read
  Future<int> markNotificationAsRead(int id) async {
    final db = await database;
    return await db.update(
      'notifications',
      {'is_read': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Mark all notifications as read
  Future<int> markAllNotificationsAsRead() async {
    final db = await database;
    return await db.update(
      'notifications',
      {'is_read': 1},
    );
  }

  // Delete a notification
  Future<int> deleteNotification(int id) async {
    final db = await database;
    return await db.delete(
      'notifications',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Delete all notifications
  Future<int> deleteAllNotifications() async {
    final db = await database;
    return await db.delete('notifications');
  }

  // Delete all read notifications
  Future<int> deleteAllReadNotifications() async {
    final db = await database;
    return await db.delete(
      'notifications',
      where: 'is_read = 1',
    );
  }

  // Get notification by ID
  Future<Map<String, dynamic>?> getNotification(int id) async {
    final db = await database;
    final results = await db.query(
      'notifications',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (results.isNotEmpty) {
      final notification = results.first;
      if (notification['additional_data'] != null) {
        try {
          notification['additional_data'] = jsonDecode(notification['additional_data'] as String);
        } catch (e) {
          print('Error parsing additional_data: $e');
          notification['additional_data'] = {};
        }
      }
      return notification;
    }
    return null;
  }
}
