// lib/view/work_session/session_widget.dart

import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../models/work_session.dart';
import '../../utils/colors.dart';
import 'session_create_view.dart';

class SessionWidget extends StatefulWidget {
  const SessionWidget({
    super.key,
    required this.session,
  });

  final WorkSession session;

  @override
  State<SessionWidget> createState() => _SessionWidgetState();
}

class _SessionWidgetState extends State<SessionWidget> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // Sécuriser la lecture de isRunning (nullable)
    if (widget.session.isRunning ?? false) {
      _startTimer();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    // Éviter plusieurs timers
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        widget.session.elapsedSeconds++;

        final isBreak = widget.session.isOnBreak ?? false;

        int maxDuration = isBreak
            ? widget.session.breakDurationMinutes * 60
            : widget.session.workDurationMinutes * 60;

        if (widget.session.elapsedSeconds >= maxDuration) {
          if (isBreak) {
            widget.session.isOnBreak = false;
            widget.session.elapsedSeconds = 0;
          } else {
            widget.session.isOnBreak = true;
            widget.session.elapsedSeconds = 0;
          }
        }

        widget.session.save();
      });
    });
  }

  void _toggleTimer() {
    setState(() {
      // Lire la valeur en toute sécurité
      final currentlyRunning = widget.session.isRunning ?? false;
      final nowRunning = !currentlyRunning;

      widget.session.isRunning = nowRunning;

      if (nowRunning) {
        _startTimer();
      } else {
        _timer?.cancel();
      }

      widget.session.save();
    });
  }

  void _resetTimer() {
    setState(() {
      widget.session.isRunning = false;
      widget.session.elapsedSeconds = 0;
      widget.session.isOnBreak = false;
      _timer?.cancel();
      widget.session.save();
    });
  }

  String _formatTime(int seconds) {
    int mins = seconds ~/ 60;
    int secs = seconds % 60;
    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final isBreak = widget.session.isOnBreak ?? false;
    final isRunning = widget.session.isRunning ?? false;
    final isCompleted = widget.session.isCompleted ?? false;

    int remainingSeconds = widget.session.getRemainingSeconds();
    double progress = widget.session.getProgress();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: -5,
            blurRadius: 20,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.of(context).push(
              CupertinoPageRoute(
                builder: (context) => SessionCreateView(
                  session: widget.session,
                ),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        widget.session.title,
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                    ),
                    Icon(
                      isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
                      color: isCompleted ? MyColors.primaryColor : Colors.grey.shade400,
                      size: 28,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  widget.session.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: Colors.grey.shade600,
                      ),
                ),
                const SizedBox(height: 12),

                // Progress bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: progress.isFinite ? progress.clamp(0.0, 1.0) : 0.0,
                    minHeight: 8,
                    backgroundColor: Colors.grey.shade200,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      isBreak ? Colors.green : MyColors.primaryColor,
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // Timer row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Remaining time badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: isBreak ? Colors.green.withOpacity(0.1) : MyColors.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            isBreak ? Icons.coffee : Icons.timer,
                            size: 18,
                            color: isBreak ? Colors.green : MyColors.primaryColor,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            _formatTime(remainingSeconds),
                            style: TextStyle(
                              color: isBreak ? Colors.green : MyColors.primaryColor,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Buttons
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(
                            isRunning ? Icons.pause_circle_filled : Icons.play_circle_filled,
                            size: 36,
                            color: MyColors.primaryColor,
                          ),
                          onPressed: _toggleTimer,
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.refresh,
                            size: 32,
                            color: Colors.grey,
                          ),
                          onPressed: _resetTimer,
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
