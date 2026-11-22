import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/auth_service.dart';

// Garde l'utilisateur connecté en mémoire et prévient les écrans quand il change
class AuthProvider extends ChangeNotifier {
  final AuthService _service = AuthService();

  AppUser? _user;        // utilisateur connecté (null = personne)
  bool _isLoading = false; // true pendant une inscription ou connexion
  String? _error;        // message d'erreur à afficher (null = aucune)

  // Au démarrage : retrouve l'utilisateur resté connecté
  AuthProvider() {
    _user = _service.getCurrentUser();
  }

  // Lecture seule pour les écrans
  AppUser? get user => _user;
  bool get isLoggedIn => _user != null;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // INSCRIPTION : retourne true si ça a marché
  Future<bool> register({
    required String name,
    required String email,
    required String password,
  }) async {
    return _run(() => _service.register(
          name: name,
          email: email,
          password: password,
        ));
  }

  // CONNEXION : retourne true si ça a marché
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    return _run(() => _service.login(email: email, password: password));
  }

  // DÉCONNEXION
  Future<void> logout() async {
    await _service.logout();
    _user = null;
    notifyListeners(); // prévient les écrans
  }

  // Efface le message d'erreur (quand on change de page)
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Code commun à register et login :
  // affiche le chargement, lance l'action, capture l'erreur éventuelle
  Future<bool> _run(Future<AppUser> Function() action) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _user = await action();
      return true;
    } on AuthException catch (e) {
      _error = e.message; // message prévu (ex : email déjà utilisé)
      return false;
    } catch (_) {
      _error = 'Une erreur est survenue';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
