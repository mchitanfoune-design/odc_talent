class EvolutionProModel {
  final int? id;
  final String poste;
  final String entreprise;
  final String statutEmploi; // CDI, CDD, STAGE, FREELANCE, etc.
  final String localisation;
  final String? dateDebut;
  final String? dateFin;
  final String? remarquesAdmin;

  EvolutionProModel({
    this.id,
    required this.poste,
    required this.entreprise,
    required this.statutEmploi,
    required this.localisation,
    this.dateDebut,
    this.dateFin,
    this.remarquesAdmin,
  });

  factory EvolutionProModel.fromJson(Map<String, dynamic> json) {
    return EvolutionProModel(
      id: json['id'] is int ? json['id'] : (json['id'] is String ? int.tryParse(json['id']) : null),
      poste: json['poste'] ?? json['post'] ?? '',
      entreprise: json['entreprise'] ?? '',
      statutEmploi: json['statutEmploi'] ?? 'CDI',
      localisation: json['localisation'] ?? 'Bamako, Mali',
      dateDebut: json['dateDebut']?.toString(),
      dateFin: json['dateFin']?.toString(),
      remarquesAdmin: json['remarquesAdmin'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'poste': poste,
      'entreprise': entreprise,
      'statutEmploi': statutEmploi,
      'localisation': localisation,
      if (dateDebut != null) 'dateDebut': dateDebut,
      if (dateFin != null) 'dateFin': dateFin,
      if (remarquesAdmin != null) 'remarquesAdmin': remarquesAdmin,
    };
  }

  bool get isCurrentJob => dateFin == null || dateFin!.isEmpty;
}
