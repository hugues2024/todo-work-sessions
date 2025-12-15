// lib/view/clock/world_clock_view.dart

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class WorldClockView extends StatelessWidget {
  const WorldClockView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final timeStyle = TextStyle(
      fontSize: 60,
      fontWeight: FontWeight.w300,
      color: isDarkMode ? Colors.white : Colors.black,
    );
    final dateStyle = TextStyle(
      fontSize: 16,
      color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade700,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'World Clock',
          style: TextStyle(
            color: isDarkMode ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(CupertinoIcons.add, color: isDarkMode ? Colors.white : Colors.black),
            onPressed: () {
              // Ajouter fuseau horaire
            },
          ),
          IconButton(
            icon: Icon(Icons.more_vert, color: isDarkMode ? Colors.white : Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Simule l'heure en grand (avec une légère mise à jour visuelle pour le flux)
            Text(
              '07:57:28 PM', 
              style: timeStyle,
            ),
            const SizedBox(height: 8),
            Text(
              'Mon, Dec 15',
              style: dateStyle,
            ),
            Text(
              'West Africa Standard Time',
              style: dateStyle,
            ),
          ],
        ),
      ),
    );
  }
}