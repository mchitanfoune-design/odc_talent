import 'dart:convert';
import 'package:http/http.dart' as http;

class PortfolioService {
  // Adresse IP de l'émulateur Android vers Spring Boot local (remplace par ton URL/IP en prod)
  static const String baseUrl = 'http://10.0.2.2:8080/api/v1/portfolio';

  /// 1. Créer ou mettre à jour le portfolio (Formulaire d'expériences & compétences)
  static Future<http.Response> createPortfolio({
    required String aPropos,
    required String experiences,
    required String competences,
    String? token, // Passe le JWT si l'endpoint est sécurisé
  }) async {
    final Uri url = Uri.parse(baseUrl);

    final Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };

    final String body = jsonEncode({
      'aPropos': aPropos,
      'experiences': experiences,
      'competences': competences,
    });

    return await http.post(url, headers: headers, body: body);
  }

  /// 2. Récupérer les données du portfolio généré (Pour la page d'affichage du Portfolio)
  static Future<http.Response> getPortfolio({String? token}) async {
    final Uri url = Uri.parse(baseUrl);

    final Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };

    return await http.get(url, headers: headers);
  }

  /// 3. Récupérer un portfolio par ID d'apprenant
  static Future<http.Response> getPortfolioByApprenantId(int apprenantId, {String? token}) async {
    final Uri url = Uri.parse('$baseUrl/apprenant/$apprenantId');

    final Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };

    return await http.get(url, headers: headers);
  }
}