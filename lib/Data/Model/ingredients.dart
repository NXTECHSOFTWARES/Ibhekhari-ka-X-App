import 'enum/ingredient_prefend_condition.dart';

class Ingredient {
  final String title;
  final Condition condition;
  final String unit;
  final String quantity;

  Ingredient({
    required this.title,
    required this.condition,
    required this.unit,
    required this.quantity,
  });

  factory Ingredient.fromMap(Map<String, dynamic> json) => Ingredient(
    title: json["title"],
    condition: conditionValues.map[json["condition"]]!,
    unit: json["unit"],
    quantity: json["quantity"],
  );

  Map<String, dynamic> toMap() => {
    "title": title,
    "condition": conditionValues.reverse[condition],
    "unit": unit,
    "quantity": quantity,
  };

  Ingredient copyWith({
    String? title,
    Condition? condition,
    String? unit,
    String? quantity,
  }) =>
      Ingredient(
        title: title ?? this.title,
        condition: condition ?? this.condition,
        unit: unit ?? this.unit,
        quantity: quantity ?? this.quantity,
      );
}