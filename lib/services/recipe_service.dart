import '../models/recipe.dart';
import 'storage_service.dart';

// Lit et écrit les recettes dans la base Hive
class RecipeService {
  // Toutes les recettes d'UN utilisateur (triées par nom)
  List<Recipe> getAll(String userId) {
    final recipes = StorageService.recipes.values
        .map((item) => Recipe.fromMap(item as Map))
        .where((recipe) => recipe.userId == userId)
        .toList();
    recipes.sort(
        (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    return recipes;
  }

  // AJOUTER ou MODIFIER : "put" crée la recette, ou la remplace si l'id existe
  Future<void> save(Recipe recipe) async {
    await StorageService.recipes.put(recipe.id, recipe.toMap());
  }

  // SUPPRIMER une recette
  Future<void> delete(String recipeId) async {
    await StorageService.recipes.delete(recipeId);
  }
}