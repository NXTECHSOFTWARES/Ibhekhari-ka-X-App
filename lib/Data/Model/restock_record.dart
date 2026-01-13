class RestockRecord{
  final int? id;
  final String restockDate;
  final int quantityAdded;
  final int pastryId;
  final String pastryName;

  RestockRecord({
    this.id,
    required this.restockDate,
    required this.quantityAdded,
    required this.pastryId,
    required this.pastryName,
  });

  // Create from database map
  factory RestockRecord.fromMap(Map<String, dynamic> map) {
    return RestockRecord(
      id: map['id'] as int?,
      restockDate: map['restock_date'] as String,
      quantityAdded: map['quantity_added'] as int,
      pastryId: map['pastry_id'] as int,
      pastryName: map['pastry_name'] as String,
    );
  }

  // Convert to database map
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'restock_date': restockDate,
      'quantity_added': quantityAdded,
      'pastry_id': pastryId,
      'pastry_name': pastryName,
    };
  }

  // Create from JSON (for your import data)
  factory RestockRecord.fromJson(Map<String, dynamic> json, String restockDate) {
    return RestockRecord(
      restockDate: restockDate,
      quantityAdded: json['quantity_added'] as int,
      pastryId: json['pastry_id'] as int,
      pastryName: json['pastry_name'] as String,
    );
  }

  @override
  String toString() {
    // TODO: implement toString
    return "restockDate: $restockDate, quantityAdded: $quantityAdded, pastryId: $pastryId, pastryName: $pastryName";
  }
}