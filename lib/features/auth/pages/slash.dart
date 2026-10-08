import 'package:flutter/material.dart';
import 'package:odc_talent/features/auth/pages/registre_page.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({Key? key}) : super(key: key);

  @override
  _OnboardingPageState createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _controller = PageController();
  int _pageActuelle = 0;

  // Liste des 3 écrans avec leurs textes et images
  final List<Map<String, String>> _pages = [
    {
      'titre': 'Montre ton talent',
      'description': 'Publie tes projets, partage tes compétences et fais-toi remarquer !',
      'image': 'assets/images/slash_1.jpg',
    },
    {
      'titre': 'Construire ton Avenir',
      'description': 'Rejoins une communauté d’apprenants, de recruteurs et de professionnels',
      'image': 'assets/images/slash_2.jpg',
    },
    {
      'titre': 'Trouve des opportunités',
      'description': 'Trouve des opportunités de recrutement et de freelance, collabore et développe ta carrière.',
      'image': 'assets/images/slash_3.jpg',
    },
  ];

  @override
  Widget build(BuildContext context) {
    const orangeODC = Color(0xFFFF6501);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            children: [
              // 1. Zone de défilement (Images + Textes)
              Expanded(
                child: PageView.builder(
                  controller: _controller,
                  onPageChanged: (index) {
                    setState(() {
                      _pageActuelle = index;
                    });
                  },
                  itemCount: _pages.length,
                  itemBuilder: (context, index) {
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Image d'illustration
                        Image.asset(
                          _pages[index]['image']!,
                          height: 280,
                        ),
                        const SizedBox(height: 32),

                        // Titre en gras
                        Text(
                          _pages[index]['titre']!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Description
                        Text(
                          _pages[index]['description']!,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.grey.shade600,
                            height: 1.4,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),

              // 2. Bouton "Suivant"
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: orangeODC,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 0,
                  ),
                  onPressed: () {
                    if (_pageActuelle < _pages.length - 1) {
                      // Passer à la page suivante
                      _controller.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    } else {
                      // À la dernière page -> Aller sur la page de registre
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const RegisterApprenantPage(),
                        ), // Syntax corrigée ici
                      );
                    }
                  },
                  child: const Text(
                    'Suivant',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // 3. Les 3 petits points de navigation en bas
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _pages.length,
                  (index) => Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _pageActuelle == index ? orangeODC : Colors.grey.shade300,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}