// lib/view/clock/world_clock_view.dart

import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Nécessaire pour le formatage des dates
import '../../utils/colors.dart';
import 'city_selection_view.dart'; // Import de la vue de sélection
import 'clock_settings_view.dart'; // Import de la vue paramètres

class WorldClockView extends StatefulWidget {
  const WorldClockView({super.key});

  @override
  State<WorldClockView> createState() => _WorldClockViewState();
}

class _WorldClockViewState extends State<WorldClockView> {
  late Timer _timer;
  DateTime _currentTime = DateTime.now();

  // Liste des villes ajoutées par l'utilisateur
  final List<CityTimeData> _selectedCities = [];

  // Gestion du mode sélection
  bool _isSelectionMode = false;
  final Set<CityTimeData> _citiesToDelete = {};

  @override
  void initState() {
    super.initState();
    // Mise à jour de l'heure chaque seconde
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _currentTime = DateTime.now();
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  /// Navigue vers la page de sélection de ville
  Future<void> _navigateToAddCity() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CitySelectionView()),
    );

    if (result != null && result is CityTimeData) {
      setState(() {
        // Vérifier si la ville n'est pas déjà dans la liste
        if (!_selectedCities.any((c) => c.name == result.name)) {
          _selectedCities.add(result);
        }
      });
    }
  }

  // --- LOGIQUE DE SÉLECTION ---

  void _toggleSelectionMode(CityTimeData? initialCity) {
    setState(() {
      _isSelectionMode = !_isSelectionMode;
      _citiesToDelete.clear();
      if (_isSelectionMode && initialCity != null) {
        _citiesToDelete.add(initialCity);
      }
    });
  }

  void _toggleCitySelection(CityTimeData city) {
    setState(() {
      if (_citiesToDelete.contains(city)) {
        _citiesToDelete.remove(city);
        // Si on désélectionne tout, on quitte le mode sélection ?
        // Optionnel: if (_citiesToDelete.isEmpty) _isSelectionMode = false;
      } else {
        _citiesToDelete.add(city);
      }
    });
  }

  void _deleteSelectedCities() {
    if (_citiesToDelete.isEmpty) return;

    final int count = _citiesToDelete.length;
    final String message = count == 1
        ? "Supprimer cette ville ?"
        : "Supprimer ces $count villes ?";

    // Afficher la confirmation
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Confirmation"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(), // Annuler
            child: const Text("Annuler", style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _selectedCities
                    .removeWhere((city) => _citiesToDelete.contains(city));
                _isSelectionMode = false;
                _citiesToDelete.clear();
              });
              Navigator.of(ctx).pop(); // Fermer dialog
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Villes supprimées avec succès")),
              );
            },
            child: const Text("Supprimer", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDarkMode ? Colors.white : Colors.black;

    // Formatage de l'heure locale
    final String formattedTime = DateFormat('HH:mm:ss').format(_currentTime);
    // Formatage de la date en français (nécessite locale fr_FR ou par défaut système)
    // Si la locale n'est pas initialisée, cela utilisera l'anglais par défaut,
    // mais on peut forcer le formatage manuel si nécessaire.
    final String formattedDate =
        DateFormat('EEEE d MMMM', 'fr_FR').format(_currentTime);

    // Récupération du nom du fuseau horaire (ex: GMT+01:00 ou nom complet selon l'OS)
    final String timeZoneName = _currentTime.timeZoneName;

    final timeStyle = TextStyle(
      fontSize: 60,
      fontWeight: FontWeight.w300,
      color: textColor,
      fontFeatures: const [
        FontFeature.tabularFigures()
      ], // Empêche le texte de bouger quand les chiffres changent
    );
    final dateStyle = TextStyle(
      fontSize: 18,
      color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade700,
    );

    return Scaffold(
      appBar: AppBar(
        // Changement dynamique du Header
        leading: _isSelectionMode
            ? IconButton(
                icon: const Icon(Icons.close),
                color: textColor,
                onPressed: () => setState(() {
                  _isSelectionMode = false;
                  _citiesToDelete.clear();
                }),
              )
            : null,
        title: _isSelectionMode
            ? Text(
                _citiesToDelete.isEmpty
                    ? "Aucun sélectionné"
                    : "${_citiesToDelete.length} sélectionné(s)",
                style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
              )
            : Text(
                'Horloge mondiale',
                style: TextStyle(
                  color: textColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        actions: [
          if (!_isSelectionMode) ...[
            // Bouton Ajouter (+)
            IconButton(
              icon: Icon(CupertinoIcons.add, color: textColor),
              onPressed: _navigateToAddCity,
            ),
            // Menu Popup (Paramètres)
            PopupMenuButton<String>(
              icon: Icon(Icons.more_vert, color: textColor),
              onSelected: (value) {
                if (value == 'settings') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const ClockSettingsView()),
                  );
                }
              },
              itemBuilder: (BuildContext context) {
                return [
                  const PopupMenuItem<String>(
                    value: 'settings',
                    child: Text('Paramètres'),
                  ),
                ];
              },
            ),
          ] else ...[
            // Actions spécifiques au mode sélection si besoin (ex: tout sélectionner)
          ]
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 40),
            // --- HEURE LOCALE ---
            Center(
              child: Column(
                children: [
                  Text(
                    formattedTime,
                    style: timeStyle,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    formattedDate, // ex: Lundi 15 Décembre
                    style: dateStyle,
                  ),
                  const SizedBox(height: 5),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(CupertinoIcons.location_solid,
                          size: 16, color: MyColors.primaryColor),
                      const SizedBox(width: 5),
                      Text(
                        "Heure locale ($timeZoneName)", // ex: Heure locale (WAT)
                        style: dateStyle.copyWith(
                            fontSize: 14, color: MyColors.primaryColor),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 50),

            // --- VILLES SÉLECTIONNÉES ---
            if (_selectedCities.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Villes suivies",
                    style: TextStyle(
                        color: textColor.withOpacity(0.5),
                        fontWeight: FontWeight.bold,
                        fontSize: 14),
                  ),
                ),
              ),

            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              itemCount: _selectedCities.length,
              itemBuilder: (context, index) {
                final city = _selectedCities[index];
                return _buildCityCard(context, city, isDarkMode);
              },
            ),

            if (_selectedCities.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 40),
                child: Text(
                  "Aucune ville ajoutée",
                  style: TextStyle(color: textColor.withOpacity(0.3)),
                ),
              ),
          ],
        ),
      ),
      // Menu du bas (Poubelle) qui s'affiche en mode sélection
      bottomSheet: _isSelectionMode
          ? Container(
              color: isDarkMode ? Colors.grey.shade900 : Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 10),
              width: double.infinity,
              child: IconButton(
                icon: const Icon(CupertinoIcons.delete,
                    color: Colors.red, size: 30),
                onPressed:
                    _citiesToDelete.isNotEmpty ? _deleteSelectedCities : null,
              ),
              // Petit hack pour l'ombre
              decoration: BoxDecoration(
                  color: isDarkMode ? Colors.grey.shade900 : Colors.white,
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black12,
                        blurRadius: 5,
                        offset: Offset(0, -2))
                  ]),
            )
          : null,
    );
  }

  Widget _buildCityCard(
      BuildContext context, CityTimeData city, bool isDarkMode) {
    // Calcul de l'heure de la ville basée sur UTC
    final nowUtc = DateTime.now().toUtc();
    final cityTime = nowUtc.add(city.utcOffset);
    final timeString = DateFormat('HH:mm').format(cityTime);

    // Calcul du décalage relatif (ex: +1h, -2h) par rapport à l'heure locale
    final localOffset = DateTime.now().timeZoneOffset;
    final diffDuration = city.utcOffset - localOffset;
    final diffHours = diffDuration.inHours;
    String diffString = diffHours == 0
        ? "Même heure"
        : (diffHours > 0 ? "+$diffHours h" : "$diffHours h");

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: isDarkMode ? Colors.grey.shade800 : Colors.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  city.name,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white : Colors.black,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "${city.region} • $diffString",
                  style: TextStyle(
                    fontSize: 13,
                    color: isDarkMode
                        ? Colors.grey.shade400
                        : Colors.grey.shade600,
                  ),
                ),
              ],
            ),
            Text(
              timeString,
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w300,
                color: isDarkMode ? Colors.white : Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
