// lib/view/home/widgets/task_list_view.dart

// ignore_for_file: must_be_immutable, use_build_context_synchronously

import 'package:animate_do/animate_do.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:lottie/lottie.dart';

/// Les imports sont corrigés et utilisent le chemin relatif
import '../../../main.dart';
import '../../../models/task.dart';
import '../../../utils/colors.dart';
import '../../../utils/constanst.dart';
import '../../../utils/strings.dart';
import '../../tasks/task_view.dart';
import 'task_widget.dart';

class TaskListView extends StatelessWidget {
  const TaskListView({super.key});

  /// Checking Done Tasks
  int checkDoneTask(List<Task> task) {
    int i = 0;
    for (Task doneTasks in task) {
      if (doneTasks.isCompleted) {
        i++;
      }
    }
    return i;
  }

  /// Checking The Value Of the Circle Indicator
  double valueOfTheIndicator(List<Task> task) {
    // Renvoie la taille ou 1.0 si vide pour éviter la division par zéro.
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

        /// Sort Task List: Tâches incomplètes en premier, puis par date.
        tasks.sort((a, b) {
          // Tâches non complétées viennent avant les complétées
          if (a.isCompleted != b.isCompleted) {
            return a.isCompleted ? 1 : -1;
          }
          // Sinon, trier par date croissante
          return a.createdAtDate.compareTo(b.createdAtDate);
        });

        return Scaffold(
          // Retiré l'AppBar car HomeView la gère maintenant
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          
          // Floating Action Button pour ajouter une tâche
          floatingActionButton: const FAB(),

          /// Body (Seul le corps est conservé)
          body: _buildBody(
              tasks,
              base,
              textTheme,
            ),
        );
      }
    );
  }

  /// Main Body Content
  SizedBox _buildBody(
    List<Task> tasks,
    BaseWidget base,
    TextTheme textTheme,
  ) {
    final double totalTasks = valueOfTheIndicator(tasks);
    final int doneTasks = checkDoneTask(tasks);
    final double percentage = totalTasks > 0 ? (doneTasks / totalTasks) : 0.0;

    return SizedBox(
      width: double.infinity,
      height: double.infinity,
      child: Column(
        children: [
          /// Top Section Of Home page : Header modernisé avec carte
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
                  /// Grand cercle de progression
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
                          value: percentage, // Utilise la valeur calculée
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

                  /// Textes avec meilleure hiérarchie
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
                  
                  /// Badge de progression
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle, color: Colors.white, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          '${doneTasks}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          /// Bottom ListView : Tasks
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
                          background: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.delete_outline,
                                color: Colors.grey,
                              ),
                              const SizedBox(
                                width: 8,
                              ),
                              Text(MyString.deletedTask,
                                  style: const TextStyle(
                                    color: Colors.grey,
                                  ))
                            ],
                          ),
                          onDismissed: (direction) {
                            base.dataStore.deleteTask(task: task);
                          },
                          // Utilisation d'une clé unique stable
                          key: Key(task.id), 
                          child: TaskWidget(
                            task: tasks[index],
                          ),
                        ),
                      );
                    },
                  )

                /// if All Tasks Done Show this Widgets
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      /// Lottie
                      FadeIn(
                        child: SizedBox(
                          width: 200,
                          height: 200,
                          child: Lottie.asset(
                            lottieURL, // Assurez-vous que cette constante est définie
                            animate: true,
                          ),
                        ),
                      ),

                      /// Bottom Texts
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

/// Floating Action Button (FAB) pour ajouter une tâche
class FAB extends StatelessWidget {
  const FAB({super.key});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      backgroundColor: MyColors.primaryColor,
      heroTag: 'task_list_fab', // Changer le heroTag pour éviter les conflits si MainWrapper avait un FAB
      onPressed: () {
        // Appelle la vue de création/édition de tâche sans arguments pour le mode création
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