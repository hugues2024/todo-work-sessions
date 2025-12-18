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
  DateTime createdAt;

  @HiveField(4)
  DateTime? completedAt;

  @HiveField(5)
  int elapsedSeconds;

  @HiveField(6)
  String? taskId;

  @HiveField(7)
  bool isPersonal;

  @HiveField(8)
  String sessionType;

  @HiveField(9)
  int workDurationMinutes; // AJOUTÉ

  @HiveField(10)
  int breakDurationMinutes; // AJOUTÉ

  WorkSession({
    required this.id,
    required this.title,
    this.description = "",
    required this.createdAt,
    this.completedAt,
    this.elapsedSeconds = 0,
    this.taskId,
    this.isPersonal = true,
    this.sessionType = 'Timer',
    this.workDurationMinutes = 25,
    this.breakDurationMinutes = 5,
  });

  factory WorkSession.create({
    required String title,
    String description = "",
    String? taskId,
    bool isPersonal = true,
    String sessionType = 'Timer',
    int workDurationMinutes = 25,
    int breakDurationMinutes = 5,
  }) {
    return WorkSession(
      id: const Uuid().v4(),
      title: title,
      description: description,
      createdAt: DateTime.now(),
      taskId: taskId,
      isPersonal: isPersonal,
      sessionType: sessionType,
      workDurationMinutes: workDurationMinutes,
      breakDurationMinutes: breakDurationMinutes,
    );
  }

  String get durationFormatted {
    final h = elapsedSeconds ~/ 3600;
    final m = (elapsedSeconds % 3600) ~/ 60;
    final s = elapsedSeconds % 60;
    return "${h.toString().padLeft(2, '0')}h ${m.toString().padLeft(2, '0')}m ${s.toString().padLeft(2, '0')}s";
  }
}
