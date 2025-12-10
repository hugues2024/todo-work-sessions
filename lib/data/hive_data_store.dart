// lib/data/hive_data_store.dart

import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hive/hive.dart';
import '../models/task.dart';
import '../models/user_profile.dart'; 
import '../models/work_session.dart'; 

///
class HiveDataStore {
  // Constante de la Box Tâches
  static const boxName = "tasksBox";

  // Définitions des Boxes
  final Box<UserProfile> userBox = Hive.box<UserProfile>("userProfileBox");
  final Box<WorkSession> sessionBox = Hive.box<WorkSession>("workSessionsBox"); 
  final Box<Task> box = Hive.box<Task>(boxName);

  // =========================================================================
  // 🎯 GESTION DES TÂCHES (CRUD)
  // =========================================================================

  /// Add new Task
  Future<void> addTask({required Task task}) async {
    await box.put(task.id, task);
  }

  /// Show task
  Future<Task?> getTask({required String id}) async {
    return box.get(id);
  }

  /// Update task
  Future<void> updateTask({required Task task}) async {
    await task.save();
  }

  /// Delete task (CORRECTION DE LA FAUTE DE FRAPPE : dalateTask -> deleteTask)
  Future<void> deleteTask({required Task task}) async {
    await task.delete();
  }

  ValueListenable<Box<Task>> listenToTask() {
    return box.listenable();
  }
  
  // =========================================================================
  // 👤 GESTION DU PROFIL
  // =========================================================================

  // Cette méthode récupère le profil (ou null s'il n'existe pas)
  // NOTE : Cette méthode est dangereuse si la box est vide (RangeError). 
  // L'accès sûr est déjà géré dans home_view.dart.
  UserProfile? getUserProfile() {
    return userBox.isNotEmpty ? userBox.getAt(0) : null;
  }

  // Cette méthode ajoute ou met à jour le profil (on utilise un seul index 0)
  void saveUserProfile(UserProfile profile) {
    if (userBox.isEmpty) {
      userBox.add(profile);
    } else {
      userBox.putAt(0, profile);
    }
  }

  ValueListenable<Box<UserProfile>> listenToUserProfile() {
    return userBox.listenable();
  }

  // =========================================================================
  // ⏱️ GESTION DES SESSIONS DE TRAVAIL (CRUD) - AJOUTÉ
  // =========================================================================

  // 1. Ajouter une nouvelle session (CORRECTION : Méthode manquante `addSession`)
  Future<void> addSession({required WorkSession session}) async {
    await sessionBox.put(session.id, session);
  }

  // 2. Supprimer une session (CORRECTION : Méthode manquante `deleteSession`, et faute de frappe corrigée dans les vues)
  Future<void> deleteSession({required WorkSession session}) async {
    await session.delete();
  }

  // 3. Écouter les changements des sessions (CORRECTION : Méthode manquante `listenToSessions`)
  ValueListenable<Box<WorkSession>> listenToSessions() {
    return sessionBox.listenable();
  }

  // Méthode pour trouver une session par ID (optionnel, mais utile)
  WorkSession? findSession({required String id}) {
    return sessionBox.get(id);
  }
}