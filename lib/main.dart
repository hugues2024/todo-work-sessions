
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
  // Initialisation des bindings avant Hive
  WidgetsFlutterBinding.ensureInitialized();
  
  /// Initialisation de Hive
  await Hive.initFlutter();

  // Enregistrement des adaptateurs
  Hive.registerAdapter<Task>(TaskAdapter());
  Hive.registerAdapter<TaskStep>(TaskStepAdapter()); 
  Hive.registerAdapter<UserProfile>(UserProfileAdapter());
  Hive.registerAdapter<WorkSession>(WorkSessionAdapter());
  Hive.registerAdapter<UserAuth>(UserAuthAdapter());

  // Ouverture des boîtes
  final taskBox = await Hive.openBox<Task>(HiveDataStore.boxName); 
  final profileBox = await Hive.openBox<UserProfile>("userProfileBox"); 
  final sessionBox = await Hive.openBox<WorkSession>("workSessionsBox");
  final authBox = await Hive.openBox<UserAuth>("userAuthBox"); 

  // 🚀 GARANTIE : S'assure qu'un profil par défaut existe toujours dans la boîte.
  if (profileBox.get(UserProfile.defaultProfileId) == null) {
    profileBox.put(UserProfile.defaultProfileId, UserProfile.defaultProfile());
  }

  // Création de l'instance HiveDataStore
  final HiveDataStore dataStore = HiveDataStore(taskBox, sessionBox, profileBox, authBox);

  // On peut maintenant lire le profil en toute sécurité.
  final UserProfile profile = dataStore.getLoggedInUserProfile() ?? 
                             profileBox.get(UserProfile.defaultProfileId)!;

  if (profile.notificationsEnabled) {
    print("✅ Notifications activées. Initialisation du service...");
  } else {
    print("❌ Notifications désactivées.");
  }

  // Lancement de l'application
  runApp(BaseWidget(dataStore: dataStore, child: const MyApp()));
}

class BaseWidget extends InheritedWidget {
  final HiveDataStore dataStore; 
  final Widget child;

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

    return ValueListenableBuilder<Box<UserProfile>>(
      valueListenable: base.dataStore.listenToUserProfile(),
      builder: (context, box, child) {

        final UserProfile profile = base.dataStore.getLoggedInUserProfile() ?? 
                                    box.get(UserProfile.defaultProfileId)!; // Le '!' est maintenant sûr.
        
        ThemeMode currentThemeMode = profile.themeMode == 1 ? ThemeMode.dark : ThemeMode.light;

        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Todo Work Sessions',
          themeMode: currentThemeMode, 
          theme: ThemeData(
            primaryColor: MyColors.primaryColor,
            useMaterial3: true,
            brightness: Brightness.light,
            scaffoldBackgroundColor: Colors.white,
            textTheme: const TextTheme(
              displayLarge: TextStyle(color: MyColors.primaryColor, fontWeight: FontWeight.bold, fontSize: 35),
              titleMedium: TextStyle(color: Colors.grey, fontSize: 16, fontWeight: FontWeight.w300),
              displayMedium: TextStyle(color: Colors.white, fontSize: 21),
            ),
          ),
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            primaryColor: MyColors.primaryColor,
            useMaterial3: true,
            scaffoldBackgroundColor: const Color(0xFF121212), 
            textTheme: const TextTheme(
              displayLarge: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 35),
              titleMedium: TextStyle(color: Colors.grey, fontSize: 16, fontWeight: FontWeight.w300),
              displayMedium: TextStyle(color: Colors.white, fontSize: 21),
              titleSmall: TextStyle(color: Colors.white70, fontWeight: FontWeight.w500),
              titleLarge: TextStyle(fontSize: 40, color: Colors.white, fontWeight: FontWeight.w300),
            ),
          ),
          home: const MainWrapper(), 
        );
      },
    );
  }
}
