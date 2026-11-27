import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/recipe_provider.dart';
import 'services/storage_service.dart';
import 'theme/app_theme.dart';
import 'views/auth/auth_gate.dart';

// Point de départ de l'appli
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized(); // obligatoire avant un "await"
  await StorageService.init(); // ouvre la base de données

  runApp(
    // Rend les providers accessibles dans toute l'appli
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        // RecipeProvider a besoin d'AuthProvider pour connaître l'utilisateur
        ChangeNotifierProvider(
          create: (context) => RecipeProvider(context.read<AuthProvider>()),
        ),
      ],
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
      home: const AuthGate(), // connecté ? navigation : connexion
    );
  }
}