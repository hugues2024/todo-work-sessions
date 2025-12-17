// lib/view/settings/settings_view.dart

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:hive/hive.dart';
import 'package:panara_dialogs/panara_dialogs.dart';

import '../../main.dart';
import '../../models/user_profile.dart';
import '../../utils/colors.dart';
import '../../utils/constanst.dart';
import '../profile/profile_view.dart';
import '../details/details_view.dart';
import '../../view/auth/login_view.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  void _updateSettings(BuildContext context, Box<UserProfile> box, Function(UserProfile) updateAction) async {
    final dataStore = BaseWidget.of(context).dataStore;
    UserProfile? profile = dataStore.getLoggedInUserProfile();
    
    if (profile == null) {
      if (box.isNotEmpty) {
        profile = box.getAt(0);
      } else {
        profile = UserProfile.defaultProfile();
        await box.add(profile);
      }
    }
    
    if (profile != null) {
      updateAction(profile);
      if (profile.isInBox) {
        await profile.save();
      } else {
        await dataStore.saveUserProfile(profile);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final base = BaseWidget.of(context);
    
    return ValueListenableBuilder<Box<UserProfile>>(
      valueListenable: base.dataStore.listenToUserProfile(),
      builder: (context, box, child) {
        final UserProfile? loggedInProfile = base.dataStore.getLoggedInUserProfile();
        final UserProfile profile = loggedInProfile ?? (box.isNotEmpty ? box.getAt(0)! : UserProfile.defaultProfile());
        final bool isUserConnected = loggedInProfile != null;

        return Scaffold(
          appBar: AppBar(
            title: const Text("Paramètres", style: TextStyle(fontWeight: FontWeight.bold)),
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            elevation: 0,
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildSectionHeader("UTILISATEUR"),
              _buildMenuTile(
                context,
                title: "Mon Profil",
                subtitle: profile.name ?? "Utilisateur",
                icon: CupertinoIcons.person_circle,
                destination: const ProfileView(),
              ),
              const SizedBox(height: 20),

              _buildSectionHeader("PERSONNALISATION"),
              SwitchListTile(
                title: const Text("Notifications"),
                value: profile.notificationsEnabled,
                activeColor: MyColors.primaryColor, // 🎯 FIX: Couleur appliquée ici
                onChanged: (v) => _updateSettings(context, box, (p) => p.notificationsEnabled = v),
              ),
              ListTile(
                leading: const Icon(CupertinoIcons.moon_stars, color: MyColors.primaryColor),
                title: const Text("Mode Sombre"),
                trailing: CupertinoSwitch(
                  activeColor: MyColors.primaryColor, // 🎯 Identique au toggle notifications
                  value: profile.themeMode == 1,
                  onChanged: (v) => _updateSettings(context, box, (p) => p.themeMode = v ? 1 : 0),
                ),
              ),
              const SizedBox(height: 20),

              _buildSectionHeader("À PROPOS"),
              _buildMenuTile(
                context,
                title: "Détails de l'application",
                subtitle: "Version et informations",
                icon: CupertinoIcons.info_circle,
                destination: const DetailsView(),
              ),
              const SizedBox(height: 40),
              
              _buildSectionHeader("COMPTE"),
              if (isUserConnected)
                ListTile(
                  leading: const Icon(Icons.logout, color: Colors.red),
                  title: const Text("Se déconnecter"),
                  onTap: () async {
                    await base.dataStore.logout();
                    Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => const LoginView(canPop: true)), (route) => false);
                  },
                ),
              ListTile(
                leading: const Icon(CupertinoIcons.trash, color: Colors.red),
                title: const Text("Effacer les données", style: TextStyle(color: Colors.red)),
                onTap: () => _clearAllData(context),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, bottom: 8, top: 16),
      child: Text(title, style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 12)),
    );
  }

  Widget _buildMenuTile(BuildContext context, {required String title, required String subtitle, required IconData icon, required Widget destination}) {
    return ListTile(
      leading: Icon(icon, color: MyColors.primaryColor),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
      trailing: const Icon(Icons.chevron_right, size: 20),
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => destination)),
    );
  }

  void _clearAllData(BuildContext context) {
    PanaraConfirmDialog.show(
      context,
      title: "Effacer tout ?",
      message: "Cette action supprimera vos tâches et votre profil.",
      confirmButtonText: "Confirmer",
      cancelButtonText: "Annuler",
      panaraDialogType: PanaraDialogType.error,
      onTapCancel: () => Navigator.pop(context),
      onTapConfirm: () async {
        final dataStore = BaseWidget.of(context).dataStore;
        await dataStore.taskBox.clear();
        await dataStore.profileBox.clear();
        await dataStore.logout();
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginView(canPop: true)),
          (route) => false,
        );
      }
    );
  }
}
