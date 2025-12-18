// lib/view/clock/stopwatch_view.dart

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../utils/colors.dart';
import '../../services/timer_service.dart';
import '../../main.dart';

class StopwatchView extends StatefulWidget {
  const StopwatchView({super.key});

  @override
  State<StopwatchView> createState() => _StopwatchViewState();
}

class _StopwatchViewState extends State<StopwatchView> {
  List<String> _laps = [];

  String _formatTime(int totalSeconds) {
    int h = totalSeconds ~/ 3600;
    int m = (totalSeconds % 3600) ~/ 60;
    int s = totalSeconds % 60;
    return "${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}";
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TimerService>().startStopwatchSession();
    });
  }

  @override
  Widget build(BuildContext context) {
    final timerService = context.watch<TimerService>();
    final dataStore = BaseWidget.of(context).dataStore;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDarkMode ? Colors.white : Colors.black;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Stopwatch', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
      ),
      body: Column(
        children: [
          const SizedBox(height: 50),
          Center(
            child: Text(
              _formatTime(timerService.elapsedSeconds),
              style: TextStyle(fontSize: 70, fontWeight: FontWeight.w200, color: textColor, fontFeatures: const [FontFeature.tabularFigures()]),
            ),
          ),
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
                _buildBtn(
                  icon: timerService.isRunning ? Icons.flag : Icons.refresh,
                  onPressed: () {
                    if (timerService.isRunning) {
                      setState(() => _laps.insert(0, _formatTime(timerService.elapsedSeconds)));
                    } else {
                      timerService.resetTimer(dataStore: dataStore);
                      setState(() => _laps.clear());
                    }
                  },
                  isDarkMode: isDarkMode,
                ),
                _buildBtn(
                  icon: timerService.isRunning ? Icons.pause : Icons.play_arrow,
                  onPressed: () => timerService.isRunning ? timerService.pauseTimer() : timerService.startTimer(dataStore: dataStore),
                  isDarkMode: isDarkMode,
                  isPrimary: true,
                  size: 80,
                ),
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
