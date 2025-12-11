// lib/view/profile/profile_create_view.dart

// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb; // 👈 Import pour détecter le Web

///
import '../../main.dart';
import '../../models/user_profile.dart';
import '../../utils/colors.dart';
import '../../utils/constanst.dart'; // Pour emptyFieldsWarning et defaultProfileImage
import '../../utils/strings.dart';
// NOTE: L'importation de utils.dart a été supprimée pour corriger l'erreur de fichier manquant.

class ProfileCreateView extends StatefulWidget {
  final bool isLoginMode;
  final UserProfile? existingProfile;

  const ProfileCreateView({
    Key? key,
    required this.isLoginMode, 
    this.existingProfile,
  }) : super(key: key);

  @override
  State<ProfileCreateView> createState() => _ProfileCreateViewState();
}

class _ProfileCreateViewState extends State<ProfileCreateView> {
  // Contrôleurs pour l'AUTHENTIFICATION
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  
  // Contrôleurs pour le PROFIL
  late TextEditingController _nameController;
  late TextEditingController _professionController;
  
  String? _imagePath; 
  XFile? _pickedFileForWeb; 
  
  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    
    _nameController = TextEditingController(
      text: widget.existingProfile?.name ?? '',
    );
    _professionController = TextEditingController(
      text: widget.existingProfile?.profession ?? '',
    );
    
    _imagePath = widget.existingProfile?.imagePath;
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _professionController.dispose();
    super.dispose();
  }
  
  /// Gère la sélection d'image de manière compatible Web/Mobile
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _imagePath = pickedFile.path;
        
        if (kIsWeb) {
          _pickedFileForWeb = pickedFile;
        }
      });
    }
  }

  /// Gère la soumission du formulaire
  void _handleFormSubmission() async {
    final dataStore = BaseWidget.of(context).dataStore;
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final name = _nameController.text.trim();
    
    // ======================================================
    // 1. GESTION DE L'AUTHENTIFICATION (SI NON CONNECTÉ)
    // ======================================================
    if (!dataStore.isUserLoggedIn()) {
      bool authSuccess = false;
      String errorMessage = MyString.authError;

      if (widget.isLoginMode) {
        // Mode CONNEXION
        if (email.isEmpty || password.isEmpty) {
          emptyFieldsWarning(context);
          return;
        }
        authSuccess = await dataStore.loginUser(email, password);
        if (!authSuccess) {
          errorMessage = MyString.loginFailed;
        }
      } else {
        // Mode INSCRIPTION
        if (email.isEmpty || password.isEmpty || name.isEmpty) {
          emptyFieldsWarning(context);
          return;
        }
        authSuccess = await dataStore.signupUser(email, password);
        if (!authSuccess) {
          errorMessage = MyString.signupFailed; 
        }
      }

      if (authSuccess) {
        if (!widget.isLoginMode) {
          final UserProfile newProfile = UserProfile(
            name: name,
            profession: _professionController.text.trim(),
            imagePath: _imagePath, 
            themeMode: 0, 
            notificationsEnabled: true,
          );
          await dataStore.saveUserProfile(newProfile);
        }
        
        // CORRECTION CRUCIALE : Naviguer vers la racine pour forcer le MainWrapper à recharger
        Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(content: Text(errorMessage)),
        );
      }
      return;
    }
    
    // ======================================================
    // 2. GESTION DE L'ÉDITION DU PROFIL (SI CONNECTÉ)
    // ======================================================
    if (dataStore.isUserLoggedIn() && widget.existingProfile != null) {
       if (name.isEmpty) {
         emptyFieldsWarning(context);
         return;
       }
       
       final UserProfile profileToSave = widget.existingProfile!.copyWith(
          name: name,
          profession: _professionController.text.trim(),
          imagePath: _imagePath, 
       );
       
       await dataStore.saveUserProfile(profileToSave); 
       Navigator.of(context).pop();
       return;
    }
  }

  // Fonction utilitaire pour l'affichage de l'image (compatible Web/Mobile)
  ImageProvider<Object> _getProfileImage() {
    // Si nous avons sélectionné un fichier sur le Web et qu'il est encore en mémoire
    if (kIsWeb && _pickedFileForWeb != null) {
      return NetworkImage(_pickedFileForWeb!.path);
    }
    
    // Si nous sommes sur mobile et que nous avons un chemin d'accès
    if (!kIsWeb && _imagePath != null) {
      final file = File(_imagePath!);
      // Vérifiez si le fichier existe pour éviter les erreurs FileSystemException (Mobile)
      if (file.existsSync()) {
        return FileImage(file);
      }
    }
    
    // Sinon, utiliser l'image par défaut (asset)
    return AssetImage(defaultProfileImage);
  }


  @override
  Widget build(BuildContext context) {
    final bool isLoggedIn = BaseWidget.of(context).dataStore.isUserLoggedIn();
    final bool isEditing = isLoggedIn && widget.existingProfile != null;
    
    String title = isEditing 
        ? MyString.updateProfile 
        : widget.isLoginMode ? MyString.loginTitle : MyString.signupTitle;

    final bool showDefaultIcon = _imagePath == null;

    return Scaffold(
      appBar: AppBar(
        title: Text(title, style: const TextStyle(color: Colors.white)),
        backgroundColor: MyColors.primaryColor,
        // Bouton de retour : icône Close pour une action modale
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
            
            // --- SECTION IMAGE ---
            if (isEditing || !widget.isLoginMode)
              GestureDetector(
                onTap: _pickImage,
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundColor: MyColors.primaryColor.withOpacity(0.1),
                      backgroundImage: showDefaultIcon ? null : _getProfileImage(),
                      child: showDefaultIcon 
                          ? const Icon(Icons.person, size: 60, color: MyColors.primaryColor)
                          : null,
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
            
            // --- CHAMPS AUTHENTIFICATION ET PROFIL ---
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    // Champ Email (toujours affiché en mode Auth)
                    if (!isEditing)
                      TextField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          labelText: MyString.email,
                          prefixIcon: const Icon(Icons.email, color: MyColors.primaryColor),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: MyColors.primaryColor, width: 2)),
                        ),
                      ),
                    
                    if (!isEditing) const SizedBox(height: 20),

                    // Champ Mot de passe (toujours affiché en mode Auth)
                    if (!isEditing)
                      TextField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: MyString.password,
                          prefixIcon: const Icon(Icons.lock, color: MyColors.primaryColor),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: MyColors.primaryColor, width: 2)),
                        ),
                      ),
                    
                    if (!isEditing && (!widget.isLoginMode || isEditing)) const SizedBox(height: 20),
                    
                    // Champ Nom Complet (Affiché en mode Inscription ou Édition)
                    if (!widget.isLoginMode || isEditing)
                      TextField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: "Nom Complet",
                          helperText: "Entrez votre nom complet (requis pour l'inscription)",
                          prefixIcon: const Icon(Icons.person, color: MyColors.primaryColor),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: MyColors.primaryColor, width: 2)),
                        ),
                      ),
                    
                    if (!widget.isLoginMode || isEditing) const SizedBox(height: 20),

                    // Champ Profession (Affiché en mode Inscription ou Édition)
                    if (!widget.isLoginMode || isEditing)
                      TextField(
                        controller: _professionController,
                        decoration: InputDecoration(
                          labelText: "Profession",
                          helperText: "Ex: Développeur, Designer, etc.",
                          prefixIcon: const Icon(Icons.work, color: MyColors.primaryColor),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: MyColors.primaryColor, width: 2)),
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
                onPressed: _handleFormSubmission,
                style: ElevatedButton.styleFrom(
                  backgroundColor: MyColors.primaryColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(
                  isEditing ? "Valider les modifications" : (widget.isLoginMode ? MyString.loginTitle : "S'inscrire et Créer Profil"),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            
            // Bouton Annuler/Retour
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