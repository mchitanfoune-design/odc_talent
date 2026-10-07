import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // Ces contrôleurs servent à lire ce que l'utilisateur tape
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ODCTalent'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          // CORRECTION ICI : crossAxisAlignment (avec Axis)
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Bienvenue !',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const Text('Connectez-vous à votre compte'),
            const SizedBox(height: 30),

            // Champ 1 : Email
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),

            // Champ 2 : Mot de passe
            TextField(
              controller: passwordController,
              obscureText: true, // Cacher les caractères
              decoration: const InputDecoration(
                labelText: 'Mot de passe',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 30),

            // Bouton "Se connecter"
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF6501), // Orange ODC
                ),
                onPressed: () {
                  // Récupérer le texte tapé
                  String email = emailController.text;
                  String password = passwordController.text;

                  print('Email tapé : $email');
                  print('Mot de passe tapé : $password');

                  // Rediriger vers l'accueil
                  Navigator.pushNamed(context, '/home');
                },
                child: const Text('Se connecter', style: TextStyle(color: Colors.white)),
              ),
            ),

            const SizedBox(height: 20),

            // Lien pour aller vers S'inscrire
            Center(
              child: TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/register');
                },
                child: const Text('Pas encore de compte ? S\'inscrire'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}