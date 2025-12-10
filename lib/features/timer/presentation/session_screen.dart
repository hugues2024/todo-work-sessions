import 'package:flutter/material.dart';

class SessionScreen extends StatelessWidget {
  const SessionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Session de Focus (Pomodoro)')),
      body: const Center(
        child: Text('Minuteur Pomodoro', style: TextStyle(fontSize: 18)),
      ),
    );
  }
}