import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:odc_talent/core/constants/constant.dart';
import 'package:odc_talent/features/apprenants/models/mission_model.dart';
import 'package:odc_talent/features/apprenants/services/candidature_service.dart';

class PostulerPage extends StatefulWidget {
  final MissionModel mission;

  const PostulerPage({super.key, required this.mission});

  @override
  State<PostulerPage> createState() => _PostulerPageState();
}

class _PostulerPageState extends State<PostulerPage> {
  final _formKey = GlobalKey<FormState>();
  final _lettreController = TextEditingController();
  final _tarifController = TextEditingController();
  final CandidatureService _candidatureService = CandidatureService();
  
  bool _isLoading = false;

  @override
  void dispose() {
    _lettreController.dispose();
    _tarifController.dispose();
    super.dispose();
  }

  Future<void> _submitCandidature() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final tarif = double.parse(_tarifController.text.trim());
      
      await _candidatureService.postuler(
       missionId: widget.mission.id!,
        lettreMotivation: _lettreController.text.trim(),
        tarifPropose: tarif,
      );

      if (!mounted) return;

      // Afficher un message de succès et rediriger vers la liste des candidatures
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Candidature envoyée avec succès ! 🎉'),
          backgroundColor: Colors.green,
        ),
      );

      // Rediriger vers la page des candidatures
      context.go('/candidatures');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur : $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Postuler à la mission', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Rappel de la mission
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.mission.titre,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryOrange,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (widget.mission.budget != null)
                      Text(
                        'Budget indicatif : ${widget.mission.budget} FCFA',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Champ Lettre de motivation
              const Text(
                'Lettre de motivation',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _lettreController,
                maxLines: 6,
                decoration: InputDecoration(
                  hintText: 'Expliquez pourquoi vous êtes le meilleur profil pour cette mission...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Veuillez saisir une lettre de motivation.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Champ Tarif proposé
              const Text(
                'Tarif proposé (FCFA)',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _tarifController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: 'Ex: 150000',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.money, color: AppColors.primaryOrange),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Veuillez proposer un tarif.';
                  }
                  if (double.tryParse(value.trim()) == null) {
                    return 'Veuillez entrer un nombre valide.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),

              // Bouton de Soumission
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryOrange,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: _isLoading ? null : _submitCandidature,
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Envoyer ma candidature',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}