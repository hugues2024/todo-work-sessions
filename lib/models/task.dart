// lib/models/task.dart

import 'package:uuid/uuid.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';

part 'task.g.dart';

@HiveType(typeId: 0)
class Task extends HiveObject {
  Task({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.createdAtTime,
    required this.createdAtDate,
    this.isCompleted = false,
    this.startDate,
    this.endDate,
    this.workingDuration = 0,
    this.priority = 1,
    this.status = "To Do",
    this.parentId,
    this.isOngoing = false,
    List<String>? history,
  }) : history = history ?? [];

  @HiveField(0)
  final String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  String subtitle;

  @HiveField(3)
  DateTime createdAtTime;

  @HiveField(4)
  DateTime createdAtDate;

  @HiveField(5)
  bool isCompleted;

  @HiveField(6)
  DateTime? startDate;

  @HiveField(7)
  DateTime? endDate;

  @HiveField(8)
  int workingDuration;

  @HiveField(9)
  int priority;

  @HiveField(10)
  String status;

  @HiveField(11)
  String? parentId;

  @HiveField(12)
  bool isOngoing;

  @HiveField(13)
  List<String> history; // 🎯 NOUVEAU: Journal d'activité

  // Helpers UX
  bool get isSubTask => parentId != null;

  String get durationFormatted {
    final h = workingDuration ~/ 60;
    final m = workingDuration % 60;
    if (h > 0) return "${h}h${m.toString().padLeft(2, '0')}";
    return "${m}min";
  }

  // 🎯 Méthode pour ajouter une entrée au journal
  void addLog(String message) {
    final now = DateTime.now();
    final timestamp = DateFormat('dd/MM HH:mm').format(now);
    history.insert(0, "[$timestamp] $message");
  }

  factory Task.create({
    required String title,
    String subtitle = "",
    DateTime? startDate,
    DateTime? endDate,
    int workingDuration = 0,
    int priority = 1,
    String? parentId,
  }) {
    final task = Task(
      id: const Uuid().v4(),
      title: title,
      subtitle: subtitle,
      createdAtTime: DateTime.now(),
      createdAtDate: DateTime.now(),
      startDate: startDate ?? DateTime.now(),
      endDate: endDate ?? DateTime.now().add(const Duration(days: 1)),
      workingDuration: workingDuration,
      priority: priority,
      parentId: parentId,
    );
    task.addLog("Création de la ${parentId != null ? 'sous-tâche' : 'tâche'}");
    return task;
  }
}
