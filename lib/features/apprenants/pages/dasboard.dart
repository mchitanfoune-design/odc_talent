import 'package:flutter/material.dart';
import 'package:odc_talent/core/constants/constant.dart';
import 'package:odc_talent/features/apprenants/models/actualite_model.dart';
import 'package:odc_talent/features/apprenants/pages/evolution_pro.dart';
import 'package:odc_talent/features/apprenants/pages/mes_projets.dart';
import 'package:odc_talent/features/apprenants/pages/notifications.dart';
import 'package:odc_talent/features/apprenants/pages/opportunites.dart';
import 'package:odc_talent/features/apprenants/pages/portfolio.dart';
import 'package:odc_talent/features/apprenants/pages/profil.dart';
import 'package:odc_talent/features/apprenants/services/dashboardService.dart';
import 'package:odc_talent/features/auth/services/auth_service.dart';

class DashboardApprenantPage extends StatefulWidget {
  const DashboardApprenantPage({Key? key}) : super(key: key);

  @override
  State<DashboardApprenantPage> createState() => _DashboardApprenantPageState();
}

class _DashboardApprenantPageState extends State<DashboardApprenantPage> {
  final DashboardService _dashboardService = DashboardService();
  final AuthService _authService = AuthService();

  bool _isLoading = true;
  String? _errorMessage;

  // Données dynamiques de l'utilisateur
  String _prenom = "";
  String _nom = "";
  String _email = "";
  String _role = "";
  String? _titreProfessionnel;
  String? _photoProfil;

  // Liste dynamique des actualités
  List<Actualite> _actualites = [];

  int _currentNavIndex = 0;
  static const Color _primaryOrange = AppColors.primaryOrange;

  @override
  void initState() {
    super.initState();
    _initDashboard();
  }

  /// Chargement initial des données
  Future<void> _initDashboard() async {
    await _loadUserData();
    await _loadActualites();
  }

  /// Récupération des informations de session et du portfolio Spring Boot
  Future<void> _loadUserData() async {
    try {
      // 1. Chargement instantané depuis le stockage sécurisé (rempli au Login)
      final session = await _dashboardService.getUserSession();
      if (mounted) {
        setState(() {
          _prenom = session['prenom'] ?? '';
          _nom = session['nom'] ?? '';
          _email = session['email'] ?? '';
          _role = session['role'] ?? 'APPRENANT';
        });
      }

      // 2. Enrichissement en temps réel via GET /api/v1/portfolios/me de Spring Boot
      final myPortfolio = await _dashboardService.getMyPortfolio();
      if (myPortfolio != null && mounted) {
        setState(() {
          if (myPortfolio['prenomApprenant'] != null && myPortfolio['prenomApprenant'].toString().isNotEmpty) {
            _prenom = myPortfolio['prenomApprenant'];
          }
          if (myPortfolio['nomApprenant'] != null && myPortfolio['nomApprenant'].toString().isNotEmpty) {
            _nom = myPortfolio['nomApprenant'];
          }
          if (myPortfolio['emailApprenant'] != null && myPortfolio['emailApprenant'].toString().isNotEmpty) {
            _email = myPortfolio['emailApprenant'];
          }
          _titreProfessionnel = myPortfolio['titreProfessionnel'];
          _photoProfil = myPortfolio['photoProfil'];
        });
      }
    } catch (_) {
      // Conservation des données du stockage sécurisé
    }
  }

  /// Récupération des actualités depuis GET /api/v1/actualites de Spring Boot
  Future<void> _loadActualites() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final actualites = await _dashboardService.getActualites();
      if (mounted) {
        setState(() {
          _actualites = actualites;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = "Impossible de joindre le serveur pour les actualités.";
          // Fallback informatif élégant si le backend est vide ou inaccessible
          if (_actualites.isEmpty) {
            _actualites = [
              Actualite(
                titre: "Cérémonie de graduation",
                description: "Félicitations à la nouvelle promotion des apprenants Orange Digital Center.",
                date: "Aujourd'hui",
                badge: "Événement",
              ),
              Actualite(
                titre: "Nouvelle Formation DevOps",
                description: "DevOps pratique avec Docker et CI/CD : de l'application au déploiement.",
                date: "Il y a 2 jours",
                badge: "Formation",
              ),
              Actualite(
                titre: "Partenariat & Recrutement ODC",
                description: "Rencontrez les entreprises partenaires pour des opportunités de stage et d'embauche.",
                date: "Il y a 3 jours",
                badge: "Opportunités",
              ),
            ];
          }
        });
      }
    }
  }

  /// Déconnexion sécurisée
  Future<void> _handleLogout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Déconnexion'),
        content: const Text('Voulez-vous vraiment vous déconnecter de votre compte ODCTalent ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: _primaryOrange,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Déconnexion', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _authService.logout();
      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    }
  }

  /// Modal Profil Utilisateur
  void _showUserProfileDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        contentPadding: const EdgeInsets.all(24),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 36,
              backgroundColor: _primaryOrange.withOpacity(0.15),
              child: Text(
                _getInitials(),
                style: const TextStyle(
                  color: _primaryOrange,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '${_prenom.isNotEmpty ? _prenom : "Apprenant"} $_nom'.trim(),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            if (_titreProfessionnel != null && _titreProfessionnel!.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                _titreProfessionnel!,
                style: const TextStyle(fontSize: 14, color: _primaryOrange, fontWeight: FontWeight.w500),
                textAlign: TextAlign.center,
              ),
            ],
            if (_email.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                _email,
                style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                textAlign: TextAlign.center,
              ),
            ],
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: _primaryOrange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _role.isNotEmpty ? _role : 'APPRENANT ODC',
                style: const TextStyle(
                  color: _primaryOrange,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.trending_up_rounded, color: Colors.white, size: 18),
                label: const Text('Mon Évolution Professionnelle', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primaryOrange,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const EvolutionProPage()),
                  );
                },
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                icon: const Icon(Icons.logout, color: Colors.red, size: 18),
                label: const Text('Se déconnecter', style: TextStyle(color: Colors.red)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.red),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                onPressed: () {
                  Navigator.pop(context);
                  _handleLogout();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getInitials() {
    String p = _prenom.isNotEmpty ? _prenom[0].toUpperCase() : 'O';
    String n = _nom.isNotEmpty ? _nom[0].toUpperCase() : 'D';
    return '$p$n';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: RefreshIndicator(
          color: _primaryOrange,
          onRefresh: _initDashboard,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 14.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ==========================================
                // 1. EN-TÊTE : LOGO, NOTIFICATIONS & AVATAR
                // ==========================================
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Image.asset(
                      'assets/images/logo.jpg',
                      height: 42,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => const Text(
                        'ODCTalent',
                        style: TextStyle(
                          color: _primaryOrange,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        // Cloche notification
                        InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const NotificationsPage()),
                            );
                          },
                          borderRadius: BorderRadius.circular(25),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(
                              color: Color(0xFFF3F4F6),
                              shape: BoxShape.circle,
                            ),
                            child: Stack(
                              clipBehavior: Clip.none,
                              children: [
                                const Icon(
                                  Icons.notifications_none_rounded,
                                  color: Colors.black87,
                                  size: 22,
                                ),
                                Positioned(
                                  right: 0,
                                  top: 0,
                                  child: Container(
                                    width: 8,
                                    height: 8,
                                    decoration: const BoxDecoration(
                                      color: _primaryOrange,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),

                        // Avatar dynamique cliquable
                        GestureDetector(
                          onTap: _showUserProfileDialog,
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [_primaryOrange, Color(0xFFFF9248)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: _primaryOrange.withOpacity(0.25),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Text(
                                _getInitials(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 22),

                // ==========================================
                // 2. SALUTATION APPRENANT DYNAMIQUE
                // ==========================================
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        _prenom.isNotEmpty ? 'Bonjour $_prenom 👋' : 'Bonjour 👋',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          letterSpacing: -0.5,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  _titreProfessionnel != null && _titreProfessionnel!.isNotEmpty
                      ? '$_titreProfessionnel • Orange Digital Center'
                      : 'Bienvenue sur votre espace apprenant ODC',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),

                const SizedBox(height: 22),

                // ==========================================
                // 3. CARTE BANNIÈRE PORTFOLIO
                // ==========================================
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [_primaryOrange, Color(0xFFFF7E26)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: [
                      BoxShadow(
                        color: _primaryOrange.withOpacity(0.25),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
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
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                height: 1.3,
                              ),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF111827),
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
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 4,
                        child: Container(
                          height: 95,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.school_rounded,
                            size: 48,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 28),

                // ==========================================
                // 4. SECTION ACTUALITÉS DYNAMIQUE
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
                    InkWell(
                      onTap: _loadActualites,
                      borderRadius: BorderRadius.circular(8),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                        child: Row(
                          children: const [
                            Icon(Icons.refresh_rounded, size: 16, color: _primaryOrange),
                            SizedBox(width: 4),
                            Text(
                              'Actualiser',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: _primaryOrange,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                if (_errorMessage != null) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.orange.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, size: 18, color: Colors.orange.shade800),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: TextStyle(fontSize: 12, color: Colors.orange.shade900),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 16),

                // Liste des cartes actualités
                if (_isLoading)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 40),
                    child: Center(
                      child: CircularProgressIndicator(color: _primaryOrange),
                    ),
                  )
                else if (_actualites.isEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF9FAFB),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE5E7EB)),
                    ),
                    child: Column(
                      children: [
                        Icon(Icons.feed_outlined, size: 44, color: Colors.grey.shade400),
                        const SizedBox(height: 12),
                        const Text(
                          'Aucune actualité pour le moment',
                          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Tenez-vous prêt pour les prochaines annonces d\'Orange Digital Center.',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  )
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _actualites.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 14),
                    itemBuilder: (context, index) {
                      final item = _actualites[index];
                      return _buildActualiteCard(item);
                    },
                  ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),

      // ==========================================
      // 5. BARRE DE NAVIGATION INFÉRIEURE
      // ==========================================
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentNavIndex,
        onTap: (index) {
          setState(() => _currentNavIndex = index);
          if (index == 3) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ProfilApprenantPage()),
            );
          } else if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const OpportunitesPage()),
            );
          } else if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const MesProjetsPage()),
            );
          }
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: _primaryOrange,
        unselectedItemColor: Colors.grey.shade400,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
        unselectedLabelStyle: const TextStyle(fontSize: 12),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: 'Accueil'),
          BottomNavigationBarItem(icon: Icon(Icons.folder_outlined), label: 'Projets'),
          BottomNavigationBarItem(icon: Icon(Icons.work_outline), label: 'Opportunités'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profil'),
        ],
      ),
    );
  }

  // Widget Réutilisable : Carte d'actualité dynamique
  Widget _buildActualiteCard(Actualite actualite) {
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
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: 80,
              height: 80,
              color: const Color(0xFFFFF7ED),
              child: _buildActualiteImage(actualite.image),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (actualite.badge != null && actualite.badge!.isNotEmpty) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    margin: const EdgeInsets.only(bottom: 4),
                    decoration: BoxDecoration(
                      color: _primaryOrange.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      actualite.badge!,
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: _primaryOrange,
                      ),
                    ),
                  ),
                ],
                Text(
                  actualite.titre,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  actualite.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.calendar_today_outlined, size: 12, color: _primaryOrange),
                    const SizedBox(width: 4),
                    Text(
                      actualite.date,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: _primaryOrange,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActualiteImage(String? imagePath) {
    if (imagePath != null && (imagePath.startsWith('http://') || imagePath.startsWith('https://'))) {
      return Image.network(
        imagePath,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => const Icon(Icons.newspaper_rounded, color: _primaryOrange, size: 30),
      );
    }
    return const Icon(
      Icons.newspaper_rounded,
      color: _primaryOrange,
      size: 32,
    );
  }
}
