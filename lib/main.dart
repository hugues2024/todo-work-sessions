// lib/main.dart
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart'; // 👈 Import nécessaire pour les dates en FR

// --- IMPORTS NOTIFICATIONS ---
import '../services/notification_service.dart';

// --- AUTRES IMPORTS ---
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
import '../view/clock/clock_wrapper.dart';
import '../view/calendar/calendar_agenda_view.dart';
import '../services/timer_service.dart';

Future<void> main() async {
  // 1. Initialisation des bindings (CRITIQUE pour Hive et Notifications)
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Initialisation des données de locale pour le Français (CORRECTION DE L'ERREUR)
  await initializeDateFormatting('fr_FR', null);

  // 2. INITIALISATION DES NOTIFICATIONS
  await NotificationService.initializeNotification();

  // 3. Initial Hive DB
  await Hive.initFlutter();

  // --- ENREGISTREMENT DES ADAPTATEURS ---
  Hive.registerAdapter<Task>(TaskAdapter());
  Hive.registerAdapter<TaskStep>(TaskStepAdapter());
  Hive.registerAdapter<UserProfile>(UserProfileAdapter());
  Hive.registerAdapter<WorkSession>(WorkSessionAdapter());
  Hive.registerAdapter<UserAuth>(UserAuthAdapter());

  // --- OPEN BOXES ---
  final taskBox = await Hive.openBox<Task>(Constants.taskBox);
  final profileBox = await Hive.openBox<UserProfile>(Constants.userProfileBox);
  final sessionBox = await Hive.openBox<WorkSession>(Constants.sessionBox);
  final authBox = await Hive.openBox<UserAuth>(Constants.userAuthBox);

  final HiveDataStore dataStore =
      HiveDataStore(taskBox, sessionBox, profileBox, authBox);

  runApp(BaseWidget(
    dataStore: dataStore,
    child: ChangeNotifierProvider(
      create: (context) => TimerService(),
      child: const MyApp(),
    ),
  ));
}

// 🎯 CLASSE BASEWIDGET
class BaseWidget extends InheritedWidget {
  final HiveDataStore dataStore;
  @override
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

  // 4. CLÉ DE NAVIGATION GLOBALE (Ajoutée pour les notifications)
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    final base = BaseWidget.of(context);
    final profileBox = Hive.box<UserProfile>(Constants.userProfileBox);

    return ValueListenableBuilder<Box<UserProfile>>(
      valueListenable: base.dataStore.listenToUserProfile(),
      builder: (context, box, child) {
        final UserProfile? loggedInProfile =
            base.dataStore.getLoggedInUserProfile();
        final UserProfile? guestProfile =
            profileBox.isEmpty ? null : profileBox.getAt(0);
        final UserProfile profile =
            loggedInProfile ?? guestProfile ?? UserProfile.defaultProfile();

        ThemeMode currentThemeMode =
            profile.themeMode == 1 ? ThemeMode.dark : ThemeMode.light;

        return MaterialApp(
          // 5. CONFIGURATION DE LA CLÉ DE NAVIGATION
          navigatorKey: MyApp.navigatorKey,

          debugShowCheckedModeBanner: false,
          title: 'Todo Work Sessions',
          themeMode: currentThemeMode,

          // --- THÈME CLAIR ---
          theme: ThemeData(
            primaryColor: MyColors.primaryColor,
            useMaterial3: true,
            brightness: Brightness.light,
            scaffoldBackgroundColor: Colors.white,
            textTheme: const TextTheme(
              displayLarge: TextStyle(
                  color: MyColors.primaryColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 35),
              titleMedium: TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                  fontWeight: FontWeight.w300),
              displayMedium: TextStyle(color: Colors.white, fontSize: 21),
            ),
          ),

          // --- THÈME SOMBRE ---
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            primaryColor: MyColors.primaryColor,
            useMaterial3: true,
            scaffoldBackgroundColor: const Color(0xFF121212),
            textTheme: const TextTheme(
              displayLarge: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 35),
              titleMedium: TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                  fontWeight: FontWeight.w300),
              displayMedium: TextStyle(color: Colors.white, fontSize: 21),
              titleSmall:
                  TextStyle(color: Colors.white70, fontWeight: FontWeight.w500),
              titleLarge: TextStyle(
                  fontSize: 40,
                  color: Colors.white,
                  fontWeight: FontWeight.w300),
            ),
          ),

          initialRoute: '/',
          routes: {
            '/': (context) => const MainWrapper(),
            '/clock': (context) => const ClockWrapper(),
            '/calendar': (context) => const CalendarAgendaView(),
          },
        );
      },
    );
  }
}
