class Actualite {
  final int? id;
  final String titre;
  final String description;
  final String date;
  final String? badge;
  final String? category;
  final String? author;
  final String? image;

  Actualite({
    this.id,
    required this.titre,
    required this.description,
    required this.date,
    this.badge,
    this.category,
    this.author,
    this.image,
  });

  factory Actualite.fromJson(Map<String, dynamic> json) {
    return Actualite(
      id: json['id'] is int ? json['id'] : (json['id'] is String ? int.tryParse(json['id']) : null),
      // Supporte à la fois title (Spring Boot entity) et titre (fallback)
      titre: json['title'] ?? json['titre'] ?? '',
      description: json['description'] ?? '',
      // Supporte publicationDate (Spring Boot entity) et date
      date: json['publicationDate'] ?? json['date'] ?? 'Récemment',
      badge: json['badge'] ?? 'ODC',
      category: json['category'],
      author: json['author'] ?? 'Admin ODC',
      // Supporte imageUrl (Spring Boot entity) et image
      image: json['imageUrl'] ?? json['image'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'title': titre,
      'description': description,
      'publicationDate': date,
      if (badge != null) 'badge': badge,
      if (category != null) 'category': category,
      if (author != null) 'author': author,
      if (image != null) 'imageUrl': image,
    };
  }
}
