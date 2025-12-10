// lib/view/profile/profile_view.dart

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:animate_do/animate_do.dart';

///
import '../../main.dart';
import '../../models/user_profile.dart';
import '../../utils/colors.dart';
import 'profile_create_view.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final base = BaseWidget.of(context);
    
    // Vérifier si l'utilisateur est connecté
    if (!base.dataStore.isUserLoggedIn()) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: MyColors.primaryColor,
          elevation: 0,
          title: const Text("Mon Profil", style: TextStyle(color: Colors.white)),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(30.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.lock_outline, size: 80, color: Colors.grey.shade400),
                const SizedBox(height: 20),
                Text(
                  "Connexion requise",
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  "Vous devez être connecté pour accéder à votre profil",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey.shade600),
                ),
                const SizedBox(height: 30),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).pushNamed('/login');
                  },
                  icon: const Icon(Icons.login, color: Colors.white),
                  label: const Text("Se connecter", style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: MyColors.primaryColor,
                    minimumSize: const Size(200, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
    
    // Le ValueListenableBuilder ici est crucial pour éviter la RangeError 
    // car il gère l'état de la Box (vide ou non) de manière réactive.
    return ValueListenableBuilder<Box<UserProfile>>(
      valueListenable: base.dataStore.listenToUserProfile(),
      builder: (context, box, child) {
        
        // La même logique de vérification que dans MySlider, mais on l'utilise ici pour l'affichage
        final UserProfile? profile = box.isNotEmpty ? box.getAt(0) : null;
        final bool profileExists = profile != null && profile.name != null && profile.name!.isNotEmpty;
        
        final String displayName = profileExists 
            ? profile.name! 
            : "Nom non défini";
        
        final String displayProfession = profileExists 
            ? profile.profession ?? "Profession non définie"
            : "Cliquez sur Modifier pour ajouter votre profession";
        
        final String displayImage = profile?.imagePath ?? 'assets/img/main.png';
        
        return Scaffold(
          appBar: AppBar(
            backgroundColor: MyColors.primaryColor,
            elevation: 0,
            title: const Text("Mon Profil", style: TextStyle(color: Colors.white)),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
              onPressed: () => Navigator.of(context).pop(),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.white),
                onPressed: () {
                  // Naviguer vers la vue de création/modification
                  Navigator.of(context).push(
                    CupertinoPageRoute(
                      builder: (context) => ProfileCreateView(
                        existingProfile: profile,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                const SizedBox(height: 20),
                
                // Avatar avec animation
                FadeIn(
                  duration: const Duration(milliseconds: 600),
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: MyColors.primaryColor, width: 3),
                      boxShadow: [
                        BoxShadow(
                          color: MyColors.primaryColor.withOpacity(0.3),
                          blurRadius: 15,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: CircleAvatar(
                      radius: 70,
                      backgroundImage: AssetImage(displayImage),
                      backgroundColor: MyColors.primaryColor.withOpacity(0.1),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                
                // Card de profil
                FadeInUp(
                  duration: const Duration(milliseconds: 600),
                  delay: const Duration(milliseconds: 100),
                  child: Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        children: [
                          // Nom Complet
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: MyColors.primaryColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(Icons.person, color: MyColors.primaryColor),
                            ),
                            title: Text(
                              displayName,
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            subtitle: const Text("Nom Complet"),
                          ),
                          const Divider(height: 30),
                          
                          // Profession
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: MyColors.primaryColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(Icons.work, color: MyColors.primaryColor),
                            ),
                            title: Text(
                              displayProfession,
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            subtitle: const Text("Profession"),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}