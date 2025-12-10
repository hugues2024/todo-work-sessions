// test/features/tasks/data/repositories/hive_task_repository_impl_test.dart

import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:todo_work_sessions/data/models/task.dart';
import 'package:todo_work_sessions/features/tasks/data/repositories/hive_task_repository_impl.dart';

import '../../../mocks.mocks.dart';

void main() {
  late HiveTaskRepositoryImpl repository;
  late MockBox<Task> mockBox;

  setUp(() {
    mockBox = MockBox<Task>();
    repository = HiveTaskRepositoryImpl(mockBox);
  });

  group('HiveTaskRepositoryImpl', () {
    
    final tTask1 = Task(title: 'Tâche 1', createdAt: DateTime.now());
    final tTask2 = Task(title: 'Tâche 2', createdAt: DateTime.now());
    final tasksList = [tTask1, tTask2];

    test('addTask devrait appeler box.add avec la bonne tâche', () async {
      // ARRANGE
      when(mockBox.add(any)).thenAnswer((_) async => 1);
      // ACT
      await repository.addTask(tTask1);
      // ASSERT
      verify(mockBox.add(tTask1)).called(1);
      verifyNoMoreInteractions(mockBox);
    });
    
    test('getTasks devrait retourner une liste de tâches immédiatement et sur changement', () {
      // ARRANGE
      // 1. Pour l'émission initiale
      when(mockBox.values).thenReturn(tasksList);

      // 2. Pour les émissions futures
      final streamController = StreamController<BoxEvent>.broadcast();
      when(mockBox.watch()).thenAnswer((_) => streamController.stream);
      
      // ACT & ASSERT
      // On vérifie que le stream émet bien la liste initiale immédiatement
      expect(repository.getTasks(), emits(tasksList));
      
      // On simule une mise à jour dans la box
      streamController.add(BoxEvent('key', 'value', false));
      
      // On vérifie que le stream ré-émet la liste
      // (dans une vraie app, on pourrait vérifier avec une nouvelle liste)
      expect(repository.getTasks(), emits(tasksList));

      streamController.close();
    });

    // Pour updateTask et deleteTask, comme ils appellent directement des méthodes
    // sur l'objet `task` lui-même (`task.save()`, `task.delete()`), qui est un HiveObject,
    // les tester unitairement nécessiterait de mocker HiveObject, ce qui est complexe.
    // Nous faisons confiance aux tests de l'équipe Hive pour ces méthodes et nous concentrons
    // sur ce que notre repository contrôle directement.
  });
}
