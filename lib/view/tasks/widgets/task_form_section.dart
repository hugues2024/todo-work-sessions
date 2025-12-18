// lib/view/tasks/widgets/task_form_section.dart

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../models/task.dart';
import '../../../utils/colors.dart';
import '../../../utils/strings.dart';

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
  DateTime? _selectedStartTime;
  DateTime? _selectedEndTime;
  int _workingDuration = 0;
  int _priority = 1; // 0: Basse, 1: Moyenne, 2: Haute

  @override
  void initState() {
    super.initState();
    _selectedStartTime = widget.task?.startDate;
    _selectedEndTime = widget.task?.endDate;
    _workingDuration = widget.task?.workingDuration ?? 0;
    _priority = widget.task?.priority ?? 1;
  }

  void _notifyChanges() {
    widget.onDataChanged(_selectedStartTime, _selectedEndTime, _workingDuration, _priority);
  }

  Future<void> _pickDateTime(BuildContext context, bool isStart) async {
    DateTime initialDate = (isStart ? _selectedStartTime : _selectedEndTime) ?? DateTime.now();
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );

    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(initialDate),
      );

      if (pickedTime != null) {
        final newDateTime = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );

        setState(() {
          if (isStart) _selectedStartTime = newDateTime;
          else _selectedEndTime = newDateTime;
        });
        _notifyChanges();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // TITRE
          _buildLabel("Qu'avez-vous prévu ?"),
          TextField(
            controller: widget.titleController,
            decoration: InputDecoration(
              hintText: "Titre de la tâche",
              filled: true,
              fillColor: Theme.of(context).cardColor,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            ),
          ),
          const SizedBox(height: 24),

          // PRIORITÉ
          _buildLabel("Priorité"),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildPriorityChip("Basse", 0, Colors.green),
              _buildPriorityChip("Moyenne", 1, Colors.orange),
              _buildPriorityChip("Haute", 2, Colors.red),
            ],
          ),
          const SizedBox(height: 24),

          // DURÉE (Z)
          _buildLabel("Durée de travail effective"),
          Row(
            children: [
              Expanded(
                child: Slider(
                  value: _workingDuration.toDouble(),
                  min: 0,
                  max: 480, // 8 heures
                  divisions: 96,
                  activeColor: MyColors.primaryColor,
                  onChanged: (v) {
                    setState(() => _workingDuration = v.toInt());
                    _notifyChanges();
                  },
                ),
              ),
              Text(
                "${_workingDuration ~/ 60}h ${_workingDuration % 60}m",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // DATES (X et Y)
          Row(
            children: [
              Expanded(child: _buildDateTimeBtn("Début", _selectedStartTime, true)),
              const SizedBox(width: 16),
              Expanded(child: _buildDateTimeBtn("Fin", _selectedEndTime, false)),
            ],
          ),
          const SizedBox(height: 24),

          // NOTES
          _buildLabel("Notes"),
          TextField(
            controller: widget.noteController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: "Ajouter un contexte...",
              filled: true,
              fillColor: Theme.of(context).cardColor,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(text, style: TextStyle(color: MyColors.primaryColor, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildPriorityChip(String label, int value, Color color) {
    final isSelected = _priority == value;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: color.withOpacity(0.2),
      onSelected: (s) {
        setState(() => _priority = value);
        _notifyChanges();
      },
    );
  }

  Widget _buildDateTimeBtn(String label, DateTime? date, bool isStart) {
    return InkWell(
      onTap: () => _pickDateTime(context, isStart),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              date == null ? "Choisir" : DateFormat('dd/MM HH:mm').format(date),
              style: const TextStyle(fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
