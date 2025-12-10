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
  String? imagePath; 

  @HiveField(3) // 👈 NOUVEAU : Préférence de thème (0: Clair, 1: Sombre)
  int themeMode;

  @HiveField(4) // 👈 NOUVEAU : État des notifications (true/false)
  bool notificationsEnabled;

  UserProfile({
    this.name, 
    this.profession, 
    this.imagePath,
    // Initialisation par défaut
    this.themeMode = 0, 
    this.notificationsEnabled = true,
  });

  // Méthode pour obtenir un profil par défaut/initial
  static UserProfile defaultProfile() {
    return UserProfile(
      name: null,
      profession: null,
      imagePath: 'assets/img/main.png',
      themeMode: 0, // Clair par défaut
      notificationsEnabled: true, // Activées par défaut
    );
  }
}