import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import '../models/user.dart';
import 'storage_service.dart';

// Erreur avec un message lisible (affiché à l'écran)
class AuthException implements Exception {
  final String message;
  AuthException(this.message);
}

// Gère les comptes : inscription, connexion, déconnexion
class AuthService {
  // Clé qui retient quel utilisateur est connecté
  static const _sessionKey = 'currentUserId';

  // Transforme le mot de passe en empreinte (on ne stocke jamais le vrai)
  String _hash(String password) {
    return sha256.convert(utf8.encode(password)).toString();
  }

  // Cherche un compte avec cet email (retourne null s'il n'existe pas)
  AppUser? _findByEmail(String email) {
    final wanted = email.trim().toLowerCase();
    for (final item in StorageService.users.values) {
      final user = AppUser.fromMap(item as Map);
      if (user.email == wanted) return user;
    }
    return null;
  }

  // INSCRIPTION : crée un compte et connecte directement l'utilisateur
  Future<AppUser> register({
    required String name,
    required String email,
    required String password,
  }) async {
    if (_findByEmail(email) != null) {
      throw AuthException('Cet email est déjà utilisé');
    }
    final user = AppUser(
      id: const Uuid().v4(), // identifiant unique
      name: name.trim(),
      email: email.trim().toLowerCase(),
      passwordHash: _hash(password),
    );
    await StorageService.users.put(user.id, user.toMap());
    await StorageService.session.put(_sessionKey, user.id);
    return user;
  }

  // CONNEXION : compare l'empreinte du mot de passe saisi avec celle enregistrée
  Future<AppUser> login({
    required String email,
    required String password,
  }) async {
    final user = _findByEmail(email);
    if (user == null || user.passwordHash != _hash(password)) {
      throw AuthException('Email ou mot de passe incorrect');
    }
    await StorageService.session.put(_sessionKey, user.id);
    return user;
  }

  // DÉCONNEXION : efface la session
  Future<void> logout() async {
    await StorageService.session.delete(_sessionKey);
  }

  // Au lancement de l'appli : qui est resté connecté ? (null = personne)
  AppUser? getCurrentUser() {
    final id = StorageService.session.get(_sessionKey);
    if (id == null) return null;
    final data = StorageService.users.get(id);
    if (data == null) return null;
    return AppUser.fromMap(data as Map);
  }
}
