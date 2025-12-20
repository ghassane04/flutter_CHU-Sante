class LoginRequest {
  final String username;
  final String password;

  LoginRequest({
    required this.username,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'password': password,
    };
  }
}

class SignupRequest {
  final String username;
  final String password;
  final String email;
  final String nom;
  final String prenom;

  SignupRequest({
    required this.username,
    required this.password,
    required this.email,
    required this.nom,
    required this.prenom,
  });

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'password': password,
      'email': email,
      'nom': nom,
      'prenom': prenom,
    };
  }
}

class JwtResponse {
  final String token;
  final int id;
  final String username;
  final String email;

  JwtResponse({
    required this.token,
    required this.id,
    required this.username,
    required this.email,
  });

  factory JwtResponse.fromJson(Map<String, dynamic> json) {
    return JwtResponse(
      token: json['token'] ?? '',
      id: json['id'] ?? 0,
      username: json['username'] ?? '',
      email: json['email'] ?? '',
    );
  }
}

class MessageResponse {
  final String message;

  MessageResponse({required this.message});

  factory MessageResponse.fromJson(Map<String, dynamic> json) {
    return MessageResponse(
      message: json['message'] ?? '',
    );
  }
}
