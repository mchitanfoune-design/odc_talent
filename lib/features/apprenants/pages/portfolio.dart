import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:odc_talent/features/apprenants/services/portfolio.dart';

class PortfolioScreen extends StatefulWidget {
  const PortfolioScreen({Key? key}) : super(key: key);

  @override
  State<PortfolioScreen> createState() => _PortfolioScreenState();
}


class _PortfolioScreenState extends State<PortfolioScreen> {
  bool _isLoading = true;
  String _selectedLanguage = 'Français';

  // Données dynamiques du portfolio avec valeurs par défaut
  Map<String, dynamic> _portfolioData = {
    "nom": "Mohamed Coulibaly",
    "titre": "Développeur Web",
    "descriptionCourte": "Je crée des solutions digitales modernes et performantes.",
    "email": "alex.martin@gmail.com",
    "localisation": "Mali_Bamako",
    "disponibilite": "Disponible",
    "aPropos": "Passionné par le développement web, je conçois et développe des applications et sites web pour répondre aux besoins des utilisateurs.",
    "experiences": [
      {
        "role": "Développeur Web",
        "periode": "2023 - 2025",
        "description": "Création et maintenance de sites web et d'applications."
      }
    ],
    "competences": [
      "HTML", "CSS", "JavaScript", "React",
      "PHP", "MySQL", "Git", "Node.js"
    ],
    "projets": [
      "assets/images/project1.png",
      "assets/images/project2.png"
    ]
  };

  @override
  void initState() {
    super.initState();
    _fetchPortfolioData();
  }

  // Récupération des données depuis Spring Boot
  Future<void> _fetchPortfolioData() async {
    try {
      final response = await PortfolioService.getPortfolio();

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _portfolioData = data;
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      // En cas d'erreur réseau, on conserve les données de secours locales
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color darkNavy = Color(0xFF03152F);
    const Color primaryOrange = Color(0xFFFF6501);

    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: CircularProgressIndicator(color: primaryOrange),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Column(
            children: [
              // ==========================================
              // 1. HEADER BLEU NUIT (INFO PROFIL)
              // ==========================================
              Container(
                color: darkNavy,
                padding: const EdgeInsets.only(
                  top: 50,
                  left: 20,
                  right: 20,
                  bottom: 24,
                ),
                child: Column(
                  children: [
                    // Barre supérieure : Retour + Switcher de Langue
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back, color: Colors.white),
                          onPressed: () => Navigator.pop(context),
                        ),
                        _buildLanguageToggle(),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Photo + Nom + Rôle
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Avatar Rond
                        Container(
                          width: 85,
                          height: 85,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                            image: const DecorationImage(
                              image: AssetImage('assets/images/profile.jpg'), // Ajuste l'image de profil
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _portfolioData["nom"] ?? '',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _portfolioData["titre"] ?? '',
                                style: const TextStyle(
                                  color: Color(0xFF3B82F6),
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                _portfolioData["descriptionCourte"] ?? '',
                                style: const TextStyle(
                                  color: Color(0xFF94A3B8),
                                  fontSize: 13,
                                  height: 1.3,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Badges d'infos (Email, Localisation, Disponibilité)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildHeaderMeta(Icons.mail_outline, _portfolioData["email"] ?? ''),
                        _buildHeaderMeta(Icons.location_on_outlined, _portfolioData["localisation"] ?? ''),
                        _buildHeaderMeta(Icons.person_outline, _portfolioData["disponibilite"] ?? ''),
                      ],
                    ),
                  ],
                ),
              ),

              // ==========================================
              // 2. CORPS DE LA PAGE (CARTES ET SECTIONS)
              // ==========================================
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Section À propos
                    _buildAboutCard(_portfolioData["aPropos"] ?? ''),
                    const SizedBox(height: 24),

                    // Section Expériences
                    _buildSectionHeader(Icons.business_center_outlined, 'Expériences'),
                    const SizedBox(height: 12),
                    ...(_portfolioData["experiences"] as List).map(
                      (exp) => _buildExperienceCard(
                        exp["role"] ?? '',
                        exp["periode"] ?? '',
                        exp["description"] ?? '',
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Section Compétences
                    _buildSectionHeader(Icons.star_outline_rounded, 'Compétences'),
                    const SizedBox(height: 12),
                    _buildSkillsWrap(_portfolioData["competences"] as List),
                    const SizedBox(height: 24),

                    // Section Projets
                    _buildSectionHeader(Icons.folder_open_rounded, 'Projets'),
                    const SizedBox(height: 12),
                    _buildProjectsList(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),

      // ==========================================
      // 3. BARRE DE NAVIGATION INFÉRIEURE
      // ==========================================
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 3, // Sélectionné sur "Profil"
        type: BottomNavigationBarType.fixed,
        selectedItemColor: primaryOrange,
        unselectedItemColor: Colors.grey,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
        unselectedLabelStyle: const TextStyle(fontSize: 12),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Accueil'),
          BottomNavigationBarItem(icon: Icon(Icons.menu_book_outlined), label: 'Projets'),
          BottomNavigationBarItem(icon: Icon(Icons.work_outline), label: 'Opportunités'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
    );
  }

  // Widget : Switcher Français / Anglais
  Widget _buildLanguageToggle() {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          _buildLangButton('Français'),
          _buildLangButton('Anglais'),
        ],
      ),
    );
  }

  Widget _buildLangButton(String lang) {
    bool isSelected = _selectedLanguage == lang;
    return GestureDetector(
      onTap: () => setState(() => _selectedLanguage = lang),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? Colors.black : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          lang,
          style: TextStyle(
            color: isSelected ? Colors.white : const Color(0xFFFF9800),
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderMeta(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF94A3B8), size: 16),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildAboutCard(String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: Color(0xFFE2E8F0),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.person_outline, color: Color(0xFF3B82F6), size: 20),
              ),
              const SizedBox(width: 12),
              const Text(
                'À propos',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            text,
            style: const TextStyle(color: Color(0xFF64748B), fontSize: 14, height: 1.4),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(IconData icon, String title) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF3B82F6), size: 22),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
        ),
      ],
    );
  }

  Widget _buildExperienceCard(String role, String periode, String description) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF0F172A),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.code, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  role,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
                ),
                const SizedBox(height: 2),
                Text(
                  periode,
                  style: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
                ),
                const SizedBox(height: 6),
                Text(
                  description,
                  style: const TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkillsWrap(List skills) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: skills.map((skill) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.cancel_outlined, size: 16, color: Colors.redAccent),
              const SizedBox(width: 6),
              Text(
                skill.toString(),
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black87),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildProjectsList() {
    return SizedBox(
      height: 160,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildProjectItem('assets/images/project1.png'),
          const SizedBox(width: 12),
          _buildProjectItem('assets/images/project2.png'),
        ],
      ),
    );
  }

  Widget _buildProjectItem(String imagePath) {
    return Container(
      width: 240,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.grey.shade300,
        image: DecorationImage(
          image: AssetImage(imagePath),
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}