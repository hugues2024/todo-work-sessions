// lib/services/timer_service.dart

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';

import '../models/task.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

const String _alarmSound = 'audio/alarme.mp3';
const String _notificationSound = 'audio/notification.mp3';
const String _tictacSound = 'audio/minuteur.mp3';
const String _androidNotificationSoundName = 'notification'; 

class TimerService extends ChangeNotifier {
  Task? _currentTask;
  
  Duration _totalDuration = Duration.zero;
  Duration _remainingDuration = Duration.zero;
  
  Timer? _timer;
  bool _isRunning = false;
  bool _isFinished = false;

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
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    
    // 🎯 FIX: Ajout des paramètres Linux obligatoires
    const LinuxInitializationSettings initializationSettingsLinux =
        LinuxInitializationSettings(defaultActionName: 'Ouvrir');

    final InitializationSettings initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid,
        linux: initializationSettingsLinux, // Requis pour éviter le crash sur Linux
    );
    
    try {
      await flutterLocalNotificationsPlugin.initialize(initializationSettings);
    } catch (e) {
      debugPrint("Erreur lors de l'initialisation des notifications : $e");
    }
  }

  void initializeTimer(Task task) {
    if (_currentTask?.id == task.id && !_isFinished) return;

    _stopTimerInternal(); 
    _currentTask = task;
    
    final start = task.startDate;
    final end = task.endDate;
    
    _isFinished = false;

    if (start != null && end != null && end.isAfter(start)) {
      _totalDuration = end.difference(start);
      _remainingDuration = end.difference(DateTime.now());

      if (_remainingDuration.isNegative) {
        _remainingDuration = Duration.zero;
        _totalDuration = Duration.zero;
        _isFinished = true;
      }
    } else {
      _totalDuration = Duration.zero;
      _remainingDuration = Duration.zero;
    }
    notifyListeners();
  }

  void startTimer() {
    if (_remainingDuration > Duration.zero && !_isRunning) {
      _isRunning = true;
      _isFinished = false;
      
      if (!kIsWeb) {
        _startTictac(); 
      }

      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (_remainingDuration.inSeconds > 0) {
          _remainingDuration -= const Duration(seconds: 1);
          notifyListeners();
        } else {
          _stopTimerInternal();
          _isFinished = true;
          _showNotification("Tâche Terminée : ${_currentTask?.title ?? ''}", "Il est temps de passer à autre chose !");
          _playAlarm();
          notifyListeners();
        }
      });
      notifyListeners();
    }
  }

  void pauseTimer() {
    _stopTimerInternal();
    _isRunning = false;
    notifyListeners();
  }
  
  void resetTimer() {
    if (_currentTask != null) {
      _stopTimerInternal();
      initializeTimer(_currentTask!);
    }
  }

  void _stopTimerInternal() {
    _timer?.cancel();
    _isRunning = false;
    _stopTictac();
    _stopAlarm();
  }

  void _startTictac() async {
    if (await _tictacPlayer.state == PlayerState.playing) return; 
    await _tictacPlayer.setSourceAsset(_tictacSound);
    await _tictacPlayer.resume(); 
  }

  void _stopTictac() async {
    await _tictacPlayer.stop();
  }
  
  void _playAlarm() async {
    if (kIsWeb) return;
    await _alarmPlayer.setSourceAsset(_alarmSound);
    await _alarmPlayer.resume();
  }

  void _stopAlarm() async {
    await _alarmPlayer.stop();
  }

  Future<void> _showNotification(String title, String body) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'timer_channel_id',
      'Minuteur des Tâches',
      importance: Importance.max,
      priority: Priority.high,
    );
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.show(
      _currentTask.hashCode, 
      title,
      body,
      platformChannelSpecifics,
    );
  }
}
