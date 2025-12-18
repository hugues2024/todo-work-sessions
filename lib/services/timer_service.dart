// lib/services/timer_service.dart

import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import 'package:sound_mode/sound_mode.dart'; 
import 'package:sound_mode/utils/constants.dart';

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

  bool _isDoNotDisturb = false;
  bool get isDoNotDisturb => _isDoNotDisturb;

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
  int get elapsedSeconds => _elapsedSeconds;
  
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
    const DarwinInitializationSettings initializationSettingsDarwin = DarwinInitializationSettings(requestAlertPermission: true, requestBadgePermission: true, requestSoundPermission: true);
    const LinuxInitializationSettings initializationSettingsLinux = LinuxInitializationSettings(defaultActionName: 'Ouvrir');
    final InitializationSettings settings = InitializationSettings(android: initializationSettingsAndroid, iOS: initializationSettingsDarwin, linux: initializationSettingsLinux);
    try { if (!kIsWeb && (Platform.isAndroid || Platform.isIOS || Platform.isLinux || Platform.isMacOS)) { await flutterLocalNotificationsPlugin.initialize(settings); } } catch (e) { debugPrint("Notification init failed: $e"); }
  }

  // 🎯 AJOUT DE FORMATHMS
  String formatHms(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = d.inHours.toString().padLeft(2, '0');
    final minutes = twoDigits(d.inMinutes.remainder(60));
    final seconds = twoDigits(d.inSeconds.remainder(60));
    return "${hours}h${minutes}m${seconds}s";
  }

  Future<void> toggleDoNotDisturb() async {
    _isDoNotDisturb = !_isDoNotDisturb;
    if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
      try {
        if (_isDoNotDisturb) {
          await (SoundMode as dynamic).setSoundMode("SILENT");
          _stopTictac();
        } else {
          await (SoundMode as dynamic).setSoundMode("NORMAL");
          if (_isRunning) _startTictac();
        }
      } catch (e) { debugPrint("DND Error: $e"); }
    } else {
      if (_isDoNotDisturb) { _stopTictac(); _stopAlarm(); } else if (_isRunning) { _startTictac(); }
    }
    notifyListeners();
  }

  void setTabIndex(int index) { _currentTabIndex = index; notifyListeners(); }
  void minimizeTimer() { _isTimerMinimized = true; notifyListeners(); }
  void restoreTimer() { _isTimerMinimized = false; notifyListeners(); }

  Future<void> finalizeAndSaveSession(HiveDataStore dataStore) async {
    if (_activeSession == null && _currentTask != null && _elapsedSeconds > 0) {
      _activeSession = WorkSession.create(title: _currentTask!.title, taskId: _currentTask!.id, isPersonal: false, sessionType: _currentTask!.isSubTask ? "SubTask" : "Task");
    }
    if (_activeSession != null && _elapsedSeconds > 0) {
      _activeSession!.completedAt = DateTime.now();
      _activeSession!.elapsedSeconds = _elapsedSeconds;
      await dataStore.addSession(session: _activeSession!);
      if (_currentTask != null) {
        _activeSession = WorkSession.create(title: _currentTask!.title, taskId: _currentTask!.id, isPersonal: false, sessionType: _currentTask!.isSubTask ? "SubTask" : "Task");
      } else {
        _activeSession = null;
      }
      _elapsedSeconds = 0;
      notifyListeners();
    }
  }

  void startStopwatchSession() {
    _stopTimerInternal();
    _currentTask = null;
    _totalDuration = Duration.zero;
    _remainingDuration = Duration.zero;
    _elapsedSeconds = 0;
    _activeSession = WorkSession.create(title: "Chronomètre", sessionType: "Stopwatch");
    notifyListeners();
  }

  void setManualTimer(Duration duration) {
    _stopTimerInternal();
    _currentTask = null;
    _totalDuration = duration;
    _remainingDuration = duration;
    _elapsedSeconds = 0;
    _activeSession = WorkSession.create(title: "Minuteur Manuel", sessionType: "Timer");
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
    _activeSession = WorkSession.create(title: task.title, taskId: task.id, isPersonal: false, sessionType: task.isSubTask ? "SubTask" : "Task");
    notifyListeners();
  }

  void startTaskTimer(Task task) async {
    initializeTimer(task);
    task.status = "In Progress";
    task.isOngoing = true;
    await task.save();
    setTabIndex(2); 
  }

  void startTimer({HiveDataStore? dataStore}) {
    if ((_remainingDuration > Duration.zero || _activeSession?.sessionType == "Stopwatch") && !_isRunning) {
      _isRunning = true;
      _isFinished = false;
      if (!kIsWeb && !_isDoNotDisturb) _startTictac(); 
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (_activeSession?.sessionType == "Stopwatch") {
          _elapsedSeconds++;
          notifyListeners();
        } else {
          if (_remainingDuration.inSeconds > 0) {
            _remainingDuration -= const Duration(seconds: 1);
            _elapsedSeconds++;
            notifyListeners();
          } else {
            _completeSession(dataStore);
          }
        }
      });
      notifyListeners();
    }
  }

  void _completeSession(HiveDataStore? dataStore) async {
    _stopTimerInternal();
    _isFinished = true;
    if (_currentTask != null) {
      _currentTask!.status = "To Do"; 
      _currentTask!.isCompleted = true;
      _currentTask!.isOngoing = false;
      await _currentTask!.save();
    }
    if (dataStore != null) await finalizeAndSaveSession(dataStore);
    if (!_isDoNotDisturb) {
      _showNotification("Terminé", "Session de focus accomplie !");
      _playAlarm();
    }
    notifyListeners();
  }

  void pauseTimer({HiveDataStore? dataStore}) async {
    _stopTimerInternal();
    _isRunning = false;
    if (dataStore != null) await finalizeAndSaveSession(dataStore);
    notifyListeners();
  }
  
  Future<void> resetTimer({HiveDataStore? dataStore}) async {
    if (dataStore != null) await finalizeAndSaveSession(dataStore);
    if (_currentTask != null) initializeTimer(_currentTask!);
    else { _stopTimerInternal(); _remainingDuration = Duration.zero; _elapsedSeconds = 0; }
    notifyListeners();
  }

  Future<void> cancelTaskAndExit(HiveDataStore dataStore) async {
    await finalizeAndSaveSession(dataStore);
    if (_currentTask != null) {
      _currentTask!.status = "To Do";
      _currentTask!.isOngoing = false;
      await _currentTask!.save();
    }
    _stopTimerInternal();
    _currentTask = null;
    _activeSession = null;
    _elapsedSeconds = 0;
    _isTimerMinimized = false;
    notifyListeners();
  }

  void _stopTimerInternal() { _timer?.cancel(); _isRunning = false; _stopTictac(); _stopAlarm(); }
  void _startTictac() async { if (await _tictacPlayer.state == PlayerState.playing) return; await _tictacPlayer.setSourceAsset(_tictacSound); await _tictacPlayer.resume(); }
  void _stopTictac() async { await _tictacPlayer.stop(); }
  void _playAlarm() async { if (kIsWeb || _isDoNotDisturb) return; await _alarmPlayer.setSourceAsset(_alarmSound); await _alarmPlayer.resume(); }
  void _stopAlarm() async { await _alarmPlayer.stop(); }

  Future<void> _showNotification(String title, String body) async {
    if (kIsWeb || _isDoNotDisturb || !(Platform.isAndroid || Platform.isIOS || Platform.isLinux || Platform.isMacOS)) return;
    const AndroidNotificationDetails android = AndroidNotificationDetails('timer_channel', 'Minuteur', importance: Importance.max, priority: Priority.high);
    const NotificationDetails platform = NotificationDetails(android: android);
    try { await flutterLocalNotificationsPlugin.show(_currentTask?.hashCode ?? 0, title, body, platform); } catch (e) { debugPrint("Notification failed: $e"); }
  }
}
