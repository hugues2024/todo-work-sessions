// lib/models/alarm.dart

import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'alarm.g.dart';

@HiveType(typeId: 6) // Utilisation d'un nouvel ID unique
class Alarm extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  int hour;

  @HiveField(2)
  int minute;

  @HiveField(3)
  String label;

  @HiveField(4)
  bool isActive;

  @HiveField(5)
  List<int> repeatDays; // 1 = Lundi, 7 = Dimanche

  @HiveField(6)
  String soundPath;

  Alarm({
    required this.id,
    required this.hour,
    required this.minute,
    this.label = "Alarme",
    this.isActive = true,
    this.repeatDays = const [],
    this.soundPath = "default.mp3",
  });

  factory Alarm.create({required int hour, required int minute, String label = "Alarme"}) {
    return Alarm(
      id: const Uuid().v4(),
      hour: hour,
      minute: minute,
      label: label,
    );
  }

  String get timeFormatted {
    final h = hour.toString().padLeft(2, '0');
    final m = minute.toString().padLeft(2, '0');
    return "$h:$m";
  }
}
