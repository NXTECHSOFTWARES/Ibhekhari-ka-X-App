import 'package:nxbakers/Data/Model/shelf_record.dart';
import 'package:nxbakers/Domain/Repositories/pastry_repo.dart';

import '../../Data/Database/Local/sql_database_helper.dart';
import '../../Data/Model/pastry.dart';
import '../../Data/Model/restock_record.dart';

class ShelfRecordsRepository {
  final PastryRepository _pastryRepository = PastryRepository();

  static final ShelfRecordsRepository _instance = ShelfRecordsRepository._internal();

  factory ShelfRecordsRepository() => _instance;

  final SqlDatabaseHelper _dbHelper = SqlDatabaseHelper();

  ShelfRecordsRepository._internal();

  Future<int> addShelfRecord(
    RestockRecord restockRecord,
  ) async {
    try {
      final shelfRecordMap = await _dbHelper.getShelfRecordByPastryId(restockRecord.pastryId);
      Pastry? pastry = await _pastryRepository.getPastryById(restockRecord.pastryId);

      String lastRestockedDate = restockRecord.restockDate;
      String pastryName = restockRecord.pastryName;
      int quantityAdded = restockRecord.quantityAdded;
      int shelfLife = pastry!.shelfLife ?? 0;
      int pastryId = restockRecord.pastryId;
      if (shelfRecordMap == null) {
        print("hey: ${restockRecord.pastryName}");
      }
      if (shelfRecordMap == null) {
        final ShelfRecord shelfRecord = ShelfRecord.create(
            lastRestockedDate: lastRestockedDate,
            currentStock: restockRecord.quantityAdded,
            quantityAdded: quantityAdded,
            shelfLife: shelfLife,
            pastryId: pastryId,
            pastryName: pastryName);
        print("new record:\n $shelfRecord");
        print('Successfully added shelf record of Pastry: $pastryName');
        return await _dbHelper.insertShelfRecord(shelfRecord.toMap());
      }

      final shelfRecordDb = ShelfRecord.fromMap(shelfRecordMap);
      int newQuantity = shelfRecordDb.currentStock + restockRecord.quantityAdded;

      final updatedShelfRecord = shelfRecordDb.copyWith(
          lastRestockedDate: lastRestockedDate,
          currentStock: newQuantity,
          quantityAdded: quantityAdded,
          shelfLife: shelfLife,
          pastryId: pastryId,
          pastryName: pastryName);

      print("new record:\n $updatedShelfRecord");
      updateShelfRecord(updatedShelfRecord);
      print('Successfully update shelf record of Pastry: $pastryName');
      return 1;
    } catch (e) {
      throw ("Failed to add new shelf: $e");
    }
  }

  Future<int> addBatchShelfRecord(
      MapEntry<int, Map<String, dynamic>> restockRecordEntry, // Changed parameter type
      ) async {
    try {
      RestockRecord restockRecord = restockRecordEntry.value["record"];
      final shelfRecordMap = await _dbHelper.getShelfRecordByPastryId(restockRecord.pastryId);
      Pastry? pastry = await _pastryRepository.getPastryById(restockRecord.pastryId);

      String lastRestockedDate = restockRecordEntry.value["last_restocked"];
      String pastryName = restockRecord.pastryName;
      int _currentStock = restockRecordEntry.value["current_stock"];
      int quantityAdded = restockRecordEntry.value["last_restocked_quantity"];
      int shelfLife = pastry!.shelfLife ?? 0;
      int pastryId = restockRecord.pastryId;

      if (shelfRecordMap == null) {
        final ShelfRecord shelfRecord = ShelfRecord.create(
            lastRestockedDate: lastRestockedDate,
            currentStock: _currentStock,
            quantityAdded: quantityAdded,
            shelfLife: shelfLife,
            pastryId: pastryId,
            pastryName: pastryName);
        print("new record:\n $shelfRecord");
        print('Successfully added shelf record of Pastry: $pastryName');
        return await _dbHelper.insertShelfRecord(shelfRecord.toMap());
      }

      return 1;
    } catch (e) {
      throw Exception("Failed to add new shelf: $e");
    }
  }

  Future<List<ShelfRecord>> getAllShelfRecords() async {
    try {
      final allRecords = await _dbHelper.getAllShelfRecords();
      return allRecords.map((record) => ShelfRecord.fromMap(record)).toList();
    } catch (e) {
      throw Exception('Failed to get all Shelf Record: $e');
    }
  }

  Future<ShelfRecord?> getShelfRecordById(int id) async {
    try {
      final shelfMap = await _dbHelper.getShelfRecordById(id);

      final shelfRecord = ShelfRecord.fromMap(shelfMap);
      return shelfRecord;
    } catch (e) {
      throw Exception('Failed to get shelf Record: $e');
    }
  }

  Future<bool> deleteShelfRecord(int id) async {
    try {
      int isSuccess = await _dbHelper.deleteShelfRecord(id);
      return isSuccess == 1;
    } catch (e) {
      throw Exception('Failed to delete shelf Record: $e');
    }
  }

  Future<bool> updateShelfRecord(ShelfRecord shelfRecord) async {
    try {
      if (shelfRecord.id == null) throw Exception('Cannot update Shelf Record without ID');
      final result = await _dbHelper.updateShelfRecord(shelfRecord.id!, shelfRecord.toMap());
      return result > 0;
    } catch (e) {
      throw Exception('Failed to update pastry: $e');
    }
  }

  Future<bool> isPastryShelfAvailable(String pastryName, {int? excludeId}) async {
    if (pastryName.trim().isEmpty) return false;

    final shelfRecords = await getAllShelfRecords();
    final trimmedPastryName = pastryName.trim();

    return !shelfRecords.any((record) => record.pastryName.trim().toLowerCase() == trimmedPastryName.toLowerCase() && record.id != excludeId);
  }
}
