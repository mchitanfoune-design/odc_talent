import 'package:flutter/material.dart';
import 'package:odc_talent/core/constants/constant.dart';
import 'package:odc_talent/features/apprenants/pages/dasboard.dart';
import 'package:odc_talent/features/auth/services/CompExp.dart';

class PortfolioFormPage extends StatefulWidget {
  const PortfolioFormPage({Key? key}) : super(key: key);

  @override
  State<PortfolioFormPage> createState() => _PortfolioFormPageState();
}

class _PortfolioFormPageState extends State<PortfolioFormPage> {
  final _formKey = GlobalKey<FormState>();

  final _titreProfessionnelController = TextEditingController(text: 'Développeur Web & Mobile');
  final _aProposController = TextEditingController();
  final _experiencesController = TextEditingController();
  final _competencesController = TextEditingController();

  final CompExpApiService _apiService = CompExpApiService();

  bool _isLoading = false;
  static const Color _primaryOrange = AppColors.primaryOrange;

  @override
  void dispose() {
    _titreProfessionnelController.dispose();
    _aProposController.dispose();
    _experiencesController.dispose();
    _competencesController.dispose();
    super.dispose();
  }

  Future<void> _submitPortfolio() async {
    if (!_formKey.currentState!.validate()) return;

    FocusScope.of(context).unfocus();
    setState(() => _isLoading = true);

    try {
      await _apiService.saveCompetencesAndExperiences(
        titreProfessionnel: _titreProfessionnelController.text.trim(),
        aPropos: _aProposController.text.trim(),
        experiences: _experiencesController.text.trim(),
        competences: _competencesController.text.trim(),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profil et Portfolio initialisés avec succès !'),
          backgroundColor: Color(0xFF10B981),
          behavior: SnackBarBehavior.floating,
        ),
      );

      // Redirection vers le tableau de bord principal
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const DashboardApprenantPage()),
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll('Exception: ', '')),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Navigator.canPop(context)
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black87, size: 20),
                onPressed: () => Navigator.pop(context),
              )
            : null,
        title: Image.asset(
          'assets/images/logo.jpg',
          height: 38,
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) => const Text(
            'ODCTalent',
            style: TextStyle(color: _primaryOrange, fontWeight: FontWeight.bold),
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),

                // Titre & Consigne
                const Text(
                  'Construisez votre profil professionnel',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Renseignez vos compétences et expériences afin de générer automatiquement votre portfolio ODC visible par les recruteurs.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 24),

                // 1. Titre professionnel
                _buildSectionCard(
                  icon: Icons.badge_outlined,
                  title: 'Titre professionnel',
                  subtitle: 'Votre métier ou spécialité principale',
                  hintText: 'Ex: Développeur Flutter & Mobile, Fullstack Spring Boot...',
                  controller: _titreProfessionnelController,
                  maxLines: 1,
                ),
                const SizedBox(height: 18),

                // 2. Section "À propos de moi"
                _buildSectionCard(
                  icon: Icons.person_outline_rounded,
                  title: 'À propos de moi',
                  subtitle: 'Présentez brièvement vos ambitions et centres d\'intérêt',
                  hintText: 'Ex: Passionné par le développement d\'applications mobiles et les architectures backend performantes...',
                  controller: _aProposController,
                  maxLines: 3,
                ),
                const SizedBox(height: 18),

                // 3. Section "Expériences"
                _buildSectionCard(
                  icon: Icons.work_outline_rounded,
                  title: 'Expériences',
                  subtitle: 'Vos stages, projets d\'études ou missions antérieures',
                  hintText: 'Ex: Projet académique de 6 mois, stage de développement à Orange Digital Center...',
                  controller: _experiencesController,
                  maxLines: 3,
                ),
                const SizedBox(height: 18),

                // 4. Section "Compétences"
                _buildSectionCard(
                  icon: Icons.layers_outlined,
                  title: 'Compétences clés',
                  subtitle: 'Séparez vos compétences par une virgule',
                  hintText: 'Ex: Flutter, Dart, Spring Boot, MySQL, Git, Docker, REST API',
                  controller: _competencesController,
                  maxLines: 2,
                ),
                const SizedBox(height: 30),

                // 5. Bouton de validation
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _primaryOrange,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(26),
                      ),
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
                            'Générer mon portfolio & Continuer',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required String hintText,
    required TextEditingController controller,
    int maxLines = 3,
  }) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 6, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _primaryOrange.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: _primaryOrange, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          TextFormField(
            controller: controller,
            maxLines: maxLines,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Ce champ est requis';
              }
              return null;
            },
            style: const TextStyle(fontSize: 14, color: Colors.black87),
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
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
