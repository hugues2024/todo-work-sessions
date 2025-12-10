
import 'package:uuid/uuid.dart';
import 'package:hive/hive.dart';
import 'task_step.dart';

part 'task.g.dart';

@HiveType(typeId: 0)
class Task extends HiveObject {
  Task({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.createdAtTime,
    required this.createdAtDate,
    required this.isCompleted,
    List<TaskStep>? steps,
  }) : steps = steps ?? [];

  /// ID
  @HiveField(0)
  final String id;

  /// TITLE
  @HiveField(1)
  String title;

  /// SUBTITLE
  @HiveField(2)
  String subtitle;

  /// CREATED AT TIME
  @HiveField(3)
  DateTime createdAtTime;

  /// CREATED AT DATE
  @HiveField(4)
  DateTime createdAtDate;

  /// IS COMPLETED
  @HiveField(5)
  bool isCompleted;

  /// STEPS (étapes de réalisation)
  @HiveField(6)
  List<TaskStep> steps;

  /// Calculer le pourcentage de completion basé sur les étapes
  double get completionPercentage {
    if (steps.isEmpty) {
      return isCompleted ? 100.0 : 0.0;
    }
    final completedSteps = steps.where((step) => step.isCompleted).length;
    return (completedSteps / steps.length) * 100;
  }

  /// Vérifier si toutes les étapes sont complétées
  bool get allStepsCompleted {
    if (steps.isEmpty) return isCompleted;
    return steps.every((step) => step.isCompleted);
  }

  /// Ajouter une étape
  void addStep(TaskStep step) {
    steps.add(step);
    save();
  }

  /// Supprimer une étape
  void removeStep(TaskStep step) {
    steps.remove(step);
    save();
  }

  /// Mettre à jour l'état de completion globale
  void updateCompletionStatus() {
    if (steps.isNotEmpty) {
      isCompleted = allStepsCompleted;
    }
    save();
  }

  /// create new Task 
  factory Task.create({
    required String? title,
    required String? subtitle,
    DateTime? createdAtTime,
    DateTime? createdAtDate,
    List<TaskStep>? steps,
  }) =>
      Task(
        id: const Uuid().v1(),
        title: title ?? "",
        subtitle: subtitle ?? "",
        createdAtTime: createdAtTime ?? DateTime.now(),
        isCompleted: false,
        createdAtDate: createdAtDate ?? DateTime.now(),
        steps: steps ?? [],
      );
}
