// lib/view/main_wrapper.dart

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart'; 

import 'home/home_view.dart';
import 'settings/settings_view.dart';
import 'work_session/session_tab_view.dart'; 

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
  late int _currentIndex; 

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex.clamp(0, 3);
  }

  // 🎯 NAVIGATION À 4 ONGLETS : Accueil, Activité, Horloge, Paramètres
  final List<Widget> _views = const [
    HomeView(),          
    Scaffold(body: Center(child: Text("Historique d'Activité"))), // Tab Activité (Historique pur)
    SessionTabView(),    // Tab Horloge (Hub des outils d'horloge)
    SettingsView(),      
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _views,
      ),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed, 
        selectedItemColor: Theme.of(context).primaryColor, 
        unselectedItemColor: Colors.grey, 
        backgroundColor: Theme.of(context).scaffoldBackgroundColor, 
        items: const [
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.house_fill),
            label: "Accueil",
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.graph_square_fill),
            label: "Activité",
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.clock_fill),
            label: "Horloge",
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.settings_solid),
            label: "Paramètres",
          ),
        ],
      ),
    );
  }
}
