// lib/main.dart

//? CodeWithFlexz on Instagram
//* AmirBayat0 on Github
//! Programming with Flexz on Youtube

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

///
import '../data/hive_data_store.dart';
import '../models/task.dart';
import '../models/task_step.dart'; // Import added
import '../models/user_profile.dart'; 
import '../models/work_session.dart';
import '../models/user_auth.dart';
import '../utils/colors.dart'; // Importez MyColors
import '../view/home/home_view.dart';
import '../view/auth/login_view.dart';

Future<void> main() async {
  /// Initial Hive DB
  await Hive.initFlutter();

  // --- 1. ENREGISTREMENT DES ADAPTATEURS ---
  Hive.registerAdapter<Task>(TaskAdapter());
  Hive.registerAdapter<TaskStep>(TaskStepAdapter()); // TaskStep adapter registered
  Hive.registerAdapter<UserProfile>(UserProfileAdapter());
  Hive.registerAdapter<WorkSession>(WorkSessionAdapter());
  Hive.registerAdapter<UserAuth>(UserAuthAdapter());

  /// Open boxes
  var taskBox = await Hive.openBox<Task>("tasksBox");
  await Hive.openBox<UserProfile>("userProfileBox"); 
  await Hive.openBox<WorkSession>("workSessionsBox");
  await Hive.openBox<UserAuth>("userAuthBox"); 

  /// Delete data from previous day - DÉSACTIVÉ pour conserver toutes les tâches
  // Si vous voulez réactiver la suppression automatique des anciennes tâches :
  // taskBox.values.forEach((task) {
  //   if (task.createdAtTime.day != DateTime.now().day) { 
  //     task.delete();
  //   }
  // });

  runApp(BaseWidget(child: const MyApp()));
}

class BaseWidget extends InheritedWidget {
  BaseWidget({Key? key, required this.child}) : super(key: key, child: child);
  final HiveDataStore dataStore = HiveDataStore();
  final Widget child;

  static BaseWidget of(BuildContext context) {
    final base = context.dependOnInheritedWidgetOfExactType<BaseWidget>();
    if (base != null) {
      return base;
    } else {
      throw StateError('Could not find ancestor widget of type BaseWidget');
    }
  }

  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) {
    return false;
  }
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final base = BaseWidget.of(context);

    // --- 2. ÉCOUTE DE L'ÉTAT DU PROFIL POUR LE THÈME ---
    return ValueListenableBuilder<Box<UserProfile>>(
      valueListenable: base.dataStore.listenToUserProfile(),
      builder: (context, box, child) {

        // Récupère le mode de thème stocké dans le profil (ou le profil par défaut)
        final UserProfile profile = box.isNotEmpty 
            ? box.getAt(0)! 
            : UserProfile.defaultProfile();

        // 0 = Clair (par défaut), 1 = Sombre
        ThemeMode currentThemeMode = profile.themeMode == 1 ? ThemeMode.dark : ThemeMode.light;

        // Vérifier si l'utilisateur est connecté
        final bool isLoggedIn = base.dataStore.isUserLoggedIn();

        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Todo Work Sessions',

          // Applique le mode de thème (Clair/Sombre)
          themeMode: currentThemeMode, 

          // --- 3. THÈME CLAIR (ThemeData) ---
          theme: ThemeData(
            primaryColor: MyColors.primaryColor,
            useMaterial3: true,
            brightness: Brightness.light,
            scaffoldBackgroundColor: Colors.white,
            textTheme: const TextTheme(
              displayLarge: TextStyle(
                color: MyColors.primaryColor, // Couleur principale pour le titre
                fontWeight: FontWeight.bold,
                fontSize: 35, // Taille ajustée pour le titre principal
              ),
              titleMedium: TextStyle(
                color: Colors.grey,
                fontSize: 16,
                fontWeight: FontWeight.w300,
              ),
              // Utilisez displayMedium pour les textes blancs dans le menu (MySlider)
              displayMedium: TextStyle(
                color: Colors.white,
                fontSize: 21,
              ),
              // ... autres styles...
            ),
          ),

          // --- 4. THÈME SOMBRE (darkTheme) ---
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            primaryColor: MyColors.primaryColor,
            useMaterial3: true,
            scaffoldBackgroundColor: const Color(0xFF121212), // Fond sombre
            textTheme: const TextTheme(
              displayLarge: TextStyle(
                color: Colors.white, 
                fontWeight: FontWeight.bold,
                fontSize: 35,
              ),
              titleMedium: TextStyle(
                color: Colors.grey,
                fontSize: 16,
                fontWeight: FontWeight.w300,
              ),
              displayMedium: TextStyle(
                color: Colors.white,
                fontSize: 21,
              ),
              // Définissez tous les autres styles de texte pour le mode sombre si nécessaire
              titleSmall: TextStyle(
                color: Colors.white70,
                fontWeight: FontWeight.w500,
              ),
              titleLarge: TextStyle(
                fontSize: 40,
                color: Colors.white,
                fontWeight: FontWeight.w300,
              ),
            ),
          ),

          // L'authentification n'est pas obligatoire pour utiliser l'application
          // Seules certaines pages (profil, etc.) nécessitent une connexion
          home: const HomeView(),
        );
      },
    );
  }
}