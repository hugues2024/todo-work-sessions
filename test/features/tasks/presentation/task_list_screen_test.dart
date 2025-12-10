// test/features/tasks/presentation/task_list_screen_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:todo_work_sessions/data/models/task.dart';
import 'package:todo_work_sessions/features/tasks/application/task_providers.dart';
import 'package:todo_work_sessions/features/tasks/domain/repositories/task_repository.dart';
import 'package:todo_work_sessions/features/tasks/presentation/task_list_screen.dart';

import '../../../mocks.mocks.dart';

void main() {
  late MockTaskRepository mockTaskRepository;

  setUp(() {
    mockTaskRepository = MockTaskRepository();
  });

  final tTask1 = Task(title: 'Tâche de test 1', createdAt: DateTime.now());
  final tTask2 = Task(title: 'Tâche de test 2', createdAt: DateTime.now());
  final tasksList = [tTask1, tTask2];

  Widget createWidgetUnderTest() {
    return MaterialApp(
      home: ProviderScope(
        overrides: [
          taskRepositoryProvider.overrideWithValue(mockTaskRepository),
        ],
        child: const TaskListScreen(),
      ),
    );
  }

  testWidgets(
    'devrait afficher une ListView quand le repository retourne des tâches', 
    (WidgetTester tester) async {
      // ARRANGE
      when(mockTaskRepository.getTasks()).thenAnswer((_) => Stream.value(tasksList));

      // ACT
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      // ASSERT
      expect(find.byType(ListView), findsOneWidget);
      expect(find.text('Tâche de test 1'), findsOneWidget);
      expect(find.text('Tâche de test 2'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    },
  );

  testWidgets(
    'devrait afficher un message quand le repository ne retourne aucune tâche', 
    (WidgetTester tester) async {
      // ARRANGE
      when(mockTaskRepository.getTasks()).thenAnswer((_) => Stream.value(<Task>[])); 

      // ACT
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      // ASSERT
      expect(find.text('Aucune tâche pour le moment.\nAppuyez sur + pour en ajouter une !'), findsOneWidget);
      expect(find.byType(ListView), findsNothing);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    },
  );

  testWidgets(
    'devrait afficher un message d'erreur quand le repository émet une erreur', 
    (WidgetTester tester) async {
      // ARRANGE
      final errorMessage = 'Erreur de base de données';
      when(mockTaskRepository.getTasks()).thenAnswer((_) => Stream.error(errorMessage));

      // ACT
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      // ASSERT
      // On vérifie que le message d'erreur est bien présent
      expect(find.text('Erreur: $errorMessage'), findsOneWidget);
      // On s'assure qu'il n'y a PAS de ListView
      expect(find.byType(ListView), findsNothing);
      // Et que le loader a bien disparu
      expect(find.byType(CircularProgressIndicator), findsNothing);
    },
  );
}
