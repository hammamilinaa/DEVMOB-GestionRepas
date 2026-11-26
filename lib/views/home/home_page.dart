import 'package:flutter/material.dart';

// Page d'accueil (provisoire, sera complétée au commit 13)
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Accueil')),
      body: const Center(child: Text('Accueil : bientôt disponible')),
    );
  }
}