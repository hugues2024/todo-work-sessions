// lib/view/clock/stopwatch_view.dart

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../utils/colors.dart';

class StopwatchView extends StatelessWidget {
  const StopwatchView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDarkMode ? Colors.white : Colors.black;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Stopwatch',
          style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.more_vert, color: textColor),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 100),
          // 🎯 Affichage du temps
          Center(
            child: Column(
              children: [
                Text(
                  '00:05.03', // Simulé
                  style: TextStyle(
                    fontSize: 70,
                    fontWeight: FontWeight.w300,
                    color: textColor,
                  ),
                ),
                Text(
                  '+00:05.03', // Temps du tour (Lap time)
                  style: TextStyle(
                    fontSize: 18,
                    color: textColor.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
          
          const Spacer(),

          // 🎯 Boutons de contrôle (Réinitialiser, Lecture/Pause, Tour)
          Padding(
            padding: const EdgeInsets.only(bottom: 20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // 1. Bouton Réinitialiser (ou Tour/Lap)
                _buildCircularButton(
                  icon: CupertinoIcons.arrow_counterclockwise,
                  onPressed: () {},
                  isDarkMode: isDarkMode,
                  size: 60,
                ),
                // 2. Bouton Lecture/Pause
                _buildCircularButton(
                  icon: CupertinoIcons.play_fill,
                  onPressed: () {},
                  isDarkMode: isDarkMode,
                  isPrimary: true,
                  size: 80,
                ),
                // 3. Bouton Lap/Tour
                _buildCircularButton(
                  icon: CupertinoIcons.timer, // Icône de Lap Time
                  onPressed: () {},
                  isDarkMode: isDarkMode,
                  size: 60,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCircularButton({
    required IconData icon, 
    required VoidCallback onPressed, 
    required bool isDarkMode, 
    bool isPrimary = false,
    double size = 60,
  }) {
    final primaryColor = MyColors.primaryColor;
    final bgColor = isPrimary 
        ? primaryColor 
        : isDarkMode ? Colors.grey.shade800 : Colors.grey.shade200;
    final iconColor = isPrimary ? Colors.white : (isDarkMode ? Colors.white : Colors.black);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: bgColor,
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: Icon(icon, color: iconColor, size: isPrimary ? size * 0.45 : size * 0.4),
        onPressed: onPressed,
      ),
    );
  }
}