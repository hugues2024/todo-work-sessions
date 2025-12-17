// lib/view/clock/alarm_edit_view.dart

import 'package:flutter/material.dart';
import '../../models/alarm.dart';
import '../../utils/colors.dart';
import '../../main.dart';

class AlarmEditView extends StatefulWidget {
  final Alarm? alarm;

  const AlarmEditView({super.key, this.alarm});

  @override
  State<AlarmEditView> createState() => _AlarmEditViewState();
}

class _AlarmEditViewState extends State<AlarmEditView> {
  late TimeOfDay _selectedTime;
  late TextEditingController _labelController;
  late List<int> _selectedDays;

  final List<String> _daysOfWeek = ["L", "M", "M", "J", "V", "S", "D"];

  @override
  void initState() {
    super.initState();
    _selectedTime = widget.alarm != null 
        ? TimeOfDay(hour: widget.alarm!.hour, minute: widget.alarm!.minute) 
        : TimeOfDay.now();
    _labelController = TextEditingController(text: widget.alarm?.label ?? "Alarme");
    _selectedDays = List<int>.from(widget.alarm?.repeatDays ?? []);
  }

  void _toggleDay(int day) {
    setState(() {
      if (_selectedDays.contains(day)) {
        _selectedDays.remove(day);
      } else {
        _selectedDays.add(day);
      }
    });
  }

  Future<void> _saveAlarm() async {
    final dataStore = BaseWidget.of(context).dataStore;
    if (widget.alarm != null) {
      widget.alarm!.hour = _selectedTime.hour;
      widget.alarm!.minute = _selectedTime.minute;
      widget.alarm!.label = _labelController.text;
      widget.alarm!.repeatDays = _selectedDays;
      await widget.alarm!.save();
    } else {
      final newAlarm = Alarm(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        hour: _selectedTime.hour,
        minute: _selectedTime.minute,
        label: _labelController.text,
        repeatDays: _selectedDays,
      );
      await dataStore.addAlarm(newAlarm);
    }
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.alarm == null ? "Nouvelle alarme" : "Modifier l'alarme"),
        actions: [
          IconButton(onPressed: _saveAlarm, icon: const Icon(Icons.check, color: MyColors.primaryColor)),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // HEURE
            Center(
              child: GestureDetector(
                onTap: () async {
                  // Utilisation de entryMode pour forcer le mode cadran qui est plus stable sur Linux
                  final TimeOfDay? picked = await showTimePicker(
                    context: context,
                    initialTime: _selectedTime,
                    initialEntryMode: TimePickerEntryMode.dial,
                  );
                  if (picked != null) setState(() => _selectedTime = picked);
                },
                child: Text(
                  "${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}",
                  style: const TextStyle(fontSize: 80, fontWeight: FontWeight.w200),
                ),
              ),
            ),
            const SizedBox(height: 40),

            // RÉPÉTITION
            const Text("Répéter", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(7, (index) {
                final day = index + 1;
                final isSelected = _selectedDays.contains(day);
                return GestureDetector(
                  onTap: () => _toggleDay(day),
                  child: Container(
                    width: 40, height: 40,
                    decoration: BoxDecoration(
                      color: isSelected ? MyColors.primaryColor : (isDarkMode ? Colors.white10 : Colors.grey.shade200),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        _daysOfWeek[index],
                        style: TextStyle(color: isSelected ? Colors.white : (isDarkMode ? Colors.white70 : Colors.black87), fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 40),

            // LIBELLÉ
            const Text("Nom de l'alarme", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
            TextField(
              controller: _labelController,
              decoration: const InputDecoration(hintText: "Ex: Travail, Sport..."),
            ),
          ],
        ),
      ),
    );
  }
}
