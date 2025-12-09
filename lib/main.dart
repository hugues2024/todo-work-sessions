// lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:hive_flutter/hive_flutter.dart'; 
// Importations de nos fichiers
import 'core/theme/app_theme.dart';
import 'data/models/task.dart'; // Importation du modèle de Tâche
import 'features/main_wrapper.dart'; // <== NOUVEL ÉCRAN CONTENEUR
// Note: Assurez-vous d'avoir exécuté 'build_runner' et que 'task.g.dart' existe pour l'import ci-dessus.


// Fonction d'initialisation asynchrone des dépendances (Hive, etc.)
Future<void> initDependencies() async {
  // 1. Initialiser Hive
  await Hive.initFlutter();
  
  // 2. Enregistrer l'Adaptateur Task
  if (!Hive.isAdapterRegistered(0)) {
    Hive.registerAdapter(TaskAdapter()); 
  }
  
  // 3. Ouvrir la 'Boîte' (Box) de stockage pour les tâches
  await Hive.openBox('tasksBox');
}


void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  // Exécution de l'initialisation avant de lancer l'application
  await initDependencies();

  runApp(const TodoWorkSessionsApp());
}

class TodoWorkSessionsApp extends StatelessWidget {
  const TodoWorkSessionsApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Retrait du splash screen natif
    FlutterNativeSplash.remove();

    return MaterialApp(
      title: 'Todo Work Sessions',
      debugShowCheckedModeBanner: false,
      
      // Utilisation de votre thème élégant
      theme: AppTheme.lightTheme,
      
      // Le point d'entrée est maintenant le MainWrapper
      home: const MainWrapper(), 
    );
  }
}