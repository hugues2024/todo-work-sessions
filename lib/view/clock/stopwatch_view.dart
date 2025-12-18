// lib/view/clock/stopwatch_view.dart

import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../utils/colors.dart';
import '../../models/work_session.dart';
import '../../main.dart';

class StopwatchView extends StatefulWidget {
  const StopwatchView({super.key});

  @override
  State<StopwatchView> createState() => _StopwatchViewState();
}

class _StopwatchViewState extends State<StopwatchView> {
  final Stopwatch _stopwatch = Stopwatch();
  late Timer _timer;
  List<String> _laps = [];

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(milliseconds: 30), (timer) {
      if (_stopwatch.isRunning) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  String _formatTime(int ms) {
    int hundreds = (ms / 10).truncate() % 100;
    int seconds = (ms / 1000).truncate() % 60;
    int minutes = (ms / (1000 * 60)).truncate() % 60;
    int hours = (ms / (1000 * 60 * 60)).truncate();
    String h = hours > 0 ? '${hours.toString().padLeft(2, '0')}:' : '';
    return "$h${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}.${hundreds.toString().padLeft(2, '0')}";
  }

  void _handleStartPause() {
    setState(() {
      if (_stopwatch.isRunning) {
        _stopwatch.stop();
        // 🎯 FIX: PLUS DE SAUVEGARDE SUR PAUSE
      } else {
        _stopwatch.start();
      }
    });
  }

  void _handleResetLap() {
    final dataStore = BaseWidget.of(context).dataStore;
    setState(() {
      if (_stopwatch.isRunning) {
        _laps.insert(0, _formatTime(_stopwatch.elapsedMilliseconds));
      } else {
        // 🎯 SAUVEGARDE UNIQUEMENT SUR RESET (si du temps a été écoulé)
        if (_stopwatch.elapsedMilliseconds > 1000) {
          _saveSession(dataStore);
        }
        _stopwatch.reset();
        _laps.clear();
      }
    });
  }

  void _saveSession(dynamic dataStore) async {
    final session = WorkSession.create(title: "Chronomètre", isPersonal: true);
    session.elapsedSeconds = (_stopwatch.elapsedMilliseconds / 1000).round();
    session.completedAt = DateTime.now();
    await dataStore.addSession(session: session);
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDarkMode ? Colors.white : Colors.black;

    return Scaffold(
      appBar: AppBar(title: const Text('Stopwatch', style: TextStyle(fontWeight: FontWeight.bold)), backgroundColor: Theme.of(context).scaffoldBackgroundColor, elevation: 0),
      body: Column(
        children: [
          const SizedBox(height: 50),
          Center(child: Text(_formatTime(_stopwatch.elapsedMilliseconds), style: TextStyle(fontSize: 70, fontWeight: FontWeight.w200, color: textColor, fontFeatures: const [FontFeature.tabularFigures()]))),
          const SizedBox(height: 20),
          Expanded(
            child: ListView.builder(
              itemCount: _laps.length,
              itemBuilder: (context, index) => ListTile(
                leading: Text('Lap ${_laps.length - index}', style: const TextStyle(color: Colors.grey)),
                trailing: Text(_laps[index], style: TextStyle(color: textColor, fontWeight: FontWeight.w500)),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 40.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildBtn(icon: _stopwatch.isRunning ? Icons.flag : Icons.refresh, onPressed: _handleResetLap, isDarkMode: isDarkMode),
                _buildBtn(icon: _stopwatch.isRunning ? Icons.pause : Icons.play_arrow, onPressed: _handleStartPause, isDarkMode: isDarkMode, isPrimary: true, size: 80),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBtn({required IconData icon, required VoidCallback onPressed, required bool isDarkMode, bool isPrimary = false, double size = 60}) {
    return Container(
      width: size, height: size,
      decoration: BoxDecoration(color: isPrimary ? MyColors.primaryColor : (isDarkMode ? Colors.white10 : Colors.grey.shade200), shape: BoxShape.circle),
      child: IconButton(icon: Icon(icon, color: isPrimary ? Colors.white : (isDarkMode ? Colors.white : Colors.black87), size: size * 0.4), onPressed: onPressed),
    );
  }
}
