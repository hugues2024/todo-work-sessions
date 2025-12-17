// lib/view/home/widgets/task_list_view.dart

// ignore_for_file: must_be_immutable, use_build_context_synchronously

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
      if (doneTasks.isCompleted) {
        i++;
      }
    }
    return i;
  }

  double valueOfTheIndicator(List<Task> task) {
    return task.isNotEmpty ? task.length.toDouble() : 1.0; 
  }

  @override
  Widget build(BuildContext context) {
    final base = BaseWidget.of(context);
    var textTheme = Theme.of(context).textTheme;

    return ValueListenableBuilder(
      valueListenable: base.dataStore.listenToTask(),
      builder: (ctx, Box<Task> box, Widget? child) {
        var tasks = box.values.toList();

        // 🎯 RETOUR AU TRI D'ORIGINE
        tasks.sort((a, b) {
          if (a.isCompleted != b.isCompleted) {
            return a.isCompleted ? 1 : -1;
          }
          return a.createdAtDate.compareTo(b.createdAtDate);
        });

        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          floatingActionButton: const FAB(),
          body: _buildBody(
              tasks,
              base,
              textTheme,
            ),
        );
      }
    );
  }

  SizedBox _buildBody(List<Task> tasks, BaseWidget base, TextTheme textTheme) {
    final double totalTasks = valueOfTheIndicator(tasks);
    final int doneTasks = checkDoneTask(tasks);
    final double percentage = totalTasks > 0 ? (doneTasks / totalTasks) : 0.0;

    return SizedBox(
      width: double.infinity,
      height: double.infinity,
      child: Column(
        children: [
          FadeInDown(
            duration: const Duration(milliseconds: 800),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: MyColors.primaryGradientColor,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: MyColors.primaryColor.withOpacity(0.3),
                    blurRadius: 15,
                    spreadRadius: -5,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 70,
                        height: 70,
                        child: CircularProgressIndicator(
                          valueColor: const AlwaysStoppedAnimation(Colors.white),
                          backgroundColor: Colors.white.withOpacity(0.3),
                          strokeWidth: 6,
                          value: percentage,
                        ),
                      ),
                      Text(
                        '${(percentage * 100).toInt()}%',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          MyString.mainTitle,
                          style: textTheme.displayLarge?.copyWith(
                            color: Colors.white,
                            fontSize: 24,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          "${doneTasks} sur ${tasks.length} ${MyString.taskStrnig.toLowerCase()}${tasks.length > 1 ? 's' : ''}",
                          style: textTheme.titleMedium?.copyWith(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: tasks.isNotEmpty
                ? ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    itemCount: tasks.length,
                    itemBuilder: (BuildContext context, int index) {
                      var task = tasks[index];
                      return FadeInLeft(
                        duration: const Duration(milliseconds: 500),
                        child: Dismissible(
                          direction: DismissDirection.horizontal,
                          onDismissed: (direction) {
                            base.dataStore.deleteTask(task: task);
                          },
                          key: Key(task.id), 
                          child: TaskWidget(
                            task: tasks[index],
                          ),
                        ),
                      );
                    },
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      FadeIn(
                        child: SizedBox(
                          width: 200,
                          height: 200,
                          child: Lottie.asset(
                            lottieURL,
                            animate: true,
                          ),
                        ),
                      ),
                      FadeInUp(
                        from: 30,
                        child: const Padding(
                          padding: EdgeInsets.all(30.0),
                          child: Text(
                            MyString.doneAllTask,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ],
                  ),
          )
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
      onPressed: () {
        Navigator.of(context).push(
          CupertinoPageRoute(
            builder: (context) => const TaskView(), 
          ),
        );
      },
      child: const Icon(Icons.add, color: Colors.white),
    );
  }
}
