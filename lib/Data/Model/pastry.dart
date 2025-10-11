import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class Pastry {
  final int? id;
  final String title;
  final double price;
  int quantity;
  final String category;
  final Uint8List imageBytes;
  final String createdAt;

  int? totalSales;
  double? totalIncome;

  Pastry({
    this.id,
    required this.title,
    required this.price,
    required this.quantity,
    required this.category,
    required this.imageBytes,
    required this.createdAt,
    this.totalSales,
    this.totalIncome,
  });

  Pastry copyWith({
    int? id,
    String? title,
    double? price,
    int? quantity,
    String? category,
    Uint8List? imageBytes,
    String? createdAt,
    int? totalSales,
    double? totalIncome,
  }) {
    return Pastry(
      id: id ?? this.id,
      title: title ?? this.title,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      category: category ?? this.category,
      imageBytes: imageBytes ?? this.imageBytes,
      createdAt: createdAt ?? this.createdAt,
      totalSales: totalSales ?? this.totalSales,
      totalIncome: totalIncome ?? this.totalIncome,
    );
  }

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

  factory Pastry.fromJson(Map<String, dynamic> json) {
    return Pastry(
      id: json['id'],
      title: json['title'],
      price: json['price'] is int ? (json['price'] as int).toDouble() : json['price'],
      quantity: json['quantity'],
      category: json['category'],
      imageBytes: json['imageBytes'] is Uint8List
          ? json['imageBytes']
          : (json['imageBytes'] != null
          ? Uint8List.fromList(List<int>.from(json['imageBytes'] ?? []))
          : Uint8List(0)),
      createdAt: json['created_at'] ?? DateFormat('yyyy-MM-dd').format(DateTime.now()),
    );
  }

  @override
  String toString() {
    return '''
    Pastry(
      id: $id,
      title: $title, 
      price: $price, 
      quantity: $quantity, 
      category: $category, 
      imageBytes: ${imageBytes.length} bytes, 
      createdAt: $createdAt,
      totalSales: $totalSales,
      totalIncome: $totalIncome
    )
    ''';
  }
}