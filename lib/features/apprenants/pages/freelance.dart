import 'package:flutter/material.dart';
import 'package:odc_talent/core/constants/constant.dart';
import 'package:odc_talent/features/apprenants/models/mission_model.dart';
import 'package:odc_talent/features/apprenants/pages/detail_freelance.dart';
import 'package:odc_talent/features/apprenants/services/opportunite_service.dart';

class FreelancePage extends StatefulWidget {
  const FreelancePage({Key? key}) : super(key: key);

  @override
  State<FreelancePage> createState() => _FreelancePageState();
}

class _FreelancePageState extends State<FreelancePage> {
  final OpportuniteService _opportuniteService = OpportuniteService();
  final TextEditingController _searchController = TextEditingController();

  bool _isLoading = true;
  List<MissionModel> _missions = [];
  List<MissionModel> _filteredMissions = [];

  static const Color primaryOrange = AppColors.primaryOrange;

  @override
  void initState() {
    super.initState();
    _loadMissions();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadMissions() async {
    setState(() => _isLoading = true);

    try {
      final missions = await _opportuniteService.getMissions();
      if (!mounted) return;
      setState(() {
        _missions = missions;
        _filteredMissions = missions;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _missions = [
          MissionModel(
            id: 1,
            titre: 'Développeur mobile Flutter freelance',
            description: 'Réalisation d’une application mobile pour le suivi des formations et des opportunités.',
            budget: 300000,
            competencesRequises: 'Flutter, Dart, API REST, UI Design',
            statut: 'OUVERTE',
            datePublication: '2026-11-02',
            nomRecruteur: 'Orange Digital Center',
          ),
          MissionModel(
            id: 2,
            titre: 'Backend Java Spring Boot',
            description: 'Développement de services sécurisés et d’API pour une application pédagogique.',
            budget: 450000,
            competencesRequises: 'Java, Spring Boot, JWT, MySQL',
            statut: 'OUVERTE',
            datePublication: '2026-11-01',
            nomRecruteur: 'ODC Ventures',
          ),
        ];
        _filteredMissions = _missions;
        _isLoading = false;
      });
    }
  }

  void _filterMissions() {
    final query = _searchController.text.trim().toLowerCase();
    setState(() {
      _filteredMissions = _missions.where((mission) {
        final title = mission.titre.toLowerCase();
        final description = mission.description.toLowerCase();
        final skills = mission.competencesRequises.toLowerCase();
        return query.isEmpty || title.contains(query) || description.contains(query) || skills.contains(query);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        title: const Text('Freelance', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: primaryOrange))
          : RefreshIndicator(
              onRefresh: _loadMissions,
              color: primaryOrange,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    TextField(
                      controller: _searchController,
                      onChanged: (_) => _filterMissions(),
                      decoration: InputDecoration(
                        hintText: 'Rechercher une mission',
                        prefixIcon: const Icon(Icons.search_rounded, color: primaryOrange),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: _filteredMissions.isEmpty
                          ? const Center(child: Text('Aucune mission freelance trouvée'))
                          : ListView.builder(
                              itemCount: _filteredMissions.length,
                              itemBuilder: (context, index) {
                                final mission = _filteredMissions[index];
                                return Container(
                                  margin: const EdgeInsets.only(bottom: 14),
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(18),
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
                                              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
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
                                      const SizedBox(height: 10),
                                      Text(
                                        mission.description,
                                        style: TextStyle(color: Colors.grey.shade700, height: 1.45),
                                      ),
                                      const SizedBox(height: 12),
                                      Row(
                                        children: [
                                          const Icon(Icons.payments_rounded, size: 16, color: primaryOrange),
                                          const SizedBox(width: 6),
                                          Text(
                                            mission.budget != null ? '${mission.budget!.toStringAsFixed(0)} FCFA' : 'Budget selon devis',
                                            style: const TextStyle(fontWeight: FontWeight.w600),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      Wrap(
                                        spacing: 8,
                                        runSpacing: 8,
                                        children: mission.competencesList.take(3).map((skill) => Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                                          decoration: BoxDecoration(
                                            color: primaryOrange.withOpacity(0.08),
                                            borderRadius: BorderRadius.circular(999),
                                          ),
                                          child: Text(skill, style: const TextStyle(color: primaryOrange, fontSize: 11, fontWeight: FontWeight.w600)),
                                        )).toList(),
                                      ),
                                      const SizedBox(height: 14),
                                      SizedBox(
                                        width: double.infinity,
                                        child: ElevatedButton(
                                          onPressed: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(builder: (_) => DetailFreelancePage(mission: mission)),
                                            );
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: primaryOrange,
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                          ),
                                          child: const Text('Voir le détail', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
