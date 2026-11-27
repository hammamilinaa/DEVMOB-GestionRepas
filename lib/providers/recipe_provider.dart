import 'package:flutter/material.dart';
import '../models/recipe.dart';
import '../services/recipe_service.dart';
import 'auth_provider.dart';

// Garde les recettes de l'utilisateur connecté en mémoire
class RecipeProvider extends ChangeNotifier {
  final RecipeService _service = RecipeService();
  final AuthProvider _auth;

  List<Recipe> _recipes = [];

  RecipeProvider(this._auth) {
    _load();
    // Quand l'utilisateur change (connexion, déconnexion), on recharge
    _auth.addListener(_onAuthChanged);
  }

  // Lecture seule pour les écrans
  List<Recipe> get recipes => _recipes;
  List<Recipe> get favorites => _recipes.where((r) => r.isFavorite).toList();

  // Retrouve une recette par son id (null si introuvable)
  Recipe? getById(String id) {
    for (final recipe in _recipes) {
      if (recipe.id == id) return recipe;
    }
    return null;
  }

  // Filtre par texte de recherche et par catégorie
  List<Recipe> search({String query = '', String? category}) {
    return _recipes.where((recipe) {
      final matchName =
          recipe.name.toLowerCase().contains(query.trim().toLowerCase());
      final matchCategory = category == null || recipe.category == category;
      return matchName && matchCategory;
    }).toList();
  }

  // AJOUTER ou MODIFIER une recette
  Future<void> saveRecipe(Recipe recipe) async {
    await _service.save(recipe);
    _load();
    notifyListeners();
  }

  // SUPPRIMER une recette
  Future<void> deleteRecipe(String id) async {
    await _service.delete(id);
    _load();
    notifyListeners();
  }

  // FAVORI : inverse l'état (favori <-> non favori)
  Future<void> toggleFavorite(Recipe recipe) async {
    await _service.save(recipe.copyWith(isFavorite: !recipe.isFavorite));
    _load();
    notifyListeners();
  }

  // Recharge la liste depuis Hive pour l'utilisateur connecté
  void _load() {
    final userId = _auth.user?.id;
    _recipes = userId == null ? [] : _service.getAll(userId);
  }

  void _onAuthChanged() {
    _load();
    notifyListeners();
  }

  @override
  void dispose() {
    _auth.removeListener(_onAuthChanged);
    super.dispose();
  }
}