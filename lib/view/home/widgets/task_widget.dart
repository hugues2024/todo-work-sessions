import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

///
import '../../../models/task.dart';
import '../../../utils/colors.dart';
import '../../../view/tasks/task_view.dart';

class TaskWidget extends StatefulWidget {
  const TaskWidget({Key? key, required this.task}) : super(key: key);

  final Task task;

  @override
  // ignore: library_private_types_in_public_api
  _TaskWidgetState createState() => _TaskWidgetState();
}

class _TaskWidgetState extends State<TaskWidget> {
  TextEditingController taskControllerForTitle = TextEditingController();
  TextEditingController taskControllerForSubtitle = TextEditingController();
  @override
  void initState() {
    super.initState();
    taskControllerForTitle.text = widget.task.title;
    taskControllerForSubtitle.text = widget.task.subtitle;
  }

  @override
  void dispose() {
    taskControllerForTitle.dispose();
    taskControllerForSubtitle.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          CupertinoPageRoute(
            builder: (ctx) => TaskView(
              taskControllerForTitle: taskControllerForTitle,
              taskControllerForSubtitle: taskControllerForSubtitle,
              task: widget.task,
            ),
          ),
        );
      },

      /// Main Card - Style Material 3 modernisé
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 600),
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
            color: widget.task.isCompleted
                ? Colors.green.shade50
                : Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(.08),
                  offset: const Offset(0, 4),
                  blurRadius: 20,
                  spreadRadius: -5)
            ]),
        child: IntrinsicHeight(
          child: Row(
            children: [
              /// Barre verticale colorée selon le statut
              AnimatedContainer(
                duration: const Duration(milliseconds: 600),
                width: 5,
                decoration: BoxDecoration(
                  color: widget.task.isCompleted
                      ? Colors.green
                      : MyColors.primaryColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    bottomLeft: Radius.circular(16),
                  ),
                ),
              ),
              Expanded(
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),

            /// Check icon
            leading: GestureDetector(
              onTap: () {
                // Marquer/démarquer la tâche comme complétée
                widget.task.isCompleted = !widget.task.isCompleted;
                
                // Synchroniser toutes les étapes avec l'état de la tâche
                for (var step in widget.task.steps) {
                  step.isCompleted = widget.task.isCompleted;
                  if (widget.task.isCompleted) {
                    step.completedAt = DateTime.now();
                  } else {
                    step.completedAt = null;
                  }
                }
                
                widget.task.save();
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 600),
                decoration: BoxDecoration(
                    color: widget.task.isCompleted
                        ? MyColors.primaryColor
                        : Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.grey, width: .8)),
                child: const Icon(
                  Icons.check,
                  color: Colors.white,
                ),
              ),
            ),

            /// title of Task
            title: Padding(
              padding: const EdgeInsets.only(bottom: 5, top: 3),
              child: Text(
                taskControllerForTitle.text,
                style: TextStyle(
                    color: widget.task.isCompleted
                        ? Colors.grey.shade600
                        : Colors.black,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    decoration: widget.task.isCompleted
                        ? TextDecoration.lineThrough
                        : null),
              ),
            ),

            /// Description of task
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  taskControllerForSubtitle.text,
                  style: TextStyle(
                    color: widget.task.isCompleted
                        ? Colors.grey.shade500
                        : Colors.grey.shade600,
                    fontWeight: FontWeight.w400,
                    fontSize: 14,
                    decoration: widget.task.isCompleted
                        ? TextDecoration.lineThrough
                        : null,
                  ),
                ),

                const SizedBox(height: 8),

                /// Barre de progression si des étapes existent
                if (widget.task.steps.isNotEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: LinearProgressIndicator(
                                value: widget.task.completionPercentage / 100,
                                minHeight: 6,
                                backgroundColor: Colors.grey.shade200,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  widget.task.isCompleted
                                      ? Colors.green
                                      : MyColors.primaryColor,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            "${widget.task.completionPercentage.toInt()}%",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: widget.task.isCompleted
                                  ? Colors.green.shade700
                                  : MyColors.primaryColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "${widget.task.steps.where((s) => s.isCompleted).length}/${widget.task.steps.length} étapes complétées",
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),

                const SizedBox(height: 8),

                /// Date & Time of Task
                Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: const EdgeInsets.only(
                      bottom: 10,
                      top: 2,
                    ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: widget.task.isCompleted
                            ? Colors.green.shade100
                            : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            DateFormat('HH:mm')
                                .format(widget.task.createdAtTime),
                            style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: widget.task.isCompleted
                                    ? Colors.green.shade700
                                    : Colors.grey.shade700),
                          ),
                          Text(
                            DateFormat.yMMMEd()
                                .format(widget.task.createdAtDate),
                            style: TextStyle(
                                fontSize: 11,
                                color: widget.task.isCompleted
                                    ? Colors.green.shade600
                                    : Colors.grey.shade600),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            )),
                ),
              
            ],
          ),
        ),
      ),
    );
  }
}
