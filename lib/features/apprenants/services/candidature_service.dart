// lib/features/apprenants/services/candidature_service.dart
import 'package:dio/dio.dart';
import 'package:odc_talent/core/network/dio_client.dart';
import 'package:odc_talent/features/apprenants/models/candidature_model.dart';

class CandidatureService {
  final DioClient _dioClient;

  CandidatureService({DioClient? dioClient})
      : _dioClient = dioClient ?? DioClient();

  /// Récupérer les candidatures de l'apprenant connecté
  /// GET /api/v1/candidatures/me
  Future<List<CandidatureModel>> getMyCandidatures() async {
    try {
      final response = await _dioClient.dio.get('/candidatures/me');

      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> data = response.data is List ? response.data : [];
        return data.map((json) => CandidatureModel.fromJson(json)).toList();
      }
      return [];
    } on DioException {
      rethrow;
    }
  }

  /// Postuler à une mission
  /// POST /api/v1/candidatures
  Future<void> postuler({
    required int missionId,
    required String lettreMotivation,
    required double tarifPropose,
  }) async {
    try {
      await _dioClient.dio.post(
        '/candidatures',
        data: {
          'missionId': missionId,
          'lettreMotivation': lettreMotivation,
          'tarifPropose': tarifPropose,
        },
      );
    } on DioException {
      rethrow;
    }
  }
}