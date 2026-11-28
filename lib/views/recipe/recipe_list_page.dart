import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/recipe_categories.dart';
import '../../providers/recipe_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/recipe_card.dart';

// Liste des recettes : recherche, catégories et grille de cartes
class RecipeListPage extends StatefulWidget {
  const RecipeListPage({super.key});

  @override
  State<RecipeListPage> createState() => _RecipeListPageState();
}

class _RecipeListPageState extends State<RecipeListPage> {
  String _query = ''; // texte tapé dans la recherche
  String? _category; // catégorie choisie (null = toutes)

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RecipeProvider>();
    final recipes = provider.search(query: _query, category: _category);

    return Scaffold(
      appBar: AppBar(title: const Text('Mes recettes')),

      // Bouton vert "+" (le formulaire d'ajout arrive au commit 11)
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text("Le formulaire d'ajout arrive bientôt")),
          );
        },
        child: const Icon(Icons.add),
      ),

      body: Column(
        children: [
          // Barre de recherche
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
            child: TextField(
              onChanged: (value) => setState(() => _query = value),
              decoration: const InputDecoration(
                hintText: 'Rechercher une recette',
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),

          // Chips de catégories (défilent à l'horizontale)
          SizedBox(
            height: 44,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _chip('Toutes', null),
                for (final c in recipeCategories) _chip(c, c),
              ],
            ),
          ),

          // Grille de recettes, ou message si la liste est vide
          Expanded(
            child: recipes.isEmpty
                ? Center(
                    child: Text(
                      provider.recipes.isEmpty
                          ? "Vous n'avez pas encore de recette"
                          : 'Aucune recette trouvée',
                      style: const TextStyle(color: AppColors.textGrey),
                    ),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate:
                        const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 220,
                      childAspectRatio: 0.8,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    itemCount: recipes.length,
                    itemBuilder: (context, index) {
                      final recipe = recipes[index];
                      return RecipeCard(
                        recipe: recipe,
                        onFavorite: () => context
                            .read<RecipeProvider>()
                            .toggleFavorite(recipe),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  // Une chip de catégorie (value null = "Toutes")
  Widget _chip(String label, String? value) {
    final selected = _category == value;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        showCheckmark: false,
        selectedColor: AppColors.primary,
        backgroundColor: Colors.white,
        labelStyle: TextStyle(
          color: selected ? Colors.white : AppColors.text,
          fontSize: 13,
        ),
        onSelected: (_) => setState(() => _category = value),
      ),
    );
  }
}