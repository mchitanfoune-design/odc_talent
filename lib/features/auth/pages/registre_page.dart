import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// ============================================================================
// SERVICE HTTP - CONNEXION SPRING BOOT
// ============================================================================
class RegistrePage {
  // Adresse IP de ton serveur Spring Boot (10.0.2.2 pour l'émulateur Android)
  static const String baseUrl = 'http://10.0.2.2:8080/api/v1/auth';

  static Future<http.Response> registerApprenant({
    required String prenom,
    required String nom,
    required String email,
    required String telephone,
    required String role,
    required String promotion,
    required String formation,
  }) async {
    final Uri url = Uri.parse('$baseUrl/register');

    final Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    final String body = jsonEncode({
      'prenom': prenom,
      'nom': nom,
      'email': email,
      'telephone': telephone,
      'role': role,
      'promotion': promotion,
      'formation': formation,
    });

    return await http.post(url, headers: headers, body: body);
  }
}

// ============================================================================
// PAGE D'INSCRIPTION APPRENANT ODC (DÉFILABLE ET FONCTIONNELLE)
// ============================================================================
class RegisterApprenantPage extends StatefulWidget {
  const RegisterApprenantPage({Key? key}) : super(key: key);

  @override
  State<RegisterApprenantPage> createState() => _RegisterApprenantPageState();
}

class _RegisterApprenantPageState extends State<RegisterApprenantPage> {
  // Clé pour la validation du formulaire
  final _formKey = GlobalKey<FormState>();

  // Contrôleurs des champs de texte
  final _prenomController = TextEditingController();
  final _nomController = TextEditingController();
  final _emailController = TextEditingController();
  final _telephoneController = TextEditingController();
  final _profileController = TextEditingController(text: 'Apprenant ODC');
  final _promotionController = TextEditingController();
  final _formationController = TextEditingController();

  // État de chargement de l'API
  bool _isLoading = false;

  // Couleur principale Orange ODC
  static const Color _primaryOrange = Color(0xFFFF6501);

  @override
  void dispose() {
    _prenomController.dispose();
    _nomController.dispose();
    _emailController.dispose();
    _telephoneController.dispose();
    _profileController.dispose();
    _promotionController.dispose();
    _formationController.dispose();
    super.dispose();
  }

  // ==========================================
  // LOGIQUE DE SOUMISSION VERS SPRING BOOT
  // ==========================================
  Future<void> _submitRegister() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final response = await RegistrePage.registerApprenant(
        prenom: _prenomController.text.trim(),
        nom: _nomController.text.trim(),
        email: _emailController.text.trim(),
        telephone: _telephoneController.text.trim(),
        role: _profileController.text.trim(),
        promotion: _promotionController.text.trim(),
        formation: _formationController.text.trim(),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        _showSnackBar("Compte Apprenant créé avec succès !");
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/login');
        }
      } else {
        final errorData = jsonDecode(response.body);
        String errorMessage = "Erreur lors de l'inscription";

        if (errorData is Map && errorData.containsKey('message')) {
          errorMessage = errorData['message'];
        } else if (errorData is String) {
          errorMessage = errorData;
        }

        _showSnackBar(errorMessage, isError: true);
      }
    } catch (e) {
      _showSnackBar("Impossible de contacter le serveur Spring Boot.", isError: true);
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
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Bouton retour
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.black, size: 28),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () => Navigator.pop(context),
                  ),

                  const SizedBox(height: 10),

                  // Logo ODC
                  Center(
                    child: Image.asset(
                      'assets/images/logo.jpg',
                      height: 90,
                      filterQuality: FilterQuality.high,
                    ),
                  ),

                  const SizedBox(height: 25),

                  // Titre
                  const Text(
                    'Créer votre compte',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Sous-titre
                  const Text(
                    'Remplissez les informations ci-dessous pour rejoindre la plateforme ODC.',
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.grey,
                      height: 1.3,
                    ),
                  ),

                  const SizedBox(height: 25),

                  // 1. Champ Prénom
                  _buildFieldLabel('Prénom', isRequired: true),
                  const SizedBox(height: 8),
                  _buildTextFormField(
                    controller: _prenomController,
                    hintText: 'Entrez votre prénom',
                    prefixIcon: Icons.person_outline_rounded,
                    validator: (val) => (val == null || val.trim().isEmpty) ? 'Veuillez entrer votre prénom' : null,
                  ),

                  const SizedBox(height: 20),

                  // 2. Champ Nom
                  _buildFieldLabel('Nom', isRequired: true),
                  const SizedBox(height: 8),
                  _buildTextFormField(
                    controller: _nomController,
                    hintText: 'Entrez votre nom',
                    prefixIcon: Icons.person_outline_rounded,
                    validator: (val) => (val == null || val.trim().isEmpty) ? 'Veuillez entrer votre nom' : null,
                  ),

                  const SizedBox(height: 20),

                  // 3. Champ Email
                  _buildFieldLabel('Email', isRequired: true),
                  const SizedBox(height: 8),
                  _buildTextFormField(
                    controller: _emailController,
                    hintText: 'exemple@odc.com',
                    prefixIcon: Icons.mail_outline_rounded,
                    keyboardType: TextInputType.emailAddress,
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) return 'Veuillez entrer votre email';
                      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(val.trim())) {
                        return 'Veuillez entrer un email valide';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 20),

                  // 4. Champ Téléphone
                  _buildFieldLabel('Téléphone', isRequired: true),
                  const SizedBox(height: 8),
                  _buildTextFormField(
                    controller: _telephoneController,
                    hintText: '+225 07 00 00 00 00',
                    prefixIcon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) return 'Veuillez entrer votre numéro de téléphone';
                      if (val.trim().length < 8) return 'Numéro de téléphone invalide';
                      return null;
                    },
                  ),

                  const SizedBox(height: 20),

                  // 5. Champ Profil sélectionné (Fixe)
                  _buildFieldLabel('Choissez votre profile', isRequired: false),
                  const SizedBox(height: 8),
                  _buildTextFormField(
                    controller: _profileController,
                    hintText: 'Apprenant ODC',
                    prefixIcon: Icons.school_outlined,
                    readOnly: true,
                    validator: (val) => null,
                  ),

                  const SizedBox(height: 20),

                  // 6. Champ Votre promotion
                  _buildFieldLabel('Votre promotion', isRequired: false),
                  const SizedBox(height: 8),
                  _buildTextFormField(
                    controller: _promotionController,
                    hintText: 'Ex:Promotion 01',
                    prefixIcon: Icons.verified_outlined,
                    validator: (val) => (val == null || val.trim().isEmpty) ? 'Veuillez renseigner votre promotion' : null,
                  ),

                  const SizedBox(height: 20),

                  // 7. Champ Formation
                  _buildFieldLabel('Formation', isRequired: false),
                  const SizedBox(height: 8),
                  _buildTextFormField(
                    controller: _formationController,
                    hintText: 'Ex:Dev Mobile et web',
                    prefixIcon: Icons.list_alt_rounded,
                    validator: (val) => (val == null || val.trim().isEmpty) ? 'Veuillez renseigner votre formation' : null,
                  ),

                  const SizedBox(height: 35),

                  // 8. Bouton Suivant (Soumission)
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
                      onPressed: _isLoading ? null : _submitRegister,
                      child: _isLoading
                          ? const SizedBox(
                              height: 22,
                              width: 22,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                            )
                          : const Text(
                              'Suivant',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(height: 25),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFieldLabel(String label, {bool isRequired = false}) {
    return RichText(
      text: TextSpan(
        text: label,
        style: const TextStyle(
          color: Colors.black,
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
        children: [
          if (isRequired)
            const TextSpan(
              text: ' *',
              style: TextStyle(color: _primaryOrange, fontWeight: FontWeight.bold),
            ),
        ],
      ),
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String hintText,
    required IconData prefixIcon,
    required String? Function(String?) validator,
    TextInputType keyboardType = TextInputType.text,
    bool readOnly = false,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      readOnly: readOnly,
      validator: validator,
      style: TextStyle(
        color: readOnly ? Colors.grey[700] : Colors.black,
        fontSize: 14,
      ),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
        prefixIcon: Icon(prefixIcon, color: _primaryOrange, size: 22),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        fillColor: readOnly ? const Color(0xFFF9F9F9) : Colors.white,
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
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
    );
  }
}