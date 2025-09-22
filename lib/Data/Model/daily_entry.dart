class DailyEntry {
  final int? id;
  final int soldStock;
  final int remainingStock;
  final String createdAt;
  final int pastryId;

  DailyEntry(
      {this.id,
      required this.soldStock,
      required this.remainingStock,
      required this.createdAt,
      required this.pastryId});

  factory DailyEntry.fromJson(Map<String, dynamic> json) {
    return DailyEntry(
      id: json["id"],
      soldStock: json["sold_stock"],
      remainingStock: json["remaining_stock"],
      createdAt: json["created_at"],
      pastryId: json["pastry_id"],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "sold_stock": soldStock,
      "remaining_stock": remainingStock,
      "created_at": createdAt,
      "pastry_id": pastryId,
    };
  }

  @override
  String toString() {
    return '''
DailyEntry {
  id: $id,
  soldStock: $soldStock,
  remainingStock: $remainingStock,
  createdAt: $createdAt,
  pastryId: $pastryId
}
''';
  }
}
