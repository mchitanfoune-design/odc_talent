import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  // Adresse IP de l'émulateur Android vers Spring Boot local
  static const String baseUrl = 'http://10.0.2.2:8080/api/v1/auth';

  // Méthode de Connexion (Login)
  static Future<http.Response> login({
    required String email,
    required String password,
  }) async {
    final Uri url = Uri.parse('$baseUrl/login');

    return await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );
  }

  // Méthode d'Inscription (Register)
  static Future<http.Response> registerApprenant({
    required String prenom,
    required String nom,
    required String email,
    required String telephone,
    required String role,
    required String promotion,
    required String formation,
  }) async {
    final Uri url = Uri.parse('$baseUrl/register');

    return await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({
        'prenom': prenom,
        'nom': nom,
        'email': email,
        'telephone': telephone,
        'role': role,
        'promotion': promotion,
        'formation': formation,
      }),
    );
  }
}