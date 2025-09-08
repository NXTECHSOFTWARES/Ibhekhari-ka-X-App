import 'package:nxbakers/Data/Model/ingredients.dart';

class Recipe {
  final String header;
  final Map<String, List<Ingredient>> ingredients;
  final String subHeader;
  final Map<String, String> instructions;

  Recipe({
    required this.header,
    required this.ingredients,
    required this.subHeader,
    required this.instructions,
  });

  factory Recipe.fromMap(Map<String, dynamic> json) => Recipe(
    header: json["header"],
    ingredients: Map.from(json["ingredients"]).map((k, v) => MapEntry<String, List<Ingredient>>(k, List<Ingredient>.from(v.map((x) => Ingredient.fromMap(x))))),
    subHeader: json["sub_header"],
    instructions: Map.from(json["instructions"]).map((k, v) => MapEntry<String, String>(k, v)),
  );

  Map<String, dynamic> toMap() => {
    "header": header,
    "ingredients": Map.from(ingredients).map((k, v) => MapEntry<String, dynamic>(k, List<dynamic>.from(v.map((x) => x.toMap())))),
    "sub_header": subHeader,
    "instructions": Map.from(instructions).map((k, v) => MapEntry<String, dynamic>(k, v)),
  };

  Recipe copyWith({
    String? header,
    Map<String, List<Ingredient>>? ingredients,
    String? subHeader,
    Map<String, String>? instructions,
  }) =>
      Recipe(
        header: header ?? this.header,
        ingredients: ingredients ?? this.ingredients,
        subHeader: subHeader ?? this.subHeader,
        instructions: instructions ?? this.instructions,
      );
}
