// lib/view/main_wrapper.dart

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart'; 

// Importez toutes les vues principales :
import 'home/home_view.dart';
import 'work_session/work_session_view.dart';
import 'profile/profile_view.dart';
import 'settings/settings_view.dart';
import 'details/details_view.dart';

class MainWrapper extends StatefulWidget {
  const MainWrapper({super.key});

  @override
  State<MainWrapper> createState() => _MainWrapperState();
}

class _MainWrapperState extends State<MainWrapper> {
  int _currentIndex = 0; // Index de la vue actuellement sélectionnée

  // Liste des vues à afficher dans le BottomNavigationBar
  final List<Widget> _views = const [
    HomeView(),          // 0: Accueil (Tâches)
    WorkSessionView(),   // 1: Session de travail
    ProfileView(),       // 2: Profil
    SettingsView(),      // 3: Paramètres
    DetailsView(),       // 4: Détails
  ];

  @override
  Widget build(BuildContext context) {
    // La couleur primaire est utilisée ici pour le sélecteur, 
    // en fonction du thème (light/dark) pour garder la cohérence du projet
    final Color selectedColor = Theme.of(context).primaryColor; 

    return Scaffold(
      // Utilisation d'un IndexedStack pour ne pas reconstruire les vues à chaque changement d'onglet
      // (Maintient l'état de chaque écran, par exemple la position de défilement)
      body: IndexedStack(
        index: _currentIndex,
        children: _views,
      ),

      // La Barre de Navigation Inférieure
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        // Utilisez 'fixed' si vous avez plus de 3 éléments pour que les labels restent visibles
        type: BottomNavigationBarType.fixed, 
        selectedItemColor: selectedColor,
        unselectedItemColor: Colors.grey, 
        backgroundColor: Theme.of(context).scaffoldBackgroundColor, // Respecte le mode sombre
        items: const [
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.house_fill),
            label: "Accueil",
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.clock_fill),
            label: "Sessions",
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.person_fill),
            label: "Profil",
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.settings),
            label: "Paramètres",
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.info_circle_fill),
            label: "Détails",
          ),
        ],
      ),
    );
  }
}