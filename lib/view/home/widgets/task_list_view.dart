// lib/view/home/widgets/task_list_view.dart

import 'package:animate_do/animate_do.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
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

  int checkDoneTask(List<Task> task) {
    int i = 0;
    for (Task doneTasks in task) {
      if (doneTasks.isCompleted) i++;
    }
    return i;
  }

  @override
  Widget build(BuildContext context) {
    final base = BaseWidget.of(context);
    var textTheme = Theme.of(context).textTheme;

    return ValueListenableBuilder(
      valueListenable: base.dataStore.listenToTask(),
      builder: (ctx, Box<Task> box, Widget? child) {
        // 🎯 FILTRAGE PROFESSIONNEL : Uniquement les tâches principales (parentId == null)
        var tasks = box.values.where((t) => t.parentId == null).toList();

        tasks.sort((a, b) {
          if (a.isCompleted != b.isCompleted) return a.isCompleted ? 1 : -1;
          return a.createdAtDate.compareTo(b.createdAtDate);
        });

        final double totalTasks = tasks.length.toDouble();
        final int doneTasks = checkDoneTask(tasks);
        final double percentage = totalTasks > 0 ? (doneTasks / totalTasks) : 0.0;

        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          floatingActionButton: const FAB(),
          body: SizedBox(
            width: double.infinity,
            height: double.infinity,
            child: Column(
              children: [
                FadeInDown(
                  duration: const Duration(milliseconds: 800),
                  child: _buildHeader(percentage, doneTasks, tasks.length, textTheme),
                ),
                Expanded(
                  child: tasks.isNotEmpty
                      ? ListView.builder(
                          physics: const BouncingScrollPhysics(),
                          itemCount: tasks.length,
                          itemBuilder: (context, index) {
                            var task = tasks[index];
                            return FadeInLeft(
                              duration: const Duration(milliseconds: 500),
                              child: Dismissible(
                                direction: DismissDirection.horizontal,
                                onDismissed: (_) => base.dataStore.deleteTask(task: task),
                                key: Key(task.id), 
                                child: TaskWidget(task: task),
                              ),
                            );
                          },
                        )
                      : _buildEmptyState(),
                )
              ],
            ),
          ),
        );
      }
    );
  }

  Widget _buildHeader(double percentage, int done, int total, TextTheme textTheme) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: MyColors.primaryGradientColor, begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: MyColors.primaryColor.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 8))],
      ),
      child: Row(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(width: 70, height: 70, child: CircularProgressIndicator(value: percentage, strokeWidth: 6, valueColor: const AlwaysStoppedAnimation(Colors.white), backgroundColor: Colors.white24)),
              Text("${(percentage * 100).toInt()}%", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(MyString.mainTitle, style: textTheme.displayLarge?.copyWith(color: Colors.white, fontSize: 24)),
                const SizedBox(height: 6),
                Text("$done sur $total tâches principales", style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 15)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Lottie.asset(lottieURL, width: 200, height: 200),
        const Padding(padding: EdgeInsets.all(30.0), child: Text(MyString.doneAllTask, textAlign: TextAlign.center)),
      ],
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
