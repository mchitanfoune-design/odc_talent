class ConversationModel {
  final int id;
  final int otherUserId;
  final String otherUserNom;
  final String otherUserPrenom;
  final String? dernierMessage;
  final String? dateDernierMessage;

  ConversationModel({
    required this.id,
    required this.otherUserId,
    required this.otherUserNom,
    required this.otherUserPrenom,
    this.dernierMessage,
    this.dateDernierMessage,
  });

  factory ConversationModel.fromJson(Map<String, dynamic> json) {
    return ConversationModel(
      id: json['id'] ?? 0,
      otherUserId: json['otherUserId'] ?? 0,
      otherUserNom: json['otherUserNom'] ?? '',
      otherUserPrenom: json['otherUserPrenom'] ?? '',
      dernierMessage: json['dernierMessage'],
      dateDernierMessage: json['dateDernierMessage'],
    );
  }
}

class MessageModel {
  final int id;
  final int expediteurId;
  final String contenu;
  final String dateEnvoi;

  MessageModel({
    required this.id,
    required this.expediteurId,
    required this.contenu,
    required this.dateEnvoi,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id'] ?? 0,
      expediteurId: json['expediteurId'] ?? 0,
      contenu: json['contenu'] ?? '',
      dateEnvoi: json['dateEnvoi'] ?? '',
    );
  }
}