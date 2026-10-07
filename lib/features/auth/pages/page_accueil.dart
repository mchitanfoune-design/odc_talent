import 'package:flutter/material.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 1. La grande photo des deux personnes en arrière-plan plein écran
          Positioned.fill(
            child: Image.asset(
              'assets/images/nous.jpg', // Votre image de fond
              fit: BoxFit.cover,
            ),
          ),
        
          // 2. Le contenu au-dessus de la photo (Logo + Boutons)
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
              child: Column(
                children: [
                  const SizedBox(height: 20),

                  // Logo ODC en haut
                  Image.asset(
                    'assets/images/logo.jpg',
                    height: 100,
                  ),

                  const Spacer(), // Pousse les boutons vers le bas de l'écran

                  // Les deux boutons côte à côte en bas
                  Row(
                    children: [
                      // Bouton Orange : Se connecter
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFF6501), // Orange ODC
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                          ),
                          onPressed: () {
                            Navigator.pushNamed(context, '/login');
                          },
                          child: const Text(
                            'Se connecter',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),

                      const SizedBox(width: 12),

                      // Bouton Noir : S'inscrire
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                          ),
                          onPressed: () {
                            Navigator.pushNamed(context, '/register');
                          },
                          child: const Text(
                            'S\'inscrire',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}