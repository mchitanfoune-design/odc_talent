enum Disponibilite {
  Disponible,
  NON_DISPONIBLE,
}


class PortfolioModel {
  final int idPortfolio;
  final String aProposDeMoi;
  final String experience;
  final String competence;
  final Disponibilite disponibilite;

  PortfolioModel({
    required this.idPortfolio,
    required this.aProposDeMoi,
    required this.experience,
    required this.competence,
    required this.disponibilite,
  });

  // Factory pour la désérialisation depuis l'API REST (JSON -> PortfolioModel)
  factory PortfolioModel.fromJson(Map<String, dynamic> json) {
    return PortfolioModel(
      idPortfolio: json['idPortfolio'] as int,
      aProposDeMoi: json['aProposDeMoi'] as String? ?? '',
      experience: json['experience'] as String? ?? '',
      competence: json['competence'] as String? ?? '',
      disponibilite: Disponibilite.values.firstWhere(
        (e) => e.name == json['disponibilite'],
        orElse: () => Disponibilite.Disponible,
      ),
    );
  }

  // Conversion de l'objet en JSON pour l'envoi vers l'API
  Map<String, dynamic> toJson() {
    return {
      'idPortfolio': idPortfolio,
      'aProposDeMoi': aProposDeMoi,
      'experience': experience,
      'competence': competence,
      'disponibilite': disponibilite.name,
    };
  }

  // Méthode copyWith pour la mise à jour dynamique dans l'état (State Management)
  PortfolioModel copyWith({
    int? idPortfolio,
    String? aProposDeMoi,
    String? experience,
    String? competence,
    Disponibilite? disponibilite,
  }) {
    return PortfolioModel(
      idPortfolio: idPortfolio ?? this.idPortfolio,
      aProposDeMoi: aProposDeMoi ?? this.aProposDeMoi,
      experience: experience ?? this.experience,
      competence: competence ?? this.competence,
      disponibilite: disponibilite ?? this.disponibilite,
    );
  }
}