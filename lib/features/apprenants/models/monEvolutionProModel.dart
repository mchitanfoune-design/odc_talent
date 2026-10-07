enum StatutEmploi {
  CDI,
  CDD,
  STAGE,
  FREELANCE,
  
}


class MonEvolutionProModel {
  final int idEvolution;
  final String poste; // Renommé 'poste' pour corriger la coquille de 'post'
  final String entreprise;
  final String localisation;
  final StatutEmploi statutEmploi;
  final DateTime dateDeCommencement;
  final DateTime? dateDeFin; // Nullable si l'emploi est toujours en cours

  MonEvolutionProModel({
    required this.idEvolution,
    required this.poste,
    required this.entreprise,
    required this.localisation,
    required this.statutEmploi,
    required this.dateDeCommencement,
    this.dateDeFin,
  });

  // Factory pour la désérialisation depuis l'API REST
  factory MonEvolutionProModel.fromJson(Map<String, dynamic> json) {
    return MonEvolutionProModel(
      idEvolution: json['idEvolution'] as int,
      poste: json['post'] ?? json['poste'] as String? ?? '',
      entreprise: json['entreprise'] as String? ?? '',
      localisation: json['localisation'] as String? ?? '',
      statutEmploi: StatutEmploi.values.firstWhere(
        (e) => e.name == json['statutEmploi'],
        orElse: () => StatutEmploi.CDI,
      ),
      dateDeCommencement: json['dateDecommencement'] != null
          ? DateTime.parse(json['dateDecommencement'].toString())
          : DateTime.now(),
      dateDeFin: json['dateDuFin'] != null
          ? DateTime.parse(json['dateDuFin'].toString())
          : null,
    );
  }

  // Conversion en JSON pour l'envoi vers l'API
  Map<String, dynamic> toJson() {
    return {
      'idEvolution': idEvolution,
      'post': poste,
      'entreprise': entreprise,
      'localisation': localisation,
      'statutEmploi': statutEmploi.name,
      'dateDecommencement': dateDeCommencement.toIso8601String(),
      'dateDuFin': dateDeFin?.toIso8601String(),
    };
  }

  // Méthode copyWith pour la gestion d'état
  MonEvolutionProModel copyWith({
    int? idEvolution,
    String? poste,
    String? entreprise,
    String? localisation,
    StatutEmploi? statutEmploi,
    DateTime? dateDeCommencement,
    DateTime? dateDeFin,
  }) {
    return MonEvolutionProModel(
      idEvolution: idEvolution ?? this.idEvolution,
      poste: poste ?? this.poste,
      entreprise: entreprise ?? this.entreprise,
      localisation: localisation ?? this.localisation,
      statutEmploi: statutEmploi ?? this.statutEmploi,
      dateDeCommencement: dateDeCommencement ?? this.dateDeCommencement,
      dateDeFin: dateDeFin ?? this.dateDeFin,
    );
  }

  // Propriété pratique pour savoir si c'est le poste actuel
  bool get estPosteActuel => dateDeFin == null;
}