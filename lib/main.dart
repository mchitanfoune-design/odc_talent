// lib/main.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:odc_talent/core/constants/constant.dart';
import 'package:odc_talent/features/apprenants/models/mission_model.dart';
import 'package:odc_talent/features/apprenants/pages/accueil.dart';
import 'package:odc_talent/features/apprenants/pages/ajout_projet.dart';
import 'package:odc_talent/features/apprenants/pages/dasboard.dart';
import 'package:odc_talent/features/apprenants/pages/detail_freelance.dart';
import 'package:odc_talent/features/apprenants/pages/evolution_pro.dart';
import 'package:odc_talent/features/apprenants/pages/freelance.dart';
import 'package:odc_talent/features/apprenants/pages/mes_projets.dart';
import 'package:odc_talent/features/apprenants/pages/notifications.dart';
import 'package:odc_talent/features/apprenants/pages/opportunites.dart';
import 'package:odc_talent/features/apprenants/pages/portfolio.dart';
import 'package:odc_talent/features/apprenants/pages/postuler_page.dart';
import 'package:odc_talent/features/apprenants/pages/profil.dart';
import 'package:odc_talent/features/auth/pages/ComExp.dart';
import 'package:odc_talent/features/apprenants/pages/messages_recus_page.dart';
import 'package:odc_talent/features/apprenants/pages/chat_detail_page.dart';
import 'package:odc_talent/features/auth/pages/login_page.dart';
import 'package:odc_talent/features/auth/pages/page_accueil.dart';
import 'package:odc_talent/features/auth/pages/registre_page.dart';
import 'package:odc_talent/features/apprenants/pages/mes_candidatures.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

// Configuration de GoRouter
final GoRouter _router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const WelcomePage(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginPage(),
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterApprenantPage(),
    ),
    GoRoute(
      path: '/dashboard',
      builder: (context, state) => const DashboardApprenantPage(),
    ),
    GoRoute(
      path: '/accueil',
      builder: (context, state) => const AccueilApprenantPage(),
    ),
    GoRoute(
      path: '/ajout-projet',
      builder: (context, state) => const AjoutProjetPage(),
    ),
    GoRoute(
      path: '/freelance',
      builder: (context, state) => const FreelancePage(),
    ),
    GoRoute(
      path: '/detail-freelance',
      builder: (context, state) {
        final mission = state.extra as MissionModel?;
        return mission != null ? DetailFreelancePage(mission: mission) : const FreelancePage();
      },
    ),
    GoRoute(
      path: '/complete-profil',
      builder: (context, state) => const PortfolioFormPage(),
    ),
    GoRoute(
      path: '/projets',
      builder: (context, state) => const MesProjetsPage(),
    ),
    GoRoute(
      path: '/opportunites',
      builder: (context, state) => const OpportunitesPage(),
    ),
    GoRoute(
      path: '/portfolio',
      builder: (context, state) => const PortfolioScreen(),
    ),
    GoRoute(
      path: '/evolution-pro',
      builder: (context, state) => const EvolutionProPage(),
    ),
    GoRoute(
      path: '/notifications',
      builder: (context, state) => const NotificationsPage(),
    ),
    GoRoute(
      path: '/profil',
      builder: (context, state) => const ProfilApprenantPage(),
    ),
    GoRoute(
      path: '/postuler',
      builder: (context, state) {
        final mission = state.extra as MissionModel?;
        return mission != null ? PostulerPage(mission: mission) : const OpportunitesPage();
      },
    ),
    GoRoute(
      path: '/candidatures',
      builder: (context, state) => const MesCandidaturesPage(),
    ),
    GoRoute(
      path: '/messages',
      builder: (context, state) => const MessagesRecusPage(),
    ),
    GoRoute(
      path: '/chat',
      builder: (context, state) {
        final args = state.extra as Map<String, dynamic>?;
        final userId = args?['userId'] as int? ?? 0;
        final userName = args?['userName'] as String? ?? 'Discussion';
        return ChatDetailPage(autreUserId: userId, autreUserName: userName);
      },
    ),
  ],
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'ODCTalent',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        primaryColor: AppColors.primaryOrange,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primaryOrange,
          primary: AppColors.primaryOrange,
        ),
        scaffoldBackgroundColor: Colors.white,
      ),
      routerConfig: _router,
    );
  }
}