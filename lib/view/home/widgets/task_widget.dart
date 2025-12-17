// lib/view/home/widgets/task_widget.dart

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../models/task.dart';
import '../../../utils/colors.dart';
import '../../../view/tasks/task_view.dart';

class TaskWidget extends StatefulWidget {
  const TaskWidget({Key? key, required this.task}) : super(key: key);

  final Task task;

  @override
  _TaskWidgetState createState() => _TaskWidgetState();
}

class _TaskWidgetState extends State<TaskWidget> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          CupertinoPageRoute(
            builder: (ctx) => TaskView(
              task: widget.task,
            ),
          ),
        );
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 600),
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
            color: widget.task.isCompleted
                ? Colors.green.shade50
                : Theme.of(context).cardColor, 
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
              // 🎯 RETOUR À LA BARRE DE COULEUR SIMPLE
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
                  leading: GestureDetector(
                    onTap: () {
                      setState(() {
                        widget.task.isCompleted = !widget.task.isCompleted;
                        for (var step in widget.task.steps) {
                          step.isCompleted = widget.task.isCompleted;
                          if (widget.task.isCompleted) {
                            step.completedAt = DateTime.now();
                          } else {
                            step.completedAt = null;
                          }
                        }
                        widget.task.save(); 
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      decoration: BoxDecoration(
                          color: widget.task.isCompleted
                              ? MyColors.primaryColor
                              : Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: widget.task.isCompleted ? MyColors.primaryColor : Colors.grey, 
                            width: 1.5
                          )
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Icon(
                          Icons.check,
                          color: widget.task.isCompleted ? Colors.white : Colors.transparent,
                          size: 18,
                        ),
                      ),
                    ),
                  ),
                  title: Text(
                    widget.task.title,
                    style: TextStyle(
                        color: widget.task.isCompleted
                            ? Colors.grey.shade600
                            : Theme.of(context).textTheme.titleMedium?.color,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        decoration: widget.task.isCompleted
                            ? TextDecoration.lineThrough
                            : null),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (widget.task.subtitle.trim().isNotEmpty)
                        Text(
                          widget.task.subtitle,
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
                      Align(
                        alignment: Alignment.centerRight,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: widget.task.isCompleted ? Colors.green.shade100 : Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            children: [
                              Text(DateFormat('HH:mm').format(widget.task.createdAtTime), style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: widget.task.isCompleted ? Colors.green.shade700 : Colors.grey.shade700)),
                              Text(DateFormat.yMMMEd().format(widget.task.createdAtDate), style: TextStyle(fontSize: 11, color: widget.task.isCompleted ? Colors.green.shade600 : Colors.grey.shade600)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
