// lib/data/services/local_storage_service.dart

import 'package:hive_flutter/hive_flutter.dart';
import 'package:todo_work_sessions/data/models/task.dart';

class LocalStorageService {
  // Référence statique à la boîte Hive des tâches
  static final _tasksBox = Hive.box('tasksBox');

  // 1. Lire toutes les tâches
  List<Task> getAllTasks() {
    // La méthode values de HiveObject retourne une liste dynamique, nous la mappons en Task
    return _tasksBox.values.cast<Task>().toList();
  }

  // 2. Ajouter une nouvelle tâche
  // Nous retournons l'index pour la gestion future
  Future<int> addTask(Task task) async {
    // La méthode add ajoute la tâche et retourne son index (clé locale)
    return await _tasksBox.add(task);
  }

  // 3. Mettre à jour l'état d'une tâche (complétée ou non)
  Future<void> updateTaskCompletion(Task task, bool isCompleted) async {
    task.isCompleted = isCompleted;
    // La méthode save() met à jour l'objet existant dans sa boîte
    await task.save();
  }

  // 4. Supprimer une tâche
  Future<void> deleteTask(Task task) async {
    // La méthode delete() supprime l'objet de sa boîte
    await task.delete();
  }
  
  // (Optionnel pour l'instant) Mettre à jour le titre d'une tâche
  Future<void> updateTaskTitle(Task task, String newTitle) async {
    // Si l'attribut 'title' était mutable (pas final), on pourrait le modifier directement:
    // task.title = newTitle;
    // await task.save();
    
    // Si title est final, nous devrons recréer l'objet ou utiliser une méthode de copie. 
    // Pour l'instant, nous laissons le modèle 'title' en 'final' car c'est plus sûr.
    // Pour une mise à jour, nous devrons plutôt mettre à jour l'objet via son index.
  }

  // Méthode utilitaire pour le mode de synchronisation (sera utilisée plus tard)
  Future<void> clearAllLocalData() async {
    await _tasksBox.clear();
  }
}