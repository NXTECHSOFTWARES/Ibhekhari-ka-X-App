import 'package:nxbakers/Data/Model/baking_records.dart';
import 'package:nxbakers/Domain/Repositories/pastry_repo.dart';
import '../../Data/Database/Local/sql_database_helper.dart';

class BakingRepo {
  final PastryRepository _pastryRepository = PastryRepository();

  static final BakingRepo _instance = BakingRepo._internal();
  factory BakingRepo() => _instance;

  final SqlDatabaseHelper _dbHelper = SqlDatabaseHelper();

  BakingRepo._internal();

  Future<int> addBakingRecord(BakingRecord bakingRecord) async {
    try {
      return await _dbHelper.insertBakingRecord(bakingRecord.toJson());
    } catch (e) {
      print("Failed to add Baking Record: $e");
      throw Exception('Failed to add Baking Record: $e');
    }
  }

  // Add batch insert method
  Future<void> addBatchEntries(List<BakingRecord> bakingRecords) async {
    final db = await _dbHelper.database;
    final batch = db.batch();

    // Group records by pastry_id to calculate total quantities
    Map<int, int> pastryQuantityUpdates = {};

    for (var record in bakingRecords) {
      // Accumulate quantity updates
      pastryQuantityUpdates[record.pastryId] =
          (pastryQuantityUpdates[record.pastryId] ?? 0) + record.quantityBaked;

      // Add baking record to batch - use toMap() not toJson()
      batch.insert('baking_records', record.toJson());
    }

    try {
      // Commit all baking records
      await batch.commit(noResult: true);
      print("Successfully added ${bakingRecords.length} baking records");

      // Now update pastry quantities
      for (var entry in pastryQuantityUpdates.entries) {
        int pastryId = entry.key;
        int quantityToAdd = entry.value;

        final currentQuantity = await _pastryRepository.getPastryQuantityById(pastryId);

        if (currentQuantity == null) {
          print("Warning: Pastry ID $pastryId not found, skipping quantity update");
          continue;
        }

        int newQuantity = currentQuantity + quantityToAdd;
        await _pastryRepository.updatePastryQuantity(pastryId, newQuantity);

        // Get pastry name for logging
        final pastry = await _pastryRepository.getPastryById(pastryId);
        print("Successfully updated Pastry Quantity of: ${pastry?.title ?? 'Unknown'} (added $quantityToAdd, new total: $newQuantity)");
      }

    } catch (e) {
      print("Failed to add batch records: $e");
      throw Exception('Failed to add batch records: $e');
    }
  }

  // Get all baking records
  Future<List<BakingRecord>> getAllBakingRecords() async {
    try {
      final records = await _dbHelper.getAllBakingRecords();
      return records.map((map) => BakingRecord.fromMap(map)).toList();
    } catch (e) {
      print("Failed to get baking records: $e");
      throw Exception('Failed to get baking records: $e');
    }
  }

  Future<bool> deleteBakingRecord(int id) async {
    try {
      final result = await _dbHelper.deleteBakingRecord(id);
      return result > 0;
    } catch (e) {
      throw Exception('Failed to delete Baking Record: $e');
    }
  }

}