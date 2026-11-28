import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../models/ingredient.dart';
import '../../models/recipe.dart';
import '../../models/recipe_categories.dart';
import '../../providers/auth_provider.dart';
import '../../providers/recipe_provider.dart';
import '../../theme/app_theme.dart';

// Une ligne d'ingrédient dans le formulaire (nom + quantité + unité)
class _IngredientRow {
  final TextEditingController name;
  final TextEditingController quantity;
  String unit;

  _IngredientRow({String name = '', String quantity = '', this.unit = 'g'})
      : name = TextEditingController(text: name),
        quantity = TextEditingController(text: quantity);

  void dispose() {
    name.dispose();
    quantity.dispose();
  }
}

// Formulaire d'ajout ET de modification d'une recette
// recipe == null -> ajout ; recipe != null -> modification
class AddRecipePage extends StatefulWidget {
  final Recipe? recipe;

  const AddRecipePage({super.key, this.recipe});

  @override
  State<AddRecipePage> createState() => _AddRecipePageState();
}

class _AddRecipePageState extends State<AddRecipePage> {
  static const _units = ['g', 'kg', 'ml', 'L', 'pièce', 'c.à.s', 'c.à.c'];

  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  String? _category;
  String? _imagePath;
  final List<_IngredientRow> _ingredients = [];
  final List<TextEditingController> _steps = [];

  bool get _isEditing => widget.recipe != null;

  // Si on modifie une recette, on remplit le formulaire avec ses données
  @override
  void initState() {
    super.initState();
    final r = widget.recipe;
    if (r != null) {
      _nameCtrl.text = r.name;
      _descCtrl.text = r.description;
      _category = r.category;
      _imagePath = r.imagePath;
      for (final i in r.ingredients) {
        _ingredients.add(_IngredientRow(
          name: i.name,
          quantity: i.quantity.toString(),
          unit: _units.contains(i.unit) ? i.unit : 'g',
        ));
      }
      for (final s in r.steps) {
        _steps.add(TextEditingController(text: s));
      }
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    for (final i in _ingredients) {
      i.dispose();
    }
    for (final s in _steps) {
      s.dispose();
    }
    super.dispose();
  }

  // Ouvre la galerie pour choisir une photo
  Future<void> _pickImage() async {
    final file = await ImagePicker()
        .pickImage(source: ImageSource.gallery, maxWidth: 1000);
    if (file != null) setState(() => _imagePath = file.path);
  }

  // Enregistre la recette (ajout ou modification)
  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final user = context.read<AuthProvider>().user;
    if (user == null) return;

    // On ignore les lignes vides
    final ingredients = _ingredients
        .where((row) => row.name.text.trim().isNotEmpty)
        .map((row) => Ingredient(
              name: row.name.text.trim(),
              quantity:
                  double.tryParse(row.quantity.text.replaceAll(',', '.')) ?? 1,
              unit: row.unit,
            ))
        .toList();
    final steps = _steps
        .map((c) => c.text.trim())
        .where((text) => text.isNotEmpty)
        .toList();

    final recipe = Recipe(
      id: widget.recipe?.id ?? const Uuid().v4(), // garde l'id si modification
      userId: user.id,
      name: _nameCtrl.text.trim(),
      description: _descCtrl.text.trim(),
      category: _category!,
      ingredients: ingredients,
      steps: steps,
      imagePath: _imagePath,
      isFavorite: widget.recipe?.isFavorite ?? false,
    );

    await context.read<RecipeProvider>().saveRecipe(recipe);
    if (mounted) Navigator.of(context).pop();
  }

  // Supprime la recette après confirmation
  Future<void> _delete() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Supprimer la recette ?'),
        content: const Text('Cette action est définitive.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Supprimer',
                style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
    if (confirm == true && mounted) {
      await context.read<RecipeProvider>().deleteRecipe(widget.recipe!.id);
      if (mounted) Navigator.of(context).pop();
    }
  }

  // Aperçu de la photo choisie
  Widget _photoPreview() {
    return kIsWeb
        ? Image.network(_imagePath!, fit: BoxFit.cover)
        : Image.file(File(_imagePath!), fit: BoxFit.cover);
  }

  // Titre de section
  Widget _title(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 8),
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.w600)),
    );
  }

  // Une ligne d'ingrédient : nom, quantité, unité, bouton supprimer
  Widget _ingredientRow(int index) {
    final row = _ingredients[index];
    return Padding(
      key: ObjectKey(row), // évite de mélanger les lignes quand on en supprime
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: row.name,
              decoration: const InputDecoration(hintText: 'Ingrédient'),
            ),
          ),
          const SizedBox(width: 6),
          SizedBox(
            width: 64,
            child: TextField(
              controller: row.quantity,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(hintText: 'Qté'),
            ),
          ),
          const SizedBox(width: 6),
          SizedBox(
            width: 88,
            child: DropdownButtonFormField<String>(
              initialValue: row.unit, // correction 1 : remplace "value"
              isExpanded: true,
              decoration: const InputDecoration(
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 8, vertical: 14),
              ),
              items: _units
                  .map((u) => DropdownMenuItem(
                        value: u,
                        child: Text(u, style: const TextStyle(fontSize: 13)),
                      ))
                  .toList(),
              onChanged: (u) => setState(() => row.unit = u ?? 'g'),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 20),
            onPressed: () => setState(() {
              _ingredients.removeAt(index).dispose();
            }),
          ),
        ],
      ),
    );
  }

  // Une ligne d'étape : numéro + texte + bouton supprimer
  Widget _stepRow(int index) {
    return Padding(
      key: ObjectKey(_steps[index]),
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          CircleAvatar(
            radius: 12,
            backgroundColor: AppColors.sage,
            child: Text('${index + 1}',
                style: const TextStyle(
                    fontSize: 12, color: AppColors.primaryDark)),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _steps[index],
              decoration: const InputDecoration(hintText: "Décrivez l'étape"),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 20),
            onPressed: () => setState(() {
              _steps.removeAt(index).dispose();
            }),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Modifier la recette' : 'Ajouter une recette'),
        actions: [
          if (_isEditing)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: AppColors.error),
              tooltip: 'Supprimer',
              onPressed: _delete,
            ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Photo facultative
                GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    height: 150,
                    width: double.infinity,
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(
                      color: AppColors.sage,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: _imagePath == null
                        ? const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.photo_camera_outlined,
                                  color: AppColors.primaryDark),
                              SizedBox(height: 6),
                              Text('Ajouter une photo',
                                  style:
                                      TextStyle(color: AppColors.primaryDark)),
                            ],
                          )
                        : _photoPreview(),
                  ),
                ),
                if (_imagePath != null)
                  TextButton(
                    onPressed: () => setState(() => _imagePath = null),
                    child: const Text('Retirer la photo'),
                  ),

                _title('Nom de la recette *'),
                TextFormField(
                  controller: _nameCtrl,
                  decoration:
                      const InputDecoration(hintText: 'Ex : Poulet au curry'),
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Entrez le nom de la recette'
                      : null,
                ),

                _title('Catégorie *'),
                DropdownButtonFormField<String>(
                  initialValue: _category, // correction 2 : remplace "value"
                  decoration: const InputDecoration(
                      hintText: 'Sélectionner une catégorie'),
                  items: recipeCategories
                      .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                      .toList(),
                  onChanged: (c) => setState(() => _category = c),
                  validator: (c) =>
                      c == null ? 'Choisissez une catégorie' : null,
                ),

                _title('Description'),
                TextFormField(
                  controller: _descCtrl,
                  maxLines: 3,
                  maxLength: 500,
                  decoration:
                      const InputDecoration(hintText: 'Décrivez la recette...'),
                ),

                _title('Ingrédients'),
                for (var i = 0; i < _ingredients.length; i++) _ingredientRow(i),
                OutlinedButton.icon(
                  onPressed: () =>
                      setState(() => _ingredients.add(_IngredientRow())),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Ajouter un ingrédient'),
                ),

                _title('Étapes de préparation'),
                for (var i = 0; i < _steps.length; i++) _stepRow(i),
                OutlinedButton.icon(
                  onPressed: () =>
                      setState(() => _steps.add(TextEditingController())),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Ajouter une étape'),
                ),

                const SizedBox(height: 28),
                ElevatedButton(
                  onPressed: _save,
                  child: const Text('Enregistrer'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}