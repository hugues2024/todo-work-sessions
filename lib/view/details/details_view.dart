// lib/view/details/details_view.dart

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

///
import '../../utils/colors.dart';

class DetailsView extends StatelessWidget {
  const DetailsView({super.key});

  // Fonction pour ouvrir un lien externe
  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw Exception('Impossible de lancer $uri');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: MyColors.primaryColor,
        elevation: 0,
        title: const Text("Détails de l'Application",
            style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios,
              color: Color.fromARGB(255, 228, 207, 207)),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Section 1: À propos de l'application ---
            Text(
              "Todo Work Sessions",
              style: Theme.of(context)
                  .textTheme
                  .displayLarge
                  ?.copyWith(fontSize: 30),
            ),
            const SizedBox(height: 10),
            const Text(
              "Une application de gestion de tâches et de productivité basée sur le principe de la session de travail concentrée (similaire à Pomodoro). Elle utilise Hive pour un stockage local rapide et fiable.",
              style: TextStyle(fontSize: 16),
            ),
            const Divider(height: 40),

            // --- Section 2: Objectifs et Fonctionnalités ---
            _buildSectionTitle(context, "Objectifs Clés & Fonctionnalités"),
            _buildFeatureList([
              "Gestion complète des tâches (CRUD) pour organiser le travail quotidien.",
              "Planification et suivi des sessions de travail (Durée de travail/pause).",
              "Personnalisation du profil utilisateur (Nom, Profession).",
              "Réglages des préférences (Thème Clair/Sombre, Notifications).",
              "Utilisation d'un système de base de données NoSQL local (Hive).",
            ]),
            const Divider(height: 40),

            // --- Section 3: Lien GitHub du Projet ---
            _buildSectionTitle(context, "Code Source de l'Application"),
            ListTile(
              leading: const FaIcon(FontAwesomeIcons.github, size: 30),
              title: const Text("hugues2024/todo-work-sessions"),
              trailing: const Icon(Icons.open_in_new),
              onTap: () => _launchUrl(
                  'https://github.com/hugues2024/todo-work-sessions'),
            ),
            const Divider(height: 40),

            // --- Section 4: Membres de l'équipe (Statique) ---
            _buildSectionTitle(context, "Équipe de Développement"),
            _buildTeamMember(context,
                name: "HOUNKPATIN Hugues",
                role: "Développeur Mobile Principal",
                githubUrl: "https://github.com/hugues2024"),
            _buildTeamMember(context,
                name: "BELLO Mohamed",
                role: "Developpeur Mobile",
                githubUrl: "https://github.com/mohamedbello18"),
            _buildTeamMember(context,
                name: "PATINDE Nolan",
                role: "Developpeur Mobile",
                githubUrl: "https://github.com/Mehdi-ahd"),
            _buildTeamMember(context,
                name: "SOTON Prince",
                role: "Developpeur Mobile",
                githubUrl: "https://github.com/PrinceSoton"),
            const SizedBox(height: 30),
            Center(
              child: Text(
                "Application développée avec Flutter.",
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, top: 5),
      child: Text(
        title,
        style: Theme.of(context)
            .textTheme
            .titleLarge
            ?.copyWith(fontSize: 22, color: MyColors.primaryColor),
      ),
    );
  }

  Widget _buildFeatureList(List<String> features) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: features
          .map((feature) => Padding(
                padding: const EdgeInsets.only(left: 10, bottom: 5),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 5),
                      child: Icon(Icons.check_circle_outline,
                          size: 16, color: Colors.green),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                        child: Text(feature,
                            style: const TextStyle(fontSize: 15))),
                  ],
                ),
              ))
          .toList(),
    );
  }

  Widget _buildTeamMember(BuildContext context,
      {required String name, required String role, required String githubUrl}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: ListTile(
        leading: const CircleAvatar(
          backgroundColor: MyColors.primaryColor,
          child: FaIcon(FontAwesomeIcons.user, color: Colors.white, size: 18),
        ),
        title: Text(name,
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.bold, color: Colors.black)),
        subtitle: Text(role),
        trailing: IconButton(
          icon: const FaIcon(FontAwesomeIcons.github,
              size: 24, color: Colors.black),
          onPressed: () => _launchUrl(githubUrl),
        ),
        onTap: () => _launchUrl(githubUrl),
      ),
    );
  }
}
