// lib/view/main_wrapper.dart

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart'; 

// Importez toutes les vues principales :
import 'home/home_view.dart';
import 'profile/profile_view.dart';
import 'settings/settings_view.dart';
import 'details/details_view.dart';

class MainWrapper extends StatefulWidget {
  final int initialIndex;
  
  const MainWrapper({
    super.key,
    this.initialIndex = 0, 
  });

  @override
  State<MainWrapper> createState() => _MainWrapperState();
}

class _MainWrapperState extends State<MainWrapper> {
  // 🎯 L'index est initialisé à l'index initial (par défaut 0)
  late int _currentIndex; 

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex.clamp(0, 4);
  }

  // Les 5 vues pour les 5 onglets de la barre inférieure principale
  final List<Widget> _views = const [
    HomeView(),          // 0: Accueil (Contient Tâches, et lance Horloge/Calendrier en plein écran)
    HomeView(),          // 1: Sessions (Pointe également sur HomeView)
    ProfileView(),       // 2: Profil
    SettingsView(),      // 3: Paramètres
    DetailsView(),       // 4: Détails
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Utilisation d'un IndexedStack pour ne pas reconstruire les vues à chaque changement d'onglet
      body: IndexedStack(
        index: _currentIndex,
        children: _views,
      ),

      // La Barre de Navigation Inférieure (Main Wrapper)
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed, 
        selectedItemColor: Theme.of(context).primaryColor, 
        unselectedItemColor: Colors.grey, 
        backgroundColor: Theme.of(context).scaffoldBackgroundColor, 
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