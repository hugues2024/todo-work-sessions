// lib/view/home/home_view.dart

import 'package:flutter/material.dart';
import '../../utils/strings.dart';
import '../../utils/colors.dart';
import '../tasks/task_view.dart'; // 🎯 On appelle maintenant TaskView
import 'widgets/task_list_view.dart';

class HomeView extends StatefulWidget {
  const HomeView({Key? key}) : super(key: key);

  @override
  _HomeViewState createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,

      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          MyString.mainTitle,
          style: Theme.of(context).textTheme.displayLarge?.copyWith(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white
                    : MyColors.primaryColor,
              ),
        ),
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      ),

      // Affiche la liste des tâches existantes
      body: const TaskListView(),

      // 🎯 LE BOUTON PLUS (+) APPELLE MAINTENANT TASKVIEW
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigue vers la page de configuration des Tâches
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    const TaskView()), // Création d'une nouvelle tâche
          );
        },
        backgroundColor: MyColors.primaryColor,
        child: const Icon(Icons.add, color: Colors.white, size: 30),
      ),
    );
  }
}
