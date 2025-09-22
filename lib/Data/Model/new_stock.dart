class NewStock {
  final int? id;
  final int currentQuantity;
  final int newQuantity;
  final String createdAt;
  final int pastryId;

  NewStock({
    this.id,
    required this.currentQuantity,
    required this.newQuantity,
    required this.createdAt,
    required this.pastryId,
  });

  factory NewStock.fromJson(Map<String, dynamic> json) {
    return NewStock(
      id: json["id"],
      currentQuantity: json["current_quantity"],
      newQuantity: json["new_quantity"],
      createdAt: json["created_at"],
      pastryId: json["pastry_id"],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "current_quantity": currentQuantity,
      "new_quantity": newQuantity,
      "created_at": createdAt,
      "pastry_id": pastryId,
    };
  }
}