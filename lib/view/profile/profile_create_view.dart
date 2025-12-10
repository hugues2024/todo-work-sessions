// lib/view/profile/profile_create_view.dart

// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';

///
import '../../main.dart';
import '../../models/user_profile.dart';
import '../../utils/colors.dart';
import '../../utils/constanst.dart'; // Pour emptyFieldsWarning
import '../../utils/strings.dart';

class ProfileCreateView extends StatefulWidget {
  const ProfileCreateView({
    Key? key,
    this.existingProfile,
  }) : super(key: key);

  final UserProfile? existingProfile;

  @override
  State<ProfileCreateView> createState() => _ProfileCreateViewState();
}

class _ProfileCreateViewState extends State<ProfileCreateView> {
  late TextEditingController _nameController;
  late TextEditingController _professionController;
  
  // Note : La gestion de l'image est simplifiée ici (pas de sélecteur de fichier)

  @override
  void initState() {
    super.initState();
    // Initialisation des contrôleurs avec les données existantes ou des chaînes vides
    _nameController = TextEditingController(
      text: widget.existingProfile?.name ?? '',
    );
    _professionController = TextEditingController(
      text: widget.existingProfile?.profession ?? '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _professionController.dispose();
    super.dispose();
  }
  
  // Fonction de sauvegarde du profil
  void _saveProfile() {
    final dataStore = BaseWidget.of(context).dataStore;
    final String name = _nameController.text.trim();
    final String profession = _professionController.text.trim();

    if (name.isEmpty) {
      emptyFieldsWarning(context); // Afficher une alerte
      return;
    }

    final UserProfile profileToSave = UserProfile(
      name: name,
      profession: profession,
      // Conserver l'ancien chemin d'image si on est en mode édition
      imagePath: widget.existingProfile?.imagePath ?? 'assets/img/main.png', 
    );
    
    // La méthode HiveDataStore gère la logique de add vs putAt(0)
    dataStore.saveUserProfile(profileToSave); 
    
    Navigator.of(context).pop();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.existingProfile == null ? MyString.addNewProfile : MyString.updateProfile, 
          style: const TextStyle(color: Colors.white)
        ),
        backgroundColor: MyColors.primaryColor,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(), // Annuler
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // Champ Nom Complet
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: "Nom Complet",
                prefixIcon: Icon(Icons.person),
              ),
            ),
            const SizedBox(height: 20),

            // Champ Profession
            TextField(
              controller: _professionController,
              decoration: const InputDecoration(
                labelText: "Profession",
                prefixIcon: Icon(Icons.work),
              ),
            ),
            const SizedBox(height: 40),

            // Boutons Valider et Annuler
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text("Annuler"),
                ),
                ElevatedButton(
                  onPressed: _saveProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: MyColors.primaryColor,
                    padding: const EdgeInsets.symmetric(horizontal: 30)
                  ),
                  child: Text(
                    widget.existingProfile == null ? "Créer Profil" : "Valider",
                    style: const TextStyle(color: Colors.white)
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}