import 'package:flutter/material.dart';
import 'package:odc_talent/core/constants/constant.dart';
import 'package:odc_talent/features/apprenants/models/candidature_item_model.dart';
import 'package:odc_talent/features/apprenants/models/mission_model.dart';
import 'package:odc_talent/features/apprenants/pages/postuler_page.dart';
import 'package:odc_talent/features/apprenants/services/opportunite_service.dart';

class OpportunitesPage extends StatefulWidget {
  const OpportunitesPage({super.key});

  @override
  State<OpportunitesPage> createState() => _OpportunitesPageState();
}

class _OpportunitesPageState extends State<OpportunitesPage> with SingleTickerProviderStateMixin {
  final OpportuniteService _opportuniteService = OpportuniteService();

  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  bool _isLoading = true;
  String? _errorMessage;

  List<MissionModel> _allMissions = [];
  List<MissionModel> _filteredMissions = [];
  List<CandidatureItemModel> _myCandidatures = [];

  static const Color primaryOrange = AppColors.primaryOrange;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final missions = await _opportuniteService.getMissions();
      final candidatures = await _opportuniteService.getMyCandidatures();

      if (mounted) {
        setState(() {
          _allMissions = missions;
          _filteredMissions = missions;
          _myCandidatures = candidatures;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = "Impossible de joindre le serveur pour les opportunités.";
          // Fallback informatif pour tester l'interface
          if (_allMissions.isEmpty) {
            _allMissions = [
              MissionModel(
                id: 1,
                titre: "Développeur Mobile Flutter (Stage/Freelance)",
                description: "Participation à la refonte de l'application mobile et intégration des API REST Spring Boot.",
                budget: 200000,
                competencesRequises: "Flutter, Dart, REST API, Git",
                statut: "OUVERTE",
                datePublication: "2026-11-01",
                nomRecruteur: "Orange Digital Center",
              ),
              MissionModel(
                id: 2,
                titre: "Développeur Backend Java Spring Boot",
                description: "Conception de microservices sécurisés avec JWT, Spring Security et base de données MySQL.",
                budget: 350000,
                competencesRequises: "Java, Spring Boot, MySQL, Docker",
                statut: "OUVERTE",
                datePublication: "2026-10-30",
                nomRecruteur: "Partenaire Télécom",
              ),
            ];
            _filteredMissions = _allMissions;
          }
        });
      }
    }
  }

  void _filterMissions(String query) {
    if (query.trim().isEmpty) {
      setState(() => _filteredMissions = _allMissions);
      return;
    }
    final q = query.toLowerCase();
    setState(() {
      _filteredMissions = _allMissions.where((m) {
        final matchTitre = m.titre.toLowerCase().contains(q);
        final matchDesc = m.description.toLowerCase().contains(q);
        final matchSkills = m.competencesRequises.toLowerCase().contains(q);
        return matchTitre || matchDesc || matchSkills;
      }).toList();
    });
  }

  void _openPostulerModal(MissionModel mission) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => PostulerPage(mission: mission)),
    );
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
          'Opportunités',
          style: TextStyle(color: Colors.black, fontSize: 22, fontWeight: FontWeight.bold),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: primaryOrange,
          unselectedLabelColor: Colors.grey.shade600,
          indicatorColor: primaryOrange,
          indicatorWeight: 3,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          tabs: [
            Tab(text: 'Offres (${_filteredMissions.length})'),
            Tab(text: 'Mes candidatures (${_myCandidatures.length})'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // ==========================================
          // 1. ONGLET : TOUTES LES OFFRES / MISSIONS
          // ==========================================
          RefreshIndicator(
            color: primaryOrange,
            onRefresh: _loadData,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Barre de recherche
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: _filterMissions,
                      decoration: InputDecoration(
                        hintText: 'Rechercher un poste, mot-clé, compétence...',
                        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
                        prefixIcon: const Icon(Icons.search_rounded, color: primaryOrange, size: 22),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear, size: 18),
                                onPressed: () {
                                  _searchController.clear();
                                  _filterMissions('');
                                },
                              )
                            : null,
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),

                  if (_errorMessage != null) ...[
                    const SizedBox(height: 12),
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
                            child: Text(_errorMessage!, style: TextStyle(fontSize: 12, color: Colors.orange.shade900)),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 16),

                  if (_isLoading)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 50),
                      child: Center(child: CircularProgressIndicator(color: primaryOrange)),
                    )
                  else if (_filteredMissions.isEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Column(
                        children: [
                          Icon(Icons.work_off_outlined, size: 48, color: Colors.grey.shade400),
                          const SizedBox(height: 12),
                          const Text('Aucune opportunité trouvée', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          const SizedBox(height: 4),
                          Text('Revenez plus tard ou modifiez vos critères de recherche.', style: TextStyle(fontSize: 12, color: Colors.grey.shade600), textAlign: TextAlign.center),
                        ],
                      ),
                    )
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _filteredMissions.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 14),
                      itemBuilder: (context, index) {
                        final mission = _filteredMissions[index];
                        return _buildMissionCard(mission);
                      },
                    ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),

          // ==========================================
          // 2. ONGLET : MES CANDIDATURES
          // ==========================================
          RefreshIndicator(
            color: primaryOrange,
            onRefresh: _loadData,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: _isLoading
                  ? const Padding(
                      padding: EdgeInsets.symmetric(vertical: 50),
                      child: Center(child: CircularProgressIndicator(color: primaryOrange)),
                    )
                  : _myCandidatures.isEmpty
                      ? Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(32),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: Column(
                            children: [
                              Icon(Icons.assignment_outlined, size: 48, color: Colors.grey.shade400),
                              const SizedBox(height: 12),
                              const Text('Aucune candidature en cours', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                              const SizedBox(height: 4),
                              Text('Consultez les offres disponibles et postulez dès maintenant !', style: TextStyle(fontSize: 12, color: Colors.grey.shade600), textAlign: TextAlign.center),
                            ],
                          ),
                        )
                      : ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _myCandidatures.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final c = _myCandidatures[index];
                            return _buildCandidatureCard(c);
                          },
                        ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget : Carte d'opportunité / mission
  Widget _buildMissionCard(MissionModel mission) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: primaryOrange.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  mission.statut ?? 'OUVERTE',
                  style: const TextStyle(color: primaryOrange, fontWeight: FontWeight.bold, fontSize: 11),
                ),
              ),
              if (mission.budget != null) ...[
                Text(
                  '${mission.budget!.toStringAsFixed(0)} FCFA',
                  style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ],
            ],
          ),
          const SizedBox(height: 10),

          Text(
            mission.titre,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
          ),
          const SizedBox(height: 4),

          if (mission.nomRecruteur != null && mission.nomRecruteur!.isNotEmpty) ...[
            Row(
              children: [
                const Icon(Icons.business_outlined, size: 14, color: Colors.grey),
                const SizedBox(width: 4),
                Text(mission.nomRecruteur!, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
              ],
            ),
            const SizedBox(height: 8),
          ],

          Text(
            mission.description,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 13, color: Colors.grey.shade700, height: 1.3),
          ),
          const SizedBox(height: 12),

          if (mission.competencesList.isNotEmpty) ...[
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: mission.competencesList.map((skill) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(skill, style: const TextStyle(fontSize: 11, color: Color(0xFF475569), fontWeight: FontWeight.w500)),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
          ],

          SizedBox(
            width: double.infinity,
            height: 42,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryOrange,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                elevation: 0,
              ),
              onPressed: () => _openPostulerModal(mission),
              child: const Text('Postuler maintenant', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
            ),
          ),
        ],
      ),
    );
  }

  // Widget : Carte d'état de ma candidature
  Widget _buildCandidatureCard(CandidatureItemModel c) {
    Color badgeColor = Colors.orange;
    String statutLabel = 'En attente';

    if (c.statut == 'ACCEPTEE' || c.statut == 'VALIDEE') {
      badgeColor = const Color(0xFF10B981);
      statutLabel = 'Acceptée';
    } else if (c.statut == 'REFUSEE' || c.statut == 'REJETEE') {
      badgeColor = Colors.red;
      statutLabel = 'Non retenue';
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  c.titreMission ?? 'Mission ODC',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: badgeColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(statutLabel, style: TextStyle(color: badgeColor, fontWeight: FontWeight.bold, fontSize: 11)),
              ),
            ],
          ),
          const SizedBox(height: 8),

          Text(
            c.lettreMotivation,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 10),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (c.tarifPropose != null)
                Text('Tarif proposé : ${c.tarifPropose!.toStringAsFixed(0)} FCFA', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
              if (c.dateCandidature != null)
                Text(c.dateCandidature!, style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
            ],
          ),
        ],
      ),
    );
  }
}
