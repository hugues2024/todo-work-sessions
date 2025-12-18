// lib/view/home/widgets/task_list_view.dart

import 'package:animate_do/animate_do.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';

import '../../../main.dart';
import '../../../models/task.dart';
import '../../../utils/colors.dart';
import '../../../utils/constanst.dart';
import '../../../utils/strings.dart';
import '../../tasks/task_view.dart';
import 'task_widget.dart';

class TaskListView extends StatelessWidget {
  const TaskListView({super.key});

  String _getDateHeader(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final taskDate = DateTime(date.year, date.month, date.day);

    if (taskDate == today) return "Aujourd'hui";
    if (taskDate == yesterday) return "Hier";
    return DateFormat('EEE d MMM', 'fr_FR').format(date);
  }

  @override
  Widget build(BuildContext context) {
    final base = BaseWidget.of(context);

    return ValueListenableBuilder(
      valueListenable: base.dataStore.listenToTask(),
      builder: (ctx, Box<Task> box, _) {
        // Uniquement tâches principales
        var tasks = box.values.where((t) => t.parentId == null).toList();
        
        // 🎯 CALCUL DU POURCENTAGE GLOBAL
        final int totalTasks = tasks.length;
        final int doneTasks = tasks.where((t) => t.status == "Done").length;
        final double percentage = totalTasks > 0 ? (doneTasks / totalTasks) : 0.0;

        // Tri par date décroissante
        tasks.sort((a, b) => b.createdAtDate.compareTo(a.createdAtDate));

        // Groupement par jour
        Map<String, List<Task>> groupedTasks = {};
        for (var task in tasks) {
          String header = _getDateHeader(task.createdAtDate);
          groupedTasks.putIfAbsent(header, () => []).add(task);
        }

        if (tasks.isEmpty) return _buildEmptyState();

        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          floatingActionButton: const FAB(),
          body: Column(
            children: [
              // 🎯 RESTAURATION DU HEADER DE PROGRESSION
              FadeInDown(
                duration: const Duration(milliseconds: 800),
                child: _buildGlobalProgressHeader(percentage, doneTasks, totalTasks),
              ),
              
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.only(top: 10, bottom: 80),
                  itemCount: groupedTasks.length,
                  itemBuilder: (context, index) {
                    String dateHeader = groupedTasks.keys.elementAt(index);
                    List<Task> dayTasks = groupedTasks[dateHeader]!;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(24, 20, 20, 8),
                          child: Text(
                            dateHeader.toUpperCase(),
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.2),
                          ),
                        ),
                        ...dayTasks.map((task) => FadeInLeft(
                          duration: const Duration(milliseconds: 300),
                          child: Dismissible(
                            direction: DismissDirection.horizontal,
                            onDismissed: (_) => base.dataStore.deleteTask(task: task),
                            key: Key(task.id),
                            child: TaskWidget(task: task),
                          ),
                        )).toList(),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        );
      }
    );
  }

  Widget _buildGlobalProgressHeader(double percentage, int done, int total) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: MyColors.primaryGradientColor, begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: MyColors.primaryColor.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 8))],
      ),
      child: Row(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(width: 60, height: 60, child: CircularProgressIndicator(value: percentage, strokeWidth: 6, valueColor: const AlwaysStoppedAnimation(Colors.white), backgroundColor: Colors.white24)),
              Text("${(percentage * 100).toInt()}%", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
            ],
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Progrès Global", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                Text("$done sur $total tâches principales terminées", style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 13)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Lottie.asset(lottieURL, width: 200),
          const Text(MyString.doneAllTask),
        ],
      ),
    );
  }
}

class FAB extends StatelessWidget {
  const FAB({super.key});
  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      backgroundColor: MyColors.primaryColor,
      heroTag: 'task_list_fab',
      onPressed: () => Navigator.of(context).push(CupertinoPageRoute(builder: (context) => const TaskView())),
      child: const Icon(Icons.add, color: Colors.white),
    );
  }
}
