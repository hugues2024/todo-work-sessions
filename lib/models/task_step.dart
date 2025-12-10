
// lib/models/task_step.dart

import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'task_step.g.dart';

@HiveType(typeId: 5)
class TaskStep extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  bool isCompleted;

  @HiveField(3)
  DateTime? scheduledStartDate;

  @HiveField(4)
  DateTime? scheduledStartTime;

  @HiveField(5)
  DateTime? completedAt;

  TaskStep({
    required this.id,
    required this.title,
    this.isCompleted = false,
    this.scheduledStartDate,
    this.scheduledStartTime,
    this.completedAt,
  });

  factory TaskStep.create({
    required String title,
    DateTime? scheduledStartDate,
    DateTime? scheduledStartTime,
  }) {
    return TaskStep(
      id: const Uuid().v1(),
      title: title,
      isCompleted: false,
      scheduledStartDate: scheduledStartDate,
      scheduledStartTime: scheduledStartTime,
    );
  }

  void toggleComplete() {
    isCompleted = !isCompleted;
    if (isCompleted) {
      completedAt = DateTime.now();
    } else {
      completedAt = null;
    }
  }
}
