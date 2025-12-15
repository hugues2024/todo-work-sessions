// lib/main.dart (Code Complet et Corrigé)

//? CodeWithFlexz on Instagram
//* AmirBayat0 on Github
//! Programming with Flexz on Youtube

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart'; 

///
import '../data/hive_data_store.dart';
import '../models/task.dart';
import '../models/task_step.dart'; 
import '../models/user_profile.dart'; 
import '../models/work_session.dart';
import '../models/user_auth.dart';
import '../utils/colors.dart'; 
import '../utils/constanst.dart'; 
import '../view/auth/login_view.dart';
import '../view/main_wrapper.dart'; 
import '../view/clock/clock_wrapper.dart'; // 🎯 Importation de ClockWrapper (qui sera la vue complète de l'horloge)
import '../view/calendar/calendar_agenda_view.dart'; // 🎯 NOUVEAU: Importation pour la route /calendar
import '../services/timer_service.dart'; 

Future<void> main() async {
  // 👈 Initialisation des bindings avant Hive
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
  final taskBox = await Hive.openBox<Task>(Constants.taskBox); 
  final profileBox = await Hive.openBox<UserProfile>(Constants.userProfileBox); 
  final sessionBox = await Hive.openBox<WorkSession>(Constants.sessionBox);
  final authBox = await Hive.openBox<UserAuth>(Constants.userAuthBox);

  // Création de l'instance HiveDataStore avec les 4 boxes
  final HiveDataStore dataStore = HiveDataStore(taskBox, sessionBox, profileBox, authBox);

  // Passer l'instance dataStore à BaseWidget
  runApp(
    BaseWidget(
      dataStore: dataStore, 
      child: ChangeNotifierProvider(
        create: (context) => TimerService(),
        child: const MyApp(),
      ),
    )
  );
}

// 🎯 CLASSE BASEWIDGET (InheritedWidget)
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
// FIN DE BASEWIDGET

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final base = BaseWidget.of(context);
    final profileBox = Hive.box<UserProfile>(Constants.userProfileBox);

    // Écoute les changements de la boîte pour réagir aux mises à jour de profil (thème)
    return ValueListenableBuilder<Box<UserProfile>>(
      valueListenable: base.dataStore.listenToUserProfile(),
      builder: (context, box, child) {

        final UserProfile? loggedInProfile = base.dataStore.getLoggedInUserProfile();
        final UserProfile? guestProfile = profileBox.isEmpty ? null : profileBox.getAt(0);
        final UserProfile profile = loggedInProfile ?? guestProfile ?? UserProfile.defaultProfile();
        
        // Détermination du ThemeMode (0=Clair, 1=Sombre)
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
          
          // Utilisez les routes nommées pour une gestion plus propre
          initialRoute: '/',
          routes: {
            // Renvoie le MainWrapper (avec la barre de navigation principale)
            '/': (context) {
              return const MainWrapper();
            },
            // 🎯 ROUTE PLEIN ÉCRAN : Horloge (pas de MainWrapper)
            '/clock': (context) {
              // NOTE: Si vous avez renommé ClockWrapper en ClockView, utilisez ClockView()
              return const ClockWrapper(); 
            },
            // 🎯 ROUTE PLEIN ÉCRAN : Calendrier (pas de MainWrapper)
            '/calendar': (context) {
              return const CalendarAgendaView();
            },
          },
        );
      },
    );
  }
}