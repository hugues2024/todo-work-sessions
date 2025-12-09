// lib/core/theme/app_theme.dart

import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class AppTheme {
  // Thème clair (Light Theme)
  static ThemeData lightTheme = ThemeData(
    // 1. Couleurs de base
    brightness: Brightness.light,
    primaryColor: AppColors.primaryBlue,
    scaffoldBackgroundColor: AppColors.backgroundLight,
    
    // 2. AppBar (Barre du haut)
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.backgroundLight,
      foregroundColor: AppColors.textPrimary,
      elevation: 0, // Design plat
    ),
    
    // 3. Boutons (Accent Green pour l'action)
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: AppColors.accentGreen,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      ),
    ),
    
    // 4. Texte (Utilisation de la couleur primaire)
    textTheme: const TextTheme(
      titleLarge: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
      bodyMedium: TextStyle(color: AppColors.textPrimary),
      // Si vous utilisez une police spécifique comme Poppins, ajoutez-la ici
    ),
    
    // 5. Entrées de Texte (Input Fields)
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.textSecondary),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.primaryBlue, width: 2),
      ),
      fillColor: Colors.white,
      filled: true,
      hintStyle: const TextStyle(color: AppColors.textSecondary),
    ),
  );
  
  // Un thème sombre pourrait être ajouté ici si nécessaire
}