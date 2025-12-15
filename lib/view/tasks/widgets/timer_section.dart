// lib/view/tasks/widgets/timer_section.dart

import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Pour se connecter au TimerService
import 'dart:math';

import '../../../models/task.dart';
import '../../../utils/colors.dart';
import '../../../utils/strings.dart';
import '../../../services/timer_service.dart'; // Importation du service persistant

class TimerSection extends StatefulWidget {
  final Task task;

  const TimerSection({
    Key? key,
    required this.task,
  }) : super(key: key);
  
  @override
  State<TimerSection> createState() => _TimerSectionState();
}

class _TimerSectionState extends State<TimerSection> with SingleTickerProviderStateMixin {
  
  // Pour l'animation de clignotement (UI pure)
  late AnimationController _blinkController; 
  
  @override
  void initState() {
    super.initState();
    
    // Initialisation du contrôleur d'animation pour le clignotement
    _blinkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    ); 

    // Initialisation du service avec la tâche actuelle
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final timerService = Provider.of<TimerService>(context, listen: false);
      
      // S'assure que le minuteur est initialisé si ce n'est pas déjà la tâche en cours
      if (timerService.currentTask?.id != widget.task.id) {
          timerService.initializeTimer(widget.task);
      }
    });
  }
  
  @override
  void dispose() {
    _blinkController.dispose();
    super.dispose();
  }
  
  // =========================================================================
  // FONCTIONS UTILITAIRES
  // =========================================================================

  String _timerDisplay(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    final hours = twoDigits(duration.inHours);
    return "$hours:$minutes:$seconds";
  }

  // Crée un bouton d'action circulaire
  Widget _buildActionButton({
    required IconData icon, 
    required VoidCallback? onPressed, 
    Color iconColor = Colors.white,
    Color backgroundColor = MyColors.primaryColor,
    required String tooltip,
  }) {
    return Tooltip(
      message: tooltip,
      child: Container(
        decoration: BoxDecoration(
          color: onPressed == null ? Colors.grey.shade300 : backgroundColor,
          shape: BoxShape.circle,
        ),
        child: IconButton(
          icon: Icon(icon, color: onPressed == null ? Colors.grey.shade500 : iconColor, size: 28),
          onPressed: onPressed,
        ),
      ),
    );
  }

  // =========================================================================
  // WIDGET BUILDER
  // =========================================================================

  @override
  Widget build(BuildContext context) {
    // 🎯 CONNEXION AU SERVICE PERSISTANT VIA PROVIDER
    final timerService = Provider.of<TimerService>(context);
    
    // Récupération des états du service
    final totalDuration = timerService.totalDuration;
    final remainingDuration = timerService.remainingDuration;
    final isRunning = timerService.isRunning;
    final isFinished = timerService.isFinished;
    
    final bool isTimerActive = totalDuration > Duration.zero;
    
    // =======================================================
    // 🎯 GESTION DU CLIGNOTEMENT (UI)
    // =======================================================
    if (isFinished && !_blinkController.isAnimating) {
      _blinkController.repeat(reverse: true);
    } else if (!isFinished && _blinkController.isAnimating) {
      _blinkController.stop();
    }
    
    // Déterminer l'état des boutons
    final canStart = !isRunning && remainingDuration > Duration.zero;
    final canPause = isRunning;
    final canReset = totalDuration > Duration.zero;

    // Déterminer l'icône du bouton central
    final IconData centerIcon = isRunning 
        ? CupertinoIcons.pause_fill // Pause si en cours
        : CupertinoIcons.play_fill; // Continuer (signe >) si en pause ou Démarrer
        
    // Le widget du Minuteur (potentiellement clignotant)
    final Widget timerWidget = isFinished 
        ? FadeTransition(
            opacity: _blinkController, 
            child: _buildTimerContent(timerService),
          )
        : _buildTimerContent(timerService);
        
    if (totalDuration.inSeconds <= 0 && remainingDuration.inSeconds <= 0) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(40.0),
          child: Text(
            "Minuteur impossible. Veuillez définir des dates de début et de fin valides pour cette tâche.",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.red.shade400, fontSize: 16),
          ),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 20),

          // =======================================================
          // 🎯 CADRAN MINUTEUR CIRCULAIRE
          // =======================================================
          SizedBox(
            width: 300,
            height: 300,
            child: timerWidget,
          ),
          
          const SizedBox(height: 50),

          // =======================================================
          // 🎯 BOUTONS DE CONTRÔLE 
          // =======================================================
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // 1. Réinitialiser (à gauche)
              _buildActionButton(
                icon: CupertinoIcons.arrow_counterclockwise, 
                onPressed: canReset ? timerService.resetTimer : null,
                iconColor: Colors.white,
                backgroundColor: Colors.redAccent,
                tooltip: MyString.resetTask,
              ),

              // 2. Pause / Continuer (au milieu)
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  // Fond violet si peut interagir (Start/Pause), gris sinon
                  color: (canStart || canPause) ? MyColors.primaryColor : Colors.grey.shade300, 
                ),
                child: IconButton(
                  // Icône blanche dans le fond violet si en cours/prêt
                  icon: Icon(
                    centerIcon, 
                    color: (canStart || canPause) ? Colors.white : Colors.grey.shade500, 
                    size: 40
                  ),
                  // Appelle les fonctions du service
                  onPressed: canPause 
                    ? timerService.pauseTimer 
                    : (canStart ? timerService.startTimer : null),
                ),
              ),

              // 3. Notification (à droite)
              _buildActionButton(
                icon: CupertinoIcons.bell_fill, 
                onPressed: isTimerActive ? () { 
                  ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Le service de notification et d'audio est actif en arrière-plan (TicTac et Alarme de fin)."),
                        backgroundColor: Colors.blueAccent,
                        duration: const Duration(seconds: 2),
                      ),
                  );
                } : null,
                iconColor: Colors.white,
                backgroundColor: Colors.blueAccent,
                tooltip: "État de la Notification",
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  // Widget séparé pour le contenu du minuteur (réutilisé pour le clignotement)
  Widget _buildTimerContent(TimerService timerService) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Cercle de Progression (Minuteur)
        SizedBox(
          width: 300,
          height: 300,
          child: CircularProgressIndicator(
            // La progression vient du service
            value: timerService.progress.clamp(0.0, 1.0), 
            strokeWidth: 15,
            backgroundColor: MyColors.primaryColor.withOpacity(0.2), // Fond de progression (zone déjà écoulée)
            valueColor: AlwaysStoppedAnimation<Color>(MyColors.primaryColor), // Couleur de la progression (zone restante)
          ),
        ),
        
        // Contenu central (Temps + Nom de la Tâche)
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _timerDisplay(timerService.remainingDuration), // Affichage de la durée restante
              style: const TextStyle(
                fontSize: 60,
                fontWeight: FontWeight.w700,
                fontFeatures: [FontFeature.tabularFigures()],
              ),
            ),
            const SizedBox(height: 5),
            Text(
              widget.task.title,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ],
    );
  }
}