// lib/view/work_session/work_session_view.dart

// ignore_for_file: must_be_immutable, use_build_context_synchronously

import 'package:animate_do/animate_do.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:lottie/lottie.dart';
import 'package:intl/intl.dart';

///
import '../../main.dart';
import '../../models/work_session.dart'; // Import du modèle WorkSession
import '../../utils/colors.dart';
import '../../utils/constanst.dart';
import '../../utils/strings.dart';
import 'session_creation_view.dart'; // <-- NOUVEL IMPORT POUR LA VUE DE CRÉATION

class WorkSessionView extends StatefulWidget {
  const WorkSessionView({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _WorkSessionViewState createState() => _WorkSessionViewState();
}

class _WorkSessionViewState extends State<WorkSessionView> {

  @override
  Widget build(BuildContext context) {
    final base = BaseWidget.of(context);
    var textTheme = Theme.of(context).textTheme;
    final f = DateFormat('dd/MM/yyyy HH:mm'); // Format pour l'affichage des dates

    // Écoute des changements dans la boîte WorkSession
    return ValueListenableBuilder(
        valueListenable: base.dataStore.listenToSessions(),
        builder: (ctx, Box<WorkSession> box, Widget? child) {
          var sessions = box.values.toList();

          /// Trier les sessions par date décroissante (plus récentes en premier, en utilisant createdAt)
          sessions.sort(((a, b) => b.createdAt.compareTo(a.createdAt)));

          return Scaffold(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor, 

            /// Floating Action Button (Pour Démarrer une nouvelle session)
            floatingActionButton: const FABSession(),

            /// App Bar (Titre de l'écran)
            appBar: AppBar(
              title: Text(
                MyString.sessionsTitle, 
                style: textTheme.displayLarge?.copyWith(
                  fontSize: 28, 
                  color: Theme.of(context).brightness == Brightness.dark 
                      ? Colors.white
                      : MyColors.primaryColor,
                ),
              ),
              elevation: 0,
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            ),
            
            /// Body
            body: sessions.isNotEmpty
                ? _buildSessionList(sessions, base, textTheme, f)
                : _buildEmptyState(textTheme),
          );
        });
  }

  /// Liste des sessions de travail
  Widget _buildSessionList(
    List<WorkSession> sessions,
    BaseWidget base,
    TextTheme textTheme,
    DateFormat formatter,
  ) {
    // Compter le nombre de sessions terminées (isCompleted est un bool? donc on vérifie si non null et true)
    final completedCount = sessions.where((s) => s.isCompleted == true).length;

    return SizedBox(
      width: double.infinity,
      height: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 20, top: 10, bottom: 10),
            child: FadeInDown(
              child: Text(
                'Total des sessions terminées : $completedCount',
                style: textTheme.titleMedium,
              ),
            ),
          ),
          
          Expanded(
            child: ListView.builder(
              physics: const BouncingScrollPhysics(),
              itemCount: sessions.length,
              itemBuilder: (BuildContext context, int index) {
                var session = sessions[index];

                return FadeInLeft(
                  duration: const Duration(milliseconds: 500),
                  child: Dismissible(
                    direction: DismissDirection.horizontal,
                    background: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.delete_outline, color: Colors.grey),
                        const SizedBox(width: 8),
                        Text(MyString.deletedSession, style: const TextStyle(color: Colors.grey))
                      ],
                    ),
                    onDismissed: (direction) {
                      base.dataStore.deleteSession(session: session); // Supprime la session
                    },
                    key: Key(session.id), // Utilisez l'ID de la session
                    child: WorkSessionWidget(session: session, formatter: formatter),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  /// État vide si aucune session
  Widget _buildEmptyState(TextTheme textTheme) {
    return Center( // Centrer le contenu de l'état vide
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FadeIn(
            child: SizedBox(
              width: 200,
              height: 200,
              child: Lottie.asset(
                lottieURL,
                animate: true,
              ),
            ),
          ),
          FadeInUp(
            from: 30,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 10.0),
              child: Text(
                MyString.noSessionsYet, 
                style: textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Floating Action Button (FAB) pour démarrer une nouvelle session
class FABSession extends StatelessWidget {
  const FABSession({super.key});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      heroTag: "start_session",
      backgroundColor: MyColors.primaryColor,
      onPressed: () {
        // CORRECTION : Navigation vers la vue de création de session
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const SessionCreationView(), // <-- Utilise la nouvelle vue
          ),
        );
      },
      label: const Text("Démarrer", style: TextStyle(color: Colors.white)),
      icon: const Icon(Icons.play_arrow, color: Colors.white),
    );
  }
}

/// WorkSessionWidget (Affichage d'une seule session)
class WorkSessionWidget extends StatelessWidget {
  final WorkSession session;
  final DateFormat formatter;

  const WorkSessionWidget({
    Key? key, 
    required this.session,
    required this.formatter,
  }) : super(key: key);

  // Calcule la durée. 
  // Utilise completedAt (endTime) ou la différence entre createdAt et maintenant si en cours.
  String _calculateDuration() {
    final bool isCompleted = session.isCompleted ?? false;
    // Si la session n'est pas complétée, le temps écoulé doit être calculé jusqu'à maintenant.
    final DateTime end = isCompleted ? session.completedAt ?? DateTime.now() : DateTime.now();
    
    // Utilisation de la date de création comme point de départ
    final Duration duration = end.difference(session.createdAt);
    
    // Formatage en H:MM:SS
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    final String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    final String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    
    if (duration.inHours > 0) {
      return "${twoDigits(duration.inHours)}h${twoDigitMinutes}m";
    }
    return "${twoDigitMinutes}m ${twoDigitSeconds}s";
  }

  @override
  Widget build(BuildContext context) {
    // Utilise isCompleted et isRunning de votre modèle
    final bool isCompleted = session.isCompleted ?? false;
    final bool isRunning = session.isRunning ?? false;

    // Détermine la couleur et le statut
    Color statusColor;
    String statusText;

    if (isRunning) {
      statusColor = Colors.blueAccent;
      statusText = "En Cours";
    } else if (isCompleted) {
      statusColor = MyColors.primaryColor; // Vert/Bleu de la couleur primaire
      statusText = "Terminée";
    } else {
      statusColor = Colors.grey;
      statusText = "En Attente";
    }
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: statusColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: statusColor.withOpacity(0.5),
            width: 1.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Titre de la session
            Text(
              session.title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: statusColor,
              ),
            ),
            const SizedBox(height: 8),
            
            // Description courte (ou un extrait)
            Text(
              session.description.isNotEmpty 
                ? session.description 
                : "Aucune description fournie.",
              style: Theme.of(context).textTheme.titleSmall,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const Divider(height: 20),

            // Détails : Statut, Durée et Début
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Statut
                _buildDetailChip(context, Icons.check_circle_outline, "Statut : $statusText", statusColor),
                
                // Durée
                _buildDetailChip(context, Icons.timer, "Durée : ${_calculateDuration()}", Colors.brown),
              ],
            ),
            const SizedBox(height: 8),
            
            // Date de Début
            _buildDetailChip(
              context, 
              Icons.calendar_today, 
              "Début : ${formatter.format(session.createdAt)}", 
              Colors.indigo,
              isSmall: true
            ),

            // Date de Fin (si complétée)
            if (isCompleted && session.completedAt != null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: _buildDetailChip(
                  context, 
                  Icons.event_available, 
                  "Fin : ${formatter.format(session.completedAt!)}", 
                  Colors.green,
                  isSmall: true
                ),
              ),
          ],
        ),
      ),
    );
  }
  
  // Widget utilitaire pour l'affichage des détails
  Widget _buildDetailChip(BuildContext context, IconData icon, String text, Color color, {bool isSmall = false}) {
    // CORRECTION APPLIQUÉE : L'argument 'final' a été retiré de 'Color color'.
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: isSmall ? 14 : 16, color: color),
        const SizedBox(width: 4),
        Text(
          text,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: color,
            fontSize: isSmall ? 10 : 12
          ),
        ),
      ],
    );
  }
}