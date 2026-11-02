import 'package:flutter/material.dart';
import 'package:odc_talent/core/constants/constant.dart';
import 'package:odc_talent/features/apprenants/models/candidature_model.dart';
import 'package:odc_talent/features/apprenants/services/candidature_service.dart';

class MesCandidaturesPage extends StatefulWidget {
  const MesCandidaturesPage({super.key});

  @override
  State<MesCandidaturesPage> createState() => _MesCandidaturesPageState();
}

class _MesCandidaturesPageState extends State<MesCandidaturesPage> {
  final CandidatureService _candidatureService = CandidatureService();
  late Future<List<CandidatureModel>> _candidaturesFuture;

  @override
  void initState() {
    super.initState();
    _loadCandidatures();
  }

  void _loadCandidatures() {
    _candidaturesFuture = _candidatureService.getMyCandidatures();
  }

  // Fonction pour retourner la couleur et le libellé selon le statut Spring Boot
  Widget _buildStatutBadge(String statut) {
    Color bgColor;
    Color textColor;
    String label;

    switch (statut.toUpperCase()) {
      case 'ACCEPTEE':
        bgColor = Colors.green.shade100;
        textColor = Colors.green.shade800;
        label = 'Acceptée 🎉';
        break;
      case 'REFUSEE':
        bgColor = Colors.red.shade100;
        textColor = Colors.red.shade800;
        label = 'Refusée ❌';
        break;
      case 'EN_ATTENTE':
      default:
        bgColor = Colors.orange.shade100;
        textColor = Colors.orange.shade800;
        label = 'En attente ⏳';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes Candidatures', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: FutureBuilder<List<CandidatureModel>>(
        future: _candidaturesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Erreur : ${snapshot.error}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.assignment_outlined, size: 64, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  const Text(
                    'Aucune candidature pour le moment.',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          final candidatures = snapshot.data!;

          return RefreshIndicator(
            onRefresh: () async {
              setState(() {
                _loadCandidatures();
              });
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: candidatures.length,
              itemBuilder: (context, index) {
                final cand = candidatures[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                cand.titreMission ?? 'Mission sans titre',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            _buildStatutBadge(cand.statut),
                          ],
                        ),
                        const SizedBox(height: 8),
                        if (cand.lettreMotivation != null && cand.lettreMotivation!.isNotEmpty) ...[
                          Text(
                            'Motivation : ${cand.lettreMotivation}',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
                          ),
                          const SizedBox(height: 8),
                        ],
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            if (cand.tarifPropose != null)
                              Text(
                                'Tarif : ${cand.tarifPropose} FCFA',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primaryOrange,
                                ),
                              ),
                            if (cand.dateCandidature != null)
                              Text(
                                'Postulé le : ${cand.dateCandidature}',
                                style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}