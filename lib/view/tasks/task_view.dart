// lib/view/tasks/task_view.dart

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../../main.dart';
import '../../../models/task.dart';
import '../../../data/hive_data_store.dart';
import '../../../utils/colors.dart';
import '../../../services/timer_service.dart';
import '../main_wrapper.dart';
import 'widgets/task_form_section.dart';

class TaskView extends StatefulWidget {
  final Task? task;
  final String? parentId; 

  const TaskView({Key? key, this.task, this.parentId}) : super(key: key);

  @override
  State<TaskView> createState() => _TaskViewState();
}

class _TaskViewState extends State<TaskView> {
  final _titleController = TextEditingController();
  final _noteController = TextEditingController();
  
  bool _isEditing = false;
  DateTime? _startDate;
  DateTime? _endDate;
  int _workingDuration = 0;
  int _priority = 1;

  @override
  void initState() {
    super.initState();
    _isEditing = widget.task == null; 
    if (widget.task != null) {
      _titleController.text = widget.task!.title;
      _noteController.text = widget.task!.subtitle;
      _startDate = widget.task!.startDate;
      _endDate = widget.task!.endDate;
      _workingDuration = widget.task!.workingDuration;
      _priority = widget.task!.priority;
    }
  }

  void _onDataChanged(DateTime? s, DateTime? e, int dur, int p) {
    setState(() { _startDate = s; _endDate = e; _workingDuration = dur; _priority = p; });
  }

  Future<void> _save() async {
    final dataStore = BaseWidget.of(context).dataStore;
    if (_titleController.text.trim().isEmpty) return;

    if (widget.task != null) {
      widget.task!.title = _titleController.text;
      widget.task!.subtitle = _noteController.text;
      widget.task!.startDate = _startDate;
      widget.task!.endDate = _endDate;
      widget.task!.workingDuration = _workingDuration;
      widget.task!.priority = _priority;
      widget.task!.addLog("Mise à jour des informations");
      await widget.task!.save();
      setState(() => _isEditing = false);
    } else {
      final newTask = Task.create(title: _titleController.text, subtitle: _noteController.text, startDate: _startDate, endDate: _endDate, workingDuration: _workingDuration, priority: _priority, parentId: widget.parentId);
      await dataStore.addTask(task: newTask);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dataStore = BaseWidget.of(context).dataStore;
    final timerService = context.watch<TimerService>();

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? "Configuration" : "Fiche de Travail", style: const TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          if (!_isEditing)
            IconButton(icon: const Icon(Icons.edit_note_rounded), onPressed: () => setState(() => _isEditing = true)),
          if (_isEditing)
            IconButton(icon: const Icon(Icons.check_circle_rounded, color: MyColors.primaryColor, size: 28), onPressed: _save),
        ],
      ),
      body: _isEditing ? _buildEditor() : _buildDetails(dataStore, timerService),
    );
  }

  Widget _buildEditor() {
    return TaskFormSection(task: widget.task, titleController: _titleController, noteController: _noteController, onDataChanged: _onDataChanged);
  }

  Widget _buildDetails(dynamic dataStore, TimerService timerService) {
    final t = widget.task!;
    final bool canHaveSubTasks = t.parentId == null;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _buildPriorityBadge(t.priority),
              const Spacer(),
              _buildStatusBadge(t.status),
            ],
          ),
          const SizedBox(height: 16),
          Text(t.title, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, letterSpacing: -0.5)),
          if (t.subtitle.isNotEmpty) Padding(padding: const EdgeInsets.only(top: 8), child: Text(t.subtitle, style: TextStyle(fontSize: 16, color: Colors.grey.shade600))),
          const SizedBox(height: 32),
          _buildInfoGrid(t),
          const SizedBox(height: 40),
          if (canHaveSubTasks) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("CHECKLIST D'EXÉCUTION", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey, fontSize: 12, letterSpacing: 1.1)),
                IconButton(icon: const Icon(Icons.add_circle_outline, color: MyColors.primaryColor), onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (ctx) => TaskView(parentId: t.id)))),
              ],
            ),
            _buildSubTasksList(dataStore, timerService, t),
            const SizedBox(height: 40),
          ],
          const Text("JOURNAL D'ACTIVITÉ", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey, fontSize: 12, letterSpacing: 1.1)),
          const SizedBox(height: 16),
          _buildHistoryList(t),
        ],
      ),
    );
  }

  Widget _buildHistoryList(Task t) {
    if (t.history.isEmpty) return const Text("Aucun événement enregistré", style: TextStyle(fontSize: 13, color: Colors.grey));
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: t.history.map((log) => Padding(padding: const EdgeInsets.only(bottom: 8.0), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [const Icon(Icons.history, size: 14, color: Colors.grey), const SizedBox(width: 8), Expanded(child: Text(log, style: const TextStyle(fontSize: 12, color: Colors.black87, fontFamily: 'monospace')))]))).toList());
  }

  Widget _buildPriorityBadge(int p) {
    final colors = [Colors.green, Colors.orange, Colors.red];
    final labels = ["Basse", "Moyenne", "Haute"];
    return Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), decoration: BoxDecoration(color: colors[p].withOpacity(0.1), borderRadius: BorderRadius.circular(20), border: Border.all(color: colors[p].withOpacity(0.2))), child: Text(labels[p], style: TextStyle(color: colors[p], fontWeight: FontWeight.bold, fontSize: 12)));
  }

  Widget _buildStatusBadge(String s) {
    return Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(20)), child: Text(s.toUpperCase(), style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 10)));
  }

  Widget _buildInfoGrid(Task t) {
    return Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(24)), child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [_buildInfoItem(Icons.calendar_today_rounded, "Période", "${DateFormat('dd/MM').format(t.startDate!)} - ${DateFormat('dd/MM').format(t.endDate!)}"), _buildInfoItem(Icons.timer_rounded, "Travail (Z)", t.durationFormatted)]));
  }

  Widget _buildInfoItem(IconData icon, String label, String value) {
    return Column(children: [Icon(icon, size: 20, color: MyColors.primaryColor), const SizedBox(height: 8), Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)), Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold))]);
  }

  Widget _buildSubTasksList(dynamic dataStore, TimerService timerService, Task parent) {
    final HiveDataStore ds = dataStore;
    return ValueListenableBuilder(
      valueListenable: ds.listenToTask(),
      builder: (ctx, Box<Task> box, _) {
        final subTasks = box.values.where((st) => st.parentId == parent.id).toList();
        if (subTasks.isEmpty) return const Padding(padding: EdgeInsets.all(20), child: Center(child: Text("Aucune sous-tâche définie", style: TextStyle(color: Colors.grey, fontSize: 13))));
        return ListView.builder(
          shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), itemCount: subTasks.length,
          itemBuilder: (ctx, i) {
            final st = subTasks[i];
            
            // 🎯 RÉCUPÉRATION DES ÉTATS
            final bool isRunning = timerService.currentTask?.id == st.id && timerService.isRunning;
            final bool isInProgress = st.status == "In Progress";
            final bool isDone = st.status == "Done" || parent.status == "Done"; // 🎯 CASCADE VISUELLE

            return Container(
              margin: const EdgeInsets.only(top: 12), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade100)),
              child: ListTile(
                title: Text(st.title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, decoration: isDone ? TextDecoration.lineThrough : null)),
                subtitle: Text(st.durationFormatted, style: const TextStyle(fontSize: 12)),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isDone)
                      const Icon(Icons.check_circle, color: Colors.green)
                    else if (isRunning) ...[
                      IconButton(icon: const Icon(CupertinoIcons.checkmark_circle_fill, color: Colors.green), onPressed: () {
                        timerService.pauseTimer(dataStore: ds);
                        setState(() { st.status = "Done"; st.isCompleted = true; st.addLog("Marquée comme terminée"); st.save(); });
                      }),
                      IconButton(icon: const Icon(CupertinoIcons.pause_circle_fill, color: Colors.orange), onPressed: () => timerService.pauseTimer(dataStore: ds)),
                    ] else
                      Row(
                        children: [
                          if (isInProgress)
                            IconButton(icon: const Icon(CupertinoIcons.checkmark_circle_fill, color: Colors.green), onPressed: () {
                              setState(() { st.status = "Done"; st.isCompleted = true; st.addLog("Marquée comme terminée"); st.save(); });
                            }),
                          IconButton(
                            icon: Icon(isInProgress ? CupertinoIcons.play_circle_fill : CupertinoIcons.play_circle, color: MyColors.primaryColor, size: 28), 
                            onPressed: () {
                              Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => MainWrapper(initialIndex: 2)), (route) => false);
                              timerService.startTaskTimer(st);
                            }
                          ),
                        ],
                      ),
                  ],
                ),
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (ctx) => TaskView(task: st))),
              ),
            );
          },
        );
      },
    );
  }
}
