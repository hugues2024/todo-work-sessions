// lib/view/home/home_view.dart (Code Corrigé pour la couleur des icônes)

// ignore_for_file: must_be_immutable, use_build_context_synchronously

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../utils/strings.dart';
import '../../utils/colors.dart';

/// Import des sous-vues
import 'widgets/task_list_view.dart'; 
// ClockView et CalendarAgendaView sont retirés car nous naviguons vers leur route complète.


class HomeView extends StatefulWidget {
  const HomeView({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _HomeViewState createState() => _HomeViewState();
}


class _HomeViewState extends State<HomeView> {
  // L'index 0 est pour Tâches. Les autres indices dans l'AppBar déclenchent la navigation.
  // 0: Tâches, 1: Horloge, 2: Calendrier
  int _currentIndex = 0; 
  
  // Liste des vues pour le corps du Scaffold (Seule TaskListView est gérée ici)
  final List<Widget> _views = const [
    TaskListView(),
    // Placeholders pour les autres vues (qui sont maintenant gérées par navigation)
    Center(child: Text("Accès Horloge...")),
    Center(child: Text("Accès Calendrier...")),
  ];

  /// Gère le titre statique de l'AppBar pour cet écran
  String get _currentTitle {
    return MyString.mainTitle; 
  }

  // Fonction pour gérer le tap sur les actions de l'AppBar
  void _onAppBarActionTapped(int index) {
    if (index == 0) {
      // 1. Tâches: Reste sur la TaskListView et active l'icône
      setState(() {
        _currentIndex = 0;
      });
    } else {
      // Pour Horloge (1) et Calendrier (2): 
      // 1. Active l'icône brièvement (setState)
      setState(() {
        _currentIndex = index;
      });

      // 2. Détermine la route
      final String route = index == 1 ? '/clock' : '/calendar';
      
      // 3. Navigue vers la route pleine écran
      Navigator.of(context).pushNamed(route).then((_) {
        // Une fois revenu, on assure qu'on revient sur l'onglet Tâches (0) et grise les autres
        setState(() {
          _currentIndex = 0; 
        });
      });
    }
  }

  // Fonction utilitaire pour la couleur des icônes
  Color _getIconColor(int index) {
    return _currentIndex == index 
        ? MyColors.primaryColor 
        : Colors.grey;
  }

  @override
  Widget build(BuildContext context) {
    var textTheme = Theme.of(context).textTheme;

    return Scaffold(
      
      appBar: AppBar(
        // Le titre aligné à gauche
        title: Text(
          _currentTitle, // "Mes Tâches"
          style: textTheme.displayLarge?.copyWith(
            fontSize: 28, 
            fontWeight: FontWeight.bold,
            color: Theme.of(context).brightness == Brightness.dark 
                ? Colors.white
                : MyColors.primaryColor,
          ),
        ),
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        
        // Les actions (icônes) alignées à droite, pour la navigation secondaire
        actions: [
          // 1. Icône Tâches (index 0) - Reste sur la vue TaskListView
          Tooltip( 
            message: MyString.tasksTab,
            child: IconButton(
              icon: Icon(
                CupertinoIcons.list_bullet,
                size: 24,
                // 🎯 CORRIGÉ : Utilisation de la fonction pour la couleur
                color: _getIconColor(0),
              ),
              onPressed: () => _onAppBarActionTapped(0),
            ),
          ),
          
          // 2. Icône Horloge (index 1) - Navigue vers la route /clock
          Tooltip( 
            message: MyString.timeMenu,
            child: IconButton(
              icon: Icon(
                CupertinoIcons.clock,
                size: 24,
                // 🎯 CORRIGÉ : Utilisation de la fonction pour la couleur
                color: _getIconColor(1),
              ),
              onPressed: () => _onAppBarActionTapped(1),
            ),
          ),
          
          // 3. Icône Calendrier (index 2) - Navigue vers la route /calendar
          Tooltip( 
            message: MyString.calendarMenu,
            child: IconButton(
              icon: Icon(
                CupertinoIcons.calendar,
                size: 24,
                // 🎯 CORRIGÉ : Utilisation de la fonction pour la couleur
                color: _getIconColor(2),
              ),
              onPressed: () => _onAppBarActionTapped(2),
            ),
          ),
          
          const SizedBox(width: 8), 
        ],
      ),
      
      // Le corps n'affiche que le contenu de l'index 0 (TaskListView) par défaut
      body: IndexedStack(
        index: _currentIndex,
        children: _views,
      ),
    );
  }
}