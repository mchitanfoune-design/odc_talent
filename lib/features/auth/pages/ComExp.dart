import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:odc_talent/features/auth/services/CompExp.dart';

class PortfolioFormPage extends StatefulWidget {
  const PortfolioFormPage({Key? key}) : super(key: key);

  @override
  State<PortfolioFormPage> createState() => _PortfolioFormPageState();
}

class _PortfolioFormPageState extends State<PortfolioFormPage> {
  final _formKey = GlobalKey<FormState>();

  // Contrôleurs de texte
  final _aProposController = TextEditingController();
  final _experiencesController = TextEditingController();
  final _competencesController = TextEditingController();

  bool _isLoading = false;

  static const Color _primaryOrange = Color(0xFFFF6501);

  @override
  void dispose() {
    _aProposController.dispose();
    _experiencesController.dispose();
    _competencesController.dispose();
    super.dispose();
  }

  // Envoi du formulaire vers le backend
  Future<void> _submitPortfolio() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final response = await Compexp.createPortfolio(
        aPropos: _aProposController.text.trim(),
        experiences: _experiencesController.text.trim(),
        competences: _competencesController.text.trim(),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        _showSnackBar('Portfolio généré avec succès !');
        // Redirection vers le profil ou le portfolio généré
      } else {
        final errorData = jsonDecode(response.body);
        String message = errorData['message'] ?? 'Erreur lors de la création.';
        _showSnackBar(message, isError: true);
      }
    } catch (e) {
      _showSnackBar('Impossible de contacter le serveur Spring Boot.', isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Logo ODC
                Center(
                  child: Image.asset(
                    'assets/images/logo.jpg', // Vérifie le chemin de ton logo
                    height: 60,
                    filterQuality: FilterQuality.high,
                  ),
                ),
                const SizedBox(height: 20),

                // 2. Texte de consigne
                const Text(
                  'Renseignez vos expériences et compétences afin de construire automatiquement votre portfolio professionnel',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 24),

                // 3. Section "À propos de moi"
                _buildSectionCard(
                  icon: Icons.person_outline_rounded,
                  title: 'A propos de moi',
                  subtitle: 'Decrivez en bref',
                  hintText:
                      'Ex: Passionné par le développement web, je crée des sites et applications...............',
                  controller: _aProposController,
                ),
                const SizedBox(height: 20),

                // 4. Section "Expériences"
                _buildSectionCard(
                  icon: Icons.work_outline_rounded,
                  title: 'Expériences',
                  subtitle:
                      'Ajoutez vos expériences professionnelles (emplois, stages, etc.).',
                  hintText:
                      'Ex: Développeur web pendant 2 ans, spécialisé dans la création de sites et d’applications web',
                  controller: _experiencesController,
                ),
                const SizedBox(height: 20),

                // 5. Section "Compétences"
                _buildSectionCard(
                  icon: Icons.layers_outlined,
                  title: 'Competences',
                  subtitle:
                      'Ajoutez vos expériences professionnelles (emplois, stages, etc.).',
                  hintText: 'Ex: Sprint boot, python,Html, Css.......',
                  controller: _competencesController,
                ),
                const SizedBox(height: 30),

                // 6. Bouton de validation
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _primaryOrange,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      elevation: 0,
                    ),
                    onPressed: _isLoading ? null : _submitPortfolio,
                    child: _isLoading
                        ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          )
                        : const Text(
                            'Générer mon portfolio',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Widget réutilisable pour créer les cartes du formulaire
  Widget _buildSectionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required String hintText,
    required TextEditingController controller,
  }) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header de la carte : Icône + Titre + Sous-titre
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: _primaryOrange,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Zone de saisie multi-lignes
          TextFormField(
            controller: controller,
            maxLines: 4,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Ce champ est requis';
              }
              return null;
            },
            style: const TextStyle(fontSize: 14, color: Colors.black87),
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: const TextStyle(
                color: Color(0xFF9CA3AF),
                fontSize: 13,
              ),
              filled: true,
              fillColor: const Color(0xFFFAFAFA),
              contentPadding: const EdgeInsets.all(14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: _primaryOrange, width: 1.5),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.red),
              ),
            ),
          ),
        ],
      ),
    );
  }
}