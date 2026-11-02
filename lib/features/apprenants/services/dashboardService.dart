import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:odc_talent/core/network/dio_client.dart';
import 'package:odc_talent/features/apprenants/models/actualite_model.dart';
import 'package:odc_talent/features/auth/services/auth_service.dart';

class DashboardService {
  final DioClient _dioClient;
  final FlutterSecureStorage _secureStorage;

  DashboardService({DioClient? dioClient, FlutterSecureStorage? secureStorage})
      : _dioClient = dioClient ?? DioClient(),
        _secureStorage = secureStorage ?? const FlutterSecureStorage();

  /// Récupère la session utilisateur stockée localement lors du Login
  Future<Map<String, String>> getUserSession() async {
    final prenom = await _secureStorage.read(key: AuthService.keyUserPrenom) ?? '';
    final nom = await _secureStorage.read(key: AuthService.keyUserNom) ?? '';
    final email = await _secureStorage.read(key: AuthService.keyUserEmail) ?? '';
    final role = await _secureStorage.read(key: AuthService.keyUserRole) ?? '';

    return {
      'prenom': prenom,
      'nom': nom,
      'email': email,
      'role': role,
    };
  }

  /// Récupère la liste des actualités depuis Spring Boot
  /// GET /api/v1/actualites
  Future<List<Actualite>> getActualites() async {
    try {
      final response = await _dioClient.dio.get('/actualites');

      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> data = response.data is List ? response.data : [];
        return data.map((json) => Actualite.fromJson(json)).toList();
      }
      return [];
    } on DioException {
      rethrow;
    }
  }

  /// Récupère le portfolio et profil de l'apprenant connecté
  /// GET /api/v1/portfolios/me
  Future<Map<String, dynamic>?> getMyPortfolio() async {
    try {
      final response = await _dioClient.dio.get('/portfolios/me');
      if (response.statusCode == 200 && response.data != null) {
        return response.data as Map<String, dynamic>;
      }
      return null;
    } catch (_) {
      return null;
    }
  }
}
