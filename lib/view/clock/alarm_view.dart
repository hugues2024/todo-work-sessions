// lib/view/clock/alarm_view.dart

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../utils/colors.dart';
import '../../models/alarm.dart';
import '../../main.dart';
import 'alarm_edit_view.dart'; // NOUVEAU

class AlarmView extends StatefulWidget {
  const AlarmView({super.key});

  @override
  State<AlarmView> createState() => _AlarmViewState();
}

class _AlarmViewState extends State<AlarmView> {
  
  void _navigateToEdit(BuildContext context, {Alarm? alarm}) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AlarmEditView(alarm: alarm)),
    );
  }

  String _formatRepeatDays(List<int> days) {
    if (days.isEmpty) return "Une seule fois";
    if (days.length == 7) return "Tous les jours";
    const dayNames = ["Lun", "Mar", "Mer", "Jeu", "Ven", "Sam", "Dim"];
    days.sort();
    return days.map((d) => dayNames[d - 1]).join(", ");
  }

  @override
  Widget build(BuildContext context) {
    final dataStore = BaseWidget.of(context).dataStore;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDarkMode ? Colors.white : Colors.black;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Alarm', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        actions: [
          IconButton(icon: const Icon(CupertinoIcons.add), onPressed: () => _navigateToEdit(context)),
        ],
      ),
      body: ValueListenableBuilder(
        valueListenable: dataStore.listenToAlarms(),
        builder: (context, Box<Alarm> box, _) {
          final alarms = box.values.toList();
          if (alarms.isEmpty) return const Center(child: Text("Aucune alarme réglée"));

          return ListView.builder(
            itemCount: alarms.length,
            itemBuilder: (context, index) {
              final alarm = alarms[index];
              return Dismissible(
                key: Key(alarm.id),
                direction: DismissDirection.endToStart,
                onDismissed: (_) => dataStore.deleteAlarm(alarm),
                background: Container(alignment: Alignment.centerRight, padding: const EdgeInsets.only(right: 20), color: Colors.red, child: const Icon(Icons.delete, color: Colors.white)),
                child: ListTile(
                  onTap: () => _navigateToEdit(context, alarm: alarm),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  title: Text(alarm.timeFormatted, style: TextStyle(fontSize: 48, fontWeight: FontWeight.w200, color: alarm.isActive ? textColor : Colors.grey)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(alarm.label, style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text(_formatRepeatDays(alarm.repeatDays), style: const TextStyle(color: Colors.grey, fontSize: 12)),
                    ],
                  ),
                  trailing: CupertinoSwitch(
                    value: alarm.isActive,
                    onChanged: (v) {
                      alarm.isActive = v;
                      alarm.save();
                    },
                    activeColor: MyColors.primaryColor,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
