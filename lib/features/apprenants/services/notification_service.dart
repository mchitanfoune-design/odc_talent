import 'package:dio/dio.dart';
import 'package:odc_talent/core/network/dio_client.dart';
import 'package:odc_talent/features/apprenants/models/message_model.dart';
import 'package:odc_talent/features/apprenants/models/notification_model.dart';

class NotificationApiService {
  final DioClient _dioClient;

  NotificationApiService({DioClient? dioClient}) : _dioClient = dioClient ?? DioClient();

  /// 1. Récupérer les notifications de l'utilisateur connecté (GET /api/v1/notifications)
  Future<List<NotificationModel>> getMyNotifications() async {
    try {
      final response = await _dioClient.dio.get('/notifications');
      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> list = response.data is List ? response.data : [];
        return list.map((json) => NotificationModel.fromJson(json)).toList();
      }
      return [];
    } on DioException {
      rethrow;
    }
  }

  /// 2. Marquer une notification comme lue (PATCH /api/v1/notifications/{id}/lire)
  Future<void> marquerCommeLue(int notificationId) async {
    try {
      await _dioClient.dio.patch('/notifications/$notificationId/lire');
    } on DioException {
      rethrow;
    }
  }

  /// 3. Envoyer un message à un recruteur / autre utilisateur (POST /api/v1/messages)
  Future<MessageModel> envoyerMessage({
    required int destinataireId,
    required String contenu,
  }) async {
    try {
      final response = await _dioClient.dio.post(
        '/messages',
        data: {
          'destinataireId': destinataireId,
          'contenu': contenu,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return MessageModel.fromJson(response.data is Map ? response.data : {});
      }
      throw Exception('Erreur lors de l\'envoi du message');
    } on DioException catch (e) {
      throw Exception('Erreur lors de l\'envoi du message : ${e.message}');
    }
  }
}