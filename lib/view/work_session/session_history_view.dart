// lib/view/work_session/session_history_view.dart

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/work_session.dart';
import '../../utils/colors.dart';
import '../../main.dart';
import '../../services/timer_service.dart';

class SessionHistoryView extends StatelessWidget {
  const SessionHistoryView({super.key});

  String _getDateHeader(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final sessionDate = DateTime(date.year, date.month, date.day);

    if (sessionDate == today) return "Aujourd'hui";
    if (sessionDate == yesterday) return "Hier";
    return DateFormat('EEEE d MMMM', 'fr_FR').format(date);
  }

  @override
  Widget build(BuildContext context) {
    final dataStore = BaseWidget.of(context).dataStore;
    final timerService = context.watch<TimerService>();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text("Journal d'Activité", style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(CupertinoIcons.trash_fill, color: Colors.red, size: 20),
            onPressed: () => _confirmClearAll(context, dataStore),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: ValueListenableBuilder(
        valueListenable: dataStore.listenToSessions(),
        builder: (context, Box<WorkSession> box, _) {
          final sessions = box.values.toList();
          sessions.sort((a, b) => b.createdAt.compareTo(a.createdAt));

          if (sessions.isEmpty) {
            return _buildEmptyState();
          }

          // Groupement par jour
          Map<String, List<WorkSession>> groupedSessions = {};
          for (var s in sessions) {
            String header = _getDateHeader(s.createdAt);
            groupedSessions.putIfAbsent(header, () => []).add(s);
          }

          return Column(
            children: [
              _buildStatsHeader(sessions, timerService),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.only(top: 10),
                  itemCount: groupedSessions.length,
                  itemBuilder: (context, index) {
                    String dateHeader = groupedSessions.keys.elementAt(index);
                    List<WorkSession> daySessions = groupedSessions[dateHeader]!;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(24, 20, 20, 8),
                          child: Text(
                            dateHeader.toUpperCase(),
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.2),
                          ),
                        ),
                        ...daySessions.map((s) => _buildSessionCard(context, s, dataStore)).toList(),
                      ],
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatsHeader(List<WorkSession> sessions, TimerService timerService) {
    final now = DateTime.now();
    final todaySessions = sessions.where((s) => s.createdAt.day == now.day && s.createdAt.month == now.month).toList();
    int totalSecondsToday = todaySessions.fold(0, (sum, s) => sum + s.elapsedSeconds);

    return Container(
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: MyColors.primaryGradientColor, begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: MyColors.primaryColor.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 8))],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem("AUJOURD'HUI", timerService.formatHms(Duration(seconds: totalSecondsToday))),
          Container(width: 1, height: 40, color: Colors.white24),
          _buildStatItem("SESSIONS", todaySessions.length.toString()),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildSessionCard(BuildContext context, WorkSession s, dynamic dataStore) {
    IconData icon;
    Color iconColor;
    switch (s.sessionType) {
      case 'Task': icon = CupertinoIcons.briefcase_fill; iconColor = MyColors.primaryColor; break;
      case 'SubTask': icon = CupertinoIcons.layers_fill; iconColor = Colors.orange; break;
      case 'Stopwatch': icon = CupertinoIcons.stopwatch_fill; iconColor = Colors.blue; break;
      default: icon = CupertinoIcons.timer; iconColor = Colors.teal;
    }

    return Dismissible(
      key: Key(s.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => dataStore.deleteSession(session: s),
      background: Container(alignment: Alignment.centerRight, padding: const EdgeInsets.only(right: 20), color: Colors.red, child: const Icon(CupertinoIcons.delete, color: Colors.white)),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.black.withOpacity(0.05))),
        child: Row(
          children: [
            Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: iconColor.withOpacity(0.1), shape: BoxShape.circle), child: Icon(icon, color: iconColor, size: 20)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(s.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  Text(DateFormat('HH:mm').format(s.createdAt), style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
                ],
              ),
            ),
            Text(s.durationFormatted, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14, fontFamily: 'monospace')),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(child: Text("Aucune activité", style: TextStyle(color: Colors.grey)));
  }

  void _confirmClearAll(BuildContext context, dynamic dataStore) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text("Vider l'historique ?"),
        content: const Text("Cette action est irréversible."),
        actions: [
          CupertinoDialogAction(child: const Text("Annuler"), onPressed: () => Navigator.pop(context)),
          CupertinoDialogAction(isDestructiveAction: true, child: const Text("Confirmer"), onPressed: () async { await dataStore.sessionBox.clear(); Navigator.pop(context); }),
        ],
      ),
    );
  }
}
