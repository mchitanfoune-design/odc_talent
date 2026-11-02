class PortfolioResponseModel {
  final int? id;
  final String bio;
  final String titreProfessionnel;
  final String? githubUrl;
  final String? linkedinUrl;
  final String? websiteUrl;
  final String competences;
  final int? apprenantId;
  final String nomApprenant;
  final String prenomApprenant;
  final String emailApprenant;
  final String? photoProfil;

  PortfolioResponseModel({
    this.id,
    required this.bio,
    required this.titreProfessionnel,
    this.githubUrl,
    this.linkedinUrl,
    this.websiteUrl,
    required this.competences,
    this.apprenantId,
    required this.nomApprenant,
    required this.prenomApprenant,
    required this.emailApprenant,
    this.photoProfil,
  });

  factory PortfolioResponseModel.fromJson(Map<String, dynamic> json) {
    return PortfolioResponseModel(
      id: json['id'] is int ? json['id'] : (json['id'] is String ? int.tryParse(json['id']) : null),
      bio: json['bio'] ?? '',
      titreProfessionnel: json['titreProfessionnel'] ?? 'Apprenant ODC',
      githubUrl: json['githubUrl'],
      linkedinUrl: json['linkedinUrl'],
      websiteUrl: json['websiteUrl'],
      competences: json['competences'] ?? '',
      apprenantId: json['apprenantId'] is int
          ? json['apprenantId']
          : (json['apprenantId'] is String ? int.tryParse(json['apprenantId']) : null),
      nomApprenant: json['nomApprenant'] ?? '',
      prenomApprenant: json['prenomApprenant'] ?? '',
      emailApprenant: json['emailApprenant'] ?? '',
      photoProfil: json['photoProfil'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'bio': bio,
      'titreProfessionnel': titreProfessionnel,
      if (githubUrl != null) 'githubUrl': githubUrl,
      if (linkedinUrl != null) 'linkedinUrl': linkedinUrl,
      if (websiteUrl != null) 'websiteUrl': websiteUrl,
      'competences': competences,
      if (apprenantId != null) 'apprenantId': apprenantId,
      'nomApprenant': nomApprenant,
      'prenomApprenant': prenomApprenant,
      'emailApprenant': emailApprenant,
      if (photoProfil != null) 'photoProfil': photoProfil,
    };
  }

  List<String> get competencesList {
    if (competences.trim().isEmpty) return [];
    return competences
        .split(RegExp(r'[,;]'))
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
  }
}
