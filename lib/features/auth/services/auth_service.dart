import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:odc_talent/core/network/dio_client.dart';
import 'package:odc_talent/features/auth/models/auth_response.dart';

class AuthService {
  final DioClient _dioClient;
  final FlutterSecureStorage _secureStorage;

  AuthService({DioClient? dioClient, FlutterSecureStorage? secureStorage})
      : _dioClient = dioClient ?? DioClient(),
        _secureStorage = secureStorage ?? const FlutterSecureStorage();

  // Clés de stockage sécurisé
  static const String keyJwtToken = 'jwt_token';
  static const String keyUserRole = 'user_role';
  static const String keyUserEmail = 'user_email';
  static const String keyUserNom = 'user_nom';
  static const String keyUserPrenom = 'user_prenom';

  /// Effectue la connexion auprès de Spring Boot
  /// POST /api/v1/auth/login
  Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dioClient.dio.post(
        '/auth/login',
        data: {
          'email': email,
          'password': password,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final authData = AuthResponse.fromJson(response.data);

        // Sauvegarde du token JWT et des infos utilisateur dans le stockage sécurisé
        await _secureStorage.write(key: keyJwtToken, value: authData.token);
        await _secureStorage.write(key: keyUserRole, value: authData.role);
        await _secureStorage.write(key: keyUserEmail, value: authData.email);
        await _secureStorage.write(key: keyUserNom, value: authData.nom);
        await _secureStorage.write(key: keyUserPrenom, value: authData.prenom);

        return authData;
      } else {
        throw Exception('Échec de connexion : code ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.response != null && e.response?.data != null) {
        final data = e.response!.data;
        if (data is Map && data.containsKey('message')) {
          throw Exception(data['message']);
        }
      }
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw Exception('Délai d\'attente dépassé. Vérifiez votre connexion.');
      }
      if (e.type == DioExceptionType.connectionError) {
        throw Exception('Impossible de joindre le serveur Spring Boot.');
      }
      throw Exception('Identifiants incorrects ou serveur indisponible.');
    } catch (e) {
      rethrow;
    }
  }

  /// Inscription d'un apprenant auprès de Spring Boot
  /// POST /api/v1/auth/register
  Future<AuthResponse> register({
    required String nom,
    required String prenom,
    required String email,
    required String telephone,
    required String password,
    String role = 'APPRENANT',
  }) async {
    try {
      final response = await _dioClient.dio.post(
        '/auth/register',
        data: {
          'nom': nom,
          'prenom': prenom,
          'email': email,
          'telephone': telephone,
          'motDePasse': password,
          'role': role,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return AuthResponse.fromJson(response.data);
      } else {
        throw Exception('Échec de l\'inscription : code ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.response?.data != null && e.response?.data is Map) {
        final data = e.response!.data;
        if (data.containsKey('message')) {
          throw Exception(data['message']);
        }
      }
      if (e.type == DioExceptionType.connectionTimeout) {
        throw Exception('Délai de connexion dépassé.');
      }
      throw Exception('Une erreur est survenue lors de l\'inscription.');
    }
  }

  /// Déconnexion : suppression des données de session
  Future<void> logout() async {
    await _secureStorage.deleteAll();
  }

  /// Récupère le token actuel s'il existe
  Future<String?> getToken() async {
    return await _secureStorage.read(key: keyJwtToken);
  }

  /// Vérifie si l'utilisateur est déjà connecté
  Future<bool> isAuthenticated() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }
}
