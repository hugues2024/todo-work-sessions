// lib/view/clock/clock_view.dart

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../utils/colors.dart';
import 'alarm_view.dart';
import 'world_clock_view.dart';
import 'timer_view.dart';
import 'stopwatch_view.dart';

/// Cette classe est le conteneur de navigation spécifique à la section Horloge.
/// Elle est affichée en tant que page de niveau supérieur via la route /clock
/// et inclut son propre Scaffold pour fonctionner en plein écran.
class ClockView extends StatefulWidget {
  const ClockView({super.key});

  @override
  State<ClockView> createState() => _ClockViewState();
}

class _ClockViewState extends State<ClockView> {
  // 🎯 Commence par l'onglet Minuteur (Timer) (index 2)
  int _clockTabIndex = 2; 

  // Liste des vues pour le corps de la section Horloge
  final List<Widget> _clockViews = const [
    AlarmView(),
    WorldClockView(),
    TimerView(),
    StopwatchView(),
  ];

  @override
  Widget build(BuildContext context) {
    // 🎯 CORRECTION : Ajout du Scaffold
    return Scaffold(
      // 🎯 Optionnel : Ajouter une AppBar pour la navigation "Retour" vers HomeView
      appBar: AppBar(
        title: const Text('Horloge'), // Titre de la section Horloge
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        // Le bouton Retour est géré automatiquement par Flutter grâce à Navigator.pushNamed
      ),
      
      // Le corps utilise IndexedStack
      body: IndexedStack(
        index: _clockTabIndex,
        children: _clockViews,
      ),

      // La Barre de Navigation spécifique à l'Horloge
      bottomNavigationBar: _buildBottomNavBar(context),
    );
  }

  Widget _buildBottomNavBar(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final Color selectedColor = isDarkMode ? Colors.white : MyColors.primaryColor;
    final Color unselectedColor = isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600;

    return BottomNavigationBar(
      elevation: 5,
      type: BottomNavigationBarType.fixed,
      currentIndex: _clockTabIndex,
      onTap: (index) {
        setState(() {
          _clockTabIndex = index;
        });
      },
      selectedItemColor: selectedColor,
      unselectedItemColor: unselectedColor,
      // Utilisation du couleur de fond du thème pour la barre
      backgroundColor: Theme.of(context).scaffoldBackgroundColor, 
      showUnselectedLabels: true,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(CupertinoIcons.bell_fill, size: 22),
          label: 'Alarm',
        ),
        BottomNavigationBarItem(
          icon: Icon(CupertinoIcons.globe, size: 22),
          label: 'World Clock',
        ),
        BottomNavigationBarItem(
          icon: Icon(CupertinoIcons.hourglass, size: 22),
          label: 'Timer',
        ),
        BottomNavigationBarItem(
          icon: Icon(CupertinoIcons.stopwatch_fill, size: 22),
          label: 'Stopwatch',
        ),
      ],
    );
  }
}