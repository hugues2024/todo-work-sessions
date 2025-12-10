// test/mocks.dart

import 'package:hive/hive.dart';
import 'package:mockito/annotations.dart';
import 'package:todo_work_sessions/features/tasks/domain/repositories/task_repository.dart';

// On ajoute `Box` à la liste des classes à mocker.
// Note: On doit spécifier le type <Task> car Box est une classe générique.
@GenerateMocks([TaskRepository, Box<Task>])
void main() {
  // Ce fichier sert uniquement de configuration pour le générateur de code.
}
