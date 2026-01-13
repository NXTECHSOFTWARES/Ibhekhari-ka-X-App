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
      int id = bakingRecord.pastryId;

      final currentQuantity = await _pastryRepository.getPastryQuantityById(id);
      if (currentQuantity == null) {
        print("Warning: Pastry ID $id not found, skipping quantity update");
        return 0;
      }

      final newQuantity = bakingRecord.quantityBaked + currentQuantity;

      final success = await _pastryRepository.updatePastryQuantity(id, newQuantity);
      if (success) {
        print("Successfully updated Pastry Quantity of: ${bakingRecord.pastryName ?? 'Unknown'} "
            "(added ${bakingRecord.quantityBaked}, new total: ${newQuantity})");
      }
      return await _dbHelper.insertBakingRecord(bakingRecord.toMap());
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
      pastryQuantityUpdates[record.pastryId] = (pastryQuantityUpdates[record.pastryId] ?? 0) + record.quantityBaked;
      batch.insert('baking_records', record.toMap());
    }

    try {
      // Commit all baking records
      await batch.commit(noResult: true);
      print("Successfully added ${bakingRecords.length} baking records");

      // Now update pastry quantities
      for (var entry in pastryQuantityUpdates.entries) {
        int pastryId = entry.key;
        int quantityToAdd = entry.value;

        final pastryBefore = await _pastryRepository.getPastryById(pastryId);
        if (pastryBefore == null) {
          print("ERROR: Pastry ID $pastryId not found!");
          continue;
        }

        int newQuantity = pastryBefore.quantity + quantityToAdd;

        // Perform update
        bool updateResult = await _pastryRepository.updatePastryQuantity(pastryId, newQuantity);
        print("  Update Result: $updateResult");

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
