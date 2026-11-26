import 'package:flutter/material.dart';

// Calendrier des repas (provisoire, sera complété au commit 15)
class MealCalendarPage extends StatelessWidget {
  const MealCalendarPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Calendrier des repas')),
      body: const Center(child: Text('Planning : bientôt disponible')),
    );
  }
}