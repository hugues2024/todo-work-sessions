// lib/view/auth/register_view.dart - CODE COMPLET CORRIGÉ

import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';

///
import '../../main.dart';
import '../../models/user_auth.dart';
import '../../utils/colors.dart';

class RegisterView extends StatefulWidget {
  // Ajout d'un booléen pour savoir si l'utilisateur peut fermer la vue
  final bool canPop; 
  const RegisterView({Key? key, this.canPop = false}) : super(key: key);

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _register() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if (email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez remplir tous les champs')),
      );
      return;
    }

    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Les mots de passe ne correspondent pas')),
      );
      return;
    }

    if (password.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Le mot de passe doit contenir au moins 6 caractères'),
        ),
      );
      return;
    }

    final dataStore = BaseWidget.of(context).dataStore;
    
    // Utilisation de la fonction signupUser de HiveDataStore
    final success = await dataStore.signupUser(email, password);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Compte créé avec succès !')),
      );
      // Retourne à la page de connexion pour qu'il se connecte (ou pop si déjà connecté)
      Navigator.of(context).pop(); 
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cet email est déjà utilisé')),
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
        
        // 1. Bouton de fermeture conditionnel
        leading: widget.canPop
            ? IconButton(
                // Utilise Icons.clear (ou Icons.close) pour la croix
                icon: const Icon(Icons.clear, color: MyColors.primaryColor), 
                onPressed: () => Navigator.of(context).pop(), // Retourne à la vue précédente
              )
            // Si la navigation est gérée par l'App, laisse le bouton de retour standard (flèche)
            : IconButton(
                icon: const Icon(Icons.arrow_back_ios, color: MyColors.primaryColor),
                onPressed: () => Navigator.of(context).pop(),
              ),
            
        // 2. Titre "S'inscrire" en violet
        title: Text(
          "S'inscrire",
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
                FadeInDown(
                  child: Icon(
                    Icons.person_add_alt_1_rounded, // Icône suggérée pour l'inscription
                    size: 100,
                    color: MyColors.primaryColor,
                  ),
                ),
                const SizedBox(height: 30),

                FadeInDown(
                  delay: const Duration(milliseconds: 200),
                  child: Text(
                    'Créer un compte',
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(color: MyColors.primaryColor),
                  ),
                ),
                const SizedBox(height: 40),

                // Email
                FadeInUp(
                  delay: const Duration(milliseconds: 300),
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

                // Mot de passe
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
                const SizedBox(height: 20),

                // Confirmation mot de passe
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
                        controller: _confirmPasswordController,
                        obscureText: _obscureConfirmPassword,
                        decoration: InputDecoration(
                          labelText: 'Confirmer le mot de passe',
                          prefixIcon: const Icon(Icons.lock_outline, color: MyColors.primaryColor),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureConfirmPassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: MyColors.primaryColor,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscureConfirmPassword =
                                    !_obscureConfirmPassword;
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

                // Bouton Inscription
                FadeInUp(
                  delay: const Duration(milliseconds: 600),
                  child: SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: _register,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: MyColors.primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        "S'inscrire",
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
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