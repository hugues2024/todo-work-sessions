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

  @override
  Widget build(BuildContext context) {
    final base = BaseWidget.of(context);
    
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
                  // NOTE: L'implémentation réelle des notifications dépend d'un package (ex: flutter_local_notifications)
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
                      
                      // ⚠️ Pour que le thème s'applique, vous devrez mettre à jour 
                      // le Material App dans lib/main.dart pour écouter la valeur
                      // 'profile.themeMode' et utiliser ThemeMode.light ou ThemeMode.dark.
                    }
                  },
                ),
              ),
              const Divider(),

              // 3. (Optionnel) Vider les données
              ListTile(
                leading: const Icon(Icons.delete_sweep, color: Colors.red),
                title: const Text("Effacer toutes les tâches et sessions"),
                subtitle: const Text("Attention : cette action est irréversible."),
                onTap: () {
                  // Vous devez ajouter la logique de confirmation ici, puis :
                  // base.dataStore.box.clear();
                  // base.dataStore.sessionBox.clear();
                  // Navigator.of(context).pop();
                },
              ),
              const Divider(),

              // 4. Déconnexion
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
              )
            ],
          ),
        );
      },
    );
  }
}