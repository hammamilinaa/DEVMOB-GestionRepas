import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import 'login_page.dart';

// "Porte d'entrée" : choisit quelle page afficher selon la connexion
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    // Connecté -> accueil, sinon -> page de connexion
    if (auth.isLoggedIn) {
      return const _TemporaryHome();
    }
    return const LoginPage();
  }
}

// Écran temporaire : sera remplacé par la vraie navigation (commit 8)
class _TemporaryHome extends StatelessWidget {
  const _TemporaryHome();

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('GestionRepas'),
        actions: [
          // Bouton de déconnexion
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Se déconnecter',
            onPressed: () => context.read<AuthProvider>().logout(),
          ),
        ],
      ),
      body: Center(
        child: Text(
          'Bonjour ${auth.user?.name ?? ''} !',
          style: const TextStyle(fontSize: 22),
        ),
      ),
    );
  }
}