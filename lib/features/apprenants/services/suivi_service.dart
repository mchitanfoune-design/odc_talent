import 'package:dio/dio.dart';
import 'package:odc_talent/core/network/dio_client.dart';
import 'package:odc_talent/features/apprenants/models/evolution_pro_model.dart';

class SuiviApiService {
  final DioClient _dioClient;

  SuiviApiService({DioClient? dioClient}) : _dioClient = dioClient ?? DioClient();

  /// 1. Récupérer mon historique d'insertion professionnelle (GET /api/v1/suivi/me)
  Future<List<EvolutionProModel>> getMonHistorique() async {
    try {
      final response = await _dioClient.dio.get('/suivi/me');
      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> list = response.data is List ? response.data : [];
        return list.map((json) => EvolutionProModel.fromJson(json)).toList();
      }
      return [];
    } on DioException {
      rethrow;
    }
  }

  /// 2. Ajouter une nouvelle situation professionnelle (POST /api/v1/suivi/me)
  Future<EvolutionProModel> ajouterMonEvolution({
    required String poste,
    required String entreprise,
    required String statutEmploi,
    required String localisation,
    required String dateDebut,
    String? dateFin,
  }) async {
    try {
      final response = await _dioClient.dio.post(
        '/suivi/me',
        data: {
          'poste': poste,
          'entreprise': entreprise,
          'statutEmploi': statutEmploi,
          'localisation': localisation,
          'dateDebut': dateDebut,
          if (dateFin != null && dateFin.isNotEmpty) 'dateFin': dateFin,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return EvolutionProModel.fromJson(response.data);
      }
      throw Exception('Erreur lors de l\'enregistrement de votre évolution professionnelle');
    } on DioException catch (e) {
      if (e.response?.data != null && e.response?.data is Map) {
        final data = e.response!.data;
        if (data.containsKey('message')) {
          throw Exception(data['message']);
        }
      }
      throw Exception('Impossible d\'enregistrer votre situation professionnelle.');
    }
  }
}
