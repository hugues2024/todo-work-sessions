// lib/view/clock/alarm_view.dart

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../utils/colors.dart';

class AlarmView extends StatelessWidget {
  const AlarmView({super.key});

  // Simule les données d'alarme pour l'interface
  final List<Map<String, String>> mockAlarms = const [
    {'time': '03:45 AM', 'desc': 'Every day. Alarm in 7 hours and 48 mi...'},
    {'time': '04:00 AM', 'desc': 'Every day. Alarm in 8 hours and 3 min...'},
    {'time': '04:05 AM', 'desc': 'Every day. Alarm in 8 hours and 8 min...'},
    {'time': '04:20 AM', 'desc': 'Every day. Alarm in 8 hours and 23 mi...'},
    {'time': '04:30 AM', 'desc': 'Every day. Alarm in 8 hours and 33 mi...'},
    {'time': '04:45 AM', 'desc': 'Every day. Alarm in 8 hours and 48 mi...'},
  ];

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Alarm',
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
              // Ajouter une alarme
            },
          ),
          // Micro et Menu (pour la reproduction exacte)
          IconButton(
            icon: Icon(CupertinoIcons.mic, color: isDarkMode ? Colors.white : Colors.black),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(Icons.more_vert, color: isDarkMode ? Colors.white : Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        itemCount: mockAlarms.length,
        itemBuilder: (context, index) {
          final alarm = mockAlarms[index];
          // Utilise Dismissible pour simuler le swipe et la suppression (comme la capture 4)
          return Dismissible(
            key: Key(alarm['time']!),
            direction: DismissDirection.endToStart,
            background: Container(
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 20.0),
              color: Colors.red,
              child: const Icon(CupertinoIcons.delete_solid, color: Colors.white),
            ),
            onDismissed: (direction) {
              // Logique de suppression ici
            },
            child: ListTile(
              title: Text(
                alarm['time']!,
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.w300,
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
              ),
              subtitle: Text(
                alarm['desc']!,
                style: TextStyle(
                  color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade700,
                ),
              ),
              trailing: CupertinoSwitch(
                value: index % 3 != 0, // Exemple d'état activé/désactivé
                onChanged: (bool value) {
                  // Logique d'activation/désactivation de l'alarme
                },
                activeColor: MyColors.primaryColor,
              ),
            ),
          );
        },
      ),
    );
  }
}