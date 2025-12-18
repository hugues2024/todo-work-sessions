// lib/models/task.dart

import 'package:uuid/uuid.dart';
import 'package:hive/hive.dart';

part 'task.g.dart';

@HiveType(typeId: 0)
class Task extends HiveObject {
  Task({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.createdAtTime,
    required this.createdAtDate,
    bool? isCompleted, // 🎯 Nullable
    bool? isOngoing,   // 🎯 Nullable
    this.startDate,
    this.endDate,
    this.parentId,
    this.workingDuration = 0,
    this.priority = 1,
    this.status = "To Do",
  }) : _isCompleted = isCompleted ?? false,
       _isOngoing = isOngoing ?? false;

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
  bool? _isCompleted; // 🎯 Stockage nullable pour la migration

  @HiveField(7)
  DateTime? startDate;

  @HiveField(8)
  DateTime? endDate;
  
  @HiveField(9)
  bool? _isOngoing; // 🎯 Stockage nullable pour la migration

  @HiveField(10)
  String? parentId; 

  @HiveField(11)
  int workingDuration; 

  @HiveField(12)
  int priority; 

  @HiveField(13)
  String status;

  // 🎯 Getters/Setters pour garder le reste du code propre (non-nullable)
  bool get isCompleted => _isCompleted ?? false;
  set isCompleted(bool val) => _isCompleted = val;

  bool get isOngoing => _isOngoing ?? false;
  set isOngoing(bool val) => _isOngoing = val;

  // HELPERS
  bool get isSubTask => parentId != null;

  String get workingDurationFormatted {
    final h = workingDuration ~/ 60;
    final m = workingDuration % 60;
    if (h > 0) return "${h}h ${m}m";
    return "${m}m";
  }

  factory Task.create({
    required String title,
    String subtitle = "",
    DateTime? startDate,
    DateTime? endDate,
    String? parentId,
    int workingDuration = 0,
    int priority = 1,
  }) {
    return Task(
      id: const Uuid().v4(),
      title: title,
      subtitle: subtitle,
      createdAtTime: DateTime.now(),
      createdAtDate: DateTime.now(),
      startDate: startDate ?? DateTime.now(),
      endDate: endDate ?? DateTime.now().add(const Duration(hours: 1)),
      parentId: parentId,
      workingDuration: workingDuration,
      priority: priority,
      isCompleted: false,
      isOngoing: false,
    );
  }
}
