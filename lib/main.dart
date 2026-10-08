import 'package:flutter/material.dart';
import 'package:odc_talent/features/auth/pages/page_accueil.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: WelcomePage(), // Affiche directement la page de bienvenue au démarrage
    );
  }
}