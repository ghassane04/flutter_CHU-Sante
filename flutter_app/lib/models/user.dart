class User {
  final int id;
  final String username;
  final String email;
  final String? nom;
  final String? prenom;
  final bool enabled;
  final List<Role>? roles;
  final DateTime? createdAt;

  User({
    required this.id,
    required this.username,
    required this.email,
    this.nom,
    this.prenom,
    this.enabled = true,
    this.roles,
    this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      nom: json['nom'],
      prenom: json['prenom'],
      enabled: json['enabled'] ?? true,
      roles: json['roles'] != null 
          ? (json['roles'] as List).map((r) => Role.fromJson(r)).toList()
          : null,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      if (nom != null) 'nom': nom,
      if (prenom != null) 'prenom': prenom,
      'enabled': enabled,
      if (roles != null) 'roles': roles!.map((r) => r.toJson()).toList(),
    };
  }
}

class Role {
  final int id;
  final String name;
  final String? description;

  Role({
    required this.id,
    required this.name,
    this.description,
  });

  factory Role.fromJson(Map<String, dynamic> json) {
    return Role(
      id: json['id'],
      name: json['name'] ?? '',
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      if (description != null) 'description': description,
    };
  }
}
