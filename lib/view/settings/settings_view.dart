// lib/view/settings/settings_view.dart

// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:hive/hive.dart';
import 'package:panara_dialogs/panara_dialogs.dart';

///
import '../../main.dart';
import '../../models/user_profile.dart';
import '../../utils/colors.dart';
import '../../utils/constanst.dart'; 
import '../main_wrapper.dart'; 
import '../../view/auth/login_view.dart'; // Import de LoginView


class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  // --- LOGIQUE DE GESTION DU PROFIL ET DES DONNÉES ---

  // Obtient le profil actuel (connecté ou invité par défaut) et le sauvegarde
  void _updateSettings(BuildContext context, Function(UserProfile) updateAction) async {
    final dataStore = BaseWidget.of(context).dataStore;
    final profileBox = Hive.box<UserProfile>(Constants.userProfileBox);

    UserProfile profile;
    
    // 1. Détermination du profil à modifier
    if (dataStore.getLoggedInUserProfile() != null) {
      // Cas 1: Utilisateur connecté (utilise le profil réel)
      profile = dataStore.getLoggedInUserProfile()!;
    } else {
      // Cas 2: Utilisateur non connecté (utilise ou crée le profil invité à l'index 0)
      if (profileBox.isEmpty) {
        // Créer le profil et l'ajouter pour qu'il ait une clé
        profile = UserProfile.defaultProfile();
        await profileBox.add(profile);
        // Récupérer la version persistante (qui est maintenant à l'index 0)
        profile = profileBox.getAt(0)!; 
      } else {
        // Utilise le profil invité existant à l'index 0
        profile = profileBox.getAt(0)!;
      }
    }
    
    // 2. Exécute l'action de mise à jour spécifique (modifie l'instance `profile`)
    updateAction(profile);
    
    // 3. Sauvegarde l'instance.
    await dataStore.saveUserProfile(profile); 
  }

  // Fonction pour effacer toutes les données (Tâches, Sessions et Profil)
  void _clearAllData(BuildContext context) {
    PanaraConfirmDialog.show(
      context, 
      title: "Effacer les données", 
      message: "Êtes-vous sûr de vouloir effacer TOUTES les tâches et sessions ? Cette action est IRREVERSIBLE.", 
      confirmButtonText: "Effacer tout", 
      cancelButtonText: "Annuler", 
      panaraDialogType: PanaraDialogType.error, 
      onTapCancel: () => Navigator.of(context).pop(), 
      onTapConfirm: () async {
        final dataStore = BaseWidget.of(context).dataStore;
        
        // 1. Efface les boîtes de données
        await dataStore.taskBox.clear(); 
        await dataStore.sessionBox.clear();
        
        // 2. Réinitialise/Efface le profil utilisateur
        await dataStore.profileBox.clear();
        
        // 3. Effectue la déconnexion pour rafraîchir l'état de l'application
        await dataStore.logout(); 

        // Ferme le dialogue de confirmation
        Navigator.of(context).pop(); 
        
        // 🎯 CORRECTION: Redirige vers la page de connexion, avec canPop: true (pour la croix)
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginView(canPop: true)),
          (route) => false,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Toutes les données ont été effacées et l'application a été réinitialisée.")),
        );
      }
    );
  }

  // --- WIDGETS DE LA VUE ---

  @override
  Widget build(BuildContext context) {
    final base = BaseWidget.of(context);
    
    // Écoute les changements dans la boîte UserProfile pour rafraîchir l'UI
    return ValueListenableBuilder<Box<UserProfile>>(
      valueListenable: base.dataStore.listenToUserProfile(),
      builder: (context, box, child) {
        
        // Récupère le profil connecté ou utilise le profil invité à l'index 0 s'il existe
        final UserProfile? loggedInProfile = base.dataStore.getLoggedInUserProfile();
        final UserProfile profile = loggedInProfile ?? (box.isNotEmpty ? box.getAt(0)! : UserProfile.defaultProfile()); // Correction RangeError (si vide)
        final bool isUserConnected = loggedInProfile != null;

        return Scaffold(
          appBar: AppBar(
            backgroundColor: MyColors.primaryColor,
            elevation: 0,
            title: const Text("Paramètres", style: TextStyle(color: Colors.white)),
          ),
          body: ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              
              // --- GROUPE 1: PERSONNALISATION (Accessible à tous) ---
              _buildSectionHeader(context, "Personnalisation"),
              
              // 1. GESTION DES NOTIFICATIONS
              SwitchListTile(
                title: const Text("Activer les notifications"),
                subtitle: const Text("Recevez des rappels pour vos sessions de travail."),
                value: profile.notificationsEnabled,
                activeColor: MyColors.primaryColor,
                onChanged: (bool newValue) {
                  _updateSettings(context, (p) {
                    p.notificationsEnabled = newValue;
                  });
                },
              ),
              const Divider(indent: 16, endIndent: 16),
              
              // 2. GESTION DU THÈME
              ListTile(
                leading: const Icon(Icons.palette),
                title: const Text("Mode d'affichage (Thème)"),
                subtitle: Text(profile.themeMode == 0 ? "Clair" : "Sombre"),
                trailing: DropdownButton<int>(
                  
                  // Correction Visuelle pour le mode Sombre
                  dropdownColor: Theme.of(context).cardColor, 
                  style: TextStyle(
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                    fontSize: 16
                  ),
                  icon: Icon(Icons.arrow_drop_down, color: Theme.of(context).textTheme.bodyLarge?.color),
                  
                  value: profile.themeMode,
                  items: const [
                    DropdownMenuItem(value: 0, child: Text("Clair")),
                    DropdownMenuItem(value: 1, child: Text("Sombre")),
                  ],
                  onChanged: (int? newMode) {
                    if (newMode != null) {
                      _updateSettings(context, (p) {
                        p.themeMode = newMode;
                      });
                      
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Thème modifié. (Nécessite un redémarrage de l'app pour les changements complets)")),
                      );
                    }
                  },
                ),
              ),
              const SizedBox(height: 20),


              // --- GROUPE 2: COMPTE ---
              _buildSectionHeader(context, "Compte"),

              // Afficher le statut de connexion
              ListTile(
                leading: Icon(isUserConnected ? Icons.person_rounded : Icons.person_off_rounded, 
                             color: isUserConnected ? Colors.green : Colors.red),
                title: Text(isUserConnected ? "Connecté comme ${profile.name}" : "Non connecté"),
                subtitle: Text(isUserConnected ? "Gérez vos informations de compte." : "Connectez-vous pour la synchronisation."),
                onTap: isUserConnected ? () {
                  // L'utilisateur est connecté. Navigue vers le Profil
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => const MainWrapper(initialIndex: 2), // Index du Profil
                    ),
                  );
                } : () {
                  // Navigation vers MainWrapper, forçant l'index 2 (Profil), qui affichera ensuite le LoginRequiredContent
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => const MainWrapper(initialIndex: 2), // Index du Profil
                    ),
                  );
                },
              ),
              
              // Déconnexion (uniquement si connecté)
              if (isUserConnected)
                ListTile(
                  leading: const Icon(Icons.logout, color: Colors.red),
                  title: const Text("Se déconnecter"),
                  subtitle: const Text("Vous serez déconnecté de l'application."),
                  onTap: () async {
                    await base.dataStore.logout();
                    
                    // 🎯 CORRECTION: Redirige vers la page de connexion, avec canPop: true (pour la croix)
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (context) => const LoginView(canPop: true)),
                      (route) => false,
                    );
                  },
                ),
              const SizedBox(height: 20),


              // --- GROUPE 3: GESTION DES DONNÉES ET HISTORIQUE ---
              _buildSectionHeader(context, "Gestion des Données"),
              
              // 3. Vider les données
              ListTile(
                leading: const Icon(Icons.delete_sweep, color: Colors.red),
                title: const Text("Effacer toutes les données"),
                subtitle: const Text("Tâches, sessions, et profil. IRREVERSIBLE."),
                onTap: () => _clearAllData(context),
              ),
              // TODO: Ajouter ici la fonctionnalité "Exporter les données"
              
            ],
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 10.0, bottom: 8.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
          color: MyColors.primaryColor, 
          fontWeight: FontWeight.bold
        ),
      ),
    );
  }
}