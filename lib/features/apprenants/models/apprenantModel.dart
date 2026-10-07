enum Formation {
  DEVELOPPEMENT_WEB_MOBILE,
  AWS,
}

enum ChoixDuProfil {
  APPRENANT,
  RECRUTEUR,
}

class Apprenant {
  final int id;
  final String nom;
  final String prenom;
  final String telephone;
  final String email;
  final String motDePasse;
  final DateTime dateInscription;
  final Formation formation;
  final ChoixDuProfil choixDuProfil;
  final int promotion;

  Apprenant({
    required this.id,
    required this.nom,
    required this.prenom,
    required this.telephone,
    required this.email,
    required this.motDePasse,
    required this.dateInscription,
    required this.formation,
    required this.choixDuProfil,
    required this.promotion,
  });

  // Factory pour désérialiser depuis du JSON (API REST)
  factory Apprenant.fromJson(Map<String, dynamic> json) {
    return Apprenant(
      id: json['id'] as int,
      nom: json['nom'] as String,
      prenom: json['prenom'] as String,
      telephone: json['telephone'] as String,
      email: json['email'] as String,
      motDePasse: json['motDePasse'] ?? '',
      dateInscription: DateTime.fromMillisecondsSinceEpoch(json['dateInscription']),
      formation: Formation.values.firstWhere(
        (e) => e.toString().split('.').last == json['formation'],
        orElse: () => Formation.DEVELOPPEMENT_WEB_MOBILE,
      ),
      choixDuProfil: ChoixDuProfil.values.firstWhere(
        (e) => e.toString().split('.').last == json['choixDuProfil'],
        orElse: () => ChoixDuProfil.APPRENANT,
      ),
      promotion: json['promotion'] as int,
    );
  }

  // Conversion en JSON pour l'envoi vers l'API
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nom': nom,
      'prenom': prenom,
      'telephone': telephone,
      'email': email,
      'motDePasse': motDePasse,
      'dateInscription': dateInscription.millisecondsSinceEpoch,
      'formation': formation.toString().split('.').last,
      'choixDuProfil': choixDuProfil.toString().split('.').last,
      'promotion': promotion,
    };
  }

  // Méthode copyWith pratique pour la gestion d'état
  Apprenant copyWith({
    int? id,
    String? nom,
    String? prenom,
    String? telephone,
    String? email,
    String? motDePasse,
    DateTime? dateInscription,
    Formation? formation,
    ChoixDuProfil? choixDuProfil,
    int? promotion,
  }) {
    return Apprenant(
      id: id ?? this.id,
      nom: nom ?? this.nom,
      prenom: prenom ?? this.prenom,
      telephone: telephone ?? this.telephone,
      email: email ?? this.email,
      motDePasse: motDePasse ?? this.motDePasse,
      dateInscription: dateInscription ?? this.dateInscription,
      formation: formation ?? this.formation,
      choixDuProfil: choixDuProfil ?? this.choixDuProfil,
      promotion: promotion ?? this.promotion,
    );
  }
}