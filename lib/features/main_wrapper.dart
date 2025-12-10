// lib/features/main_wrapper.dart

// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
// Importations de nos écrans (que nous déplacerons et créerons bientôt)
import 'package:todo_work_sessions/features/tasks/presentation/task_list_screen.dart'; 
import 'package:todo_work_sessions/features/timer/presentation/session_screen.dart';
// import 'package:todo_work_sessions/features/profile/presentation/profile_screen.dart';


class MainWrapper extends StatefulWidget {
  const MainWrapper({super.key});

  @override
  State<MainWrapper> createState() => _MainWrapperState();
}

class _MainWrapperState extends State<MainWrapper> {
  // Index de l'onglet actuellement sélectionné
  int _selectedIndex = 0;
  
  // Liste des écrans correspondants aux onglets
  static final List<Widget> _widgetOptions = <Widget>[
    const TaskListScreen(), // Index 0: Tâches
    const SessionScreen(), // Index 1: Minuteur
    const ProfileScreen(), // Index 2: Profil & Synchro
  ];

  // Fonction appelée lors du changement d'onglet
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Le Scaffold est la structure de base qui contient la barre de navigation
    return Scaffold(
      // Affiche l'écran sélectionné
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      
      // Le bouton flottant (FAB) pour l'ajout rapide de tâches (seulement sur l'onglet 0)
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton(
              onPressed: () {
                print("Ajouter une tâche!");
              },
              backgroundColor: Theme.of(context).colorScheme.secondary, // Utilise accentGreen
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null, // Masque le FAB sur les autres onglets
          
      // La Barre de Navigation en bas
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.check_box_outlined),
            label: 'Tâches',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.timer_outlined),
            label: 'Minuteur',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Profil',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Theme.of(context).primaryColor, // Bleu profond
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 10,
      ),
    );
  }
}

// ⚠️ Stubs pour les nouveaux écrans. Ces fichiers DOIVENT être créés
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Écran Profil & Synchronisation'));
  }
}