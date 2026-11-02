class ProjetResponseModel {
  final int? id;
  final String titre;
  final String description;
  final String? imageUrl;
  final String? githubUrl;
  final String? demoUrl;
  final String technologies;
  final String? dateCreation;
  final int? portfolioId;

  ProjetResponseModel({
    this.id,
    required this.titre,
    required this.description,
    this.imageUrl,
    this.githubUrl,
    this.demoUrl,
    required this.technologies,
    this.dateCreation,
    this.portfolioId,
  });

  factory ProjetResponseModel.fromJson(Map<String, dynamic> json) {
    return ProjetResponseModel(
      id: json['id'] is int ? json['id'] : (json['id'] is String ? int.tryParse(json['id']) : null),
      titre: json['titre'] ?? '',
      description: json['description'] ?? '',
      imageUrl: json['imageUrl'] ?? json['image'],
      githubUrl: json['githubUrl'],
      demoUrl: json['demoUrl'],
      technologies: json['technologies'] ?? '',
      dateCreation: json['dateCreation']?.toString(),
      portfolioId: json['portfolioId'] is int
          ? json['portfolioId']
          : (json['portfolioId'] is String ? int.tryParse(json['portfolioId']) : null),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'titre': titre,
      'description': description,
      if (imageUrl != null) 'imageUrl': imageUrl,
      if (githubUrl != null) 'githubUrl': githubUrl,
      if (demoUrl != null) 'demoUrl': demoUrl,
      'technologies': technologies,
      if (dateCreation != null) 'dateCreation': dateCreation,
      if (portfolioId != null) 'portfolioId': portfolioId,
    };
  }

  List<String> get technologiesList {
    if (technologies.trim().isEmpty) return [];
    return technologies
        .split(RegExp(r'[,;]'))
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
  }
}
