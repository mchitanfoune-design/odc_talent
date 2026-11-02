class NotificationModel {
  final int id;
  final String titre;
  final String message;
  final String? type;
  final int? referenceId;
  final bool lue;
  final String? dateCreation;

  NotificationModel({
    required this.id,
    required this.titre,
    required this.message,
    this.type,
    this.referenceId,
    required this.lue,
    this.dateCreation,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] ?? 0,
      titre: json['titre'] ?? 'Notification',
      message: json['message'] ?? '',
      type: json['type'],
      referenceId: json['referenceId'] != null ? json['referenceId'] as int : null,
      lue: json['lue'] ?? false,
      dateCreation: json['dateCreation']?.toString(),
    );
  }
}