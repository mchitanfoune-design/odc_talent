import 'package:dio/dio.dart';
import 'package:odc_talent/core/network/dio_client.dart';
import 'package:odc_talent/features/apprenants/models/candidature_item_model.dart';
import 'package:odc_talent/features/apprenants/models/mission_model.dart';

class OpportuniteService {
  final DioClient _dioClient;

  OpportuniteService({DioClient? dioClient}) : _dioClient = dioClient ?? DioClient();

  /// 1. Récupérer toutes les opportunités (missions) ouvertes (GET /api/v1/missions)
  Future<List<MissionModel>> getMissions() async {
    try {
      final response = await _dioClient.dio.get('/missions');
      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> list = response.data is List ? response.data : [];
        return list.map((json) => MissionModel.fromJson(json)).toList();
      }
      return [];
    } on DioException {
      rethrow;
    }
  }

  /// 2. Récupérer les détails complets d'une opportunité par ID (GET /api/v1/missions/{id})
  Future<MissionModel?> getMissionById(int id) async {
    try {
      final response = await _dioClient.dio.get('/missions/$id');
      if (response.statusCode == 200 && response.data != null) {
        return MissionModel.fromJson(response.data);
      }
      return null;
    } on DioException {
      rethrow;
    }
  }

  /// 3. Postuler à une mission (POST /api/v1/candidatures)
  Future<CandidatureItemModel> postuler({
    required int missionId,
    required String lettreMotivation,
    double? tarifPropose,
  }) async {
    try {
      final response = await _dioClient.dio.post(
        '/candidatures',
        data: {
          'missionId': missionId,
          'lettreMotivation': lettreMotivation,
          if (tarifPropose != null) 'tarifPropose': tarifPropose,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return CandidatureItemModel.fromJson(response.data);
      }
      throw Exception('Erreur lors de l\'envoi de la candidature');
    } on DioException catch (e) {
      if (e.response?.data != null && e.response?.data is Map) {
        final data = e.response!.data;
        if (data.containsKey('message')) {
          throw Exception(data['message']);
        }
      }
      throw Exception('Impossible d\'enregistrer votre candidature');
    }
  }

  /// 4. Récupérer mes candidatures en tant qu'apprenant (GET /api/v1/candidatures/me)
  Future<List<CandidatureItemModel>> getMyCandidatures() async {
    try {
      final response = await _dioClient.dio.get('/candidatures/me');
      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> list = response.data is List ? response.data : [];
        return list.map((json) => CandidatureItemModel.fromJson(json)).toList();
      }
      return [];
    } on DioException {
      return [];
    }
  }
}
