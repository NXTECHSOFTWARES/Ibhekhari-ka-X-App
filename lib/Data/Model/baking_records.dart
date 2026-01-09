class BakingRecord {
  final int? id;
  final String bakingDate;
  final int quantityBaked;
  final int pastryId;
  final String pastryName;

  BakingRecord({
    this.id,
    required this.bakingDate,
    required this.quantityBaked,
    required this.pastryId,
    required this.pastryName,
  });

  // Create from database map
  factory BakingRecord.fromMap(Map<String, dynamic> map) {
    return BakingRecord(
      id: map['id'] as int?,
      bakingDate: map['baking_date'] as String,
      quantityBaked: map['quantity_baked'] as int,
      pastryId: map['pastry_id'] as int,
      pastryName: map['pastry_name'] as String,
    );
  }

  // Convert to database map
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'baking_date': bakingDate,
      'quantity_baked': quantityBaked,
      'pastry_id': pastryId,
      'pastry_name': pastryName,
    };
  }

  // Create from JSON (for your import data)
  factory BakingRecord.fromJson(Map<String, dynamic> json, String bakingDate) {
    return BakingRecord(
      bakingDate: bakingDate,
      quantityBaked: json['quantity_baked'] as int,
      pastryId: json['pastry_id'] as int,
      pastryName: json['pastry_name'] as String,
    );
  }

  @override
  String toString() {
    // TODO: implement toString
    return "bakingDate: $bakingDate, quantityBaked: $quantityBaked, pastryId: $pastryId, pastryName: $pastryName";
  }
}