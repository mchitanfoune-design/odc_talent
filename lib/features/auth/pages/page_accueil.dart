import 'package:flutter/material.dart';
import 'package:odc_talent/features/auth/pages/login_page.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            // 1. STRUCTURE PRINCIPALE (Logo + Photo)
            Column(
              children: [
                const SizedBox(height: 35),
                // Logo ODC
                Image.asset(
                  'assets/images/logo.jpg',
                  height: 110,
                  filterQuality: FilterQuality.high,
                ),
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

            // 2. BOUTON UNIQUE EN BAS DE L'ÉCRAN ("Se connecter")
            Positioned(
              left: 20,
              right: 20,
              bottom: 30,
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF6501), // Orange ODC
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    elevation: 4,
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const LoginPage()),
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
            ),
          ],
        ),
      ),
    );
  }
}
