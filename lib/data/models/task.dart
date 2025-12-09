// lib/data/models/task.dart

import 'package:hive/hive.dart';

// Ce fichier sera généré automatiquement par la commande 'build_runner'
part 'task.g.dart'; 

// @HiveType(typeId: 0) est obligatoire pour identifier le modèle dans Hive
@HiveType(typeId: 0) 
class Task extends HiveObject { // Étend HiveObject pour les opérations de base de données
  
  // Chaque champ doit avoir un index unique (@HiveField)
  @HiveField(0)
  final int? id; // L'ID interne pour la synchronisation future avec MySQL

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String? userId; // Optionnel en mode déconnecté

  @HiveField(3)
  bool isCompleted;

  @HiveField(4)
  final DateTime createdAt;

  Task({
    this.id,
    required this.title,
    this.userId,
    this.isCompleted = false,
    required this.createdAt,
  });

  // Pour la synchronisation future avec l'API REST
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'user_id': userId,
      'is_completed': isCompleted,
      'created_at': createdAt.toIso8601String(),
    };
  }
}