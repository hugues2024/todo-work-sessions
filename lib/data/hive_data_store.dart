// lib/data/hive_data_store.dart

import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hive/hive.dart';
import '../models/task.dart';
import '../models/user_profile.dart'; 
import '../models/work_session.dart';
import '../models/user_auth.dart';
import '../models/alarm.dart'; 

class HiveDataStore {
  final Box<Task> taskBox; 
  final Box<WorkSession> sessionBox; 
  final Box<UserProfile> profileBox; 
  final Box<UserAuth> authBox; 
  final Box<Alarm> alarmBox; 

  static const String _profileKey = "user_profile_key";

  HiveDataStore(this.taskBox, this.sessionBox, this.profileBox, this.authBox, this.alarmBox);

  // --- TÂCHES ---
  Future<void> addTask({required Task task}) async { await taskBox.put(task.id, task); }
  Future<void> updateTask({required Task task}) async { await task.save(); }
  Future<void> deleteTask({required Task task}) async { await task.delete(); }
  ValueListenable<Box<Task>> listenToTask() => taskBox.listenable();
  
  // --- PROFIL ---
  UserProfile? getLoggedInUserProfile() => profileBox.get(_profileKey);
  Future<void> saveUserProfile(UserProfile profile) async { await profileBox.put(_profileKey, profile); }
  ValueListenable<Box<UserProfile>> listenToUserProfile() => profileBox.listenable();

  // --- SESSIONS ---
  Future<void> addSession({required WorkSession session}) async { await sessionBox.put(session.id, session); }
  Future<void> deleteSession({required WorkSession session}) async { await session.delete(); }
  ValueListenable<Box<WorkSession>> listenToSessions() => sessionBox.listenable();

  // --- ALARMES ---
  Future<void> addAlarm(Alarm alarm) async { await alarmBox.put(alarm.id, alarm); }
  Future<void> deleteAlarm(Alarm alarm) async { await alarm.delete(); }
  ValueListenable<Box<Alarm>> listenToAlarms() => alarmBox.listenable();

  // --- AUTH ---
  // 🎯 RESTAURATION DE LA MÉTHODE isUserLoggedIn
  bool isUserLoggedIn() {
    return authBox.values.any((user) => user.isLoggedIn);
  }

  Future<bool> loginUser(String email, String password) async {
    final user = authBox.get(email);
    if (user != null && user.password == password) {
      await logout();
      user.isLoggedIn = true;
      await user.save();
      return true;
    }
    return false;
  }
  Future<bool> signupUser(String email, String password) async {
    if (authBox.containsKey(email)) return false;
    final newUser = UserAuth(email: email, password: password, isLoggedIn: true);
    await logout();
    await authBox.put(email, newUser);
    return true;
  }
  UserAuth getLoggedInUser() {
    final loggedIn = authBox.values.where((user) => user.isLoggedIn);
    if (loggedIn.isNotEmpty) return loggedIn.first;
    return UserAuth(email: 'Utilisateur', password: '', isLoggedIn: false);
  }
  Future<void> logout() async {
    final users = authBox.values.where((user) => user.isLoggedIn);
    for (var user in users) { user.isLoggedIn = false; await user.save(); }
  }
}
