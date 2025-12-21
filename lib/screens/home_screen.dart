import 'package:TodoWork/services/notification_service.dart'; // Import corrigé
import 'package:TodoWork/widgets/notification_button.dart'; // Chemin adapté
import 'package:TodoWork/widgets/top_bar.dart'; // Chemin adapté
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Theme.of(context).primaryColor,
              Colors.grey[200]!,
            ],
          ), // Fermeture correcte du LinearGradient
        ), // Fermeture correcte du BoxDecoration
        child: SingleChildScrollView(
          // Ajout d'un scroll car il y a beaucoup de boutons
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const TopBar(title: 'Awesome Notification'),
              const SizedBox(height: 20),
              NotificationButton(
                text: "Normal Notification",
                onPressed: () async {
                  await NotificationService.showNotification(
                    title: "TodoWork Alert",
                    body: "C'est l'heure de se mettre au travail !",
                  );
                },
              ),
              NotificationButton(
                text: "Notification With Summary",
                onPressed: () async {
                  await NotificationService.showNotification(
                    title: "Session terminée",
                    body: "Vous avez complété 25 minutes de focus.",
                    summary: "Productivité",
                    notificationLayout: NotificationLayout.Inbox,
                  );
                },
              ),
              NotificationButton(
                text: "Progress Bar Notification",
                onPressed: () async {
                  await NotificationService.showNotification(
                    title: "Session en cours",
                    body: "Travail sur : Architecture Flutter",
                    summary: "Chronomètre",
                    notificationLayout: NotificationLayout.ProgressBar,
                  );
                },
              ),
              NotificationButton(
                text: "Message Notification",
                onPressed: () async {
                  await NotificationService.showNotification(
                    title: "Message de l'équipe",
                    body: "N'oublie pas de valider tes tâches du jour.",
                    summary: "Nouveau message",
                    notificationLayout: NotificationLayout.Messaging,
                  );
                },
              ),
              NotificationButton(
                text: "Big Image Notification",
                onPressed: () async {
                  await NotificationService.showNotification(
                    title: "Bravo !",
                    body: "Tâche complétée avec succès.",
                    summary: "Succès",
                    notificationLayout: NotificationLayout.BigPicture,
                    bigPicture:
                        "https://files.tecnoblog.net/wp-content/uploads/2019/09/emoji.jpg",
                  );
                },
              ),
              NotificationButton(
                text: "Action Buttons Notification",
                onPressed: () async {
                  await NotificationService.showNotification(
                      title: "Vérification",
                      body: "Voulez-vous démarrer la session maintenant ?",
                      payload: {
                        "navigate": "true",
                      },
                      actionButtons: [
                        NotificationActionButton(
                          key: 'check',
                          label: 'Démarrer',
                          actionType: ActionType.Default,
                          color: Colors.green,
                        ),
                        NotificationActionButton(
                          key: 'close',
                          label: 'Plus tard',
                          actionType: ActionType.DismissAction,
                          color: Colors.red,
                        )
                      ]);
                },
              ),
              NotificationButton(
                text: "Scheduled Notification",
                onPressed: () async {
                  await NotificationService.showNotification(
                    title: "Rappel programmé",
                    body: "Cette notification apparaît après 5 secondes",
                    scheduled: true,
                    interval: 5,
                  );
                },
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
