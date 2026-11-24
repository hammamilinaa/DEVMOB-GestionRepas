import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_theme.dart';
import 'register_page.dart';

// Page de connexion
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>(); // sert à valider le formulaire
  final _emailCtrl = TextEditingController(); // lit le champ email
  final _passwordCtrl = TextEditingController(); // lit le champ mot de passe
  bool _hidePassword = true; // cache ou montre le mot de passe

  // Libère la mémoire quand la page est fermée
  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  // Appelée quand on clique sur "Se connecter"
  Future<void> _submit() async {
    // Si un champ est invalide, on s'arrête
    if (!_formKey.currentState!.validate()) return;

    final ok = await context.read<AuthProvider>().login(
          email: _emailCtrl.text,
          password: _passwordCtrl.text,
        );

    // Si la connexion réussit, on ferme les pages ouvertes par-dessus
    if (ok && mounted) {
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
  }

  @override
  Widget build(BuildContext context) {
    // watch : la page se redessine quand l'état change (chargement, erreur)
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(28, 48, 28, 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Logo vert
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: const Icon(Icons.restaurant,
                      color: Colors.white, size: 36),
                ),
                const SizedBox(height: 16),

                // Titre
                const Text(
                  'Bon retour !',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Connectez-vous pour retrouver vos menus.',
                  style: TextStyle(color: AppColors.textGrey),
                ),
                const SizedBox(height: 28),

                // Champ email
                const Text('Email',
                    style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  decoration:
                      const InputDecoration(hintText: 'nom@exemple.com'),
                  validator: (v) => (v == null || !v.contains('@'))
                      ? 'Entrez un email valide'
                      : null,
                ),
                const SizedBox(height: 16),

                // Champ mot de passe (avec bouton oeil)
                const Text('Mot de passe',
                    style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _passwordCtrl,
                  obscureText: _hidePassword,
                  decoration: InputDecoration(
                    hintText: 'Votre mot de passe',
                    suffixIcon: IconButton(
                      icon: Icon(_hidePassword
                          ? Icons.visibility_off
                          : Icons.visibility),
                      onPressed: () =>
                          setState(() => _hidePassword = !_hidePassword),
                    ),
                  ),
                  validator: (v) => (v == null || v.isEmpty)
                      ? 'Entrez votre mot de passe'
                      : null,
                ),

                // Message d'erreur (visible seulement s'il y en a un)
                if (auth.error != null) ...[
                  const SizedBox(height: 12),
                  Text(auth.error!,
                      style: const TextStyle(color: AppColors.error)),
                ],
                const SizedBox(height: 28),

                // Bouton : affiche un cercle de chargement pendant la connexion
                ElevatedButton(
                  onPressed: auth.isLoading ? null : _submit,
                  child: auth.isLoading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('Se connecter'),
                ),
                const SizedBox(height: 24),

                // Lien vers l'inscription
                Center(
                  child: TextButton(
                    onPressed: () {
                      context.read<AuthProvider>().clearError();
                      Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (_) => const RegisterPage()),
                      );
                    },
                    child: const Text(
                      'Pas encore de compte ? Créer un compte',
                      style: TextStyle(color: AppColors.primaryDark),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}