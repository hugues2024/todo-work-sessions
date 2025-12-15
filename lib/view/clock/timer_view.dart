// lib/view/clock/timer_view.dart (Code Complet et Corrigé - Plus de rayures)

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../utils/colors.dart';

class TimerView extends StatelessWidget {
  const TimerView({super.key});

  // Simule les préréglages de minuteur
  final List<Map<String, String>> presets = const [
    {'title': 'Meeting', 'time': '00:20:00', 'icon': 'meeting'},
    {'title': 'Sleep', 'time': '05:00:00', 'icon': 'sleep'},
    {'title': 'Exercise', 'time': '00:15:00', 'icon': 'exercise'},
  ];

  IconData _getPresetIcon(String iconName) {
    switch (iconName) {
      case 'meeting':
        return CupertinoIcons.calendar;
      case 'sleep':
        return CupertinoIcons.moon;
      case 'exercise':
        return CupertinoIcons.sportscourt;
      default:
        return CupertinoIcons.tag;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDarkMode ? Colors.white : Colors.black;

    // 🎯 CORRECTION: Réinsertion du Scaffold et de l'AppBar
    return Scaffold(
      appBar: AppBar(
        // L'icône de retour est désormais gérée par ClockView (qui est le parent via IndexedStack)
        // ou manuellement si nécessaire. 
        title: Text(
          'Timer',
          style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(CupertinoIcons.mic, color: textColor),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(Icons.more_vert, color: textColor),
            onPressed: () {},
          ),
        ],
      ),
      
      // 🎯 CORRECTION: Utilisation de SingleChildScrollView pour éliminer le débordement
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 🎯 Sélecteur de temps (Heures, Minutes, Secondes)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 40.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildTimePickerColumn(context, '00', 'h'),
                  const SizedBox(width: 20),
                  _buildTimePickerColumn(context, '00', 'm'),
                  const SizedBox(width: 20),
                  _buildTimePickerColumn(context, '10', 's'),
                ],
              ),
            ),

            // 🎯 Préréglages
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: GridView.builder(
                shrinkWrap: true,
                // Le NeverScrollableScrollPhysics est maintenant correct
                physics: const NeverScrollableScrollPhysics(), 
                itemCount: presets.length + 1, // +1 pour le bouton Ajouter
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 15,
                  mainAxisSpacing: 15,
                  childAspectRatio: 1.0,
                ),
                itemBuilder: (context, index) {
                  if (index < presets.length) {
                    final preset = presets[index];
                    return _buildPresetButton(
                      context,
                      title: preset['title']!,
                      time: preset['time']!,
                      icon: _getPresetIcon(preset['icon']!),
                      isDarkMode: isDarkMode,
                    );
                  } else {
                    return _buildAddPresetButton(context, isDarkMode);
                  }
                },
              ),
            ),
            
            // 🎯 Espacement fixe au lieu de Spacer car nous sommes dans SingleChildScrollView
            const SizedBox(height: 50),

            // 🎯 Boutons de contrôle (Lecture, Réinitialiser, Cloche)
            Padding(
              padding: const EdgeInsets.only(bottom: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildCircularButton(
                    icon: CupertinoIcons.arrow_counterclockwise,
                    onPressed: () {},
                    isDarkMode: isDarkMode,
                    size: 60,
                  ),
                  _buildCircularButton(
                    icon: CupertinoIcons.play_fill,
                    onPressed: () {},
                    isDarkMode: isDarkMode,
                    isPrimary: true,
                    size: 80,
                  ),
                  _buildCircularButton(
                    icon: CupertinoIcons.bell,
                    onPressed: () {},
                    isDarkMode: isDarkMode,
                    size: 60,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimePickerColumn(BuildContext context, String value, String unit) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDarkMode ? Colors.white : Colors.black;

    return Column(
      children: [
        // Simuler le sélecteur (23 / 00 / 01)
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              // 🎯 Hauteur ajustée pour éviter le débordement
              height: 100, 
              width: 80,
              child: ListWheelScrollView.useDelegate(
                itemExtent: 50,
                perspective: 0.005,
                diameterRatio: 1.2,
                physics: const FixedExtentScrollPhysics(),
                onSelectedItemChanged: (index) {
                  // Logique de sélection de l'heure
                },
                childDelegate: ListWheelChildBuilderDelegate(
                  childCount: 60, // Pour les minutes/secondes, moins pour les heures
                  builder: (context, index) {
                    final isSelected = index == 0; // Simuler la valeur 00/10 sélectionnée
                    return Center(
                      child: Text(
                        index.toString().padLeft(2, '0'),
                        style: TextStyle(
                          fontSize: isSelected ? 40 : 25,
                          fontWeight: isSelected ? FontWeight.w500 : FontWeight.w300,
                          color: isSelected ? textColor : textColor.withOpacity(0.4),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            // Ligne de séparation (pour la mise au point)
            IgnorePointer(
              child: Container(
                height: 50,
                decoration: BoxDecoration(
                  border: Border.symmetric(
                    horizontal: BorderSide(
                      color: textColor.withOpacity(0.1),
                      width: 1.0,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        Text(
          unit,
          style: TextStyle(
            fontSize: 20,
            color: textColor,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildPresetButton(BuildContext context, {required String title, required String time, required IconData icon, required bool isDarkMode}) {
    final textColor = isDarkMode ? Colors.white : Colors.black;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade200,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, color: textColor, size: 20),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(color: textColor, fontWeight: FontWeight.w500, fontSize: 16),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          Text(
            time,
            style: TextStyle(color: textColor.withOpacity(0.7), fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildAddPresetButton(BuildContext context, bool isDarkMode) {
    return Container(
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade200,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Center(
        child: Icon(
          CupertinoIcons.add_circled,
          color: MyColors.primaryColor,
          size: 30,
        ),
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