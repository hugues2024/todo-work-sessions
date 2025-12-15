// lib/view/tasks/widgets/task_form_section.dart

// ignore_for_file: must_be_immutable, use_build_context_synchronously

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../main.dart';
import '../../../models/task.dart';
import '../../../utils/colors.dart';
import '../../../utils/strings.dart';

class TaskFormSection extends StatefulWidget {
  final Task? task; // null pour la création
  final TextEditingController titleController;
  final TextEditingController noteController;
  final Function(DateTime?, DateTime?) onDateTimeChanged; // Callback pour mettre à jour TaskView

  const TaskFormSection({
    Key? key,
    this.task,
    required this.titleController,
    required this.noteController,
    required this.onDateTimeChanged,
  }) : super(key: key);

  @override
  State<TaskFormSection> createState() => _TaskFormSectionState();
}

class _TaskFormSectionState extends State<TaskFormSection> {
  DateTime? _selectedStartTime; // Variable locale pour la date/heure de début
  DateTime? _selectedEndTime;   // Variable locale pour la date/heure de fin

  @override
  void initState() {
    super.initState();
    // CORRECTION : Utilisation de task?.startDate et task?.endDate
    _selectedStartTime = widget.task?.startDate;
    _selectedEndTime = widget.task?.endDate;
  }

  /// Ouvre le sélecteur de date et heure
  Future<void> _pickDateTime(BuildContext context, bool isStart) async {
    DateTime initialDate = (isStart ? _selectedStartTime : _selectedEndTime) ?? DateTime.now();
    
    // Sélecteur de date
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)), // Année passée
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),   // 5 ans dans le futur
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: MyColors.primaryColor,
            colorScheme: ColorScheme.light(primary: MyColors.primaryColor),
            buttonTheme: const ButtonThemeData(textTheme: ButtonTextTheme.primary),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      // Sélecteur d'heure
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(initialDate),
        builder: (context, child) {
          return Theme(
            data: ThemeData.light().copyWith(
              primaryColor: MyColors.primaryColor,
              colorScheme: ColorScheme.light(primary: MyColors.primaryColor),
              buttonTheme: const ButtonThemeData(textTheme: ButtonTextTheme.primary),
            ),
            child: child!,
          );
        },
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
          if (isStart) {
            _selectedStartTime = newDateTime;
          } else {
            _selectedEndTime = newDateTime;
          }
        });
        
        widget.onDateTimeChanged(_selectedStartTime, _selectedEndTime);
      }
    }
  }

  /// Crée un bouton de sélection de date/heure
  Widget _buildDateTimeButton(
      {required String title,
      required DateTime? dateTime,
      required bool isStart}) {
    final String label = dateTime == null
        ? MyString.chooseTime
        : DateFormat('dd/MM/yyyy HH:mm').format(dateTime);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: MyColors.primaryColor, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () => _pickDateTime(context, isStart),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: dateTime == null ? Colors.grey : Colors.black87,
                      ),
                ),
                Icon(
                  CupertinoIcons.calendar,
                  color: MyColors.primaryColor,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Champ Titre 
          Text(
            MyString.titleOfTitleTextField,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: MyColors.primaryColor, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: widget.titleController,
            decoration: InputDecoration(
              hintText: MyString.taskTitleHint,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              fillColor: Theme.of(context).cardColor,
              filled: true,
            ),
          ),
          
          const SizedBox(height: 20),

          // Sélecteur Heure de Début
          _buildDateTimeButton(
            title: MyString.startDate,
            dateTime: _selectedStartTime,
            isStart: true,
          ),
          
          const SizedBox(height: 20),

          // Sélecteur Heure de Fin
          _buildDateTimeButton(
            title: MyString.endDate,
            dateTime: _selectedEndTime,
            isStart: false,
          ),

          const SizedBox(height: 20),
          
          // Champ Note
          Text(
            MyString.addNote,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: MyColors.primaryColor, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: widget.noteController,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: MyString.addNoteHint,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              fillColor: Theme.of(context).cardColor,
              filled: true,
            ),
          ),
          
          const SizedBox(height: 80), 
        ],
      ),
    );
  }
}