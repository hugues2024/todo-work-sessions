// lib/models/work_session.dart

import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'work_session.g.dart'; // Fichier généré par build_runner

@HiveType(typeId: 3) // Assurez-vous d'utiliser un nouvel ID
class WorkSession extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String title; // Ex: "Session Pomodoro pour projet X"

  @HiveField(2)
  late String description;

  @HiveField(3)
  late int workDurationMinutes; // Durée de travail souhaitée (en minutes)

  @HiveField(4)
  late int breakDurationMinutes; // Durée de la pause (en minutes)

  @HiveField(5)
  late DateTime createdAt; // Date de création

  @HiveField(6)
  bool? isCompleted;

  @HiveField(7)
  DateTime? completedAt; // Date de complétion

  @HiveField(8)
  bool? isRunning; // Le chronomètre est en cours

  @HiveField(9)
  int elapsedSeconds; // Secondes écoulées

  @HiveField(10)
  bool? isOnBreak; // En pause ou en travail

  WorkSession({
    required this.title,
    required this.description,
    required this.workDurationMinutes,
    required this.breakDurationMinutes,
    required this.createdAt,
    this.isCompleted = false,
    this.completedAt,
    this.isRunning = false,
    this.elapsedSeconds = 0,
    this.isOnBreak = false,
  }) : id = const Uuid().v4();

  // Constructeur pour faciliter l'ajout
  static WorkSession create({
    required String title,
    required String description,
    required int workDurationMinutes,
    required int breakDurationMinutes,
  }) {
    return WorkSession(
      title: title,
      description: description,
      workDurationMinutes: workDurationMinutes,
      breakDurationMinutes: breakDurationMinutes,
      createdAt: DateTime.now(),
      isCompleted: false,
      isRunning: false,
      elapsedSeconds: 0,
      isOnBreak: false,
    );
  }

  // Obtenir le temps restant
  int getRemainingSeconds() {
    final bool onBreak = isOnBreak ?? false;

    int totalDuration = onBreak ? breakDurationMinutes * 60 : workDurationMinutes * 60;
    return totalDuration - elapsedSeconds;
  }

  double getProgress() {
    final bool onBreak = isOnBreak ?? false;

    int totalDuration = onBreak ? breakDurationMinutes * 60 : workDurationMinutes * 60;
    return elapsedSeconds / totalDuration;
  }

}