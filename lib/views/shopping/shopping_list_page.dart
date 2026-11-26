import 'package:flutter/material.dart';

// Liste de courses (provisoire, sera complétée au commit 18)
class ShoppingListPage extends StatelessWidget {
  const ShoppingListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Liste de courses')),
      body: const Center(child: Text('Courses : bientôt disponible')),
    );
  }
}