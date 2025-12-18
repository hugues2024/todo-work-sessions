// lib/view/work_session/session_tab_view.dart

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../utils/colors.dart';
import '../clock/alarm_view.dart';
import '../clock/world_clock_view.dart';
import '../clock/timer_view.dart';
import '../clock/stopwatch_view.dart';
import '../../services/timer_service.dart';

class SessionTabView extends StatelessWidget {
  const SessionTabView({super.key});

  @override
  Widget build(BuildContext context) {
    final timerService = context.watch<TimerService>();

    // 🎯 AUTO-REDIRECTION INTELLIGENTE : 
    // On n'affiche le minuteur que si une tâche est active ET que l'utilisateur ne l'a pas minimisé
    if ((timerService.isRunning || timerService.currentTask != null) && !timerService.isTimerMinimized) {
      return const TimerView(isFromHub: true); // On passe le flag pour autoriser le retour
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Horloge", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🎯 BANDEAU DE REPRISE : Si un timer tourne en fond, on propose d'y revenir
            if (timerService.currentTask != null && timerService.isTimerMinimized)
              _buildResumeBanner(context, timerService),

            const Padding(
              padding: EdgeInsets.fromLTRB(20, 20, 20, 10),
              child: Text("OUTILS", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 12)),
            ),
            _buildToolTile(context, "Alarmes", CupertinoIcons.bell_fill, const AlarmView()),
            _buildToolTile(context, "Horloge Mondiale", CupertinoIcons.globe, const WorldClockView()),
            _buildToolTile(context, "Minuteur", CupertinoIcons.hourglass, const TimerView()),
            _buildToolTile(context, "Chronomètre", CupertinoIcons.stopwatch_fill, const StopwatchView()),
          ],
        ),
      ),
    );
  }

  Widget _buildResumeBanner(BuildContext context, TimerService timerService) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: MyColors.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: MyColors.primaryColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(CupertinoIcons.timer, color: MyColors.primaryColor, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              "Tâche en cours : ${timerService.currentTask?.title}",
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          TextButton(
            onPressed: () => timerService.restoreTimer(),
            child: const Text("AFFICHER"),
          ),
        ],
      ),
    );
  }

  Widget _buildToolTile(BuildContext context, String title, IconData icon, Widget destination) {
    return ListTile(
      leading: Icon(icon, color: MyColors.primaryColor),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      trailing: const Icon(Icons.chevron_right, size: 20),
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => destination)),
    );
  }
}
