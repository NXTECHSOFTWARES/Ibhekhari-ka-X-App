import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    final String databasePath = await getDatabasesPath();
    final path = join(databasePath, "ibhekharikaxdatabase.db");

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE ingredients (
        ingredient_id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        price DECIMAL(10,2) NOT NULL,
        size INTEGER,
        unit TEXT,
        quantity INTEGER NOT NULL,
        flavour TEXT,
        supplier TEXT,
        expire_date TEXT NOT NULL,
        purchase_date TEXT
      )
    ''');

    Future<int> insertIngredient(Map<String, dynamic> ingredient) async {
      Database db = await database;
      return await db.insert('ingredients', ingredient);
    }

    Future<List<Map<String, dynamic>>> getAllIngredients() async {
      Database db = await this.database;
      return await db.query('ingredients');
    }

    Future<Map<String, dynamic>?> getIngredientById(int id) async {
      Database db = await database;
      List<Map<String, dynamic>> results = await db.query(
        'ingredients',
        where: 'ingredient_id = ?',
        whereArgs: [id],
      );
      return  results.isNotEmpty ? results.first : null;
    }

    // await db.execute('''
    //   CREATE TABLE recipes (
    //     recipe_id INTEGER PRIMARY KEY AUTOINCREMENT,
    //     name TEXT NOT NULL,
    //     recipe_owner TEXT,
    //     description TEXT,
    //     preparation_time INTEGER,
    //     baking_time INTEGER,
    //     baking_temperature INTEGER,
    //     instructions TEXT,
    //     yield INTEGER,
    //     notes TEXT,
    //     recipe_link TEXT,
    //     recipe_video_link TEXT
    //   )
    // ''');
    //
    // await db.execute('''
    //   CREATE TABLE recipe_ingredients (
    //     recipe_id INTEGER,
    //     ingredient_id INTEGER,
    //     quantity DECIMAL(10,2) NOT NULL,
    //     FOREIGN KEY (recipe_id) REFERENCES recipes(recipe_id),
    //     FOREIGN KEY (ingredient_id) REFERENCES ingredients(ingredient_id),
    //     PRIMARY KEY (recipe_id, ingredient_id)
    //   )
    // ''');
    //
    // await db.execute('''
    //   CREATE TABLE Pastry (
    //     pastry_id INTEGER PRIMARY KEY AUTOINCREMENT,
    //     name TEXT NOT NULL,
    //     recipe_id INTEGER,
    //     description TEXT,
    //     price DECIMAL(10,2) NOT NULL,
    //     category TEXT,
    //     image_url TEXT,
    //     FOREIGN KEY (recipe_id) REFERENCES recipes(recipe_id)
    //   )
    // ''');
    //
    // await db.execute('''
    //   CREATE TABLE DailyStockRecord (
    //     record_id INTEGER PRIMARY KEY AUTOINCREMENT,
    //     date TEXT NOT NULL UNIQUE
    //     total_sales DECIMAL(10,2),
    //     total_stock_sold INTEGER,
    //     total_stock_left INTEGER
    //   )
    // ''');
    //
    // await db.execute('''
    //   CREATE TABLE DailyStockDetails (
    //     detail_id INTEGER PRIMARY KEY AUTOINCREMENT,
    //     record_id INTEGER,
    //     pastry_id INTEGER,
    //     quantity INTEGER NOT NULL,
    //     FOREIGN KEY (record_id) REFERENCES DailyStockRecord(record_id),
    //     FOREIGN KEY (pastry_id) REFERENCES Pastry(pastry_id)
    //   )
    // ''');
  }

  // Future<void> saveDailyStockRecord(Database db, String date, List<Map<String, dynamic>> stockData) async {
  //   // Insert a new record into DailyStockRecord
  //   int recordId = await db.insert(
  //     'DailyStockRecord',
  //     {
  //       'date': date,
  //     },
  //     conflictAlgorithm: ConflictAlgorithm.replace, // Replace if the date already exists
  //   );
  //
  //   // Insert stock details into DailyStockDetails
  //   for (var item in stockData) {
  //     await db.insert(
  //       'DailyStockDetails',
  //       {
  //         'record_id': recordId,
  //         'pastry_id': item['pastry_id'],
  //         'quantity': item['quantity'],
  //       },
  //     );
  //   }
  // }

  // Future<List<Map<String, dynamic>>> getDailyStockRecord(Database db, String date) async {
  //   // Get the record_id for the given date
  //   List<Map<String, dynamic>> record = await db.query(
  //     'DailyStockRecord',
  //     where: 'date = ?',
  //     whereArgs: [date],
  //   );
  //
  //   if (record.isEmpty) return [];
  //
  //   int recordId = record.first['record_id'];
  //
  //   // Get the stock details for the record_id
  //   List<Map<String, dynamic>> details = await db.query(
  //     'DailyStockDetails',
  //     where: 'record_id = ?',
  //     whereArgs: [recordId],
  //   );
  //
  //   return details;
  // }
}

/*
void main() async {
  // Initialize the database
  Database db = await openDatabase('my_database.db');

  // Example data for the day
  String date = '2023-10-01';
  List<Map<String, dynamic>> stockData = [
    { 'cake_id': 1, 'quantity': 7 },  // Chocolate Cupcake
    { 'cake_id': 2, 'quantity': 5 },  // Vanilla Cake
    { 'cake_id': 3, 'quantity': 3 },  // Red Velvet Cake
  ];

  // Save the daily stock record
  await saveDailyStockRecord(db, date, stockData);

  // Query the daily stock record
  List<Map<String, dynamic>> dailyStock = await getDailyStockRecord(db, date);
  print(dailyStock); // Output: [{detail_id: 1, record_id: 1, pastry_id: 1, quantity: 7}, ...]
}
*/