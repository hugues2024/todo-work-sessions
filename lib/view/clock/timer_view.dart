// lib/view/clock/timer_view.dart

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../utils/colors.dart';
import '../../services/timer_service.dart';
import '../../main.dart';

class TimerView extends StatelessWidget {
  final bool isFromHub;
  const TimerView({super.key, this.isFromHub = false});

  String _formatDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(d.inMinutes.remainder(60));
    final seconds = twoDigits(d.inSeconds.remainder(60));
    final hours = twoDigits(d.inHours);
    return "$hours:$minutes:$seconds";
  }

  @override
  Widget build(BuildContext context) {
    final timerService = context.watch<TimerService>();
    final dataStore = BaseWidget.of(context).dataStore;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDarkMode ? Colors.white : Colors.black;

    final bool showPicker = timerService.currentTask == null && !timerService.isRunning && timerService.remainingDuration == Duration.zero;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Minuteur', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        leading: isFromHub ? IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: MyColors.primaryColor),
          onPressed: () => timerService.minimizeTimer(),
        ) : null,
        actions: [
          if (timerService.currentTask != null)
            IconButton(
              icon: const Icon(Icons.close_rounded, color: Colors.redAccent),
              onPressed: () => timerService.cancelTaskAndExit(dataStore),
              tooltip: "Quitter la tâche",
            ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (timerService.currentTask != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Text(
                  timerService.currentTask!.title,
                  style: TextStyle(color: MyColors.primaryColor, fontWeight: FontWeight.bold, fontSize: 18),
                ),
              ),

            if (showPicker)
              _buildPicker(textColor)
            else
              _buildCountdown(timerService, textColor),

            const SizedBox(height: 60),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildBtn(icon: CupertinoIcons.refresh, onPressed: () => timerService.resetTimer(dataStore: dataStore), isDarkMode: isDarkMode),
                _buildBtn(
                  icon: timerService.isRunning ? CupertinoIcons.pause_fill : CupertinoIcons.play_fill,
                  // 🎯 FIX: Encapsulation dans un bloc pour éviter l'erreur de type 'void'
                  onPressed: () {
                    if (showPicker) {
                      timerService.setManualTimer(Duration(hours: _h, minutes: _m, seconds: _s));
                    } else {
                      if (timerService.isRunning) {
                        timerService.pauseTimer();
                      } else {
                        timerService.startTimer(dataStore: dataStore);
                      }
                    }
                  },
                  isDarkMode: isDarkMode,
                  isPrimary: true,
                  size: 80,
                ),
                if (showPicker)
                  _buildBtn(
                    icon: CupertinoIcons.check_mark, 
                    onPressed: () => timerService.setManualTimer(Duration(hours: _h, minutes: _m, seconds: _s)), 
                    isDarkMode: isDarkMode
                  )
                else
                  _buildBtn(icon: CupertinoIcons.bell, onPressed: () {}, isDarkMode: isDarkMode),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static int _h = 0, _m = 0, _s = 0;

  Widget _buildPicker(Color textColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildWheel(24, (v) => _h = v, "h", textColor),
        _buildWheel(60, (v) => _m = v, "m", textColor),
        _buildWheel(60, (v) => _s = v, "s", textColor),
      ],
    );
  }

  Widget _buildWheel(int count, ValueChanged<int> onSelected, String unit, Color textColor) {
    return Column(
      children: [
        SizedBox(
          height: 150, width: 70,
          child: ListWheelScrollView.useDelegate(
            itemExtent: 50,
            perspective: 0.005,
            diameterRatio: 1.2,
            physics: const FixedExtentScrollPhysics(),
            onSelectedItemChanged: onSelected,
            childDelegate: ListWheelChildBuilderDelegate(
              childCount: count,
              builder: (context, index) => Center(child: Text(index.toString().padLeft(2, '0'), style: TextStyle(fontSize: 32, color: textColor))),
            ),
          ),
        ),
        Text(unit, style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildCountdown(TimerService timerService, Color textColor) {
    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          width: 250, height: 250,
          child: CircularProgressIndicator(
            value: timerService.progress,
            strokeWidth: 10,
            backgroundColor: Colors.grey.shade200,
            valueColor: AlwaysStoppedAnimation<Color>(MyColors.primaryColor),
          ),
        ),
        Text(
          _formatDuration(timerService.remainingDuration),
          style: TextStyle(fontSize: 48, fontWeight: FontWeight.w200, color: textColor, fontFeatures: const [FontFeature.tabularFigures()]),
        ),
      ],
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
