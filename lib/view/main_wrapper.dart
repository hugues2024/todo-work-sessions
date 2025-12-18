// lib/view/main_wrapper.dart

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart'; 
import 'package:provider/provider.dart';

import 'home/home_view.dart';
import 'settings/settings_view.dart';
import 'work_session/session_tab_view.dart'; 
import 'work_session/session_history_view.dart'; // NOUVEAU
import '../services/timer_service.dart';

class MainWrapper extends StatefulWidget {
  final int initialIndex;
  
  const MainWrapper({
    super.key,
    this.initialIndex = 0, 
  });

  @override
  State<MainWrapper> createState() => _MainWrapperState();
}

class _MainWrapperState extends State<MainWrapper> {
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TimerService>().setTabIndex(widget.initialIndex);
    });
  }

  // 🎯 NAVIGATION À 4 ONGLETS CORRIGÉE
  final List<Widget> _views = const [
    HomeView(),          
    SessionHistoryView(), // 1: Activité (Historique des sessions)
    SessionTabView(),     // 2: Horloge (Hub des outils)
    SettingsView(),      
  ];

  @override
  Widget build(BuildContext context) {
    final timerService = context.watch<TimerService>();
    final currentIndex = timerService.currentTabIndex;

    return Scaffold(
      body: IndexedStack(
        index: currentIndex,
        children: _views,
      ),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) {
          timerService.setTabIndex(index);
        },
        type: BottomNavigationBarType.fixed, 
        selectedItemColor: Theme.of(context).primaryColor, 
        unselectedItemColor: Colors.grey, 
        backgroundColor: Theme.of(context).scaffoldBackgroundColor, 
        items: const [
          BottomNavigationBarItem(icon: Icon(CupertinoIcons.house_fill), label: "Accueil"),
          BottomNavigationBarItem(icon: Icon(CupertinoIcons.graph_square_fill), label: "Activité"),
          BottomNavigationBarItem(icon: Icon(CupertinoIcons.clock_fill), label: "Horloge"),
          BottomNavigationBarItem(icon: Icon(CupertinoIcons.settings_solid), label: "Paramètres"),
        ],
      ),
    );
  }
}
