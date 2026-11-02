class MissionModel {
  final int? id;
  final String titre;
  final String description;
  final double? budget;
  final String competencesRequises;
  final String? statut;
  final String? datePublication;
  final int? recruteurId;
  final String? nomRecruteur;
  final String? prenomRecruteur;
  final String? emailRecruteur;

  MissionModel({
    this.id,
    required this.titre,
    required this.description,
    this.budget,
    required this.competencesRequises,
    this.statut,
    this.datePublication,
    this.recruteurId,
    this.nomRecruteur,
    this.prenomRecruteur,
    this.emailRecruteur,
  });

  factory MissionModel.fromJson(Map<String, dynamic> json) {
    return MissionModel(
      id: json['id'] is int ? json['id'] : (json['id'] is String ? int.tryParse(json['id']) : null),
      titre: json['titre'] ?? '',
      description: json['description'] ?? '',
      budget: json['budget'] is num ? (json['budget'] as num).toDouble() : null,
      competencesRequises: json['competencesRequises'] ?? '',
      statut: json['statut'] ?? 'OUVERTE',
      datePublication: json['datePublication']?.toString(),
      recruteurId: json['recruteurId'] is int
          ? json['recruteurId']
          : (json['recruteurId'] is String ? int.tryParse(json['recruteurId']) : null),
      nomRecruteur: json['nomRecruteur'] ?? '',
      prenomRecruteur: json['prenomRecruteur'] ?? '',
      emailRecruteur: json['emailRecruteur'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'titre': titre,
      'description': description,
      if (budget != null) 'budget': budget,
      'competencesRequises': competencesRequises,
      if (statut != null) 'statut': statut,
      if (datePublication != null) 'datePublication': datePublication,
      if (recruteurId != null) 'recruteurId': recruteurId,
      if (nomRecruteur != null) 'nomRecruteur': nomRecruteur,
      if (prenomRecruteur != null) 'prenomRecruteur': prenomRecruteur,
      if (emailRecruteur != null) 'emailRecruteur': emailRecruteur,
    };
  }

  List<String> get competencesList {
    if (competencesRequises.trim().isEmpty) return [];
    return competencesRequises
        .split(RegExp(r'[,;]'))
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
  }
}
