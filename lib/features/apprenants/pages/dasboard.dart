import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:odc_talent/features/apprenants/pages/portfolio.dart';
import 'package:odc_talent/features/apprenants/services/dashboardService.dart';

class DashboardApprenantPage extends StatefulWidget {
  const DashboardApprenantPage({Key? key}) : super(key: key);

  @override
  State<DashboardApprenantPage> createState() => _DashboardApprenantPageState();
}

class _DashboardApprenantPageState extends State<DashboardApprenantPage> {
  bool _isLoading = true;
  String _prenom = "Mohamed";

  // Liste des actualités envoyées par l'Admin (avec fallback par défaut)
  List<dynamic> _actualites = [
    {
      "titre": "Cérémonie de graduation",
      "description": "Félicitations à la nouvelle promotion des apprenants ODC.",
      "date": "Aujourd'hui",
      "image": "assets/images/graduation.png"
    },
    {
      "titre": "Nouvelle Formation",
      "description": "DevOPS pratique avec Docker et CI/CD: De l'application au deploiement",
      "date": "Il y a 2 jours",
      "image": "assets/images/devops.png"
    },
    {
      "titre": "Une visite de l'APEJ à ODC",
      "description": "Une visite riche en échanges autour des programmes d'ODC et des opportunités",
      "date": "Il y a 3 jours",
      "image": "assets/images/apej.png"
    }
  ];

  static const Color _primaryOrange = Color(0xFFFF6501);

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    try {
      final response = await DashboardService.getActualites();
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          _actualites = data;
        });
      }
    } catch (e) {
      // Conservation des données locales si le serveur hors-ligne
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ==========================================
              // 1. EN-TÊTE : LOGO, CLOCHE NOTIFICATION & AVATAR
              // ==========================================
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Image.asset(
                    'assets/images/logo.jpg',
                    height: 45,
                  ),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3F4F6),
                        shape: BoxShape.circle,
                        ),
                        child: Stack(
                          children: [
                            const Icon(Icons.notifications_none_rounded, color: Colors.black87, size: 24),
                            Positioned(
                              right: 2,
                              top: 2,
                              child: Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: _primaryOrange,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      const CircleAvatar(
                        radius: 20,
                        backgroundImage: AssetImage('assets/images/profile.jpg'),
                      ),
                    ],
                  )
                ],
              ),

              const SizedBox(height: 24),

              // ==========================================
              // 2. SALUTATION APPRENANT
              // ==========================================
              Row(
                children: [
                  Text(
                    'Bonjour $_prenom',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text('👋', style: TextStyle(fontSize: 22)),
                ],
              ),
              const SizedBox(height: 4),
              const Text(
                'Bienvenue sur votre espace apprenant ODC',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF6B7280),
                ),
              ),

              const SizedBox(height: 24),

              // ==========================================
              // 3. CARTE BANNIÈRE PORTFOLIO (EN HAUT)
              // ==========================================
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: _primaryOrange,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Row(
                  children: [
                    Expanded(
                      flex: 6,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Valorisez vos compétences et trouvez de nouvelles opportunités !',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              height: 1.3,
                            ),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1F2937),
                              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              elevation: 0,
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const PortfolioScreen(),
                                ),
                              );
                            },
                            child: const Text(
                              'Voir mon portfolio',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      flex: 4,
                      child: Image.asset(
                        'assets/images/banner_illustration.png', // Image de l'illustration fille au bureau
                        fit: BoxFit.contain,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // ==========================================
              // 4. SECTION ACTUALITÉS ADMIN (EN BAS)
              // ==========================================
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Actualités',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      // Action Voir Tout Actualités
                    },
                    child: const Text(
                      'Voir tout',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: _primaryOrange,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Liste des cartes d'actualités
              _isLoading
                  ? const Center(child: CircularProgressIndicator(color: _primaryOrange))
                  : ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _actualites.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 14),
                      itemBuilder: (context, index) {
                        final item = _actualites[index];
                        return _buildActualiteCard(
                          titre: item["titre"] ?? '',
                          description: item["description"] ?? '',
                          date: item["date"] ?? '',
                          imagePath: item["image"] ?? 'assets/images/placeholder.png',
                        );
                      },
                    ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),

      // ==========================================
      // 5. BARRE DE NAVIGATION INFÉRIEURE
      // ==========================================
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0, // Sélectionné sur "Accueil"
        type: BottomNavigationBarType.fixed,
        selectedItemColor: _primaryOrange,
        unselectedItemColor: Colors.grey,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
        unselectedLabelStyle: const TextStyle(fontSize: 12),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Accueil'),
          BottomNavigationBarItem(icon: Icon(Icons.menu_book_outlined), label: 'Projets'),
          BottomNavigationBarItem(icon: Icon(Icons.work_outline), label: 'Opportunités'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profil'),
        ],
      ),
    );
  }

  // Widget Réutilisable : Carte d'actualité envoyé par Admin
  Widget _buildActualiteCard({
    required String titre,
    required String description,
    required String date,
    required String imagePath,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image d'actualité avec bords arrondis
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: 80,
              height: 80,
              color: Colors.grey.shade200,
              child: Image.asset(
                imagePath,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.image, color: Colors.grey),
              ),
            ),
          ),
          const SizedBox(width: 14),

          // Contenu Texte (Titre, Description, Date)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titre,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF6B7280),
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  date,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: _primaryOrange,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}