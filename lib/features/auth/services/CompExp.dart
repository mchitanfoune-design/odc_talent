import 'dart:convert';
import 'package:http/http.dart' as http;

class Compexp {
  static const String baseUrl = 'http://10.0.2.2:8080/api/v1/portfolio';

  /// Envoie les données du formulaire pour créer le portfolio
  static Future<http.Response> createPortfolio({
    required String aPropos,
    required String experiences,
    required String competences,
  }) async {
    final Uri url = Uri.parse(baseUrl);

    return await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        // Ajoute les en-têtes d'autorisation JWT si nécessaire :
        // 'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'aPropos': aPropos,
        'experiences': experiences,
        'competences': competences,
      }),
    );
  }
}