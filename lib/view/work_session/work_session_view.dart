// lib/view/work_session/work_session_view.dart

import 'package:flutter/material.dart';
import 'dart:async'; // Nécessaire pour Timer
import '../../models/task.dart';
import '../../utils/strings.dart';
import '../../utils/colors.dart';

class WorkSessionView extends StatefulWidget {
  final Task task;

  const WorkSessionView({
    Key? key,
    required this.task,
  }) : super(key: key);

  @override
  State<WorkSessionView> createState() => _WorkSessionViewState();
}

class _WorkSessionViewState extends State<WorkSessionView> {
  final Stopwatch _stopwatch = Stopwatch();
  bool _isRunning = false;
  String _elapsedTime = '00:00:00';
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // Vérifier si la tâche était déjà en cours (utile si l'utilisateur quitte l'appli)
    if (widget.task.isOngoing) {
      // Dans une vraie app, on chargerait le temps écoulé si la session a été interrompue.
      // Ici, on simule une reprise.
      _startStopwatch();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    // ⚠️ Note: Si vous sortez de cette vue sans appuyer sur STOP,
    // la session restera 'isOngoing' dans Hive.
    super.dispose();
  }
  
  void _startStopwatch() {
    _stopwatch.start();
    _isRunning = true;
    _timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (mounted) {
        setState(() {
          _elapsedTime = _formatTime(_stopwatch.elapsedMilliseconds);
        });
      }
    });
    setState(() {
      // Mettre à jour l'état de la tâche dans Hive
      widget.task.isOngoing = true;
      widget.task.save(); 
    });
  }

  void _stopStopwatch() {
    _stopwatch.stop();
    _timer?.cancel();
    _isRunning = false;
    setState(() {
      // Mettre à jour l'état de la tâche dans Hive
      widget.task.isOngoing = false;
      // 🎯 Optionnel : Enregistrer le temps total dans un champ de la Task ou WorkSession.
      // widget.task.totalTime = _stopwatch.elapsed;
      widget.task.save();
    });
    
    // 🚩 PLACEHOLDER ENREGISTREMENT
    // Ici, vous devriez enregistrer la WorkSession dans la box WorkSession pour l'historique
    // print('Session de travail enregistrée pour ${widget.task.title}. Durée: $_elapsedTime');
  }

  String _formatTime(int milliseconds) {
    final int hours = (milliseconds / (1000 * 60 * 60)).truncate();
    final int minutes = (milliseconds / (1000 * 60)).truncate() % 60;
    final int seconds = (milliseconds / 1000).truncate() % 60;

    final String hoursStr = (hours).toString().padLeft(2, '0');
    final String minutesStr = (minutes).toString().padLeft(2, '0');
    final String secondsStr = (seconds).toString().padLeft(2, '0');

    return '$hoursStr:$minutesStr:$secondsStr';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Minuteur de Travail",
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              "Tâche active : ${widget.task.title}",
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: MyColors.primaryColor,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const Divider(height: 40),
            
            Container(
              padding: const EdgeInsets.all(40),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10)],
              ),
              child: Column(
                children: [
                  Text(
                    _elapsedTime,
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      fontSize: 60, 
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    _isRunning ? "Session en cours..." : "Appuyez sur Démarrer",
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 40),
            
            ElevatedButton.icon(
              onPressed: _isRunning ? _stopStopwatch : _startStopwatch,
              icon: Icon(_isRunning ? Icons.stop : Icons.play_arrow, color: Colors.white),
              label: Text(
                _isRunning ? MyString.stopSession : MyString.startSession,
                style: const TextStyle(color: Colors.white, fontSize: 18),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: _isRunning ? Colors.red.shade600 : MyColors.primaryColor,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}