// lib/view/clock/stopwatch_view.dart

import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../utils/colors.dart';

class StopwatchView extends StatefulWidget {
  const StopwatchView({super.key});

  @override
  State<StopwatchView> createState() => _StopwatchViewState();
}

class _StopwatchViewState extends State<StopwatchView> {
  final Stopwatch _stopwatch = Stopwatch();
  late Timer _timer;
  List<String> _laps = [];

  void _update() {
    if (_stopwatch.isRunning) {
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(milliseconds: 30), (timer) => _update());
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  String _formatTime(int milliseconds) {
    int hundreds = (milliseconds / 10).truncate() % 100;
    int seconds = (milliseconds / 1000).truncate() % 60;
    int minutes = (milliseconds / (1000 * 60)).truncate() % 60;
    int hours = (milliseconds / (1000 * 60 * 60)).truncate();

    String hoursStr = hours > 0 ? '${hours.toString().padLeft(2, '0')}:' : '';
    String minutesStr = minutes.toString().padLeft(2, '0');
    String secondsStr = seconds.toString().padLeft(2, '0');
    String hundredsStr = hundreds.toString().padLeft(2, '0');

    return "$hoursStr$minutesStr:$secondsStr.$hundredsStr";
  }

  void _handleStartPause() {
    setState(() {
      if (_stopwatch.isRunning) {
        _stopwatch.stop();
      } else {
        _stopwatch.start();
      }
    });
  }

  void _handleResetLap() {
    setState(() {
      if (_stopwatch.isRunning) {
        _laps.insert(0, _formatTime(_stopwatch.elapsedMilliseconds));
      } else {
        _stopwatch.reset();
        _laps.clear();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDarkMode ? Colors.white : Colors.black;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Stopwatch',
          style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
      ),
      body: Column(
        children: [
          const SizedBox(height: 50),
          Center(
            child: Text(
              _formatTime(_stopwatch.elapsedMilliseconds),
              style: TextStyle(
                fontSize: 70,
                fontWeight: FontWeight.w200,
                color: textColor,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: ListView.builder(
              itemCount: _laps.length,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: Text('Lap ${_laps.length - index}', style: const TextStyle(color: Colors.grey)),
                  trailing: Text(_laps[index], style: TextStyle(color: textColor, fontWeight: FontWeight.w500)),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 40.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildCircularButton(
                  icon: _stopwatch.isRunning ? Icons.flag : Icons.refresh,
                  onPressed: _handleResetLap,
                  isDarkMode: isDarkMode,
                ),
                _buildCircularButton(
                  // 🎯 FIX: Utilisation de Icons.pause et Icons.play_arrow au lieu de noms incorrects
                  icon: _stopwatch.isRunning ? Icons.pause : Icons.play_arrow,
                  onPressed: _handleStartPause,
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

  Widget _buildCircularButton({
    required IconData icon,
    required VoidCallback onPressed,
    required bool isDarkMode,
    bool isPrimary = false,
    double size = 60,
  }) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: isPrimary ? MyColors.primaryColor : (isDarkMode ? Colors.white10 : Colors.grey.shade200),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: Icon(icon, color: isPrimary ? Colors.white : (isDarkMode ? Colors.white : Colors.black87), size: size * 0.4),
        onPressed: onPressed,
      ),
    );
  }
}
