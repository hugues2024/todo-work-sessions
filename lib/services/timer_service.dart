// lib/services/timer_service.dart

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart'; // Ajouté pour ChangeNotifier

import '../models/task.dart';

// Initialisation des notifications (simple)
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

// =========================================================================
// 🎯 CHEMINS DES FICHIERS AUDIO (Doivent exister dans assets/audio/)
// =========================================================================
const String _alarmSound = 'audio/alarme.mp3';      // Pour la sonnerie de fin (jouée par AudioPlayer)
const String _notificationSound = 'audio/notification.mp3'; // Pour le son de la notification système
const String _tictacSound = 'audio/minuteur.mp3';  // Pour le tictac

// Nom de la ressource audio pour Android (sans extension .mp3).
// Ce fichier doit être dans android/app/src/main/res/raw/
const String _androidNotificationSoundName = 'notification'; 

class TimerService extends ChangeNotifier {
  // L'objet Task actuel géré par le minuteur
  Task? _currentTask;
  
  // Durées
  Duration _totalDuration = Duration.zero;
  Duration _remainingDuration = Duration.zero;
  
  // État du minuteur
  Timer? _timer;
  bool _isRunning = false;
  bool _isFinished = false;

  // Audio Players
  final _alarmPlayer = AudioPlayer();
  final _tictacPlayer = AudioPlayer();
  
  // Getters publics
  Task? get currentTask => _currentTask;
  Duration get remainingDuration => _remainingDuration;
  Duration get totalDuration => _totalDuration;
  bool get isRunning => _isRunning;
  bool get isFinished => _isFinished;
  
  // Calcul de la progression (utilisé par l'UI)
  double get progress {
    if (_totalDuration.inSeconds == 0) return 0.0;
    return _remainingDuration.inSeconds / _totalDuration.inSeconds;
  }
  
  // Constructeur
  TimerService() {
    _initNotifications();
    // Configure l'audio pour le tictac en mode boucle
    _tictacPlayer.setReleaseMode(ReleaseMode.loop);
  }

  // Initialisation des notifications
  void _initNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    
    const InitializationSettings initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid,
    );
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  // =========================================================================
  // 🎯 LOGIQUE DE CONTRÔLE
  // =========================================================================

  /// Charge et initialise un nouveau minuteur basé sur la tâche
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

  /// Démarre ou continue le décompte
  void startTimer() {
    if (_remainingDuration > Duration.zero && !_isRunning) {
      _isRunning = true;
      _isFinished = false;
      
      // Démarre le son du tictac
      if (!kIsWeb) {
        _startTictac(); 
      }

      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (_remainingDuration.inSeconds > 0) {
          _remainingDuration -= const Duration(seconds: 1);
          notifyListeners(); // Mise à jour de l'UI
        } else {
          _stopTimerInternal();
          _isFinished = true;
          
          // DÉCLENCHE LA NOTIFICATION SYSTÈME ET LA SONNERIE D'ALARME
          _showNotification("Tâche Terminée : ${_currentTask!.title}", "Il est temps de passer à autre chose !");
          _playAlarm(); // Joue la sonnerie de l'application
          
          notifyListeners(); // Mise à jour finale
        }
      });
      notifyListeners();
    }
  }

  /// Met le décompte en pause
  void pauseTimer() {
    _stopTimerInternal();
    _isRunning = false;
    notifyListeners();
  }
  
  /// Réinitialise le minuteur aux dates initiales de la tâche
  void resetTimer() {
    if (_currentTask != null) {
      _stopTimerInternal();
      initializeTimer(_currentTask!); // Réinitialise l'état
    }
  }

  /// Arrête le timer interne et l'audio
  void _stopTimerInternal() {
    _timer?.cancel();
    _isRunning = false;
    _stopTictac();
    _stopAlarm();
  }

  // =========================================================================
  // 🎯 GESTION DE L'AUDIO (TicTac et Alarme)
  // =========================================================================

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
    await _alarmPlayer.setReleaseMode(ReleaseMode.stop); 
    await _alarmPlayer.resume();
  }

  void _stopAlarm() async {
    await _alarmPlayer.stop();
  }

  // =========================================================================
  // 🎯 GESTION DES NOTIFICATIONS (avec son 'notification.mp3')
  // =========================================================================

  Future<void> _showNotification(String title, String body) async {
    
    // 1. Instanciation de la ressource audio (NON CONST)
    final sound = RawResourceAndroidNotificationSound(_androidNotificationSoundName);

    // 2. Création des détails de la notification (REMOVED 'const')
    final AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'timer_channel_id',
      'Minuteur des Tâches',
      channelDescription: 'Notifications pour les fins de minuteurs de tâches',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'Timer Alarme',
      // Utilise le son de notification personnalisé (instance non-const)
      sound: sound, 
    );
    
    // 3. Création du conteneur de plateformes (REMOVED 'const')
    final NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.show(
      // Utilise un ID basé sur le hash de la tâche
      _currentTask.hashCode, 
      title,
      body,
      platformChannelSpecifics,
      payload: 'timer_finished',
    );
  }
}