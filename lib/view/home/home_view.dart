// lib/view/home/home_view.dart

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../utils/strings.dart';
import '../../utils/colors.dart';
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
      appBar: AppBar(
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
        // Les icônes de navigation sont retirées car elles sont désormais dans l'onglet Activité
      ),
      body: const TaskListView(),
    );
  }
}
