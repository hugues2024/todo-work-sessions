// lib/view/settings/settings_view.dart

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../main.dart';
import '../../models/user_profile.dart';
import '../../utils/colors.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  void _clearAllData(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Confirmation"),
        content: const Text("Êtes-vous sûr de vouloir effacer toutes les données ?"),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text("Annuler")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              final base = BaseWidget.of(context);
              await base.dataStore.box.clear();
              await base.dataStore.sessionBox.clear();
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
    
    return ValueListenableBuilder<Box<UserProfile>>(
      valueListenable: base.dataStore.listenToUserProfile(),
      builder: (context, box, child) {
        
        final UserProfile profile = base.dataStore.getLoggedInUserProfile() ??
                                   box.get(UserProfile.defaultProfileId)!; // Garanti d'exister

        final isUserConnected = base.dataStore.getLoggedInUserProfile() != null;

        return Scaffold(
          appBar: AppBar(
            backgroundColor: MyColors.primaryColor,
            elevation: 0,
            title: const Text("Paramètres", style: TextStyle(color: Colors.white)),
          ),
          body: ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              SwitchListTile(
                title: const Text("Activer les notifications"),
                subtitle: const Text("Recevez des rappels pour vos sessions."),
                value: profile.notificationsEnabled,
                activeColor: MyColors.primaryColor,
                onChanged: (bool newValue) {
                  profile.notificationsEnabled = newValue;
                  profile.save(); // Sauvegarde directe sur l'objet Hive.
                },
              ),
              const Divider(),
              ListTile(
                title: const Text("Mode d'affichage"),
                subtitle: Text(profile.themeMode == 0 ? "Clair" : "Sombre"),
                trailing: DropdownButton<int>(
                  value: profile.themeMode,
                  items: const [
                    DropdownMenuItem(value: 0, child: Text("Clair")),
                    DropdownMenuItem(value: 1, child: Text("Sombre")),
                  ],
                  onChanged: (int? newMode) {
                    if (newMode != null) {
                      profile.themeMode = newMode;
                      profile.save(); // Sauvegarde directe sur l'objet Hive.
                    }
                  },
                ),
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.delete_sweep, color: Colors.red),
                title: const Text("Effacer toutes les données"),
                onTap: () => _clearAllData(context),
              ),
              const Divider(),
              if (isUserConnected)
                ListTile(
                  leading: const Icon(Icons.logout, color: Colors.red),
                  title: const Text("Se déconnecter"),
                  onTap: () async {
                    await base.dataStore.logout();
                    Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
                  },
                ),
            ],
          ),
        );
      },
    );
  }
}
