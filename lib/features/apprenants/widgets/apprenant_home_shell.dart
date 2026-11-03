import 'package:flutter/material.dart';
import 'package:odc_talent/core/constants/constant.dart';
import 'package:odc_talent/features/apprenants/pages/accueil.dart';
import 'package:odc_talent/features/apprenants/pages/opportunites.dart';
import 'package:odc_talent/features/apprenants/pages/portfolio.dart';
import 'package:odc_talent/features/apprenants/pages/profil.dart';

class ApprenantHomeShell extends StatefulWidget {
  const ApprenantHomeShell({super.key});

  @override
  State<ApprenantHomeShell> createState() => _ApprenantHomeShellState();
}

class _ApprenantHomeShellState extends State<ApprenantHomeShell> {
  int _selectedIndex = 0;

  static const List<Widget> _pages = [
    AccueilApprenantPage(),
    OpportunitesPage(),
    PortfolioScreen(),
    ProfilApprenantPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 12,
              spreadRadius: 0,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: BottomNavigationBar(
            currentIndex: _selectedIndex,
            type: BottomNavigationBarType.fixed,
            selectedItemColor: AppColors.primaryOrange,
            unselectedItemColor: const Color(0xFF8A93A5),
            backgroundColor: Colors.white,
            selectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 11,
            ),
            unselectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 11,
            ),
            selectedFontSize: 11,
            unselectedFontSize: 10,
            elevation: 0,
            iconSize: 24,
            showSelectedLabels: true,
            showUnselectedLabels: true,
            onTap: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined),
                activeIcon: Icon(Icons.home_rounded),
                label: 'Accueil',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.work_outline_rounded),
                activeIcon: Icon(Icons.work_rounded),
                label: 'Offres',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.folder_copy_outlined),
                activeIcon: Icon(Icons.folder_copy_rounded),
                label: 'Portfolio',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_outline_rounded),
                activeIcon: Icon(Icons.person_rounded),
                label: 'Profil',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
