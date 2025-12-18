// lib/view/splash_view.dart

import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'main_wrapper.dart';
import '../utils/colors.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  @override
  void initState() {
    super.initState();
    // 🎯 REDIRECTION AUTOMATIQUE APRÈS 3 SECONDES
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainWrapper()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Fond propre pour faire ressortir le logo
      body: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 🎯 ANIMATION DU LOGO
                ZoomIn(
                  duration: const Duration(milliseconds: 1200),
                  child: FadeInDown(
                    duration: const Duration(milliseconds: 1000),
                    child: Image.asset(
                      'assets/img/logo.png',
                      width: 150,
                      height: 150,
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                // 🎯 INDICATEUR DE CHARGEMENT ÉLÉGANT
                FadeInUp(
                  delay: const Duration(milliseconds: 500),
                  child: Column(
                    children: [
                      const SizedBox(
                        width: 40,
                        height: 40,
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          valueColor: AlwaysStoppedAnimation<Color>(MyColors.primaryColor),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        "Préparation de votre espace...",
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Petit texte en bas
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: FadeIn(
              delay: const Duration(seconds: 1),
              child: const Text(
                "Todo Work Sessions",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                  letterSpacing: 1.2,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
