class AppUser {
  final String id;
  final String name;
  final String email;
  final String passwordHash;

  AppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.passwordHash,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'email': email,
        'passwordHash': passwordHash,
      };

  factory AppUser.fromMap(Map map) => AppUser(
        id: map['id'] as String,
        name: map['name'] as String,
        email: map['email'] as String,
        passwordHash: map['passwordHash'] as String,
      );
}
