class CandidatureItemModel {
  final int? id;
  final String lettreMotivation;
  final double? tarifPropose;
  final String statut;
  final String? dateCandidature;
  final int? missionId;
  final String? titreMission;

  CandidatureItemModel({
    this.id,
    required this.lettreMotivation,
    this.tarifPropose,
    required this.statut,
    this.dateCandidature,
    this.missionId,
    this.titreMission,
  });

  factory CandidatureItemModel.fromJson(Map<String, dynamic> json) {
    return CandidatureItemModel(
      id: json['id'] is int ? json['id'] : (json['id'] is String ? int.tryParse(json['id']) : null),
      lettreMotivation: json['lettreMotivation'] ?? '',
      tarifPropose: json['tarifPropose'] is num ? (json['tarifPropose'] as num).toDouble() : null,
      statut: json['statut'] ?? 'EN_ATTENTE',
      dateCandidature: json['dateCandidature']?.toString(),
      missionId: json['missionId'] is int
          ? json['missionId']
          : (json['missionId'] is String ? int.tryParse(json['missionId']) : null),
      titreMission: json['titreMission'],
    );
  }
}
