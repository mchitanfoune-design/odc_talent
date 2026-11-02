class AuthResponse {
  final String token;
  final String role;
  final String email;
  final String nom;
  final String prenom;

  AuthResponse({
    required this.token,
    required this.role,
    required this.email,
    required this.nom,
    required this.prenom,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      token: json['token'] ?? '',
      role: json['role'] ?? '',
      email: json['email'] ?? '',
      nom: json['nom'] ?? '',
      prenom: json['prenom'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'role': role,
      'email': email,
      'nom': nom,
      'prenom': prenom,
    };
  }
}
