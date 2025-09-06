import 'dart:typed_data';

class Pastry {
  final int? id;
  final String title;
  final double price;
  int quantity;
  final String category;
  final Uint8List imageBytes;
  final String createdAt;

  Pastry({
    this.id,
    required this.title,
    required this.price,
    required this.quantity,
    required this.category,
    required this.imageBytes,
    required this.createdAt,
  });

  // Add copyWith method
  Pastry copyWith({
    int? id,
    String? title,
    double? price,
    int? quantity,
    String? category,
    Uint8List? imageBytes,
    String? createdAt,
  }) {
    return Pastry(
      id: id ?? this.id,
      title: title ?? this.title,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      category: category ?? this.category,
      imageBytes: imageBytes ?? this.imageBytes,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  // Update toJson method
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'price': price,
      'quantity': quantity,
      'category': category,
      'imageBytes': imageBytes,
      'created_at': createdAt,
    };
  }

  // Update fromJson method
  factory Pastry.fromJson(Map<String, dynamic> json) {
    return Pastry(
      id: json['id'],
      title: json['title'],
      price: json['price'],
      quantity: json['quantity'],
      category: json['category'],
      imageBytes: json['imageBytes'] is Uint8List
          ? json['imageBytes']
          : Uint8List.fromList(List<int>.from(json['imageBytes'] ?? [])),
      createdAt: json['created_at'],
    );
  }
}