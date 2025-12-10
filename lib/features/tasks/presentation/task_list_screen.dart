import 'package:flutter/material.dart';

class TaskListScreen extends StatelessWidget {
  const TaskListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Ce sera le futur écran affichant les tâches
    return Scaffold(
      appBar: AppBar(title: const Text('Mes Tâches de Travail')),
      body: const Center(
        child: Text('Liste des tâches (Connecté à Hive!)', style: TextStyle(fontSize: 18)),
      ),
    );
  }
}