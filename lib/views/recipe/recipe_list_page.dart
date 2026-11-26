import 'package:flutter/material.dart';

// Liste des recettes (provisoire, sera complétée au commit 10)
class RecipeListPage extends StatelessWidget {
  const RecipeListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mes recettes')),
      body: const Center(child: Text('Recettes : bientôt disponible')),
    );
  }
}