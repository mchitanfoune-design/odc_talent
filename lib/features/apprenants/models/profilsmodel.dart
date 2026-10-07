class ProfilModel {
  final int idProfil;
  final String nomDuProfil;
  final String prenomDuProfil;
  final String email;
  final String telephone;

  ProfilModel({
    required this.idProfil,
    required this.nomDuProfil,
    required this.prenomDuProfil,
    required this.email,
    required this.telephone,
  });

  // Factory pour désérialiser depuis le JSON (API REST)
  factory ProfilModel.fromJson(Map<String, dynamic> json) {
    return ProfilModel(
      idProfil: json['idprofil'] as int? ?? json['idProfil'] as int,
      nomDuProfil: json['nomDuProfil'] as String? ?? '',
      prenomDuProfil: json['prenomDuProfil'] as String? ?? '',
      email: json['email'] as String? ?? '',
      telephone: json['telephone'] as String? ?? '',
    );
  }

  // Conversion de l'objet en JSON pour l'envoi vers l'API
  Map<String, dynamic> toJson() {
    return {
      'idProfil': idProfil,
      'nomDuProfil': nomDuProfil,
      'prenomDuProfil': prenomDuProfil,
      'email': email,
      'telephone': telephone,
    };
  }

  // Méthode copyWith pour la gestion d'état (State Management)
  ProfilModel copyWith({
    int? idProfil,
    String? nomDuProfil,
    String? prenomDuProfil,
    String? email,
    String? telephone,
  }) {
    return ProfilModel(
      idProfil: idProfil ?? this.idProfil,
      nomDuProfil: nomDuProfil ?? this.nomDuProfil,
      prenomDuProfil: prenomDuProfil ?? this.prenomDuProfil,
      email: email ?? this.email,
      telephone: telephone ?? this.telephone,
    );
  }

  // Getter pratique pour afficher le nom complet dans l'UI Flutter
  String get nomComplet => '$prenomDuProfil $nomDuProfil'.trim();
}