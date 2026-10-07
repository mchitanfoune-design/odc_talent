class ProjetModel {
  final int idProjet;
  final String nomDuProjet;
  final String description;
  final DateTime dateDeCreation;
  final String image;
  final String lienDemo;
  final String technologiesUtilisees;

  ProjetModel({
    required this.idProjet,
    required this.nomDuProjet,
    required this.description,
    required this.dateDeCreation,
    required this.image,
    required this.lienDemo,
    required this.technologiesUtilisees,
  });

  // Factory pour désérialiser depuis le JSON (API REST)
  factory ProjetModel.fromJson(Map<String, dynamic> json) {
    return ProjetModel(
      idProjet: json['idprojet'] as int? ?? json['idProjet'] as int,
      nomDuProjet: json['nomduprojet'] as String? ?? json['nomDuProjet'] as String? ?? '',
      description: json['descrption'] as String? ?? json['description'] as String? ?? '',
      dateDeCreation: json['datedecreation'] != null
          ? DateTime.parse(json['datedecreation'].toString())
          : DateTime.now(),
      image: json['image'] as String? ?? '',
      lienDemo: json['lienDemo'] as String? ?? json['liendemo'] as String? ?? '',
      technologiesUtilisees: json['technologieutilisées'] as String? ??
          json['technologiesUtilisees'] as String? ?? '',
    );
  }

  // Conversion de l'objet en JSON pour l'envoi vers l'API
  Map<String, dynamic> toJson() {
    return {
      'idProjet': idProjet,
      'nomDuProjet': nomDuProjet,
      'description': description,
      'dateDeCreation': dateDeCreation.toIso8601String(),
      'image': image,
      'lienDemo': lienDemo,
      'technologiesUtilisees': technologiesUtilisees,
    };
  }

  // Méthode copyWith pour la gestion d'état (State Management)
  ProjetModel copyWith({
    int? idProjet,
    String? nomDuProjet,
    String? description,
    DateTime? dateDeCreation,
    String? image,
    String? lienDemo,
    String? technologiesUtilisees,
  }) {
    return ProjetModel(
      idProjet: idProjet ?? this.idProjet,
      nomDuProjet: nomDuProjet ?? this.nomDuProjet,
      description: description ?? this.description,
      dateDeCreation: dateDeCreation ?? this.dateDeCreation,
      image: image ?? this.image,
      lienDemo: lienDemo ?? this.lienDemo,
      technologiesUtilisees: technologiesUtilisees ?? this.technologiesUtilisees,
    );
  }

  // Getter pratique pour transformer les technologies en liste de tags/badges dans Flutter
  List<String> get listeTechnologies {
    if (technologiesUtilisees.isEmpty) return [];
    return technologiesUtilisees.split(',').map((tech) => tech.trim()).toList();
  }
}