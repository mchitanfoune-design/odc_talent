import 'package:dio/dio.dart';
import 'package:odc_talent/core/network/dio_client.dart';
import 'package:odc_talent/features/apprenants/models/portfolio_response_model.dart';
import 'package:odc_talent/features/apprenants/models/projet_response_model.dart';

class PortfolioService {
  final DioClient _dioClient;

  PortfolioService({DioClient? dioClient}) : _dioClient = dioClient ?? DioClient();

  /// 1. Récupérer le portfolio de l'apprenant connecté (GET /api/v1/portfolios/me)
  Future<PortfolioResponseModel?> getMyPortfolio() async {
    try {
      final response = await _dioClient.dio.get('/portfolios/me');
      if (response.statusCode == 200 && response.data != null) {
        return PortfolioResponseModel.fromJson(response.data);
      }
      return null;
    } on DioException catch (e) {
      // 404 : pas encore de portfolio créé pour cet apprenant
      if (e.response?.statusCode == 404) {
        return null;
      }
      rethrow;
    }
  }

  /// 2. Récupérer les projets associés à un portfolio (GET /api/v1/projets/portfolio/{id})
  Future<List<ProjetResponseModel>> getProjetsByPortfolio(int portfolioId) async {
    try {
      final response = await _dioClient.dio.get('/projets/portfolio/$portfolioId');
      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> list = response.data is List ? response.data : [];
        return list.map((json) => ProjetResponseModel.fromJson(json)).toList();
      }
      return [];
    } on DioException {
      return [];
    }
  }

  /// 3. Mettre à jour le portfolio (PUT /api/v1/portfolios/me)
  Future<PortfolioResponseModel> updateMyPortfolio({
    required String titreProfessionnel,
    required String bio,
    String? githubUrl,
    String? linkedinUrl,
    String? websiteUrl,
    required String competences,
    String? photoProfil,
  }) async {
    try {
      final response = await _dioClient.dio.put(
        '/portfolios/me',
        data: {
          'titreProfessionnel': titreProfessionnel,
          'bio': bio,
          if (githubUrl != null) 'githubUrl': githubUrl,
          if (linkedinUrl != null) 'linkedinUrl': linkedinUrl,
          if (websiteUrl != null) 'websiteUrl': websiteUrl,
          'competences': competences,
          if (photoProfil != null) 'photoProfil': photoProfil,
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        return PortfolioResponseModel.fromJson(response.data);
      }
      throw Exception('Échec de la mise à jour du portfolio');
    } on DioException catch (e) {
      if (e.response?.data != null && e.response?.data is Map) {
        final data = e.response!.data;
        if (data.containsKey('message')) {
          throw Exception(data['message']);
        }
      }
      throw Exception('Impossible de mettre à jour le portfolio');
    }
  }

  /// 4. Ajouter un projet au portfolio (POST /api/v1/projets)
  Future<ProjetResponseModel> addProjet({
    required String titre,
    required String description,
    String? imageUrl,
    String? githubUrl,
    String? demoUrl,
    required String technologies,
  }) async {
    try {
      final response = await _dioClient.dio.post(
        '/projets',
        data: {
          'titre': titre,
          'description': description,
          if (imageUrl != null) 'imageUrl': imageUrl,
          if (githubUrl != null) 'githubUrl': githubUrl,
          if (demoUrl != null) 'demoUrl': demoUrl,
          'technologies': technologies,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return ProjetResponseModel.fromJson(response.data);
      }
      throw Exception('Échec de l\'ajout du projet');
    } catch (e) {
      rethrow;
    }
  }

  /// 5. Supprimer un projet (DELETE /api/v1/projets/{id})
  Future<void> deleteProjet(int projetId) async {
    await _dioClient.dio.delete('/projets/$projetId');
  }
}
