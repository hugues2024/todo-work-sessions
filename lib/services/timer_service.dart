// lib/services/timer_service.dart

import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';

import '../models/task.dart';
import '../models/work_session.dart';
import '../data/hive_data_store.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

const String _alarmSound = 'audio/alarme.mp3';
const String _notificationSound = 'audio/notification.mp3';
const String _tictacSound = 'audio/minuteur.mp3';
const String _androidNotificationSoundName = 'notification'; 

class TimerService extends ChangeNotifier {
  Task? _currentTask;
  WorkSession? _activeSession; 
  
  Duration _totalDuration = Duration.zero;
  Duration _remainingDuration = Duration.zero;
  int _elapsedSeconds = 0; 
  
  Timer? _timer;
  bool _isRunning = false;
  bool _isFinished = false;
  bool _isTimerMinimized = false;

  int _currentTabIndex = 0;
  int get currentTabIndex => _currentTabIndex;
  bool get isTimerMinimized => _isTimerMinimized;

  final _alarmPlayer = AudioPlayer();
  final _tictacPlayer = AudioPlayer();
  
  Task? get currentTask => _currentTask;
  Duration get remainingDuration => _remainingDuration;
  Duration get totalDuration => _totalDuration;
  bool get isRunning => _isRunning;
  bool get isFinished => _isFinished;
  
  double get progress {
    if (_totalDuration.inSeconds == 0) return 0.0;
    return _remainingDuration.inSeconds / _totalDuration.inSeconds;
  }
  
  TimerService() {
    _initNotifications();
    _tictacPlayer.setReleaseMode(ReleaseMode.loop);
  }

  void _initNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
    
    // 🎯 AJOUT DARWIN (iOS/macOS)
    const DarwinInitializationSettings initializationSettingsDarwin = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const LinuxInitializationSettings initializationSettingsLinux = LinuxInitializationSettings(defaultActionName: 'Ouvrir');

    final InitializationSettings initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsDarwin,
        linux: initializationSettingsLinux,
    );
    
    try {
      // Sur Windows, le plugin peut nécessiter des dépendances supplémentaires. 
      // On wrap l'initialisation pour éviter un crash au démarrage sur Windows.
      if (!kIsWeb && (Platform.isAndroid || Platform.isIOS || Platform.isLinux || Platform.isMacOS)) {
        await flutterLocalNotificationsPlugin.initialize(initializationSettings);
      }
    } catch (e) {
      debugPrint("Notification init bypassed or failed on this platform: $e");
    }
  }

  void setTabIndex(int index) { _currentTabIndex = index; notifyListeners(); }
  void minimizeTimer() { _isTimerMinimized = true; notifyListeners(); }
  void restoreTimer() { _isTimerMinimized = false; notifyListeners(); }

  void setManualTimer(Duration duration) {
    _stopTimerInternal();
    _currentTask = null;
    _totalDuration = duration;
    _remainingDuration = duration;
    _elapsedSeconds = 0;
    _isFinished = false;
    _isTimerMinimized = false;
    _activeSession = WorkSession.create(title: "Session Personnelle", isPersonal: true);
    notifyListeners();
  }

  void initializeTimer(Task task) {
    if (_currentTask?.id == task.id && !_isFinished) return;
    _stopTimerInternal(); 
    _currentTask = task;
    _totalDuration = Duration(minutes: task.workingDuration > 0 ? task.workingDuration : 25);
    _remainingDuration = _totalDuration;
    _elapsedSeconds = 0;
    _isFinished = false;
    _isTimerMinimized = false;
    _activeSession = WorkSession.create(title: task.title, taskId: task.id, isPersonal: false);
    notifyListeners();
  }

  void startTaskTimer(Task task) async {
    initializeTimer(task);
    task.status = "In Progress";
    task.isOngoing = true;
    await task.save();
    setTabIndex(2); 
    startTimer();
  }

  void startTimer({HiveDataStore? dataStore}) {
    if (_remainingDuration > Duration.zero && !_isRunning) {
      _isRunning = true;
      _isFinished = false;
      if (!kIsWeb) _startTictac(); 
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (_remainingDuration.inSeconds > 0) {
          _remainingDuration -= const Duration(seconds: 1);
          _elapsedSeconds++;
          notifyListeners();
        } else {
          _completeSession(dataStore);
        }
      });
      notifyListeners();
    }
  }

  void _completeSession(HiveDataStore? dataStore) async {
    _stopTimerInternal();
    _isFinished = true;
    _isTimerMinimized = false;

    if (_currentTask != null) {
      _currentTask!.status = "Done";
      _currentTask!.isCompleted = true;
      _currentTask!.isOngoing = false;
      await _currentTask!.save();
    }

    if (_activeSession != null && dataStore != null) {
      _activeSession!.completedAt = DateTime.now();
      _activeSession!.elapsedSeconds = _elapsedSeconds;
      await dataStore.addSession(session: _activeSession!);
      _activeSession = null;
      _elapsedSeconds = 0;
    }

    _showNotification("Temps écoulé", "Focus terminé sur : ${_currentTask?.title ?? 'votre session'}");
    _playAlarm();
    notifyListeners();
  }

  void pauseTimer() { _stopTimerInternal(); _isRunning = false; notifyListeners(); }
  
  void resetTimer({HiveDataStore? dataStore}) async {
    if (dataStore != null && _activeSession != null && _elapsedSeconds > 0) {
      _activeSession!.completedAt = DateTime.now();
      _activeSession!.elapsedSeconds = _elapsedSeconds;
      await dataStore.addSession(session: _activeSession!);
    }
    if (_currentTask != null) {
      _stopTimerInternal();
      _remainingDuration = _totalDuration;
      _isFinished = false;
      _elapsedSeconds = 0;
      _activeSession = WorkSession.create(title: _currentTask!.title, taskId: _currentTask!.id, isPersonal: false);
    } else if (_totalDuration > Duration.zero) {
      _stopTimerInternal();
      _remainingDuration = _totalDuration;
      _isFinished = false;
      _elapsedSeconds = 0;
      _activeSession = WorkSession.create(title: "Session Personnelle", isPersonal: true);
    }
    notifyListeners();
  }

  void _stopTimerInternal() { _timer?.cancel(); _isRunning = false; _stopTictac(); _stopAlarm(); }
  void _startTictac() async { if (await _tictacPlayer.state == PlayerState.playing) return; await _tictacPlayer.setSourceAsset(_tictacSound); await _tictacPlayer.resume(); }
  void _stopTictac() async { await _tictacPlayer.stop(); }
  void _playAlarm() async { if (kIsWeb) return; await _alarmPlayer.setSourceAsset(_alarmSound); await _alarmPlayer.resume(); }
  void _stopAlarm() async { await _alarmPlayer.stop(); }

  Future<void> _showNotification(String title, String body) async {
    // 🎯 FIX: Vérification plateforme avant notification pour éviter crash Windows
    if (kIsWeb || ! (Platform.isAndroid || Platform.isIOS || Platform.isLinux || Platform.isMacOS)) return;

    const AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails('timer_channel', 'Minuteur', importance: Importance.max, priority: Priority.high);
    const NotificationDetails platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics);
    try {
      await flutterLocalNotificationsPlugin.show(_currentTask?.hashCode ?? 0, title, body, platformChannelSpecifics);
    } catch (e) {
      debugPrint("Notification failed on this platform: $e");
    }
  }
}
