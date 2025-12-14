// lib/view/auth/login_view.dart - CODE COMPLET CORRIGÉ

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:animate_do/animate_do.dart';

///
import '../../main.dart';
import '../../models/user_auth.dart';
import '../../utils/colors.dart';
import '../main_wrapper.dart'; // Import pour naviguer vers MainWrapper
import 'register_view.dart';

class LoginView extends StatefulWidget {
  // Ajout d'un booléen pour savoir si l'utilisateur peut fermer la vue
  final bool canPop; 
  const LoginView({Key? key, this.canPop = false}) : super(key: key);

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez remplir tous les champs')),
      );
      return;
    }

    final dataStore = BaseWidget.of(context).dataStore;
    // On utilise la fonction de login de HiveDataStore pour gérer la connexion
    final success = await dataStore.loginUser(email, password);

    if (success) {
      // Navigation vers le MainWrapper après une connexion réussie
      Navigator.of(context).pushAndRemoveUntil(
        CupertinoPageRoute(builder: (context) => const MainWrapper()),
        (route) => false,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Email ou mot de passe incorrect')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      
      // 🎯 NOUVEL APPBARR PERSONNALISÉ
      appBar: AppBar(
        // Fond blanc, élévation 0
        backgroundColor: Colors.white,
        elevation: 0, 
        centerTitle: false,
        
        // 1. Bouton de navigation conditionnel
        leading: widget.canPop 
            ? IconButton(
                // Si canPop est vrai (ex: après déconnexion), affiche la croix
                icon: const Icon(Icons.clear, color: MyColors.primaryColor), 
                onPressed: () {
                  // Retourne à la vue précédente (Profil/Paramètres)
                  Navigator.of(context).pop(); 
                },
              )
            : IconButton(
                // Si canPop est faux (ex: navigation depuis le Profil), affiche la flèche de retour
                icon: const Icon(Icons.arrow_back_ios, color: MyColors.primaryColor),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            
        // 2. Titre "Se connecter" en violet
        title: Text(
          'Se connecter',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: MyColors.primaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      // FIN APPBARR
      
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(30.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo (Remplacement de l'Image.asset par l'icône utilisateur)
                FadeInDown(
                  child: Icon(
                    Icons.person_pin_circle_rounded, // Icône suggérée pour remplacer l'image
                    size: 120,
                    color: MyColors.primaryColor,
                  ),
                ),
                const SizedBox(height: 40),

                // Titre (Le titre 'Bienvenue !' est conservé ici, le titre de l'AppBar est un complément)
                FadeInDown(
                  delay: const Duration(milliseconds: 200),
                  child: Text(
                    'Bienvenue !',
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(color: MyColors.primaryColor),
                  ),
                ),
                const SizedBox(height: 10),
                FadeInDown(
                  delay: const Duration(milliseconds: 300),
                  child: Text(
                    'Connectez-vous pour continuer',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                const SizedBox(height: 40),

                // Champ Email
                FadeInUp(
                  delay: const Duration(milliseconds: 400),
                  child: Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: TextField(
                        controller: _emailController,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          prefixIcon: Icon(Icons.email_outlined, color: MyColors.primaryColor),
                          border: InputBorder.none,
                        ),
                        keyboardType: TextInputType.emailAddress,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Champ Mot de passe
                FadeInUp(
                  delay: const Duration(milliseconds: 500),
                  child: Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: TextField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          labelText: 'Mot de passe',
                          prefixIcon: const Icon(Icons.lock_outline, color: MyColors.primaryColor),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: MyColors.primaryColor,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 40),

                // Bouton Connexion
                FadeInUp(
                  delay: const Duration(milliseconds: 600),
                  child: SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: _login,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: MyColors.primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        'Se connecter',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Lien Inscription
                FadeInUp(
                  delay: const Duration(milliseconds: 700),
                  child: TextButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        // Transmet le canPop pour que l'écran d'inscription puisse aussi être fermé
                        CupertinoPageRoute(
                          builder: (context) => RegisterView(canPop: widget.canPop),
                        ),
                      );
                    },
                    child: Text(
                      "Pas encore de compte ? S'inscrire",
                      style: TextStyle(color: MyColors.primaryColor),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}