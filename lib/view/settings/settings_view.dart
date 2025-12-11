// lib/view/settings/settings_view.dart

// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:hive/hive.dart';

///
import '../../main.dart';
import '../../models/user_profile.dart';
import '../../utils/colors.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  // Fonction pour changer les préférences du profil (via la boîte Hive)
  void _updateProfileSettings(BuildContext context, Function(UserProfile) updateAction) async {
    final dataStore = BaseWidget.of(context).dataStore;
    
    // 👈 CORRECTION 1: Utilisation de la nouvelle méthode
    UserProfile? profile = dataStore.getLoggedInUserProfile();
    
    // Ne pas continuer si l'utilisateur n'a pas de profil
    if (profile == null) {
      return; 
    }
    
    // Exécute l'action de mise à jour spécifique (ex: changer le thème)
    updateAction(profile);
    
    // Sauvegarde le profil
    await dataStore.saveUserProfile(profile); 
  }

  // Fonction pour effacer toutes les données
  void _clearAllData(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Confirmation"),
        content: const Text("Êtes-vous sûr de vouloir effacer toutes les tâches et sessions ? Cette action est irréversible."),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text("Annuler"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              final base = BaseWidget.of(context);
              await base.dataStore.box.clear(); // Efface les tâches
              await base.dataStore.sessionBox.clear(); // Efface les sessions
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Toutes les données ont été effacées")),
              );
            },
            child: const Text("Effacer", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final base = BaseWidget.of(context);
    
    // Écoute les changements dans la boîte UserProfile
    return ValueListenableBuilder<Box<UserProfile>>(
      valueListenable: base.dataStore.listenToUserProfile(),
      builder: (context, box, child) {
        
        // Récupère le profil de l'utilisateur connecté pour l'affichage
        final UserProfile? loggedInProfile = base.dataStore.getLoggedInUserProfile();
        final UserProfile profile = loggedInProfile ?? UserProfile.defaultProfile();
        final bool isUserConnected = loggedInProfile != null;

        return Scaffold(
          appBar: AppBar(
            backgroundColor: MyColors.primaryColor,
            elevation: 0,
            title: const Text("Paramètres", style: TextStyle(color: Colors.white)),
            // 👈 CORRECTION 2: Suppression du bouton de retour ('leading')
          ),
          body: ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              
              // 1. GESTION DES NOTIFICATIONS
              SwitchListTile(
                title: const Text("Activer les notifications"),
                subtitle: Text(isUserConnected ? "Recevez des rappels pour vos sessions de travail." : "Connectez-vous pour activer les notifications."),
                value: profile.notificationsEnabled,
                activeColor: MyColors.primaryColor,
                onChanged: isUserConnected ? (bool newValue) {
                  _updateProfileSettings(context, (p) {
                    p.notificationsEnabled = newValue;
                  });
                } : null, // Désactive le switch si non connecté
              ),
              const Divider(),
              
              // 2. GESTION DU THÈME
              ListTile(
                title: const Text("Mode d'affichage (Thème)"),
                subtitle: Text(isUserConnected ? (profile.themeMode == 0 ? "Clair" : "Sombre") : "Connectez-vous pour choisir le thème."),
                trailing: DropdownButton<int>(
                  value: profile.themeMode,
                  items: const [
                    DropdownMenuItem(
                      value: 0,
                      child: Text("Clair"),
                    ),
                    DropdownMenuItem(
                      value: 1,
                      child: Text("Sombre"),
                    ),
                  ],
                  onChanged: isUserConnected ? (int? newMode) {
                    if (newMode != null) {
                      _updateProfileSettings(context, (p) {
                        p.themeMode = newMode;
                      });
                      
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Thème modifié. (Nécessite un redémarrage de l'app pour les changements complets)")),
                      );
                    }
                  } : null, // Désactive le dropdown si non connecté
                ),
              ),
              const Divider(),

              // 3. Vider les données (Fonctionnalité technique, non liée à l'utilisateur)
              ListTile(
                leading: const Icon(Icons.delete_sweep, color: Colors.red),
                title: const Text("Effacer toutes les tâches et sessions"),
                subtitle: const Text("Attention : cette action est irréversible."),
                onTap: () => _clearAllData(context),
              ),
              const Divider(),

              // 4. Déconnexion (uniquement si connecté)
              if (isUserConnected)
                ListTile(
                  leading: const Icon(Icons.logout, color: Colors.red),
                  title: const Text("Se déconnecter"),
                  subtitle: const Text("Vous serez déconnecté de l'application."),
                  onTap: () async {
                    await base.dataStore.logout();
                    // Retour à l'écran racine, MainWrapper gérera la navigation vers la connexion
                    Navigator.of(context).pushNamedAndRemoveUntil(
                      '/',
                      (route) => false,
                    );
                  },
                ),
            ],
          ),
        );
      },
    );
  }
}