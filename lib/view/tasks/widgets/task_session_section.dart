// lib/view/tasks/widgets/task_session_section.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../models/task.dart';
import '../../../utils/colors.dart';
import '../../../utils/strings.dart';

// Transformé en StatefulWidget pour gérer le temps et l'état
class TaskSessionSection extends StatefulWidget {
  final Task task;

  const TaskSessionSection({
    Key? key,
    required this.task,
  }) : super(key: key);
  
  @override
  State<TaskSessionSection> createState() => _TaskSessionSectionState();
}

class _TaskSessionSectionState extends State<TaskSessionSection> {
  // L'état de la tâche 'isOngoing' est dans le modèle, mais nous utilisons ici
  // une variable locale pour la gestion du Timer dans le widget.
  bool _isSessionRunning = false;
  Duration _elapsedTime = Duration.zero; // Temps écoulé de la session
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // Normalement, vous récupéreriez ici le temps écoulé si la session était déjà en cours
    // (stocké dans un provider ou dans Hive pour une persistance réelle).
    
    // Si la tâche est marquée comme en cours dans le modèle, démarrer le timer (simulation)
    if (widget.task.isOngoing) {
      _startTimer();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
  
  /// Gère le démarrage du chronomètre
  void _startTimer() {
    if (!_isSessionRunning) {
      // Simulation: Marquer la tâche comme en cours (nécessite une mise à jour dans Hive)
      widget.task.isOngoing = true;
      // BaseWidget.of(context).dataStore.updateTask(task: widget.task); // Pour la persistance

      _isSessionRunning = true;
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        setState(() {
          _elapsedTime += const Duration(seconds: 1);
        });
      });
      _showSnackBar("Session démarrée !");
    }
  }

  /// Gère l'arrêt/pause du chronomètre
  void _stopTimer() {
    if (_isSessionRunning) {
      _timer?.cancel();
      _isSessionRunning = false;
      // Simulation: Marquer la tâche comme stoppée
      widget.task.isOngoing = false;
      // BaseWidget.of(context).dataStore.updateTask(task: widget.task);

      _showSnackBar("Session stoppée.");
      // L'état _elapsedTime est conservé, permettant de "Continuer"
    }
  }
  
  /// Gère la réinitialisation du chronomètre (Fin de session)
  void _resetTimer() {
    _stopTimer();
    setState(() {
      _elapsedTime = Duration.zero;
    });
    // Logique de clôture de la session (enregistrement des données)
    _showSnackBar("Session réinitialisée.");
  }

  /// Afficher une notification rapide
  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 1),
      ),
    );
  }
  
  // =========================================================================
  // 🎯 LOGIQUE D'ÉTAT DES BOUTONS
  // =========================================================================
  
  // Logique pour l'activation des boutons selon l'état actuel et les dates
  bool get _isPastStartDate => widget.task.startDate != null && widget.task.startDate!.isBefore(DateTime.now());
  
  bool get _canStart => !_isSessionRunning && _elapsedTime.inSeconds == 0 && _isPastStartDate;
  bool get _canStop => _isSessionRunning;
  bool get _canContinue => !_isSessionRunning && _elapsedTime.inSeconds > 0 && _isPastStartDate;
  // Nous utiliserons le bouton Stopper pour l'arrêt définitif/enregistrement

  // Formatage du temps écoulé (HH:MM:SS)
  String get _timerDisplay {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(_elapsedTime.inMinutes.remainder(60));
    final seconds = twoDigits(_elapsedTime.inSeconds.remainder(60));
    final hours = twoDigits(_elapsedTime.inHours);
    return "$hours:$minutes:$seconds";
  }

  // Crée un conteneur pour afficher l'heure ou la date
  Widget _buildDateTimeInfo(String title, DateTime? dateTime) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
        ),
        const SizedBox(height: 4),
        Text(
          dateTime != null ? DateFormat('dd/MM HH:mm').format(dateTime) : 'Non défini',
          style: TextStyle(
            color: MyColors.primaryColor, 
            fontWeight: FontWeight.bold, 
            fontSize: 15
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // Si l'heure de début n'est pas passée, on ne peut pas interagir
    bool canInteract = _isPastStartDate || widget.task.isOngoing; 

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Titre (Chronomètre)
          const SizedBox(height: 20),

          // =======================================================
          // 🎯 SECTION CHRONOMÈTRE + DATES
          // =======================================================
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Chronomètre
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(25),
                  decoration: BoxDecoration(
                    color: _isSessionRunning ? MyColors.primaryColor.withOpacity(0.1) : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: _isSessionRunning ? MyColors.primaryColor : Colors.grey.shade300)
                  ),
                  child: Center(
                    child: Text(
                      _timerDisplay,
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.w700,
                        color: _isSessionRunning ? MyColors.primaryColor : Colors.black87,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 15),

              // Dates de Début/Fin
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildDateTimeInfo(MyString.startDate, widget.task.startDate),
                  const SizedBox(height: 20),
                  _buildDateTimeInfo(MyString.endDate, widget.task.endDate),
                ],
              ),
            ],
          ),
          const SizedBox(height: 30),

          // =======================================================
          // 🎯 BOUTONS D'ACTION (Démarrer / Stopper / Continuer)
          // =======================================================
          if (canInteract)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // 1. Démarrer
                Expanded(
                  child: ElevatedButton(
                    onPressed: _canStart ? _startTimer : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: MyColors.primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(MyString.startSession, style: const TextStyle(color: Colors.white)),
                  ),
                ),
                const SizedBox(width: 10),
                
                // 2. Stopper/Pause (Si > 0, on peut faire une pause ou finir)
                Expanded(
                  child: ElevatedButton(
                    onPressed: _canStop || _canContinue ? _stopTimer : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _canStop ? Colors.redAccent : Colors.orange.shade300,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(_canStop ? MyString.stopSession : MyString.resetTask, 
                        style: const TextStyle(color: Colors.white)),
                  ),
                ),
                const SizedBox(width: 10),
                
                // 3. Continuer (Si en pause et temps enregistré)
                Expanded(
                  child: ElevatedButton(
                    onPressed: _canContinue ? _startTimer : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade600,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(MyString.continueSession, style: const TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            )
          else
            // Message si l'interaction n'est pas possible
            Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Text(
                  "La tâche peut être démarrée à partir de ${DateFormat('dd/MM HH:mm').format(widget.task.startDate!)}.",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey.shade600, fontStyle: FontStyle.italic),
                ),
              ),
            ),
        ],
      ),
    );
  }
}