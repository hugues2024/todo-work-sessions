// lib/view/tasks/widgets/task_form_section.dart

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../models/task.dart';
import '../../../utils/colors.dart';

class TaskFormSection extends StatefulWidget {
  final Task? task;
  final TextEditingController titleController;
  final TextEditingController noteController;
  final Function(DateTime?, DateTime?, int, int) onDataChanged;

  const TaskFormSection({
    Key? key,
    this.task,
    required this.titleController,
    required this.noteController,
    required this.onDataChanged,
  }) : super(key: key);

  @override
  State<TaskFormSection> createState() => _TaskFormSectionState();
}

class _TaskFormSectionState extends State<TaskFormSection> {
  DateTime? _start;
  DateTime? _end;
  int _duration = 0;
  int _priority = 1;

  @override
  void initState() {
    super.initState();
    _start = widget.task?.startDate;
    _end = widget.task?.endDate;
    _duration = widget.task?.workingDuration ?? 0;
    _priority = widget.task?.priority ?? 1;
  }

  void _sync() => widget.onDataChanged(_start, _end, _duration, _priority);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // TITRE
          const Text("QU'ALLEZ-VOUS ACCOMPLIR ?", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.2)),
          const SizedBox(height: 12),
          TextField(
            controller: widget.titleController,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            decoration: InputDecoration(
              hintText: "Titre de la tâche...",
              border: UnderlineInputBorder(borderSide: BorderSide(color: MyColors.primaryColor.withOpacity(0.2))),
              focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: MyColors.primaryColor, width: 2)),
            ),
          ),
          
          const SizedBox(height: 32),

          // PRIORITÉ (UX: Chips colorés)
          const Text("PRIORITÉ", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildPriorityChip("Basse", 0, Colors.green),
              _buildPriorityChip("Moyenne", 1, Colors.orange),
              _buildPriorityChip("Haute", 2, Colors.red),
            ],
          ),

          const SizedBox(height: 32),

          // DURÉE Z (UX: Slider + Text)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("DURÉE ESTIMÉE (Z)", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
              Text("${_duration ~/ 60}h${(_duration % 60).toString().padLeft(2, '0')}", style: const TextStyle(fontWeight: FontWeight.bold, color: MyColors.primaryColor)),
            ],
          ),
          Slider(
            value: _duration.toDouble(),
            min: 0, max: 480, divisions: 32,
            activeColor: MyColors.primaryColor,
            onChanged: (v) {
              setState(() => _duration = v.toInt());
              _sync();
            },
          ),

          const SizedBox(height: 32),

          // PLAGE DE DATES (X-Y)
          const Text("PÉRIODE (X -> Y)", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildDateTile("Début", _start, true)),
              const SizedBox(width: 12),
              Expanded(child: _buildDateTile("Fin", _end, false)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPriorityChip(String label, int val, Color color) {
    bool selected = _priority == val;
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      selectedColor: color.withOpacity(0.2),
      onSelected: (s) {
        setState(() => _priority = val);
        _sync();
      },
    );
  }

  Widget _buildDateTile(String label, DateTime? date, bool isStart) {
    return InkWell(
      onTap: () async {
        final d = await showDatePicker(context: context, initialDate: date ?? DateTime.now(), firstDate: DateTime.now().subtract(const Duration(days: 30)), lastDate: DateTime.now().add(const Duration(days: 365)));
        if (d != null) {
          setState(() => isStart ? _start = d : _end = d);
          _sync();
        }
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade300)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(date == null ? "Choisir" : DateFormat('dd MMM').format(date), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
