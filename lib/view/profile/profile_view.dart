// lib/view/profile/profile_view.dart

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';

///
import '../../main.dart';
import '../../models/user_profile.dart';
import '../../utils/colors.dart';
import 'profile_create_view.dart'; // 👈 On va créer cette vue

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final base = BaseWidget.of(context);

    // Le ValueListenableBuilder ici est crucial pour éviter la RangeError
    // car il gère l'état de la Box (vide ou non) de manière réactive.
    return ValueListenableBuilder<Box<UserProfile>>(
      valueListenable: base.dataStore.listenToUserProfile(),
      builder: (context, box, child) {
        // La même logique de vérification que dans MySlider, mais on l'utilise ici pour l'affichage
        final UserProfile? profile = box.isNotEmpty ? box.getAt(0) : null;
        final bool profileExists =
            profile != null && profile.name != null && profile.name!.isNotEmpty;

        final String displayName =
            profileExists ? profile.name! : "Aucun Nom défini";

        final String displayProfession = profileExists
            ? profile.profession ?? "Profession non définie"
            : "Cliquez sur Modifier pour ajouter votre profession";

        final String displayImage = profile?.imagePath ?? 'assets/img/main.png';

        return Scaffold(
          appBar: AppBar(
            backgroundColor: MyColors.primaryColor,
            elevation: 0,
            title:
                const Text("Mon Profil", style: TextStyle(color: Colors.white)),
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
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(30.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 70,
                    backgroundImage: AssetImage(displayImage),
                    backgroundColor: MyColors.primaryColor.withOpacity(0.2),
                  ),
                  const SizedBox(height: 30),

                  // Nom Complet
                  ListTile(
                    leading: const Icon(Icons.person,
                        color: Color.fromARGB(255, 57, 75, 136)),
                    title: Text(
                      displayName,
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    subtitle: const Text("Nom Complet"),
                  ),
                  const Divider(),

                  // Profession
                  ListTile(
                    leading: const Icon(Icons.work,
                        color: Color.fromARGB(255, 48, 66, 128)),
                    title: Text(
                      displayProfession,
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    subtitle: const Text("Profession"),
                  ),
                  const Divider(),

                  // Date d'enregistrement (Optionnel, si votre modèle le supporte)
                  // Ajoutez d'autres champs de profil ici...
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
