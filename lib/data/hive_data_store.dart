// lib/data/hive_data_store.dart - CODE COMPLET CORRIGÉ

import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hive/hive.dart';
import '../models/task.dart';
import '../models/user_profile.dart'; 
import '../models/work_session.dart';
import '../models/user_auth.dart';

///
class HiveDataStore {
  // Constante de la Box Tâches
  static const boxName = "tasksBox";

  // Définitions des Boxes
  final Box<Task> taskBox; // ✅ CHANGEMENT : Renommé 'box' en 'taskBox'
  final Box<WorkSession> sessionBox; // Box WorkSession
  final Box<UserProfile> profileBox; // Box UserProfile
  final Box<UserAuth> authBox; // Box UserAuth

  // Le constructeur DOIT accepter les 4 Box en arguments
  // ✅ CHANGEMENT : Le constructeur utilise maintenant this.taskBox
  HiveDataStore(this.taskBox, this.sessionBox, this.profileBox, this.authBox);

  // =========================================================================
  // 🎯 GESTION DES TÂCHES (CRUD)
  // =========================================================================

  /// Add new Task
  Future<void> addTask({required Task task}) async {
    await taskBox.put(task.id, task); // ✅ CHANGEMENT : Utilise 'taskBox'
  }

  /// Show task
  Future<Task?> getTask({required String id}) async {
    return taskBox.get(id); // ✅ CHANGEMENT : Utilise 'taskBox'
  }

  /// Update task
  Future<void> updateTask({required Task task}) async {
    await task.save();
  }

  /// Delete task
  Future<void> deleteTask({required Task task}) async {
    await task.delete();
  }

  ValueListenable<Box<Task>> listenToTask() {
    return taskBox.listenable(); // ✅ CHANGEMENT : Utilise 'taskBox'
  }
  
  // =========================================================================
  // 👤 GESTION DU PROFIL
  // =========================================================================

  /// Récupère le profil de l'utilisateur actuellement connecté
  UserProfile? getLoggedInUserProfile() {
    final loggedInUser = getLoggedInUser();

    if (loggedInUser.email == 'Utilisateur') { 
        return null; 
    }
    
    // 🎯 CORRECTION/CONFIRMATION : On utilise l'email de l'utilisateur authentifié comme clé du profil
    return profileBox.get(loggedInUser.email);
  }
  
  /// Sauvegarde ou met à jour le profil (lié à l'utilisateur connecté)
  Future<void> saveUserProfile(UserProfile profile) async {
    final loggedInUser = getLoggedInUser();
    
    if (loggedInUser.email != 'Utilisateur') {
      // 🎯 CORRECTION/CONFIRMATION : Met à jour le profil en utilisant l'email comme clé unique
      await profileBox.put(loggedInUser.email, profile);
    }
  }

  ValueListenable<Box<UserProfile>> listenToUserProfile() {
    return profileBox.listenable();
  }

  // =========================================================================
  // ⏱️ GESTION DES SESSIONS DE TRAVAIL (CRUD)
  // =========================================================================

  Future<void> addSession({required WorkSession session}) async {
    await sessionBox.put(session.id, session);
  }

  Future<void> deleteSession({required WorkSession session}) async {
    await session.delete();
  }

  ValueListenable<Box<WorkSession>> listenToSessions() {
    return sessionBox.listenable();
  }

  WorkSession? findSession({required String id}) {
    return sessionBox.get(id);
  }

  // =========================================================================
  // 🔐 GESTION DE L'AUTHENTIFICATION
  // =========================================================================
  
  Future<bool> loginUser(String email, String password) async {
    final user = authBox.get(email);
    
    if (user != null && user.password == password) {
      await logout(); // Déconnecter tous les autres
      user.isLoggedIn = true;
      await user.save();
      return true;
    }
    return false;
  }

  Future<bool> signupUser(String email, String password) async {
    if (authBox.containsKey(email)) {
      return false; // Utilisateur existe déjà
    }
    
    final newUser = UserAuth(email: email, password: password, isLoggedIn: true);
    await logout(); // Déconnecter tous les autres
    
    await authBox.put(email, newUser);
    return true;
  }

  bool isUserLoggedIn() {
    return authBox.values.any((user) => user.isLoggedIn);
  }

  UserAuth getLoggedInUser() {
    final loggedIn = authBox.values.where((user) => user.isLoggedIn);
    if (loggedIn.isNotEmpty) {
      return loggedIn.first;
    }
    // Utilisateur par défaut si personne n'est connecté
    return UserAuth(email: 'Utilisateur', password: '', isLoggedIn: false);
  }

  Future<void> logout() async {
    final users = authBox.values.where((user) => user.isLoggedIn);
    for (var user in users) {
      user.isLoggedIn = false;
      await user.save();
    }
  }

  ValueListenable<Box<UserAuth>> listenToAuth() {
    return authBox.listenable();
  }
}