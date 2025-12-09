// lib/main.dart

// 1. Importations nécessaires depuis Flutter SDK
import 'package:flutter/material.dart';

// 2. Importation du package externe pour gérer le splash screen natif
// Assurez-vous d'avoir ajouté flutter_native_splash: ^latest_version dans pubspec.yaml
import 'package:flutter_native_splash/flutter_native_splash.dart'; 

// 3. Importation des écrans que nous avons créés localement
// Assurez-vous que ces fichiers existent dans votre dossier lib/screens/
import 'package:todo_work_sessions/screens/lib/screens/home_screen.dart';
// import 'package:todo_work_sessions/screens/auth_screen.dart'; // Sera utilisé plus tard pour la connexion/inscription

// Fonction principale : Point d'entrée de l'application
void main() {
  // --- Gestion de l'écran de démarrage ---
  // S'assure que les bindings de widgets Flutter sont initialisés
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  
  // Indique au package de conserver le splash screen natif jusqu'à ce que nous appelions FlutterNativeSplash.remove()
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  // Lance l'application Flutter
  runApp(const TodoWorkSessionsApp());
}

// Le widget racine de l'application (Stateless car il ne gère pas d'état interne ici)
class TodoWorkSessionsApp extends StatelessWidget {
  const TodoWorkSessionsApp({super.key});

  @override
  Widget build(BuildContext context) {
    // --- Masquage de l'écran de démarrage ---
    // Dès que ce widget build est appelé, l'interface Flutter est prête
    // Nous pouvons donc dire au système natif de retirer le splash screen.
    FlutterNativeSplash.remove();

    return MaterialApp(
      title: 'Todo Work Sessions',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // Utilisation d'une palette de couleurs cohérente
        primarySwatch: Colors.blue,
        // Activez ceci si vous utilisez Material 3 design (le nouveau standard)
        useMaterial3: true, 
      ),
      // Définit l'écran initial de l'application
      home: HomeScreen(), 
    );
  }
}
