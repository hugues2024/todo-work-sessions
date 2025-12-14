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
  // ✅ CORRECTION 1: Ajout du paramètre initialIndex
  final int initialIndex;
  
  const MainWrapper({
    super.key,
    this.initialIndex = 0, // Valeur par défaut : Accueil (0)
  });

  @override
  State<MainWrapper> createState() => _MainWrapperState();
}

class _MainWrapperState extends State<MainWrapper> {
  // ✅ CORRECTION 2: Définir _currentIndex dans initState pour utiliser initialIndex
  late int _currentIndex; 

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  // Liste des vues à afficher dans le BottomNavigationBar
  final List<Widget> _views = const [
    HomeView(),          // 0: Accueil (Tâches)
    WorkSessionView(),   // 1: Session de travail
    ProfileView(),       // 2: Profil <-- C'est l'index que nous voulons
    SettingsView(),      // 3: Paramètres
    DetailsView(),       // 4: Détails
  ];

  @override
  Widget build(BuildContext context) {
    // ... (Reste du code inchangé)

    return Scaffold(
      // Utilisation d'un IndexedStack pour ne pas reconstruire les vues à chaque changement d'onglet
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
        selectedItemColor: Theme.of(context).primaryColor, // Utiliser le thème
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