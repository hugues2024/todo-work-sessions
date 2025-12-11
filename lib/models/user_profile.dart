// lib/models/user_profile.dart

import 'package:hive/hive.dart';

part 'user_profile.g.dart';

@HiveType(typeId: 2) 
class UserProfile extends HiveObject {
  @HiveField(0)
  String? name;

  @HiveField(1)
  String? profession;

  @HiveField(2)
  String? imagePath; // Chemin local de la photo de profil

  @HiveField(3) 
  int themeMode; // 0: Système, 1: Clair, 2: Sombre (J'ai conservé int pour la flexibilité)

  @HiveField(4) 
  bool notificationsEnabled;

  UserProfile({
    this.name, 
    this.profession, 
    this.imagePath,
    // Initialisation par défaut
    this.themeMode = 0, // Défaut : Système ou Clair
    this.notificationsEnabled = true,
  });

  // ==========================================================
  // 🛠️ MÉTHODE COPYWITH (AJOUT POUR LA MISE À JOUR IMMUABLE)
  // ==========================================================
  UserProfile copyWith({
    String? name,
    String? profession,
    String? imagePath,
    int? themeMode,
    bool? notificationsEnabled,
  }) {
    return UserProfile(
      // Si un nouveau paramètre est fourni, on l'utilise, sinon on garde l'ancien (this.champ)
      name: name ?? this.name,
      profession: profession ?? this.profession,
      imagePath: imagePath ?? this.imagePath,
      themeMode: themeMode ?? this.themeMode,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
    );
  }

  // Méthode pour obtenir un profil par défaut/initial (utile lors de l'inscription)
  static UserProfile defaultProfile() {
    return UserProfile(
      name: null,
      profession: null,
      imagePath: null, // L'image par défaut est gérée dans la vue ProfileView
      themeMode: 0, 
      notificationsEnabled: true, 
    );
  }
}