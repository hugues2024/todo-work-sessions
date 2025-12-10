
// lib/view/settings/settings_view.dart

// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';

///
import '../../main.dart';
import '../../models/user_profile.dart';
import '../../utils/colors.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  // Fonction pour changer les préférences du profil (via la boîte Hive)
  void _updateProfileSettings(BuildContext context, Function(UserProfile) updateAction) {
    final dataStore = BaseWidget.of(context).dataStore;
    UserProfile? profile = dataStore.getUserProfile();
    
    // Si le profil n'existe pas, on le crée avec les valeurs par défaut
    if (profile == null) {
      profile = UserProfile.defaultProfile();
    }
    
    // Exécute l'action de mise à jour spécifique (ex: changer le thème)
    updateAction(profile);
    
    // Sauvegarde le profil
    dataStore.saveUserProfile(profile); 
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
            onPressed: () {
              final base = BaseWidget.of(context);
              base.dataStore.box.clear();
              base.dataStore.sessionBox.clear();
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
    final bool isLoggedIn = base.dataStore.isUserLoggedIn();
    
    return ValueListenableBuilder<Box<UserProfile>>(
      valueListenable: base.dataStore.listenToUserProfile(),
      builder: (context, box, child) {
        // Récupère le profil (ou le profil par défaut pour éviter l'erreur si la box est vide)
        final UserProfile profile = box.isNotEmpty 
            ? box.getAt(0)! 
            : UserProfile.defaultProfile();

        return Scaffold(
          appBar: AppBar(
            backgroundColor: MyColors.primaryColor,
            elevation: 0,
            title: const Text("Paramètres", style: TextStyle(color: Colors.white)),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          body: ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              
              // 1. GESTION DES NOTIFICATIONS
              SwitchListTile(
                title: const Text("Activer les notifications"),
                subtitle: const Text("Recevez des rappels pour vos sessions de travail."),
                value: profile.notificationsEnabled,
                activeColor: MyColors.primaryColor,
                onChanged: (bool newValue) {
                  _updateProfileSettings(context, (p) {
                    p.notificationsEnabled = newValue;
                  });
                },
              ),
              const Divider(),
              
              // 2. GESTION DU THÈME
              ListTile(
                title: const Text("Mode d'affichage (Thème)"),
                subtitle: Text(profile.themeMode == 0 ? "Clair" : "Sombre"),
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
                  onChanged: (int? newMode) {
                    if (newMode != null) {
                      _updateProfileSettings(context, (p) {
                        p.themeMode = newMode;
                      });
                      
                      // Redémarrer l'application pour appliquer le thème
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Thème modifié (redémarrez l'app pour l'appliquer)")),
                      );
                    }
                  },
                ),
              ),
              const Divider(),

              // 3. Vider les données
              ListTile(
                leading: const Icon(Icons.delete_sweep, color: Colors.red),
                title: const Text("Effacer toutes les tâches et sessions"),
                subtitle: const Text("Attention : cette action est irréversible."),
                onTap: () => _clearAllData(context),
              ),
              const Divider(),

              // 4. Déconnexion (uniquement si connecté)
              if (isLoggedIn)
                ListTile(
                  leading: const Icon(Icons.logout, color: Colors.red),
                  title: const Text("Se déconnecter"),
                  subtitle: const Text("Vous devrez vous reconnecter."),
                  onTap: () async {
                    await base.dataStore.logout();
                    // Retour à l'écran de connexion
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
