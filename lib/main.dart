// lib/main.dart

//? CodeWithFlexz on Instagram
//* AmirBayat0 on Github
//! Programming with Flexz on Youtube

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hive/hive.dart';

///
import '../data/hive_data_store.dart';
import '../models/task.dart';
import '../models/task_step.dart'; 
import '../models/user_profile.dart'; 
import '../models/work_session.dart';
import '../models/user_auth.dart';
import '../utils/colors.dart'; 
import '../view/home/home_view.dart';
import '../view/auth/login_view.dart';
import '../view/main_wrapper.dart'; 

Future<void> main() async {
  // 👈 CORRECTION 1: Initialisation des bindings avant Hive
  WidgetsFlutterBinding.ensureInitialized();
  
  /// Initial Hive DB
  await Hive.initFlutter();

  // --- 1. ENREGISTREMENT DES ADAPTATEURS ---
  Hive.registerAdapter<Task>(TaskAdapter());
  Hive.registerAdapter<TaskStep>(TaskStepAdapter()); 
  Hive.registerAdapter<UserProfile>(UserProfileAdapter());
  Hive.registerAdapter<WorkSession>(WorkSessionAdapter());
  Hive.registerAdapter<UserAuth>(UserAuthAdapter());

  /// Open boxes
  // Utilisation des noms de boîte définis dans HiveDataStore pour plus de clarté
  final taskBox = await Hive.openBox<Task>(HiveDataStore.boxName); 
  final profileBox = await Hive.openBox<UserProfile>("userProfileBox"); 
  final sessionBox = await Hive.openBox<WorkSession>("workSessionsBox");
  final authBox = await Hive.openBox<UserAuth>("userAuthBox"); 

  // 👈 CORRECTION 2: Création de l'instance HiveDataStore avec les 4 boxes
  final HiveDataStore dataStore = HiveDataStore(taskBox, sessionBox, profileBox, authBox);

  // ... (Logique de suppression des anciennes tâches - inchangée)

  // 👈 CORRECTION 3: Passer l'instance dataStore à BaseWidget
  runApp(BaseWidget(dataStore: dataStore, child: const MyApp()));
}

class BaseWidget extends InheritedWidget {
  // 👈 CORRECTION 4: Définir dataStore comme une propriété requise et non auto-instanciée
  final HiveDataStore dataStore; 
  final Widget child;

  // 👈 CORRECTION 5: Mettre à jour le constructeur pour accepter le dataStore
  BaseWidget({
    Key? key, 
    required this.dataStore,
    required this.child,
  }) : super(key: key, child: child);

  static BaseWidget of(BuildContext context) {
    final base = context.dependOnInheritedWidgetOfExactType<BaseWidget>();
    if (base != null) {
      return base;
    } else {
      throw StateError('Could not find ancestor widget of type BaseWidget');
    }
  }

  @override
  bool updateShouldNotify(covariant BaseWidget oldWidget) {
    return oldWidget.dataStore != dataStore; 
  }
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final base = BaseWidget.of(context);

    // Écoute les changements de la boîte pour réagir aux mises à jour de profil (thème)
    return ValueListenableBuilder<Box<UserProfile>>(
      valueListenable: base.dataStore.listenToUserProfile(),
      builder: (context, box, child) {

        // Lecture du profil via la méthode DataStore (robuste pour l'utilisateur connecté)
        final UserProfile? loggedInProfile = base.dataStore.getLoggedInUserProfile();
        final UserProfile profile = loggedInProfile ?? UserProfile.defaultProfile();
        
        // Détermination du ThemeMode (0=Clair, 1=Sombre, nous excluons le mode Système pour le moment)
        ThemeMode currentThemeMode = profile.themeMode == 1 ? ThemeMode.dark : ThemeMode.light;

        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Todo Work Sessions',

          themeMode: currentThemeMode, 

          // --- 3. THÈME CLAIR (ThemeData) ---
          theme: ThemeData(
            primaryColor: MyColors.primaryColor,
            useMaterial3: true,
            brightness: Brightness.light,
            scaffoldBackgroundColor: Colors.white,
            textTheme: const TextTheme(
              displayLarge: TextStyle(
                color: MyColors.primaryColor, 
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
              // ... autres styles...
            ),
          ),

          // --- 4. THÈME SOMBRE (darkTheme) ---
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            primaryColor: MyColors.primaryColor,
            useMaterial3: true,
            scaffoldBackgroundColor: const Color(0xFF121212), 
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

          home: const MainWrapper(), 
        );
      },
    );
  }
}