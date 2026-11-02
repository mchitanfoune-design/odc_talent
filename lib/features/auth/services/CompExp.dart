import 'package:dio/dio.dart';
import 'package:odc_talent/core/network/dio_client.dart';

class CompExpApiService {
  final DioClient _dioClient;

  CompExpApiService({DioClient? dioClient}) : _dioClient = dioClient ?? DioClient();

  /// Enregistre les compétences, expériences et la biographie auprès de Spring Boot
  Future<void> saveCompetencesAndExperiences({
    required String aPropos,
    required String experiences,
    required String competences,
    String? titreProfessionnel,
    bool disponibilite = true,
  }) async {
    final List<String> competencesList = competences
        .split(RegExp(r'[,;]'))
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();

    try {
      // 1. Mise à jour du profil apprenant (PUT /api/v1/apprenants/profile)
      await _dioClient.dio.put(
        '/apprenants/profile',
        data: {
          'biographie': aPropos,
          'experiences': experiences,
          'competences': competencesList,
          'disponibilite': disponibilite,
        },
      );

      // 2. Synchronisation du portfolio (PUT /api/v1/portfolios/me)
      await _dioClient.dio.put(
        '/portfolios/me',
        data: {
          'bio': aPropos,
          'competences': competences,
          'titreProfessionnel': titreProfessionnel ?? 'Développeur Web & Mobile',
        },
      );
    } on DioException catch (e) {
      if (e.response?.data != null && e.response?.data is Map) {
        final data = e.response!.data;
        if (data.containsKey('message')) {
          throw Exception(data['message']);
        }
      }
      throw Exception('Impossible d\'enregistrer vos compétences.');
    }
  }
}
