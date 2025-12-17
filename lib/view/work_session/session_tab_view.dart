// lib/view/work_session/session_tab_view.dart

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../utils/colors.dart';
import '../clock/alarm_view.dart';
import '../clock/world_clock_view.dart';
import '../clock/timer_view.dart';
import '../clock/stopwatch_view.dart';

class SessionTabView extends StatelessWidget {
  const SessionTabView({super.key});

  @override
  Widget build(BuildContext context) {
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

  Widget _buildToolTile(BuildContext context, String title, IconData icon, Widget destination) {
    return ListTile(
      leading: Icon(icon, color: MyColors.primaryColor),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      trailing: const Icon(Icons.chevron_right, size: 20),
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => destination)),
    );
  }
}
