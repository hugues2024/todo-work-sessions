// lib/view/work_session/work_session_view.dart (CODE COMPLET ET FINAL)

// ignore_for_file: must_be_immutable, use_build_context_synchronously

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import '../../main.dart';
import '../../models/work_session.dart';
import '../../utils/colors.dart';
import '../../utils/strings.dart';
import 'session_create_view.dart';
import 'session_widget.dart'; // 👈 NOUVEL IMPORT

class WorkSessionView extends StatelessWidget {
  const WorkSessionView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final base = BaseWidget.of(context);

    return ValueListenableBuilder(
      valueListenable: base.dataStore.listenToSessions(),
      builder: (ctx, Box<WorkSession> box, Widget? child) {
        var sessions = box.values.toList();
        
        // Trier les sessions par date de création (la plus récente d'abord)
        sessions.sort(((a, b) => b.createdAt.compareTo(a.createdAt)));

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: const WorkSessionAppBar(),
          
          // Floating Action Button pour ajouter une nouvelle session
          floatingActionButton: FloatingActionButton(
            backgroundColor: MyColors.primaryColor,
            onPressed: () {
              Navigator.of(context).push(
                CupertinoPageRoute(
                  builder: (context) => SessionCreateView(session: null),
                ),
              );
            },
            child: const Icon(Icons.add, color: Colors.white),
          ),
          
          body: sessions.isNotEmpty
              ? ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  itemCount: sessions.length,
                  itemBuilder: (BuildContext context, int index) {
                    var session = sessions[index];

                    return Dismissible(
                      direction: DismissDirection.horizontal,
                      background: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.delete_outline, color: Colors.grey),
                          SizedBox(width: 8),
                          Text(MyString.deletedTask, style: TextStyle(color: Colors.grey)),
                        ],
                      ),
                      onDismissed: (direction) {
                        base.dataStore.deleteSession(session: session);
                      },
                      key: Key(session.id),
                      child: SessionWidget(session: session),
                    );
                  },
                )
              : Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Aucune session de travail planifiée.",
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "Cliquez sur '+' pour planifier une session.",
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                ),
        );
      },
    );
  }
}

/// AppBar moderne
class WorkSessionAppBar extends StatelessWidget implements PreferredSizeWidget {
  const WorkSessionAppBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.white,
      foregroundColor: Colors.black87,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 22),
        onPressed: () => Navigator.pop(context),
      ),
      title: const Text(
        "Sessions de travail",
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      centerTitle: true,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(56);
}