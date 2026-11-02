import 'package:flutter/material.dart';
import 'package:odc_talent/core/constants/constant.dart';
import 'package:odc_talent/features/apprenants/services/projet_service.dart';

class AjoutProjetPage extends StatefulWidget {
  const AjoutProjetPage({Key? key}) : super(key: key);

  @override
  State<AjoutProjetPage> createState() => _AjoutProjetPageState();
}

class _AjoutProjetPageState extends State<AjoutProjetPage> {
  final _formKey = GlobalKey<FormState>();
  final _titreController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _technologiesController = TextEditingController();
  final _githubController = TextEditingController();
  final _demoController = TextEditingController();
  final _imageController = TextEditingController();

  final ProjetApiService _projetApiService = ProjetApiService();
  bool _isSubmitting = false;

  static const Color primaryOrange = AppColors.primaryOrange;

  @override
  void dispose() {
    _titreController.dispose();
    _descriptionController.dispose();
    _technologiesController.dispose();
    _githubController.dispose();
    _demoController.dispose();
    _imageController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      await _projetApiService.createProjet(
        titre: _titreController.text.trim(),
        description: _descriptionController.text.trim(),
        technologies: _technologiesController.text.trim(),
        githubUrl: _githubController.text.trim(),
        demoUrl: _demoController.text.trim(),
        imageUrl: _imageController.text.trim(),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Projet ajouté avec succès'),
          backgroundColor: Color(0xFF10B981),
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll('Exception: ', '')),
          backgroundColor: Colors.red.shade700,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('Ajouter un projet', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Partagez votre réalisation',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'Décrivez votre projet, vos technologies et les liens associés.',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 14, height: 1.4),
                ),
                const SizedBox(height: 24),
                _buildField('Titre du projet', _titreController, 'Ex: Plateforme ODCTalent'),
                const SizedBox(height: 16),
                _buildField('Description', _descriptionController, 'Décrivez votre projet...', maxLines: 4),
                const SizedBox(height: 16),
                _buildField('Technologies', _technologiesController, 'Flutter, Dart, Spring Boot, MySQL'),
                const SizedBox(height: 16),
                _buildField('Lien GitHub', _githubController, 'https://github.com/...'),
                const SizedBox(height: 16),
                _buildField('Lien démo', _demoController, 'https://mon-projet.demo'),
                const SizedBox(height: 16),
                _buildField('Image ou visuel', _imageController, 'https://.../preview.png'),
                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryOrange,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: _isSubmitting
                        ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Text('Enregistrer le projet', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildField(String label, TextEditingController controller, String hint, {int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Ce champ est obligatoire.';
            }
            return null;
          },
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: Colors.grey.shade50,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primaryOrange, width: 1.5),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          ),
        ),
      ],
    );
  }
}
