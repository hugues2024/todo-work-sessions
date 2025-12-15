// lib/view/clock/clock_wrapper.dart

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../utils/colors.dart';
import 'alarm_view.dart';
import 'world_clock_view.dart';
import 'timer_view.dart';
import 'stopwatch_view.dart';

class ClockWrapper extends StatefulWidget {
  const ClockWrapper({super.key});

  @override
  State<ClockWrapper> createState() => _ClockWrapperState();
}

class _ClockWrapperState extends State<ClockWrapper> {
  int _currentIndex = 2; // 🎯 Commence par l'onglet Minuteur (Timer) comme dans la capture

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // La couleur de fond est gérée par le thème de MaterialApp (blanc par défaut)
      body: IndexedStack(
        index: _currentIndex,
        children: const [
          AlarmView(),
          WorldClockView(),
          TimerView(),
          StopwatchView(),
        ],
      ),
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
      currentIndex: _currentIndex,
      onTap: (index) {
        setState(() {
          _currentIndex = index;
        });
      },
      selectedItemColor: selectedColor,
      unselectedItemColor: unselectedColor,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor, // Utilise la couleur de fond de l'appli (blanc/sombre)
      showUnselectedLabels: true,
      items: [
        BottomNavigationBarItem(
          icon: Icon(CupertinoIcons.bell_fill, size: 22),
          label: 'Alarm',
        ),
        BottomNavigationBarItem(
          icon: Icon(CupertinoIcons.globe, size: 22),
          label: 'World Clock',
        ),
        BottomNavigationBarItem(
          // Icône spécifique au minuteur (sablier ou chronomètre)
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

// =================================================================
// 🎯 NOTE IMPORTANTE SUR LA NAVIGATION PRINCIPALE
// =================================================================
// Pour que ce menu s'affiche, vous devez vous assurer que votre MainWrapper
// ne s'affiche PAS lorsque vous êtes sur la route de ClockWrapper.
// Par exemple, si l'utilisateur appuie sur l'icône "Horloge" de votre menu
// principal, vous devez naviguer vers ClockWrapper.