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


/// AppBar de la Session de Travail (inchangée)
class WorkSessionAppBar extends StatelessWidget implements PreferredSizeWidget {
  const WorkSessionAppBar({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 150,
      child: Padding(
        padding: const EdgeInsets.only(top: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 20),
              child: GestureDetector(
                onTap: () {
                  Navigator.of(context).pop();
                },
                child: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  size: 50,
                ),
              ),
            ),
            const Expanded(
              child: Center(
                child: Text(
                  "Session de travail",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(100);
}