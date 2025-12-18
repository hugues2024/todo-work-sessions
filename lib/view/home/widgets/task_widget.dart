// lib/view/home/widgets/task_widget.dart

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../models/task.dart';
import '../../../utils/colors.dart';
import '../../../view/tasks/task_view.dart';
import '../../../services/timer_service.dart';

class TaskWidget extends StatefulWidget {
  const TaskWidget({Key? key, required this.task}) : super(key: key);
  final Task task;

  @override
  _TaskWidgetState createState() => _TaskWidgetState();
}

class _TaskWidgetState extends State<TaskWidget> {
  
  Color _getPriorityColor(int priority) {
    switch (priority) {
      case 2: return Colors.red;
      case 1: return Colors.orange;
      case 0: return Colors.green;
      default: return MyColors.primaryColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    final timerService = context.watch<TimerService>();
    final priorityColor = _getPriorityColor(widget.task.priority);
    
    // 🎯 État dynamique pour savoir si CETTE tâche est celle qui tourne
    final bool isThisTaskRunning = timerService.currentTask?.id == widget.task.id && timerService.isRunning;
    final bool isThisTaskPaused = timerService.currentTask?.id == widget.task.id && !timerService.isRunning && timerService.remainingDuration > Duration.zero;

    return GestureDetector(
      onTap: () => Navigator.push(context, CupertinoPageRoute(builder: (ctx) => TaskView(task: widget.task))),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(.05), blurRadius: 15, offset: const Offset(0, 5))]
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Container(width: 4, height: 20, decoration: BoxDecoration(color: widget.task.status == "Done" ? Colors.green : priorityColor, borderRadius: BorderRadius.circular(2))),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          widget.task.title,
                          style: TextStyle(
                            fontSize: 18, 
                            fontWeight: FontWeight.bold,
                            decoration: widget.task.status == "Done" ? TextDecoration.lineThrough : null,
                          ),
                          maxLines: 1, overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // 🎯 ACTIONS DYNAMIQUES
                if (widget.task.status != "Done") ...[
                  if (isThisTaskRunning) ...[
                    // Tâche en cours : Pause + Done
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(CupertinoIcons.checkmark_circle_fill, color: Colors.green, size: 28),
                          onPressed: () {
                            timerService.pauseTimer();
                            setState(() {
                              widget.task.status = "Done";
                              widget.task.isCompleted = true;
                              widget.task.save();
                            });
                          },
                        ),
                        IconButton(
                          icon: const Icon(CupertinoIcons.pause_circle_fill, color: Colors.orange, size: 28),
                          onPressed: () => timerService.pauseTimer(),
                        ),
                      ],
                    ),
                  ] else ...[
                    // Tâche en attente ou en pause : Play
                    IconButton(
                      icon: Icon(
                        isThisTaskPaused ? CupertinoIcons.play_circle_fill : CupertinoIcons.play_circle,
                        color: MyColors.primaryColor, 
                        size: 32
                      ),
                      onPressed: () => timerService.startTaskTimer(widget.task),
                    ),
                  ],
                ] else
                  const Icon(Icons.check_circle, color: Colors.green),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _buildSmallInfo(Icons.calendar_today, "${DateFormat('dd/MM').format(widget.task.startDate!)} - ${DateFormat('dd/MM').format(widget.task.endDate!)}"),
                const SizedBox(width: 16),
                _buildSmallInfo(Icons.timer, widget.task.workingDurationFormatted),
                const Spacer(),
                Text(
                  widget.task.status.toUpperCase(),
                  style: TextStyle(color: widget.task.status == "Done" ? Colors.green : priorityColor, fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSmallInfo(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 12, color: Colors.grey),
        const SizedBox(width: 4),
        Text(text, style: const TextStyle(fontSize: 11, color: Colors.grey)),
      ],
    );
  }
}
