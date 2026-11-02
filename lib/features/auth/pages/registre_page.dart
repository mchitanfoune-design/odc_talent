import 'package:flutter/material.dart';
import 'package:odc_talent/core/constants/constant.dart';
import 'package:odc_talent/features/auth/pages/login_page.dart';
import 'package:odc_talent/features/auth/services/auth_service.dart';

class RegisterApprenantPage extends StatefulWidget {
  const RegisterApprenantPage({Key? key}) : super(key: key);

  @override
  State<RegisterApprenantPage> createState() => _RegisterApprenantPageState();
}

class _RegisterApprenantPageState extends State<RegisterApprenantPage> {
  final _formKey = GlobalKey<FormState>();

  final _prenomController = TextEditingController();
  final _nomController = TextEditingController();
  final _emailController = TextEditingController();
  final _telephoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final AuthService _authService = AuthService();

  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;

  static const Color _primaryOrange = AppColors.primaryOrange;

  @override
  void dispose() {
    _prenomController.dispose();
    _nomController.dispose();
    _emailController.dispose();
    _telephoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submitRegister() async {
    if (!_formKey.currentState!.validate()) return;

    FocusScope.of(context).unfocus();
    setState(() => _isLoading = true);

    try {
      final response = await _authService.register(
        nom: _nomController.text.trim(),
        prenom: _prenomController.text.trim(),
        email: _emailController.text.trim(),
        telephone: _telephoneController.text.trim(),
        password: _passwordController.text,
        role: 'APPRENANT',
      );

      if (!mounted) return;

      // Dialogue de félicitations et d'information
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: const [
              Icon(Icons.check_circle_rounded, color: Color(0xFF10B981), size: 28),
              SizedBox(width: 10),
              Text('Inscription Réussie !', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
          content: Text(
            'Félicitations ${response.prenom} ! Votre compte apprenant ODCTalent a été enregistré.\nUn email de confirmation vous a été envoyé.',
            style: const TextStyle(fontSize: 14, height: 1.4, color: Colors.black87),
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: _primaryOrange,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                );
              },
              child: const Text('Se connecter maintenant', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
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
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // En-tête : Retour + Titre ODCTalent
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black87, size: 20),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 14),
                    RichText(
                      text: const TextSpan(
                        children: [
                          TextSpan(text: 'O', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: _primaryOrange)),
                          TextSpan(text: 'DC', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black)),
                          TextSpan(text: 'Talent', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: _primaryOrange)),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                Center(
                  child: Image.asset(
                    'assets/images/logo.jpg',
                    height: 70,
                    fit: BoxFit.contain,
                    filterQuality: FilterQuality.high,
                  ),
                ),

                const SizedBox(height: 20),

                const Text(
                  'Créer votre compte',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Rejoignez la communauté Orange Digital Center et développez votre carrière.',
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600, height: 1.3),
                ),

                const SizedBox(height: 24),

                // 1. Prénom
                _buildFieldLabel('Prénom'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _prenomController,
                  textInputAction: TextInputAction.next,
                  validator: (val) => (val == null || val.trim().isEmpty) ? 'Veuillez saisir votre prénom' : null,
                  decoration: _buildInputDecoration(hintText: 'Votre prénom', prefixIcon: Icons.person_outline_rounded),
                ),
                const SizedBox(height: 18),

                // 2. Nom
                _buildFieldLabel('Nom'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _nomController,
                  textInputAction: TextInputAction.next,
                  validator: (val) => (val == null || val.trim().isEmpty) ? 'Veuillez saisir votre nom' : null,
                  decoration: _buildInputDecoration(hintText: 'Votre nom', prefixIcon: Icons.person_outline_rounded),
                ),
                const SizedBox(height: 18),

                // 3. Email
                _buildFieldLabel('Email professionnel ou personnel'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) return 'Veuillez saisir votre email';
                    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                    if (!emailRegex.hasMatch(val.trim())) return 'Veuillez entrer une adresse email valide';
                    return null;
                  },
                  decoration: _buildInputDecoration(hintText: 'exemple@odc.com', prefixIcon: Icons.mail_outline_rounded),
                ),
                const SizedBox(height: 18),

                // 4. Téléphone
                _buildFieldLabel('Numéro de téléphone'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _telephoneController,
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.next,
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) return 'Veuillez saisir votre numéro';
                    if (val.trim().length < 8) return 'Numéro de téléphone invalide';
                    return null;
                  },
                  decoration: _buildInputDecoration(hintText: '+223 70 00 00 00', prefixIcon: Icons.phone_outlined),
                ),
                const SizedBox(height: 18),

                // 5. Mot de passe
                _buildFieldLabel('Mot de passe'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  textInputAction: TextInputAction.next,
                  validator: (val) {
                    if (val == null || val.isEmpty) return 'Veuillez définir un mot de passe';
                    if (val.length < 6) return 'Le mot de passe doit comporter au moins 6 caractères';
                    return null;
                  },
                  decoration: _buildInputDecoration(
                    hintText: '••••••••',
                    prefixIcon: Icons.lock_outline_rounded,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                        color: Colors.grey.shade600,
                        size: 20,
                      ),
                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                ),
                const SizedBox(height: 18),

                // 6. Confirmer le mot de passe
                _buildFieldLabel('Confirmer le mot de passe'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: _obscureConfirm,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _submitRegister(),
                  validator: (val) {
                    if (val != _passwordController.text) return 'Les mots de passe ne correspondent pas';
                    return null;
                  },
                  decoration: _buildInputDecoration(
                    hintText: '••••••••',
                    prefixIcon: Icons.lock_outline_rounded,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirm ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                        color: Colors.grey.shade600,
                        size: 20,
                      ),
                      onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                    ),
                  ),
                ),
                const SizedBox(height: 30),

                // 7. Bouton S'inscrire
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _primaryOrange,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
                    ),
                    onPressed: _isLoading ? null : _submitRegister,
                    child: _isLoading
                        ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                          )
                        : const Text(
                            'S\'inscrire',
                            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                  ),
                ),

                const SizedBox(height: 24),

                // 8. Déjà un compte ? Se connecter
                Center(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => const LoginPage()),
                      );
                    },
                    child: RichText(
                      text: TextSpan(
                        text: 'Vous avez déjà un compte ? ',
                        style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                        children: const [
                          TextSpan(
                            text: 'Se connecter',
                            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                          ),
                        ],
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

  Widget _buildFieldLabel(String label) {
    return Text(
      label,
      style: const TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.w600),
    );
  }

  InputDecoration _buildInputDecoration({
    required String hintText,
    required IconData prefixIcon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
      prefixIcon: Icon(prefixIcon, color: Colors.grey.shade600, size: 20),
      suffixIcon: suffixIcon,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
      filled: true,
      fillColor: Colors.white,
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
        borderSide: const BorderSide(color: _primaryOrange, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.red.shade400),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.red.shade600, width: 1.5),
      ),
    );
  }
}
