import 'package:flutter/material.dart';
import 'package:odc_talent/core/constants/constant.dart';
import 'package:odc_talent/features/apprenants/models/portfolio_response_model.dart';
import 'package:odc_talent/features/apprenants/pages/evolution_pro.dart';
import 'package:odc_talent/features/apprenants/pages/mes_candidatures.dart';
import 'package:odc_talent/features/apprenants/pages/mes_projets.dart';
import 'package:odc_talent/features/apprenants/pages/notifications.dart';
import 'package:odc_talent/features/apprenants/pages/portfolio.dart';
import 'package:odc_talent/features/apprenants/services/dashboardService.dart';
import 'package:odc_talent/features/apprenants/services/disponibilite_state.dart';
import 'package:odc_talent/features/apprenants/services/portfolio.dart';
import 'package:odc_talent/features/auth/services/CompExp.dart';
import 'package:odc_talent/features/auth/services/auth_service.dart';

class ProfilApprenantPage extends StatefulWidget {
  const ProfilApprenantPage({Key? key}) : super(key: key);

  @override
  State<ProfilApprenantPage> createState() => _ProfilApprenantPageState();
}

class _ProfilApprenantPageState extends State<ProfilApprenantPage> {
  final DashboardService _dashboardService = DashboardService();
  final PortfolioService _portfolioService = PortfolioService();
  final CompExpApiService _compExpService = CompExpApiService();
  final AuthService _authService = AuthService();

  bool _isLoading = true;
  bool _isAvailable = DisponibiliteState.current;

  String _prenom = "";
  String _nom = "";
  String _email = "";
  String _role = "";
  String _titreProfessionnel = "Apprenant ODC";

  PortfolioResponseModel? _portfolio;

  static const Color primaryOrange = AppColors.primaryOrange;
  static const Color darkNavy = Color(0xFF03152F);

  @override
  void initState() {
    super.initState();
    DisponibiliteState.load();
    _isAvailable = DisponibiliteState.current;
    DisponibiliteState.notifier.addListener(_onDisponibiliteChanged);
    _loadProfileData();
  }

  void _onDisponibiliteChanged() {
    if (!mounted) return;
    setState(() => _isAvailable = DisponibiliteState.current);
  }

  @override
  void dispose() {
    DisponibiliteState.notifier.removeListener(_onDisponibiliteChanged);
    super.dispose();
  }

  Future<void> _loadProfileData() async {
    setState(() => _isLoading = true);

    try {
      final session = await _dashboardService.getUserSession();
      _prenom = session['prenom'] ?? '';
      _nom = session['nom'] ?? '';
      _email = session['email'] ?? '';
      _role = session['role'] ?? 'APPRENANT';

      final portfolio = await _portfolioService.getMyPortfolio();
      if (portfolio != null) {
        _portfolio = portfolio;
        if (portfolio.prenomApprenant.isNotEmpty) _prenom = portfolio.prenomApprenant;
        if (portfolio.nomApprenant.isNotEmpty) _nom = portfolio.nomApprenant;
        if (portfolio.emailApprenant.isNotEmpty) _email = portfolio.emailApprenant;
        if (portfolio.titreProfessionnel.isNotEmpty) _titreProfessionnel = portfolio.titreProfessionnel;
      }
    } catch (_) {
      // Conservation des données locales
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _toggleDisponibilite(bool value) async {
    setState(() => _isAvailable = value);
    await DisponibiliteState.set(value);

    try {
      await _compExpService.saveCompetencesAndExperiences(
        aPropos: _portfolio?.bio ?? "Apprenant Orange Digital Center",
        experiences: "Formation ODC",
        competences: _portfolio?.competences ?? "Flutter, Dart, Spring Boot",
        titreProfessionnel: _titreProfessionnel,
        disponibilite: value,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(value ? 'Statut : Disponible pour opportunités' : 'Statut : Actuellement indisponible'),
            backgroundColor: value ? const Color(0xFF10B981) : Colors.grey.shade800,
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (_) {
      setState(() => _isAvailable = !value);
      await DisponibiliteState.set(!value);
    }
  }

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
              backgroundColor: primaryOrange,
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

  String _getInitials() {
    String p = _prenom.isNotEmpty ? _prenom[0].toUpperCase() : 'O';
    String n = _nom.isNotEmpty ? _nom[0].toUpperCase() : 'D';
    return '$p$n';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        title: const Text(
          'Mon Profil',
          style: TextStyle(color: Colors.black, fontSize: 22, fontWeight: FontWeight.bold),
        ),
      ),
      body: RefreshIndicator(
        color: primaryOrange,
        onRefresh: _loadProfileData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Column(
            children: [
              // ==========================================
              // 1. CARTE PROFIL HEADER
              // ==========================================
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: Colors.grey.shade200),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 12,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Avatar dynamique
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [primaryOrange, Color(0xFFFF9248)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(color: primaryOrange.withOpacity(0.25), blurRadius: 8, offset: const Offset(0, 3)),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          _getInitials(),
                          style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Nom complet
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${_prenom.isNotEmpty ? _prenom : "Apprenant"} $_nom'.trim(),
                          style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold, color: Colors.black87),
                        ),
                        const SizedBox(width: 6),
                        const Icon(Icons.verified, color: primaryOrange, size: 18),
                      ],
                    ),
                    const SizedBox(height: 4),

                    Text(
                      _titreProfessionnel,
                      style: const TextStyle(fontSize: 14, color: primaryOrange, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),

                    Text(
                      _email.isNotEmpty ? _email : 'apprenant@odc.com',
                      style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                    ),
                    const SizedBox(height: 12),

                    // Badge Rôle ODC
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Orange Digital Center • ${_role.isNotEmpty ? _role : "APPRENANT"}',
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF475569)),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // ==========================================
              // 2. TOGGLE DISPONIBILITÉ
              // ==========================================
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: Colors.grey.shade200),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.02),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: _isAvailable ? const Color(0xFF10B981).withOpacity(0.12) : Colors.grey.shade100,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            _isAvailable ? Icons.check_circle_outline : Icons.pause_circle_outline,
                            color: _isAvailable ? const Color(0xFF10B981) : Colors.grey,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Disponibilité', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                            Text(
                              _isAvailable ? 'Visible pour missions et recrutements' : 'Non disponible pour le moment',
                              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Switch(
                      value: _isAvailable,
                      activeColor: primaryOrange,
                      onChanged: _toggleDisponibilite,
                      activeTrackColor: primaryOrange.withOpacity(0.25),
                      inactiveTrackColor: Colors.grey.shade300,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // ==========================================
              // 3. MENU DES RUBRIQUES PRINCIPALES
              // ==========================================
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.grey.shade200),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.02),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _buildMenuItem(
                      icon: Icons.person_pin_rounded,
                      title: 'Mon Portfolio Public',
                      subtitle: 'Consulter et enrichir mon portfolio',
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const PortfolioScreen()));
                      },
                    ),
                    _buildDivider(),
                    _buildMenuItem(
                      icon: Icons.folder_special_outlined,
                      title: 'Mes Projets Réalisés',
                      subtitle: 'Gérer mes réalisations et liens démo',
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const MesProjetsPage()));
                      },
                    ),
                    _buildDivider(),
                    _buildMenuItem(
                      icon: Icons.trending_up_rounded,
                      title: 'Mon Évolution Professionnelle',
                      subtitle: 'Suivi de carrière et insertion post-ODC',
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const EvolutionProPage()));
                      },
                    ),
                    _buildDivider(),
                    _buildMenuItem(
                      icon: Icons.work_outline_rounded,
                      title: 'Mes Candidatures',
                      subtitle: 'Suivre l\'état de mes candidatures',
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const MesCandidaturesPage()));
                      },
                    ),
                    _buildDivider(),
                    _buildMenuItem(
                      icon: Icons.notifications_none_rounded,
                      title: 'Notifications & Messages',
                      subtitle: 'Échanges avec les recruteurs et ODC',
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsPage()));
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // ==========================================
              // 4. BOUTON DE DÉCONNEXION & INFOS APP
              // ==========================================
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.logout, color: Colors.red, size: 18),
                  label: const Text('Se déconnecter', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.red),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: _handleLogout,
                ),
              ),
              const SizedBox(height: 16),

              Text(
                'ODCTalent v1.0.0 • Orange Digital Center',
                style: TextStyle(color: Colors.grey.shade400, fontSize: 11),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: primaryOrange.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: primaryOrange, size: 20),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
      subtitle: Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
      trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey),
    );
  }

  Widget _buildDivider() {
    return Divider(height: 1, indent: 60, endIndent: 16, color: Colors.grey.shade200);
  }
}
