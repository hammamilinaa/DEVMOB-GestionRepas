import 'ingredient.dart';

class Recipe {
  final String id;
  final String userId;
  final String name;
  final String description;
  final String category;
  final List<Ingredient> ingredients;
  final List<String> steps;
  final String? imagePath;
  final bool isFavorite;

  Recipe({
    required this.id,
    required this.userId,
    required this.name,
    required this.description,
    required this.category,
    required this.ingredients,
    required this.steps,
    this.imagePath,
    this.isFavorite = false,
  });

  Recipe copyWith({
    String? name,
    String? description,
    String? category,
    List<Ingredient>? ingredients,
    List<String>? steps,
    String? imagePath,
    bool? isFavorite,
  }) =>
      Recipe(
        id: id,
        userId: userId,
        name: name ?? this.name,
        description: description ?? this.description,
        category: category ?? this.category,
        ingredients: ingredients ?? this.ingredients,
        steps: steps ?? this.steps,
        imagePath: imagePath ?? this.imagePath,
        isFavorite: isFavorite ?? this.isFavorite,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'userId': userId,
        'name': name,
        'description': description,
        'category': category,
        'ingredients': ingredients.map((i) => i.toMap()).toList(),
        'steps': steps,
        'imagePath': imagePath,
        'isFavorite': isFavorite,
      };

  factory Recipe.fromMap(Map map) => Recipe(
        id: map['id'] as String,
        userId: map['userId'] as String,
        name: map['name'] as String,
        description: map['description'] as String,
        category: map['category'] as String,
        ingredients: (map['ingredients'] as List)
            .map((i) => Ingredient.fromMap(i as Map))
            .toList(),
        steps: List<String>.from(map['steps'] as List),
        imagePath: map['imagePath'] as String?,
        isFavorite: (map['isFavorite'] as bool?) ?? false,
      );
}
