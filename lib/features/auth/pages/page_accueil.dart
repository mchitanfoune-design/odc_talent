import 'package:flutter/material.dart';
import 'package:odc_talent/features/auth/pages/inscrption.dart';
import 'package:odc_talent/features/auth/pages/slash.dart';
    // Importe la page de connexion

class WelcomePage extends StatelessWidget {
  const WelcomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Fond blanc global de la page
      body: SafeArea(
        // SafeArea évite que le contenu touche l'encoche (notch) ou la barre de statut en haut
        child: Stack(
          children: [
            // ==========================================
            // 1. STRUCTURE PRINCIPALE (Logo + Photo)
            // ==========================================
            Column(
              children: [
                // Espace pour faire descendre le logo depuis le haut de l'écran
                const SizedBox(height: 35),

                // Logo ODC
                Image.asset(
                  'assets/images/logo.jpg',
                  height: 110,
                  filterQuality: FilterQuality.high,
                ),

                // Espace entre le logo et le haut de la photo
                const SizedBox(height: 25),

                // Photo d'illustration
                Expanded(
                  child: ClipRect(
                    child: Transform.scale(
                      scale: 1.02,
                      child: Image.asset(
                        'assets/images/nous.jpg',
                        fit: BoxFit.cover,
                        alignment: const Alignment(0.19, -0.15),
                        filterQuality: FilterQuality.high,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // ==========================================
            // 2. BOUTONS SUPERPOSÉS EN BAS DE L'ÉCRAN
            // ==========================================
            Positioned(
              left: 20,   // Marge de 20px sur le côté gauche
              right: 20,  // Marge de 20px sur le côté droit
              bottom: 25, // Distance par rapport au bas de l'écran
              child: Row(
                children: [
                  // --- BOUTON "SE CONNECTER" (ORANGE) ---
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF6501), // Code couleur Orange ODC
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                        elevation: 4,
                      ),
                      onPressed: () {
                        // REDIRECTION VERS LA PAGE DE CONNEXION
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LoginPage(),
                          ),
                        );
                      },
                      child: const Text(
                        'Se connecter',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  // Espace de 12px entre les deux boutons
                  const SizedBox(width: 12),

                  // --- BOUTON "S'INSCRIRE" (NOIR) ---
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black, // Couleur Noire
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                        elevation: 4,
                      ),
                      onPressed: () {
                        // REDIRECTION VERS L'ONBOARDING
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const OnboardingPage(),
                          ),
                        );
                      },
                      child: const Text(
                        "S'inscrire",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}