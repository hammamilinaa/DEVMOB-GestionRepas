import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../main_navigation.dart';
import 'login_page.dart';

// "Porte d'entrée" : choisit quelle page afficher selon la connexion
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    // Connecté -> navigation principale, sinon -> page de connexion
    if (auth.isLoggedIn) {
      return const MainNavigation();
    }
    return const LoginPage();
  }
}