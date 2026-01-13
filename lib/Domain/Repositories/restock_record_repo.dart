import 'package:nxbakers/Data/Model/enum/shelf_status.dart';
import 'package:nxbakers/Data/Model/pastry.dart';
import 'package:nxbakers/Data/Model/restock_record.dart';
import 'package:nxbakers/Data/Model/shelf_record.dart';
import 'package:nxbakers/Domain/Repositories/pastry_repo.dart';
import 'package:nxbakers/Domain/Repositories/shelf_records_repository.dart';

import '../../Data/Database/Local/sql_database_helper.dart';

class RestockRecordRepo {
  final PastryRepository _pastryRepository = PastryRepository();
  final ShelfRecordsRepository _shelfRecordsRepository = ShelfRecordsRepository();

  static final RestockRecordRepo _instance = RestockRecordRepo._internal();

  factory RestockRecordRepo() => _instance;

  final SqlDatabaseHelper _dbHelper = SqlDatabaseHelper();

  RestockRecordRepo._internal();

  Future<int> addRestockRecord(RestockRecord restockRecord) async {
    try {
      await _shelfRecordsRepository.addShelfRecord(restockRecord);
      return await _dbHelper.insertRestockRecord(restockRecord.toMap());
    } catch (e) {
      print("Failed to add Restock Record: $e");
      throw Exception('Failed to add Restock Record: $e');
    }
  }

  // Add batch insert method
  Future<void> addBatchEntries(List<RestockRecord> restockRecords) async {
    final db = await _dbHelper.database;
    final batch = db.batch();

    // Group records by pastry_id to calculate total quantities
    Map<int, int> pastryQuantityUpdates = {};
    // Change: Use pastryId as key to group shelf record updates by pastry
    Map<int, Map<String, dynamic>> shelfRecordUpdates = {};

    for (var record in restockRecords) {
      // Accumulate quantity updates
      pastryQuantityUpdates[record.pastryId] =
          (pastryQuantityUpdates[record.pastryId] ?? 0) + record.quantityAdded;

      // Change: Group by pastryId instead of using string keys
      if (!shelfRecordUpdates.containsKey(record.pastryId)) {
        shelfRecordUpdates[record.pastryId] = {
          "record": record,
          "current_stock": 0,
          "last_restocked": record.restockDate,
          "last_restocked_quantity": 0,
        };
      }

      shelfRecordUpdates[record.pastryId]!["current_stock"] += record.quantityAdded;
      shelfRecordUpdates[record.pastryId]!["last_restocked"] = record.restockDate;
      shelfRecordUpdates[record.pastryId]!["last_restocked_quantity"] = record.quantityAdded;
      shelfRecordUpdates[record.pastryId]!["record"] = record; // Keep the latest record

      batch.insert('restock_records', record.toMap());
    }

    try {
      // Commit all restock records
      await batch.commit(noResult: true);
      print("Successfully added ${restockRecords.length} restock records");

      // Now update pastry quantities
      for (var entry in pastryQuantityUpdates.entries) {
        int pastryId = entry.key;
        int quantityToSubtracted = entry.value;

        final pastryBefore = await _pastryRepository.getPastryById(pastryId);
        if (pastryBefore == null) {
          print("ERROR: Pastry ID $pastryId not found!");
          continue;
        }

        if (quantityToSubtracted > pastryBefore.quantity) {
          print("ERROR: Restock Quantity Cannot be greater than the Current Pastry Quantity"
              "\nquantityToSubtracted: $quantityToSubtracted "
              "\npastryBefore Quantity: ${pastryBefore.quantity}");
          break;
        }
        int newQuantity = pastryBefore.quantity - quantityToSubtracted;

        bool updateResult = await _pastryRepository.updatePastryQuantity(pastryId, newQuantity);
        print("  Update Result: $updateResult");
      }

      // Change: Now iterate properly with pastryId as key
      for (var entry in shelfRecordUpdates.entries) {
        int shelfRecording = await _shelfRecordsRepository.addBatchShelfRecord(entry);
        print("  Shelf Update Result: $shelfRecording");
      }
    } catch (e) {
      print("Failed to add batch records: $e");
      throw Exception('Failed to add batch records: $e');
    }
  }

  // Get all restock records
  Future<List<RestockRecord>> getAllRestockRecords() async {
    try {
      final records = await _dbHelper.getAllRestockRecords();
      return records.map((map) => RestockRecord.fromMap(map)).toList();
    } catch (e) {
      print("Failed to get restock records: $e");
      throw Exception('Failed to get restock records: $e');
    }
  }

  Future<bool> deleteRestockRecord(int id) async {
    try {
      final result = await _dbHelper.deleteRestockRecord(id);
      return result > 0;
    } catch (e) {
      throw Exception('Failed to delete Restock Record: $e');
    }
  }
}
