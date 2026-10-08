import 'dart:convert';
import 'package:http/http.dart' as http;

class DashboardService {
  static const String baseUrl = 'http://10.0.2.2:8080/api/v1';

  /// Récupérer la liste des actualités créées par l'Admin
  static Future<http.Response> getActualites({String? token}) async {
    final Uri url = Uri.parse('$baseUrl/actualites');

    return await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );
  }

  /// Récupérer les informations de l'apprenant connecté
  static Future<http.Response> getApprenantProfile({String? token}) async {
    final Uri url = Uri.parse('$baseUrl/apprenants/me');

    return await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );
  }
}