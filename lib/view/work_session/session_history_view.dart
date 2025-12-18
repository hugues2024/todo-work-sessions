// lib/view/work_session/session_history_view.dart

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import '../../models/work_session.dart';
import '../../utils/colors.dart';
import '../../main.dart';

class SessionHistoryView extends StatelessWidget {
  const SessionHistoryView({super.key});

  @override
  Widget build(BuildContext context) {
    final dataStore = BaseWidget.of(context).dataStore;

    return Scaffold(
      appBar: AppBar(
        // 🎯 FIX: Retire le bouton back automatique
        automaticallyImplyLeading: false,
        title: const Text("Historique d'Activité", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(CupertinoIcons.trash_fill, color: Colors.red),
            onPressed: () => _confirmClearAll(context, dataStore),
          ),
        ],
      ),
      body: ValueListenableBuilder(
        valueListenable: dataStore.listenToSessions(),
        builder: (context, Box<WorkSession> box, _) {
          final sessions = box.values.toList().reversed.toList();

          if (sessions.isEmpty) {
            return const Center(child: Text("Aucune session enregistrée", style: TextStyle(color: Colors.grey)));
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: sessions.length,
            itemBuilder: (context, index) {
              final session = sessions[index];
              return Dismissible(
                key: Key(session.id),
                direction: DismissDirection.endToStart,
                onDismissed: (_) => dataStore.deleteSession(session: session),
                child: Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: CircleAvatar(
                      backgroundColor: session.isPersonal ? Colors.blue.withOpacity(0.1) : MyColors.primaryColor.withOpacity(0.1),
                      child: Icon(
                        session.isPersonal ? CupertinoIcons.person_fill : CupertinoIcons.briefcase_fill,
                        color: session.isPersonal ? Colors.blue : MyColors.primaryColor,
                        size: 20,
                      ),
                    ),
                    title: Text(session.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(DateFormat('dd MMM yyyy à HH:mm').format(session.createdAt), style: const TextStyle(fontSize: 12)),
                        if (!session.isPersonal)
                          const Text("Session liée à une tâche", style: TextStyle(fontSize: 10, fontStyle: FontStyle.italic, color: Colors.grey)),
                      ],
                    ),
                    trailing: Text(
                      session.durationFormatted,
                      style: const TextStyle(fontWeight: FontWeight.bold, color: MyColors.primaryColor),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _confirmClearAll(BuildContext context, dynamic dataStore) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text("Supprimer tout l'historique ?"),
        content: const Text("Cette action est irréversible."),
        actions: [
          CupertinoDialogAction(child: const Text("Annuler"), onPressed: () => Navigator.pop(context)),
          CupertinoDialogAction(
            isDestructiveAction: true,
            child: const Text("Supprimer"),
            onPressed: () async {
              await dataStore.sessionBox.clear();
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}
