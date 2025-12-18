// lib/view/home/widgets/task_widget.dart

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../../models/task.dart';
import '../../../utils/colors.dart';
import '../../../utils/constanst.dart'; // 🎯 FIX: Import ajouté
import '../../../view/tasks/task_view.dart';
import '../../../services/timer_service.dart';
import '../../../main.dart';

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
    final dataStore = BaseWidget.of(context).dataStore;
    final priorityColor = _getPriorityColor(widget.task.priority);
    
    final bool isThisTaskActive = timerService.currentTask?.id == widget.task.id;
    final bool isRunning = isThisTaskActive && timerService.isRunning;
    final bool isDone = widget.task.status == "Done";
    final bool isInProgress = widget.task.status == "In Progress";

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
                      Container(width: 4, height: 20, decoration: BoxDecoration(color: isDone ? Colors.green : priorityColor, borderRadius: BorderRadius.circular(2))),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          widget.task.title,
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, decoration: isDone ? TextDecoration.lineThrough : null),
                          maxLines: 1, overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                
                if (isDone)
                  const Icon(Icons.check_circle, color: Colors.green)
                else if (isRunning)
                  Row(
                    children: [
                      IconButton(icon: const Icon(CupertinoIcons.checkmark_circle_fill, color: Colors.green, size: 28), onPressed: () => _markAsDone(timerService, dataStore)),
                      IconButton(icon: const Icon(CupertinoIcons.pause_circle_fill, color: Colors.orange, size: 28), onPressed: () => timerService.pauseTimer(dataStore: dataStore)),
                    ],
                  )
                else
                  Row(
                    children: [
                      if (isInProgress)
                        IconButton(icon: const Icon(CupertinoIcons.checkmark_circle_fill, color: Colors.green, size: 28), onPressed: () => _markAsDone(timerService, dataStore)),
                      IconButton(
                        icon: Icon(isInProgress ? CupertinoIcons.play_circle_fill : CupertinoIcons.play_circle, color: MyColors.primaryColor, size: 32),
                        onPressed: () => timerService.startTaskTimer(widget.task),
                      ),
                    ],
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _buildSmallInfo(Icons.calendar_today, "${DateFormat('dd/MM').format(widget.task.startDate!)} - ${DateFormat('dd/MM').format(widget.task.endDate!)}"),
                const SizedBox(width: 16),
                _buildSmallInfo(Icons.timer, widget.task.durationFormatted),
                const Spacer(),
                Text(widget.task.status.toUpperCase(), style: TextStyle(color: isDone ? Colors.green : priorityColor, fontSize: 10, fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _markAsDone(dynamic timerService, dynamic dataStore) async {
    timerService.pauseTimer(dataStore: dataStore); 
    setState(() {
      widget.task.status = "Done";
      widget.task.isCompleted = true;
      widget.task.addLog("Marquée comme terminée (Cascade activée)");
      
      final box = Hive.box<Task>(Constants.taskBox);
      final subTasks = box.values.where((t) => t.parentId == widget.task.id);
      for (var st in subTasks) {
        st.status = "Done";
        st.isCompleted = true;
        st.addLog("Terminée par cascade du parent");
        st.save();
      }
      
      widget.task.save();
    });
  }

  Widget _buildSmallInfo(IconData icon, String text) {
    return Row(children: [Icon(icon, size: 12, color: Colors.grey), const SizedBox(width: 4), Text(text, style: const TextStyle(fontSize: 11, color: Colors.grey))]);
  }
}
