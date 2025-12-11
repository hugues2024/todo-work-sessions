// lib/models/user_profile.dart

import 'package:hive/hive.dart';

part 'user_profile.g.dart';

@HiveType(typeId: 2) 
class UserProfile extends HiveObject {

  // 🚀 AJOUT: Clé statique pour le profil par défaut
  static const String defaultProfileId = 'default_profile';

  @HiveField(0)
  String? name;

  @HiveField(1)
  String? profession;

  @HiveField(2)
  String? imagePath; // Chemin local de la photo de profil

  @HiveField(3) 
  int themeMode; // 0: Système, 1: Clair, 2: Sombre

  @HiveField(4) 
  bool notificationsEnabled;

  UserProfile({
    this.name, 
    this.profession, 
    this.imagePath,
    this.themeMode = 0, 
    this.notificationsEnabled = true,
  });

  UserProfile copyWith({
    String? name,
    String? profession,
    String? imagePath,
    int? themeMode,
    bool? notificationsEnabled,
  }) {
    return UserProfile(
      name: name ?? this.name,
      profession: profession ?? this.profession,
      imagePath: imagePath ?? this.imagePath,
      themeMode: themeMode ?? this.themeMode,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
    );
  }

  static UserProfile defaultProfile() {
    return UserProfile(
      name: null,
      profession: null,
      imagePath: null, 
      themeMode: 0, 
      notificationsEnabled: true, 
    );
  }
}