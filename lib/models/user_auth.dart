import 'package:hive/hive.dart';

part 'user_auth.g.dart';

@HiveType(typeId: 4)
class UserAuth extends HiveObject {
  @HiveField(0)
  String email;

  @HiveField(1)
  String password; // En production, utilisez un hash sécurisé

  @HiveField(2)
  bool isLoggedIn;

  @HiveField(3)
  DateTime? lastLogin;

  UserAuth({
    required this.email,
    required this.password,
    this.isLoggedIn = false,
    this.lastLogin,
  });
}
