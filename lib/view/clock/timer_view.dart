// lib/view/clock/timer_view.dart

import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../utils/colors.dart';

class TimerView extends StatefulWidget {
  const TimerView({super.key});

  @override
  State<TimerView> createState() => _TimerViewState();
}

class _TimerViewState extends State<TimerView> {
  int _selectedHours = 0;
  int _selectedMinutes = 0;
  int _selectedSeconds = 10;
  
  Timer? _timer;
  int _remainingSeconds = 0;
  bool _isRunning = false;

  final List<Map<String, dynamic>> presets = [
    {'title': 'Meeting', 'duration': 1200, 'icon': CupertinoIcons.calendar},
    {'title': 'Sleep', 'duration': 18000, 'icon': CupertinoIcons.moon},
    {'title': 'Exercise', 'duration': 900, 'icon': CupertinoIcons.sportscourt},
  ];

  void _startTimer() {
    if (_isRunning) return;
    
    if (_remainingSeconds == 0) {
      _remainingSeconds = (_selectedHours * 3600) + (_selectedMinutes * 60) + _selectedSeconds;
    }
    
    if (_remainingSeconds <= 0) return;

    setState(() => _isRunning = true);
    
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() => _remainingSeconds--);
      } else {
        _stopTimer();
        _showFinishedDialog();
      }
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    setState(() => _isRunning = false);
  }

  void _resetTimer() {
    _stopTimer();
    setState(() => _remainingSeconds = 0);
  }

  void _showFinishedDialog() {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text("Minuteur terminé"),
        actions: [
          CupertinoDialogAction(
            child: const Text("OK"),
            onPressed: () => Navigator.pop(context),
          )
        ],
      ),
    );
  }

  String _formatHms(int totalSeconds) {
    int h = totalSeconds ~/ 3600;
    int m = (totalSeconds % 3600) ~/ 60;
    int s = totalSeconds % 60;
    return "${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}";
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDarkMode ? Colors.white : Colors.black;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Timer', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 40),
            if (!_isRunning && _remainingSeconds == 0)
              _buildPickers(textColor)
            else
              _buildCountdown(textColor),

            const SizedBox(height: 40),
            
            if (!_isRunning && _remainingSeconds == 0)
              _buildPresets(isDarkMode, textColor),
            
            const SizedBox(height: 60),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildBtn(icon: CupertinoIcons.refresh, onPressed: _resetTimer, isDarkMode: isDarkMode),
                _buildBtn(
                  icon: _isRunning ? CupertinoIcons.pause_fill : CupertinoIcons.play_fill,
                  onPressed: _isRunning ? _stopTimer : _startTimer,
                  isDarkMode: isDarkMode,
                  isPrimary: true,
                  size: 80,
                ),
                _buildBtn(icon: CupertinoIcons.bell, onPressed: () {}, isDarkMode: isDarkMode),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPickers(Color textColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildWheel(60, (v) => _selectedHours = v, "h", textColor),
        _buildWheel(60, (v) => _selectedMinutes = v, "m", textColor),
        _buildWheel(60, (v) => _selectedSeconds = v, "s", textColor),
      ],
    );
  }

  Widget _buildWheel(int count, ValueChanged<int> onSelected, String unit, Color textColor) {
    return Column(
      children: [
        SizedBox(
          height: 120, width: 70,
          child: ListWheelScrollView.useDelegate(
            itemExtent: 40,
            physics: const FixedExtentScrollPhysics(),
            onSelectedItemChanged: onSelected,
            childDelegate: ListWheelChildBuilderDelegate(
              childCount: count,
              builder: (context, index) => Center(child: Text(index.toString().padLeft(2, '0'), style: TextStyle(fontSize: 24, color: textColor))),
            ),
          ),
        ),
        Text(unit, style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildCountdown(Color textColor) {
    return Center(
      child: Text(
        _formatHms(_remainingSeconds),
        style: TextStyle(fontSize: 70, fontWeight: FontWeight.w200, color: textColor, fontFeatures: const [FontFeature.tabularFigures()]),
      ),
    );
  }

  Widget _buildPresets(bool isDarkMode, Color textColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: presets.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, crossAxisSpacing: 10, mainAxisSpacing: 10),
        itemBuilder: (context, index) {
          final p = presets[index];
          return InkWell(
            onTap: () => setState(() => _remainingSeconds = p['duration'] as int),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: isDarkMode ? Colors.white10 : Colors.grey.shade200, borderRadius: BorderRadius.circular(12)),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(p['icon'] as IconData, color: textColor, size: 20),
                  const SizedBox(height: 5),
                  Text(p['title'] as String, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  Text(_formatHms(p['duration'] as int), style: const TextStyle(fontSize: 10, color: Colors.grey)),
                ],
              ),
            ),
          );
        },
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
