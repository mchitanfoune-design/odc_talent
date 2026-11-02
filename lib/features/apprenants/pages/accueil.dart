import 'package:flutter/material.dart';
import 'package:odc_talent/core/constants/constant.dart';
import 'package:odc_talent/features/apprenants/models/actualite_model.dart';
import 'package:odc_talent/features/apprenants/models/mission_model.dart';
import 'package:odc_talent/features/apprenants/models/projet_response_model.dart';
import 'package:odc_talent/features/apprenants/pages/detail_freelance.dart';
import 'package:odc_talent/features/apprenants/pages/freelance.dart';
import 'package:odc_talent/features/apprenants/pages/mes_projets.dart';
import 'package:odc_talent/features/apprenants/pages/opportunites.dart';
import 'package:odc_talent/features/apprenants/pages/portfolio.dart';
import 'package:odc_talent/features/apprenants/services/dashboardService.dart';
import 'package:odc_talent/features/apprenants/services/opportunite_service.dart';
import 'package:odc_talent/features/apprenants/services/projet_service.dart';

class AccueilApprenantPage extends StatefulWidget {
  const AccueilApprenantPage({Key? key}) : super(key: key);

  @override
  State<AccueilApprenantPage> createState() => _AccueilApprenantPageState();
}

class _AccueilApprenantPageState extends State<AccueilApprenantPage> {
  final DashboardService _dashboardService = DashboardService();
  final OpportuniteService _opportuniteService = OpportuniteService();
  final ProjetApiService _projetApiService = ProjetApiService();

  bool _isLoading = true;
  String _prenom = '';
  String _nom = '';
  String _role = 'APPRENANT';
  List<Actualite> _actualites = [];
  List<MissionModel> _missions = [];
  List<ProjetResponseModel> _projets = [];

  static const Color primaryOrange = AppColors.primaryOrange;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      final session = await _dashboardService.getUserSession();
      final actualites = await _dashboardService.getActualites();
      final missions = await _opportuniteService.getMissions();
      final projets = await _projetApiService.getMyProjets();

      if (!mounted) return;

      setState(() {
        _prenom = session['prenom'] ?? '';
        _nom = session['nom'] ?? '';
        _role = session['role'] ?? 'APPRENANT';
        _actualites = actualites;
        _missions = missions.take(3).toList();
        _projets = projets.take(3).toList();
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _prenom = 'Apprenant';
        _nom = 'ODC';
        _role = 'APPRENANT';
        _actualites = [
          Actualite(
            titre: 'Cérémonie de graduation',
            description: 'Félicitations à la nouvelle promotion ODC.',
            date: 'Aujourd\'hui',
            badge: 'Événement',
          ),
          Actualite(
            titre: 'Partenariat ODC',
            description: 'Nouvelles missions disponibles pour les apprenants.',
            date: '2 jours',
            badge: 'Formation',
          ),
        ];
        _missions = [
          MissionModel(
            id: 1,
            titre: 'Développeur Flutter',
            description: 'Refonte UI et intégration API.',
            budget: 250000,
            competencesRequises: 'Flutter, Dart, REST API',
            statut: 'OUVERTE',
            datePublication: '2026-11-01',
            nomRecruteur: 'Orange Digital Center',
          ),
        ];
        _projets = [
          ProjetResponseModel(
            id: 1,
            titre: 'Portfolio ODCTalent',
            description: 'Application mobile pour la gestion de profil et projets.',
            technologies: 'Flutter, Dart, Spring Boot',
            dateCreation: '2026-11-01',
          ),
        ];
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: primaryOrange.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.auto_awesome, color: primaryOrange),
            ),
            const SizedBox(width: 10),
            const Text(
              'ODCTalent',
              style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PortfolioScreen())),
            icon: const Icon(Icons.person_outline_rounded, color: Colors.black87),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: primaryOrange))
          : RefreshIndicator(
              onRefresh: _loadData,
              color: primaryOrange,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeroCard(),
                    const SizedBox(height: 18),
                    _buildQuickActions(),
                    const SizedBox(height: 18),
                    _buildSectionHeader('Actualités', onTap: () {}),
                    const SizedBox(height: 10),
                    if (_actualites.isEmpty)
                      _buildEmptyCard('Aucune actualité à afficher pour le moment.')
                    else
                      ..._actualites.take(3).map((item) => _buildNewsCard(item)),
                    const SizedBox(height: 18),
                    _buildSectionHeader('Missions à suivre'),
                    const SizedBox(height: 10),
                    if (_missions.isEmpty)
                      _buildEmptyCard('Aucune mission disponible pour le moment.')
                    else
                      ..._missions.map((mission) => _buildMissionTile(mission)),
                    const SizedBox(height: 18),
                    _buildSectionHeader('Mes réalisations'),
                    const SizedBox(height: 10),
                    if (_projets.isEmpty)
                      _buildEmptyCard('Aucun projet ajouté pour le moment.')
                    else
                      ..._projets.map((projet) => _buildProjectTile(projet)),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildHeroCard() {
    final greeting = _prenom.isNotEmpty ? 'Bonjour $_prenom 👋' : 'Bonjour 👋';
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          colors: [Color(0xFFFF7A1A), Color(0xFFFF6501)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            greeting,
            style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Continuez votre parcours ODC et développez votre réseau professionnel.',
            style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 14),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _metricChip('Projets', '${_projets.length}'),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _metricChip('Missions', '${_missions.length}'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _metricChip(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          Text(label, style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    final actions = [
      _QuickAction(icon: Icons.person_pin_rounded, label: 'Portfolio', page: const PortfolioScreen()),
      _QuickAction(icon: Icons.folder_open_rounded, label: 'Projets', page: const MesProjetsPage()),
      _QuickAction(icon: Icons.work_outline_rounded, label: 'Freelance', page: const FreelancePage()),
      _QuickAction(icon: Icons.search_rounded, label: 'Missions', page: const OpportunitesPage()),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: actions.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.7,
      ),
      itemBuilder: (context, index) {
        final action = actions[index];
        return InkWell(
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => action.page)),
          borderRadius: BorderRadius.circular(18),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: primaryOrange.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(action.icon, color: primaryOrange),
                ),
                const SizedBox(height: 10),
                Text(action.label, style: const TextStyle(fontWeight: FontWeight.w700)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader(String title, {VoidCallback? onTap}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        if (onTap != null)
          TextButton(onPressed: onTap, child: const Text('Voir tout', style: TextStyle(color: primaryOrange))),
      ],
    );
  }

  Widget _buildNewsCard(Actualite actualite) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                decoration: BoxDecoration(
                  color: primaryOrange.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  actualite.badge ?? 'ODC',
                  style: const TextStyle(color: primaryOrange, fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ),
              const Spacer(),
              Text(
                actualite.date ?? 'Aujourd\'hui',
                style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(actualite.titre ?? 'Actualité', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          const SizedBox(height: 6),
          Text(
            actualite.description ?? '',
            style: TextStyle(color: Colors.grey.shade700, height: 1.45),
          ),
        ],
      ),
    );
  }

  Widget _buildMissionTile(MissionModel mission) {
    return InkWell(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => DetailFreelancePage(mission: mission)),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    mission.titre,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    mission.statut ?? 'OUVERTE',
                    style: const TextStyle(color: Color(0xFF10B981), fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              mission.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: Colors.grey.shade700, height: 1.4),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: mission.competencesList.take(3).map((skill) => Chip(label: Text(skill), visualDensity: VisualDensity.compact)).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProjectTile(ProjetResponseModel projet) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: primaryOrange.withOpacity(0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.apps_rounded, color: primaryOrange),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(projet.titre, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                const SizedBox(height: 4),
                Text(
                  projet.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Colors.grey.shade700, height: 1.4),
                ),
                const SizedBox(height: 6),
                Text(
                  projet.dateCreation ?? 'Récemment',
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyCard(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Text(message, style: TextStyle(color: Colors.grey.shade600)),
    );
  }
}

class _QuickAction {
  final IconData icon;
  final String label;
  final Widget page;

  const _QuickAction({required this.icon, required this.label, required this.page});
}
