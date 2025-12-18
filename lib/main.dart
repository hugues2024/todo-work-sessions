// lib/main.dart

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart'; 

import '../data/hive_data_store.dart';
import '../models/task.dart';
import '../models/task_step.dart'; 
import '../models/user_profile.dart'; 
import '../models/work_session.dart';
import '../models/user_auth.dart';
import '../models/alarm.dart'; 
import '../utils/colors.dart'; 
import '../utils/constanst.dart'; 
import '../view/main_wrapper.dart'; 
import '../view/clock/clock_wrapper.dart'; 
import '../view/calendar/calendar_agenda_view.dart'; 
import '../view/splash_view.dart'; 
import '../services/timer_service.dart'; 

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  Hive.registerAdapter<Task>(TaskAdapter());
  Hive.registerAdapter<TaskStep>(TaskStepAdapter()); 
  Hive.registerAdapter<UserProfile>(UserProfileAdapter());
  Hive.registerAdapter<WorkSession>(WorkSessionAdapter());
  Hive.registerAdapter<UserAuth>(UserAuthAdapter());
  Hive.registerAdapter<Alarm>(AlarmAdapter()); 

  Box<Task> taskBox;
  try {
    taskBox = await Hive.openBox<Task>(Constants.taskBox);
  } catch (e) {
    final box = await Hive.openBox(Constants.taskBox);
    await box.clear();
    await box.close();
    taskBox = await Hive.openBox<Task>(Constants.taskBox);
  }

  final profileBox = await Hive.openBox<UserProfile>(Constants.userProfileBox); 
  
  Box<WorkSession> sessionBox;
  try {
    sessionBox = await Hive.openBox<WorkSession>(Constants.sessionBox);
  } catch (e) {
    final box = await Hive.openBox(Constants.sessionBox);
    await box.clear();
    await box.close();
    sessionBox = await Hive.openBox<WorkSession>(Constants.sessionBox);
  }

  final authBox = await Hive.openBox<UserAuth>(Constants.userAuthBox);
  final alarmBox = await Hive.openBox<Alarm>("alarmsBox"); 

  final dataStore = HiveDataStore(taskBox, sessionBox, profileBox, authBox, alarmBox);

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

class BaseWidget extends InheritedWidget {
  final HiveDataStore dataStore; 
  final Widget child;
  BaseWidget({Key? key, required this.dataStore, required this.child}) : super(key: key, child: child);
  static BaseWidget of(BuildContext context) {
    final base = context.dependOnInheritedWidgetOfExactType<BaseWidget>();
    if (base != null) return base;
    throw StateError('BaseWidget non trouvé');
  }
  @override
  bool updateShouldNotify(covariant BaseWidget oldWidget) => oldWidget.dataStore != dataStore; 
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    final base = BaseWidget.of(context);
    
    // 🎯 DÉFINITION COMMUNE ET PLUS PETITE DES TAILLES DE TEXTE
    const textThemeBase = TextTheme(
      displayLarge: TextStyle(fontWeight: FontWeight.bold, fontSize: 28), // Réduit de 35 à 28
      titleMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w300), // Réduit de 16 à 14
      displayMedium: TextStyle(fontSize: 18), // Réduit de 21 à 18
      titleSmall: TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
      titleLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.bold), // Pour l'AppBar
    );

    return ValueListenableBuilder<Box<UserProfile>>(
      valueListenable: base.dataStore.listenToUserProfile(),
      builder: (context, box, child) {
        final profile = base.dataStore.getLoggedInUserProfile() ?? UserProfile.defaultProfile();
        ThemeMode theme = profile.themeMode == 1 ? ThemeMode.dark : ThemeMode.light;

        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Todo Work Sessions',
          themeMode: theme, 
          
          theme: ThemeData(
            primaryColor: MyColors.primaryColor,
            useMaterial3: true,
            brightness: Brightness.light,
            scaffoldBackgroundColor: Colors.white,
            // 🎯 UNIFORMISATION DE L'APPBAR CLAIRE
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.white,
              elevation: 0,
              titleTextStyle: TextStyle(color: MyColors.primaryColor, fontSize: 20, fontWeight: FontWeight.bold),
              iconTheme: IconData(0xe092, fontFamily: 'MaterialIcons') == null ? null : IconThemeData(color: MyColors.primaryColor),
            ),
            textTheme: textThemeBase.copyWith(
              displayLarge: textThemeBase.displayLarge?.copyWith(color: MyColors.primaryColor),
              titleMedium: textThemeBase.titleMedium?.copyWith(color: Colors.grey),
              displayMedium: textThemeBase.displayMedium?.copyWith(color: Colors.white),
            ),
          ),

          darkTheme: ThemeData(
            brightness: Brightness.dark,
            primaryColor: MyColors.primaryColor,
            useMaterial3: true,
            scaffoldBackgroundColor: const Color(0xFF121212), 
            // 🎯 UNIFORMISATION DE L'APPBAR SOMBRE
            appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xFF121212),
              elevation: 0,
              titleTextStyle: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
              iconTheme: IconThemeData(color: Colors.white),
            ),
            textTheme: textThemeBase.copyWith(
              displayLarge: textThemeBase.displayLarge?.copyWith(color: Colors.white),
              titleMedium: textThemeBase.titleMedium?.copyWith(color: Colors.grey),
              displayMedium: textThemeBase.displayMedium?.copyWith(color: Colors.white),
              titleSmall: textThemeBase.titleSmall?.copyWith(color: Colors.white70),
              titleLarge: textThemeBase.titleLarge?.copyWith(color: Colors.white),
            ),
          ),
          
          initialRoute: '/splash',
          routes: {
            '/splash': (context) => const SplashView(),
            '/': (context) => const MainWrapper(),
            '/clock': (context) => const ClockWrapper(),
            '/calendar': (context) => const CalendarAgendaView(),
          },
        );
      },
    );
  }
}
