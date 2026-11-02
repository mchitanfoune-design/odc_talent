class MessageModel {
  final int id;
  final int? expediteurId;
  final String? nomExpediteur;
  final String? prenomExpediteur;
  final int? destinataireId;
  final String? nomDestinataire;
  final String? prenomDestinataire;
  final String? promotionCible;
  final String contenu;
  final String? dateEnvoi;
  final bool lu;

  MessageModel({
    required this.id,
    this.expediteurId,
    this.nomExpediteur,
    this.prenomExpediteur,
    this.destinataireId,
    this.nomDestinataire,
    this.prenomDestinataire,
    this.promotionCible,
    required this.contenu,
    this.dateEnvoi,
    required this.lu,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id'] ?? 0,
      expediteurId: json['expediteurId'],
      nomExpediteur: json['nomExpediteur'],
      prenomExpediteur: json['prenomExpediteur'],
      destinataireId: json['destinataireId'],
      nomDestinataire: json['nomDestinataire'],
      prenomDestinataire: json['prenomDestinataire'],
      promotionCible: json['promotionCible'],
      contenu: json['contenu'] ?? '',
      dateEnvoi: json['dateEnvoi']?.toString(),
      lu: json['lu'] ?? false,
    );
  }

  String get nomCompletExpediteur {
    final nom = nomExpediteur?.trim();
    final prenom = prenomExpediteur?.trim();

    if ((nom == null || nom.isEmpty) && (prenom == null || prenom.isEmpty)) {
      return 'Expéditeur';
    }
    if (nom == null || nom.isEmpty) return prenom ?? 'Expéditeur';
    if (prenom == null || prenom.isEmpty) return nom;
    return '$prenom $nom';
  }
}