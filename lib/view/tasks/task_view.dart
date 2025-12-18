// lib/view/tasks/task_view.dart

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../../main.dart';
import '../../../models/task.dart';
import '../../../utils/colors.dart';
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
    _startDate = s; _endDate = e; _workingDuration = dur; _priority = p;
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
      await widget.task!.save();
      setState(() => _isEditing = false);
    } else {
      final newTask = Task.create(
        title: _titleController.text,
        subtitle: _noteController.text,
        startDate: _startDate,
        endDate: _endDate,
        workingDuration: _workingDuration,
        priority: _priority,
        parentId: widget.parentId,
      );
      await dataStore.addTask(task: newTask);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dataStore = BaseWidget.of(context).dataStore;

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? "Configuration" : "Détails"),
        actions: [
          if (!_isEditing)
            IconButton(icon: const Icon(Icons.edit), onPressed: () => setState(() => _isEditing = true)),
          if (_isEditing)
            IconButton(icon: const Icon(Icons.check, color: MyColors.primaryColor), onPressed: _save),
        ],
      ),
      body: _isEditing ? _buildEditor() : _buildDetails(dataStore),
    );
  }

  Widget _buildEditor() {
    return TaskFormSection(
      task: widget.task,
      titleController: _titleController,
      noteController: _noteController,
      onDataChanged: _onDataChanged,
    );
  }

  Widget _buildDetails(dynamic dataStore) {
    final t = widget.task!;
    // 🎯 FIX: Une sous-tâche ne peut pas avoir de sous-tâches
    final bool canHaveSubTasks = t.parentId == null;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(t.title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(t.subtitle, style: const TextStyle(color: Colors.grey)),
          const SizedBox(height: 24),
          
          _buildInfoRow(Icons.calendar_today, "Plage : ${DateFormat('dd/MM').format(t.startDate!)} - ${DateFormat('dd/MM').format(t.endDate!)}"),
          _buildInfoRow(Icons.timer, "Durée de travail : ${t.workingDurationFormatted}"),
          
          if (canHaveSubTasks) ...[
            const Divider(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("SOUS-TÂCHES", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                TextButton.icon(
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text("Ajouter"),
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (ctx) => TaskView(parentId: t.id))),
                ),
              ],
            ),
            
            ValueListenableBuilder(
              valueListenable: dataStore.listenToTask(),
              builder: (ctx, Box<Task> box, _) {
                final subTasks = box.values.where((st) => st.parentId == t.id).toList();
                if (subTasks.isEmpty) return const Text("Aucune sous-tâche");
                
                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: subTasks.length,
                  itemBuilder: (ctx, i) {
                    final st = subTasks[i];
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(st.title),
                      subtitle: Text(st.workingDurationFormatted),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (ctx) => TaskView(task: st))),
                    );
                  },
                );
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(children: [Icon(icon, size: 16, color: MyColors.primaryColor), const SizedBox(width: 12), Text(text)]),
    );
  }
}
