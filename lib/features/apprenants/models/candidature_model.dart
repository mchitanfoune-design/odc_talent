class CandidatureModel {
  final int id;
  final String? lettreMotivation;
  final double? tarifPropose;
  final String statut;
  final String? dateCandidature;
  final int? missionId;
  final String? titreMission;
  final int? apprenantId;
  final String? nomApprenant;
  final String? prenomApprenant;
  final String? emailApprenant;

  CandidatureModel({
    required this.id,
    this.lettreMotivation,
    this.tarifPropose,
    required this.statut,
    this.dateCandidature,
    this.missionId,
    this.titreMission,
    this.apprenantId,
    this.nomApprenant,
    this.prenomApprenant,
    this.emailApprenant,
  });

  factory CandidatureModel.fromJson(Map<String, dynamic> json) {
    return CandidatureModel(
      id: json['id'],
      lettreMotivation: json['lettreMotivation'],
      tarifPropose: json['tarifPropose'] != null ? (json['tarifPropose'] as num).toDouble() : null,
      statut: json['statut'] ?? 'EN_ATTENTE',
      dateCandidature: json['dateCandidature'],
      missionId: json['missionId'],
      titreMission: json['titreMission'],
      apprenantId: json['apprenantId'],
      nomApprenant: json['nomApprenant'],
      prenomApprenant: json['prenomApprenant'],
      emailApprenant: json['emailApprenant'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'missionId': missionId,
      'lettreMotivation': lettreMotivation,
      'tarifPropose': tarifPropose,
    };
  }
}