import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import '../models/recipe.dart';
import '../models/recipe_categories.dart';
import '../theme/app_theme.dart';

// Carte d'une recette : photo, cœur favori, nom, catégorie
class RecipeCard extends StatelessWidget {
  final Recipe recipe;
  final VoidCallback? onTap;
  final VoidCallback onFavorite;

  const RecipeCard({
    super.key,
    required this.recipe,
    required this.onFavorite,
    this.onTap,
  });

  // Photo de la recette, ou une icône si elle n'a pas de photo
  Widget _buildImage() {
    final path = recipe.imagePath;
    if (path == null) {
      return Container(
        color: AppColors.sage,
        child: const Center(
          child: Icon(Icons.restaurant, size: 36, color: AppColors.primary),
        ),
      );
    }
    // Sur le web on lit l'image par son adresse, sinon depuis le fichier
    return kIsWeb
        ? Image.network(path, fit: BoxFit.cover)
        : Image.file(File(path), fit: BoxFit.cover);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias, // coupe l'image aux coins arrondis
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Partie haute : photo + bouton cœur
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  _buildImage(),
                  Positioned(
                    top: 6,
                    right: 6,
                    child: Material(
                      color: Colors.white,
                      shape: const CircleBorder(),
                      child: InkWell(
                        customBorder: const CircleBorder(),
                        onTap: onFavorite,
                        child: Padding(
                          padding: const EdgeInsets.all(6),
                          child: Icon(
                            recipe.isFavorite
                                ? Icons.favorite
                                : Icons.favorite_border,
                            size: 18,
                            color: recipe.isFavorite
                                ? AppColors.error
                                : AppColors.textGrey,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Partie basse : nom + catégorie
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    recipe.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: categoryColor(recipe.category),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      recipe.category,
                      style: const TextStyle(
                          fontSize: 11, color: AppColors.text),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}