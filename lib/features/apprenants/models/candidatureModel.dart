enum TypeMission {
  FREELANCE,
  OPPORTUNITE,
}




class CandidatureModel {
  final int idMission;
  final String nomDuMission;
  final String typeDuMission;
  final String localisation;

  CandidatureModel({
    required this.idMission,
    required this.nomDuMission,
    required this.typeDuMission,
    required this.localisation,
  });

  // Factory pour désérialiser depuis le JSON (API REST)
  factory CandidatureModel.fromJson(Map<String, dynamic> json) {
    return CandidatureModel(
      idMission: json['idMission'] as int? ?? json['idmission'] as int,
      nomDuMission: json['nomDuMission'] as String? ?? json['nomdumission'] as String? ?? '',
      typeDuMission: json['typeDuMission'] as String? ?? json['typedumission'] as String? ?? '',
      localisation: json['localisation'] as String? ?? '',
    );
  }

  // Conversion de l'objet en JSON pour l'envoi vers l'API
  Map<String, dynamic> toJson() {
    return {
      'idMission': idMission,
      'nomDuMission': nomDuMission,
      'typeDuMission': typeDuMission,
      'localisation': localisation,
    };
  }

  // Méthode copyWith pour la gestion d'état (State Management)
  CandidatureModel copyWith({
    int? idMission,
    String? nomDuMission,
    String? typeDuMission,
    String? localisation,
  }) {
    return CandidatureModel(
      idMission: idMission ?? this.idMission,
      nomDuMission: nomDuMission ?? this.nomDuMission,
      typeDuMission: typeDuMission ?? this.typeDuMission,
      localisation: localisation ?? this.localisation,
    );
  }
}