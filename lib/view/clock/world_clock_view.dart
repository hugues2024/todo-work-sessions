// lib/view/clock/world_clock_view.dart

import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class WorldClockView extends StatefulWidget {
  const WorldClockView({super.key});

  @override
  State<WorldClockView> createState() => _WorldClockViewState();
}

class _WorldClockViewState extends State<WorldClockView> {
  late Timer _timer;
  DateTime _currentTime = DateTime.now();

  final List<Map<String, dynamic>> _worldCities = [
    {'name': 'London', 'offset': 0},
    {'name': 'Paris', 'offset': 1},
    {'name': 'Cairo', 'offset': 2},
    {'name': 'Dubai', 'offset': 4},
    {'name': 'Tokyo', 'offset': 9},
    {'name': 'Sydney', 'offset': 11},
    {'name': 'New York', 'offset': -5},
    {'name': 'Los Angeles', 'offset': -8},
  ];

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) setState(() => _currentTime = DateTime.now());
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDarkMode ? Colors.white : Colors.black;

    return Scaffold(
      appBar: AppBar(
        title: const Text('World Clock', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 30),
            // --- HEURE LOCALE ---
            Text(
              DateFormat('hh:mm:ss a').format(_currentTime),
              style: TextStyle(fontSize: 64, fontWeight: FontWeight.w100, color: textColor, fontFeatures: const [FontFeature.tabularFigures()]),
            ),
            Text(
              DateFormat('EEEE, MMM d').format(_currentTime),
              style: const TextStyle(fontSize: 16, color: Colors.grey, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 40),
            const Divider(),
            
            // --- FUSEAUX HORAIRES MONDIAUX ---
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _worldCities.length,
              separatorBuilder: (context, index) => const Divider(indent: 20, endIndent: 20),
              itemBuilder: (context, index) {
                final city = _worldCities[index];
                return _buildCityRow(city['name'], city['offset'], textColor);
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildCityRow(String city, int offset, Color textColor) {
    final nowUtc = DateTime.now().toUtc();
    final cityTime = nowUtc.add(Duration(hours: offset));
    final gmtLabel = offset >= 0 ? "GMT+$offset" : "GMT$offset";

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(city, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              Text(gmtLabel, style: TextStyle(fontSize: 12, color: Colors.grey.shade600, fontWeight: FontWeight.bold)),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                DateFormat('hh:mm a').format(cityTime),
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w300, color: textColor),
              ),
              Text(
                DateFormat('MMM d').format(cityTime),
                style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
