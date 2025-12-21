// Correction de l'import : On pointe vers TON main.dart pour le navigatorKey
import 'package:TodoWork/main.dart';
// Adaptation de l'import de la TopBar selon ton arborescence lib/view/widgets/
import 'package:TodoWork/widgets/top_bar.dart';
import 'package:flutter/material.dart';

class SecondScreen extends StatelessWidget {
  const SecondScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Theme.of(context).primaryColor,
              Colors.grey[200]!,
            ],
          ), // La parenthèse du LinearGradient se ferme ici
        ), // La parenthèse du BoxDecoration se ferme ici
        child: SizedBox(
          // Utilisation de .width pour couvrir toute la largeur de l'écran
          width: MediaQuery.of(context).size.width,
          child: Column(
            children: [
              const TopBar(title: 'Second Screen'),
              const Spacer(),
              const Center(
                child: Text(
                  "Navigated from notification",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              const Spacer(),
              // Bouton de retour utilisant ta clé globale de navigation
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(
                  Icons.arrow_circle_left_outlined,
                  size: 50,
                  color: Colors.white,
                ),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
