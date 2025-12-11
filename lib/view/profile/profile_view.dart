// lib/view/profile/profile_view.dart

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:animate_do/animate_do.dart';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb; // 👈 Ajouté pour la compatibilité Web

///
import '../../main.dart';
import '../../models/user_profile.dart';
import '../../models/user_auth.dart'; 
import '../../utils/colors.dart';
import '../../utils/constanst.dart'; 
import 'profile_create_view.dart'; 

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});


  /// 🎯 NOUVEAU : Fonction pour gérer l'image sur Mobile et Web
  ImageProvider<Object> _getProfileImageProvider(String? imagePath) {
    if (imagePath == null || imagePath.isEmpty) {
      return AssetImage(defaultProfileImage);
    }

    if (kIsWeb) {
      // Sur le Web, le chemin est une URL temporaire ou une référence.
      return NetworkImage(imagePath);
    } else {
      // Sur Mobile, c'est un chemin de fichier local.
      final file = File(imagePath);
      // Vérification pour éviter les erreurs de fichier manquant
      if (file.existsSync()) {
        return FileImage(file);
      }
      return AssetImage(defaultProfileImage);
    }
  }


  /// Contenu affiché si l'utilisateur EST connecté et a un profil
  Widget _buildProfileContent(BuildContext context, UserAuth auth, UserProfile profile) {
    final base = BaseWidget.of(context);
    final textTheme = Theme.of(context).textTheme;
    final ImageProvider<Object> profileImage = _getProfileImageProvider(profile.imagePath);
    final bool isDefaultIcon = profileImage is AssetImage;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 20),
          FadeInDown(
            child: Center(
              child: CircleAvatar(
                radius: 70,
                backgroundColor: MyColors.primaryColor.withOpacity(0.1),
                backgroundImage: isDefaultIcon ? null : profileImage,
                child: isDefaultIcon 
                    ? const Icon(Icons.person, size: 70, color: MyColors.primaryColor)
                    : null,
              ),
            ),
          ),
          const SizedBox(height: 15),
          
          FadeIn(
            delay: const Duration(milliseconds: 200),
            child: Text(
              profile.name ?? 'Non défini',
              style: textTheme.headlineMedium?.copyWith(
                  fontSize: 28, 
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black87,
              ),
            ),
          ),
          
          FadeIn(
            delay: const Duration(milliseconds: 300),
            child: Text(
              profile.profession ?? 'Utilisateur Pro',
              style: textTheme.titleMedium?.copyWith(color: Colors.grey.shade600),
            ),
          ),
          
          const SizedBox(height: 30),
          
          // Section Détails
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 10),
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: Column(
                children: [
                  _buildProfileTile(
                    icon: Icons.email_outlined,
                    title: "Email",
                    subtitle: auth.email,
                  ),
                  const Divider(),
                  _buildProfileTile(
                    icon: Icons.badge_outlined,
                    title: "Profession",
                    subtitle: profile.profession ?? 'Non spécifiée',
                  ),
                  const Divider(),
                  _buildProfileTile(
                    icon: Icons.color_lens_outlined,
                    title: "Thème",
                    subtitle: profile.themeMode == 0 ? "Clair" : profile.themeMode == 1 ? "Sombre" : "Système",
                  ),
                  const Divider(),
                  _buildProfileTile(
                    icon: Icons.notifications_none,
                    title: "Notifications",
                    subtitle: profile.notificationsEnabled ? "Activées" : "Désactivées",
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 30),
          
          // Bouton Déconnexion
          FadeInUp(
            delay: const Duration(milliseconds: 400),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: () => _showLogoutDialog(context),
                icon: const Icon(Icons.logout, color: Colors.white),
                label: const Text("Déconnexion", style: TextStyle(fontSize: 18, color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade600,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  /// Helper pour les tuiles de profil
  Widget _buildProfileTile({required IconData icon, required String title, required String subtitle}) {
    return ListTile(
      leading: Icon(icon, color: MyColors.primaryColor),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(subtitle, style: const TextStyle(color: Colors.grey)),
    );
  }

  /// Dialogue de confirmation de déconnexion
  void _showLogoutDialog(BuildContext context) {
    final base = BaseWidget.of(context);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Déconnexion"),
          content: const Text("Êtes-vous sûr de vouloir vous déconnecter?"),
          actions: <Widget>[
            TextButton(
              child: const Text("Annuler"),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text("Déconnecter", style: TextStyle(color: Colors.red)),
              onPressed: () async {
                Navigator.of(context).pop(); // Ferme le dialogue
                await base.dataStore.logout(); 
                // 🎯 CORRECTION : Après logout, on navigue vers la racine pour forcer le MainWrapper à reconstruire
                Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
              },
            ),
          ],
        );
      },
    );
  }


  /// Contenu affiché si l'utilisateur N'EST PAS connecté
  Widget _buildLoginRequiredContent(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.lock_outline, size: 80, color: Colors.grey.shade400),
            const SizedBox(height: 20),
            const Text(
              "Compte Requis",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              "Veuillez vous inscrire ou vous connecter pour gérer votre profil et vos préférences.",
              style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: () {
                  // Navigue vers la vue de création de profil en mode INSCRIPTION
                  Navigator.of(context).push(
                    CupertinoPageRoute(
                      builder: (context) => const ProfileCreateView(isLoginMode: false), 
                    ),
                  );
                },
                icon: const Icon(Icons.person_add_alt_1, color: Colors.white),
                label: const Text("Créer un Compte / S'inscrire", style: TextStyle(fontSize: 18, color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: MyColors.primaryColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 5,
                ),
              ),
            ),
            
            const SizedBox(height: 15),
            
            // Bouton de connexion
            TextButton(
              onPressed: () {
                 // Navigue vers la vue de création de profil en mode CONNEXION
                 Navigator.of(context).push(
                    CupertinoPageRoute(
                      builder: (context) => const ProfileCreateView(isLoginMode: true), 
                    ),
                  );
              },
              child: const Text(
                "J'ai déjà un compte",
                style: TextStyle(color: MyColors.primaryColor, decoration: TextDecoration.underline),
              ),
            ),
          ],
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    final base = BaseWidget.of(context);
    
    // Écoute les changements dans la boîte UserAuth
    return ValueListenableBuilder<Box<UserAuth>>(
      valueListenable: base.dataStore.authBox.listenable(),
      builder: (context, authBox, child) {
        
        final bool isLoggedIn = base.dataStore.isUserLoggedIn();
        
        return Scaffold(
          appBar: AppBar(
            backgroundColor: MyColors.primaryColor,
            elevation: 0,
            title: const Text("Mon Profil", style: TextStyle(color: Colors.white)),
            // ❌ SUPPRIMÉ : Bouton de retour retiré
            actions: isLoggedIn && base.dataStore.getLoggedInUserProfile() != null ? [
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.white),
                onPressed: () {
                  // Ouvre la vue d'édition de profil
                  final profile = base.dataStore.getLoggedInUserProfile();
                  if (profile != null) {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => ProfileCreateView(
                          isLoginMode: false,
                          existingProfile: profile, // Passe le profil existant
                        ),
                      ),
                    );
                  }
                },
              ),
            ] : null,
          ),
          body: isLoggedIn 
            ? ValueListenableBuilder<Box<UserProfile>>(
              // Écoute les changements dans la boîte UserProfile (photo, nom, etc.)
              valueListenable: base.dataStore.profileBox.listenable(),
              builder: (context, profileBox, child) {
                // Tente d'obtenir l'utilisateur et le profil
                final UserAuth loggedInUser = base.dataStore.getLoggedInUser();
                final UserProfile? userProfile = base.dataStore.getLoggedInUserProfile();

                // Si l'utilisateur est techniquement connecté mais le profil n'est pas encore créé
                if (userProfile == null) {
                  // Renvoie à l'écran de demande de connexion/inscription pour créer le profil
                  return _buildLoginRequiredContent(context); 
                }

                return _buildProfileContent(context, loggedInUser, userProfile);
              },
            )
            : _buildLoginRequiredContent(context),
        );
      },
    );
  }
}