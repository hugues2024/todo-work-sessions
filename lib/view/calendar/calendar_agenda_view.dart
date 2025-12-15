// lib/view/calendar/calendar_agenda_view.dart

import 'package:flutter/material.dart';
import '../../utils/strings.dart';
import '../../utils/colors.dart';

class CalendarAgendaView extends StatelessWidget {
  const CalendarAgendaView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 🎯 CORRECTION : Ajout du Scaffold pour que cette vue fonctionne comme une page autonome.
    return Scaffold(
      appBar: AppBar(
        // Le bouton Retour est géré automatiquement par Flutter
        title: Text(
          MyString.calendarMenu, // Utilise la chaîne 'Calendrier' (si définie)
          style: Theme.of(context).textTheme.displayLarge?.copyWith(
            fontSize: 28, 
            fontWeight: FontWeight.bold,
            color: Theme.of(context).brightness == Brightness.dark 
                ? Colors.white
                : MyColors.primaryColor,
          ),
        ),
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      ),
      
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Titre "Calendrier" (retiré car déjà dans l'AppBar)
            
            // Placeholder du calendrier
            Container(
              margin: const EdgeInsets.symmetric(vertical: 10),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      TextButton(onPressed: () {}, child: const Text("Année")),
                      TextButton(onPressed: () {}, child: const Text("Mois")),
                      TextButton(onPressed: () {}, child: const Text("Semaine")),
                    ],
                  ),
                  Container(
                    height: 350,
                    color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade900 : Colors.grey.shade100,
                    child: const Center(child: Text("CALENDRIER COMPLET (table_calendar)")),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 20),
            Text("Agenda & Événements", style: Theme.of(context).textTheme.headlineMedium),
            const Divider(),
            
            // Section Événements
            _buildAgendaMenuItem(context, Icons.event_available, "Gérer les Événements", "Ajouter, modifier ou supprimer des événements planifiés."),
            
            // Section Agenda Quotidien
            _buildAgendaMenuItem(context, Icons.schedule, "Mon Agenda Quotidien", "Définir les heures de réveil/coucher et les rappels."),
            
            const SizedBox(height: 20),
            const Text("Liste des événements/tâches du jour ici..."),
          ],
        ),
      ),
    );
  }
  
  Widget _buildAgendaMenuItem(BuildContext context, IconData icon, String title, String subtitle) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: Icon(icon, color: MyColors.primaryColor),
        title: Text(title, style: Theme.of(context).textTheme.titleMedium),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.add),
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Ouvrir la gestion de: $title")),
          );
        },
      ),
    );
  }
}