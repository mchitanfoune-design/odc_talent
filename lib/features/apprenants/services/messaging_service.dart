// lib/features/apprenants/services/messaging_service.dart
import 'package:dio/dio.dart';
import 'package:odc_talent/core/network/dio_client.dart';
import 'package:odc_talent/features/apprenants/models/message_model.dart';

class MessagingService {
  final DioClient _dioClient;

  MessagingService({DioClient? dioClient})
      : _dioClient = dioClient ?? DioClient();

  /// Récupérer la conversation 1-to-1 avec un autre utilisateur
  /// GET /api/v1/messages/conversation/{autreUserId}
  Future<List<MessageModel>> getConversation(int autreUserId) async {
    try {
      final response = await _dioClient.dio.get('/messages/conversation/$autreUserId');
      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> data = response.data is List ? response.data : [];
        return data.map((json) => MessageModel.fromJson(json)).toList();
      }
      return [];
    } on DioException {
      rethrow;
    }
  }

  /// Récupérer les messages reçus
  /// GET /api/v1/messages/recus
  Future<List<MessageModel>> getMessagesRecus() async {
    try {
      final response = await _dioClient.dio.get('/messages/recus');
      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> data = response.data is List ? response.data : [];
        return data.map((json) => MessageModel.fromJson(json)).toList();
      }
      return [];
    } on DioException {
      rethrow;
    }
  }

  /// Envoyer un message (direct ou groupé)
  /// POST /api/v1/messages
  Future<void> sendMessage({int? destinataireId, String? promotionCible, required String contenu}) async {
    try {
      await _dioClient.dio.post(
        '/messages',
        data: {
          if (destinataireId != null) 'destinataireId': destinataireId,
          if (promotionCible != null) 'promotionCible': promotionCible,
          'contenu': contenu,
        },
      );
    } on DioException {
      rethrow;
    }
  }
}