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
    final base = BaseWidget.of(context);
    
    // Vérifier si l'utilisateur est connecté
    if (!base.dataStore.isUserLoggedIn()) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("Profil", style: TextStyle(color: Colors.white)),
          backgroundColor: MyColors.primaryColor,
          leading: IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
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
                  "Vous devez être connecté pour créer ou modifier votre profil",
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
    
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.existingProfile == null ? MyString.addNewProfile : MyString.updateProfile, 
          style: const TextStyle(color: Colors.white)
        ),
        backgroundColor: MyColors.primaryColor,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            
            // Avatar cliquable (placeholder)
            GestureDetector(
              onTap: () {
                // Future: ajouter sélecteur d'image
              },
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: MyColors.primaryColor.withOpacity(0.1),
                    child: const Icon(
                      Icons.person,
                      size: 60,
                      color: MyColors.primaryColor,
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: MyColors.primaryColor,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: const Icon(Icons.camera_alt, size: 18, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            
            // Card pour les champs
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    // Champ Nom Complet
                    TextField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: "Nom Complet",
                        helperText: "Entrez votre nom complet",
                        prefixIcon: const Icon(Icons.person, color: MyColors.primaryColor),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: MyColors.primaryColor, width: 2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Champ Profession
                    TextField(
                      controller: _professionController,
                      decoration: InputDecoration(
                        labelText: "Profession",
                        helperText: "Ex: Développeur, Designer, etc.",
                        prefixIcon: const Icon(Icons.work, color: MyColors.primaryColor),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: MyColors.primaryColor, width: 2),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 40),

            // Bouton large de validation
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _saveProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: MyColors.primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  widget.existingProfile == null ? "Créer Profil" : "Valider",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            
            // Bouton Annuler
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Annuler"),
            ),
          ],
        ),
      ),
    );
  }
}