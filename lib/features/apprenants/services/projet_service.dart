import 'package:dio/dio.dart';
import 'package:odc_talent/core/network/dio_client.dart';
import 'package:odc_talent/features/apprenants/models/portfolio_response_model.dart';
import 'package:odc_talent/features/apprenants/models/projet_response_model.dart';

class ProjetApiService {
  final DioClient _dioClient;

  ProjetApiService({DioClient? dioClient}) : _dioClient = dioClient ?? DioClient();

  /// Récupère le portfolio de l'apprenant connecté pour obtenir son ID
  Future<PortfolioResponseModel?> getMyPortfolio() async {
    try {
      final response = await _dioClient.dio.get('/portfolios/me');
      if (response.statusCode == 200 && response.data != null) {
        return PortfolioResponseModel.fromJson(response.data);
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  /// Récupère la liste des projets du portfolio (GET /api/v1/projets/portfolio/{portfolioId})
  Future<List<ProjetResponseModel>> getMyProjets() async {
    try {
      final portfolio = await getMyPortfolio();
      if (portfolio?.id == null) return [];

      final response = await _dioClient.dio.get('/projets/portfolio/${portfolio!.id}');
      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> list = response.data is List ? response.data : [];
        return list.map((json) => ProjetResponseModel.fromJson(json)).toList();
      }
      return [];
    } on DioException {
      rethrow;
    }
  }

  /// Ajouter un nouveau projet (POST /api/v1/projets)
  Future<ProjetResponseModel> createProjet({
    required String titre,
    required String description,
    required String technologies,
    String? githubUrl,
    String? demoUrl,
    String? imageUrl,
  }) async {
    try {
      final response = await _dioClient.dio.post(
        '/projets',
        data: {
          'titre': titre,
          'description': description,
          'technologies': technologies,
          if (githubUrl != null && githubUrl.isNotEmpty) 'githubUrl': githubUrl,
          if (demoUrl != null && demoUrl.isNotEmpty) 'demoUrl': demoUrl,
          if (imageUrl != null && imageUrl.isNotEmpty) 'imageUrl': imageUrl,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return ProjetResponseModel.fromJson(response.data);
      }
      throw Exception('Erreur lors de la création du projet');
    } on DioException catch (e) {
      if (e.response?.data != null && e.response?.data is Map) {
        final data = e.response!.data;
        if (data.containsKey('message')) {
          throw Exception(data['message']);
        }
      }
      throw Exception('Impossible d\'ajouter le projet. Assurez-vous d\'avoir initialisé votre portfolio.');
    }
  }

  /// Mettre à jour un projet existant (PUT /api/v1/projets/{id})
  Future<ProjetResponseModel> updateProjet({
    required int id,
    required String titre,
    required String description,
    required String technologies,
    String? githubUrl,
    String? demoUrl,
    String? imageUrl,
  }) async {
    try {
      final response = await _dioClient.dio.put(
        '/projets/$id',
        data: {
          'titre': titre,
          'description': description,
          'technologies': technologies,
          if (githubUrl != null) 'githubUrl': githubUrl,
          if (demoUrl != null) 'demoUrl': demoUrl,
          if (imageUrl != null) 'imageUrl': imageUrl,
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        return ProjetResponseModel.fromJson(response.data);
      }
      throw Exception('Erreur lors de la modification du projet');
    } on DioException catch (e) {
      if (e.response?.data != null && e.response?.data is Map) {
        final data = e.response!.data;
        if (data.containsKey('message')) {
          throw Exception(data['message']);
        }
      }
      throw Exception('Impossible de modifier ce projet.');
    }
  }

  /// Supprimer un projet (DELETE /api/v1/projets/{id})
  Future<void> deleteProjet(int id) async {
    try {
      await _dioClient.dio.delete('/projets/$id');
    } on DioException catch (e) {
      if (e.response?.data != null && e.response?.data is Map) {
        final data = e.response!.data;
        if (data.containsKey('message')) {
          throw Exception(data['message']);
        }
      }
      throw Exception('Impossible de supprimer ce projet.');
    }
  }
}
