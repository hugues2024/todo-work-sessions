// lib/view/clock/clock_settings_view.dart

import 'package:flutter/material.dart';
import '../../utils/colors.dart';

class ClockSettingsView extends StatelessWidget {
  const ClockSettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDarkMode ? Colors.white : Colors.black;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Paramètres de l\'horloge',
          style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        iconTheme: IconThemeData(color: textColor),
      ),
      body: ListView(
        children: [
          ListTile(
            title: const Text("Afficher les secondes"),
            trailing: Switch(
                value: true,
                onChanged: (val) {},
                activeColor: MyColors.primaryColor),
          ),
          // Ajoutez d'autres paramètres ici si nécessaire
        ],
      ),
    );
  }
}
