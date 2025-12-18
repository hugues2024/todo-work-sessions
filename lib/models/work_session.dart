// lib/models/work_session.dart

import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'work_session.g.dart';

@HiveType(typeId: 3)
class WorkSession extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  String description;

  @HiveField(3)
  DateTime createdAt; // Début de la session

  @HiveField(4)
  DateTime? completedAt; // Fin de la session

  @HiveField(5)
  int elapsedSeconds; // Temps total travaillé

  @HiveField(6)
  String? taskId; // Optionnel : Lien vers la tâche ou sous-tâche

  @HiveField(7)
  bool isPersonal; // Si démarré sans tâche spécifique

  WorkSession({
    required this.id,
    required this.title,
    this.description = "",
    required this.createdAt,
    this.completedAt,
    this.elapsedSeconds = 0,
    this.taskId,
    this.isPersonal = true,
  });

  factory WorkSession.create({
    required String title,
    String? taskId,
    bool isPersonal = true,
  }) {
    return WorkSession(
      id: const Uuid().v4(),
      title: title,
      createdAt: DateTime.now(),
      taskId: taskId,
      isPersonal: isPersonal,
    );
  }

  String get durationFormatted {
    final h = elapsedSeconds ~/ 3600;
    final m = (elapsedSeconds % 3600) ~/ 60;
    final s = elapsedSeconds % 60;
    return "${h.toString().padLeft(2, '0')}h ${m.toString().padLeft(2, '0')}m ${s.toString().padLeft(2, '0')}s";
  }
}
