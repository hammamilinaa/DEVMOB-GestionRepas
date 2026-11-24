import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'services/storage_service.dart';
import 'theme/app_theme.dart';
import 'views/auth/auth_gate.dart';

// Point de départ de l'appli
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized(); // obligatoire avant un "await"
  await StorageService.init(); // ouvre la base de données

  runApp(
    // Rend AuthProvider accessible dans toute l'appli
    ChangeNotifierProvider(
      create: (_) => AuthProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GestionRepas',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const AuthGate(), // connecté ? accueil : connexion
    );
  }
}