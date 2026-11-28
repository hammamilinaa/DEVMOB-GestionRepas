import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

// Les catégories de recettes proposées dans l'appli
const List<String> recipeCategories = [
  'Petit-déjeuner',
  'Déjeuner',
  'Dîner',
  'Dessert',
];

// Couleur de l'étiquette selon la catégorie
Color categoryColor(String category) {
  switch (category) {
    case 'Petit-déjeuner':
      return AppColors.peach;
    case 'Déjeuner':
      return AppColors.sage;
    case 'Dîner':
      return const Color(0xFFDCE6F0);
    default:
      return const Color(0xFFF3DCDC);
  }
}