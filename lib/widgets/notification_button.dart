import 'package:flutter/material.dart';

class NotificationButton extends StatelessWidget {
  const NotificationButton({
    required this.onPressed,
    required this.text,
    super.key,
  });

  final VoidCallback onPressed;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        left: 30.0,
        right: 30.0,
        top: 20,
        bottom: 10,
      ),
      child: SizedBox(
        width: MediaQuery.of(context).size.width,
        height: 55, // Légèrement plus haut pour un meilleur confort tactile
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            elevation: 5, // Ajout d'une petite ombre pour le relief
            shadowColor: Theme.of(context).shadowColor,
            backgroundColor: Theme.of(context).primaryColor,
            foregroundColor: Colors.white, // Couleur du texte en blanc
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15), // Bords plus arrondis
            ),
          ),
          onPressed: onPressed,
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold, // Texte plus lisible
              letterSpacing: 0.5,
            ),
          ),
        ),
      ),
    );
  }
}