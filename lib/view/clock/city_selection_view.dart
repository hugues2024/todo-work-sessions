// lib/view/clock/city_selection_view.dart

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../utils/colors.dart';

/// Modèle simple pour une ville et son décalage horaire
class CityTimeData {
  final String name;
  final String region;
  final Duration utcOffset;

  CityTimeData(this.name, this.region, this.utcOffset);
}

class CitySelectionView extends StatefulWidget {
  const CitySelectionView({super.key});

  @override
  State<CitySelectionView> createState() => _CitySelectionViewState();
}

class _CitySelectionViewState extends State<CitySelectionView> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  // Liste simulée de villes (Normalement, cela viendrait d'une base de données ou d'une API)
  // Liste élargie pour une expérience "complète"
  final List<CityTimeData> _allCities = [
    CityTimeData("Abidjan", "Afrique de l'Ouest", const Duration(hours: 0)),
    CityTimeData("Abuja", "Nigéria", const Duration(hours: 1)),
    CityTimeData("Accra", "Afrique de l'Ouest", const Duration(hours: 0)),
    CityTimeData("Addis-Abeba", "Éthiopie", const Duration(hours: 3)),
    CityTimeData("Alger", "Algérie", const Duration(hours: 1)),
    CityTimeData("Amsterdam", "Pays-Bas", const Duration(hours: 1)),
    CityTimeData("Athènes", "Grèce", const Duration(hours: 2)),
    CityTimeData("Bagdad", "Irak", const Duration(hours: 3)),
    CityTimeData("Bamako", "Mali", const Duration(hours: 0)),
    CityTimeData("Bangkok", "Thaïlande", const Duration(hours: 7)),
    CityTimeData("Barcelone", "Espagne", const Duration(hours: 1)),
    CityTimeData("Beijing", "Chine", const Duration(hours: 8)),
    CityTimeData("Beyrouth", "Liban", const Duration(hours: 2)),
    CityTimeData("Berlin", "Europe Centrale", const Duration(hours: 1)),
    CityTimeData("Bogota", "Colombie", const Duration(hours: -5)),
    CityTimeData("Brasilia", "Brésil", const Duration(hours: -3)),
    CityTimeData("Bruxelles", "Belgique", const Duration(hours: 1)),
    CityTimeData("Buenos Aires", "Argentine", const Duration(hours: -3)),
    CityTimeData("Caire", "Égypte", const Duration(hours: 2)),
    CityTimeData("Canberra", "Australie", const Duration(hours: 10)),
    CityTimeData("Capetown", "Afrique du Sud", const Duration(hours: 2)),
    CityTimeData("Caracas", "Venezuela", const Duration(hours: -4)),
    CityTimeData("Casablanca", "Maroc", const Duration(hours: 1)),
    CityTimeData("Chicago", "États-Unis", const Duration(hours: -6)),
    CityTimeData("Copenhague", "Danemark", const Duration(hours: 1)),
    CityTimeData("Dakar", "Sénégal", const Duration(hours: 0)),
    CityTimeData("Dallas", "États-Unis", const Duration(hours: -6)),
    CityTimeData("Delhi", "Inde", const Duration(hours: 5, minutes: 30)),
    CityTimeData("Denver", "États-Unis", const Duration(hours: -7)),
    CityTimeData("Doha", "Qatar", const Duration(hours: 3)),
    CityTimeData("Dubaï", "Émirats arabes unis", const Duration(hours: 4)),
    CityTimeData("Dublin", "Irlande", const Duration(hours: 0)),
    CityTimeData("Francfort", "Allemagne", const Duration(hours: 1)),
    CityTimeData("Genève", "Suisse", const Duration(hours: 1)),
    CityTimeData("Hanoï", "Vietnam", const Duration(hours: 7)),
    CityTimeData("Helsinki", "Finlande", const Duration(hours: 2)),
    CityTimeData("Hong Kong", "Chine", const Duration(hours: 8)),
    CityTimeData("Honolulu", "Hawaï", const Duration(hours: -10)),
    CityTimeData("Houston", "États-Unis", const Duration(hours: -6)),
    CityTimeData("Istanbul", "Turquie", const Duration(hours: 3)),
    CityTimeData("Jakarta", "Indonésie", const Duration(hours: 7)),
    CityTimeData("Jérusalem", "Israël", const Duration(hours: 2)),
    CityTimeData("Johannesburg", "Afrique du Sud", const Duration(hours: 2)),
    CityTimeData(
        "Kaboul", "Afghanistan", const Duration(hours: 4, minutes: 30)),
    CityTimeData("Kiev", "Ukraine", const Duration(hours: 2)),
    CityTimeData("Kinshasa", "RDC", const Duration(hours: 1)),
    CityTimeData("Kuala Lumpur", "Malaisie", const Duration(hours: 8)),
    CityTimeData("Lagos", "Nigéria", const Duration(hours: 1)),
    CityTimeData("Lima", "Pérou", const Duration(hours: -5)),
    CityTimeData("Lisbonne", "Portugal", const Duration(hours: 0)),
    CityTimeData("Londres", "Royaume-Uni", const Duration(hours: 0)),
    CityTimeData(
        "Los Angeles", "États-Unis (Pacifique)", const Duration(hours: -8)),
    CityTimeData("Madrid", "Espagne", const Duration(hours: 1)),
    CityTimeData("Manille", "Philippines", const Duration(hours: 8)),
    CityTimeData("Mexico", "Mexique", const Duration(hours: -6)),
    CityTimeData("Miami", "États-Unis", const Duration(hours: -5)),
    CityTimeData("Montréal", "Canada", const Duration(hours: -5)),
    CityTimeData("Moscou", "Russie", const Duration(hours: 3)),
    CityTimeData("Mumbai", "Inde", const Duration(hours: 5, minutes: 30)),
    CityTimeData("Nairobi", "Kenya", const Duration(hours: 3)),
    CityTimeData("New York", "États-Unis (Est)", const Duration(hours: -5)),
    CityTimeData("Oslo", "Norvège", const Duration(hours: 1)),
    CityTimeData("Ottawa", "Canada", const Duration(hours: -5)),
    CityTimeData("Paris", "France", const Duration(hours: 1)),
    CityTimeData("Prague", "République Tchèque", const Duration(hours: 1)),
    CityTimeData("Reykjavik", "Islande", const Duration(hours: 0)),
    CityTimeData("Rio de Janeiro", "Brésil", const Duration(hours: -3)),
    CityTimeData("Riyad", "Arabie Saoudite", const Duration(hours: 3)),
    CityTimeData("Rome", "Italie", const Duration(hours: 1)),
    CityTimeData("San Francisco", "États-Unis", const Duration(hours: -8)),
    CityTimeData("Santiago", "Chili", const Duration(hours: -4)),
    CityTimeData("Sao Paulo", "Brésil", const Duration(hours: -3)),
    CityTimeData("Séoul", "Corée du Sud", const Duration(hours: 9)),
    CityTimeData("Shanghai", "Chine", const Duration(hours: 8)),
    CityTimeData("Singapour", "Singapour", const Duration(hours: 8)),
    CityTimeData("Stockholm", "Suède", const Duration(hours: 1)),
    CityTimeData("Sydney", "Australie", const Duration(hours: 11)),
    CityTimeData("Taipei", "Taïwan", const Duration(hours: 8)),
    CityTimeData("Téhéran", "Iran", const Duration(hours: 3, minutes: 30)),
    CityTimeData("Tokyo", "Japon", const Duration(hours: 9)),
    CityTimeData("Toronto", "Canada", const Duration(hours: -5)),
    CityTimeData("Tunis", "Tunisie", const Duration(hours: 1)),
    CityTimeData("Vancouver", "Canada", const Duration(hours: -8)),
    CityTimeData("Vienne", "Autriche", const Duration(hours: 1)),
    CityTimeData("Washington", "États-Unis", const Duration(hours: -5)),
    CityTimeData("Zurich", "Suisse", const Duration(hours: 1)),
  ];

  List<CityTimeData> _filteredCities = [];
  // Map pour stocker l'index de la première occurrence de chaque lettre
  final Map<String, int> _letterIndexes = {};
  final List<String> _alphabet = [];

  @override
  void initState() {
    super.initState();
    _filteredCities = _allCities;
    _filteredCities.sort((a, b) => a.name.compareTo(b.name)); // Tri A-Z
    _generateAlphabetIndex();
  }

  void _generateAlphabetIndex() {
    _letterIndexes.clear();
    _alphabet.clear();

    for (int i = 0; i < _filteredCities.length; i++) {
      String firstLetter =
          _filteredCities[i].name.substring(0, 1).toUpperCase();
      if (!_letterIndexes.containsKey(firstLetter)) {
        _letterIndexes[firstLetter] = i;
        _alphabet.add(firstLetter);
      }
    }
  }

  void _filterCities(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredCities = _allCities;
      } else {
        _filteredCities = _allCities
            .where(
                (city) => city.name.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
      _generateAlphabetIndex();
    });
  }

  void _scrollToLetter(String letter) {
    if (_letterIndexes.containsKey(letter)) {
      final index = _letterIndexes[letter]!;
      // Estimation de la hauteur d'un élément (ListTile height ~72)
      // Pour plus de précision, on utiliserait scroll_to_index package, mais ici on fait simple
      final double offset = index * 72.0;

      _scrollController.animateTo(
        offset,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDarkMode ? Colors.white : Colors.black;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textColor),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: TextField(
          controller: _searchController,
          autofocus: true,
          style: TextStyle(color: textColor),
          decoration: InputDecoration(
            hintText: "Rechercher des villes",
            hintStyle: TextStyle(color: textColor.withOpacity(0.5)),
            border: InputBorder.none,
          ),
          onChanged: _filterCities,
        ),
      ),
      body: Stack(
        children: [
          ListView.builder(
            controller: _scrollController,
            itemCount: _filteredCities.length,
            // Ajout d'un padding en bas pour éviter que le dernier élément soit caché
            padding: const EdgeInsets.only(bottom: 20),
            itemBuilder: (context, index) {
              final city = _filteredCities[index];
              final nowUtc = DateTime.now().toUtc();
              final cityTime = nowUtc.add(city.utcOffset);

              // Formatage simple de l'heure pour l'aperçu
              final timeString =
                  "${cityTime.hour.toString().padLeft(2, '0')}:${cityTime.minute.toString().padLeft(2, '0')}";

              // Vérifier si c'est le premier élément de cette lettre pour afficher l'en-tête
              String currentLetter = city.name.substring(0, 1).toUpperCase();
              bool showHeader = false;
              if (index == 0) {
                showHeader = true;
              } else {
                String prevLetter = _filteredCities[index - 1]
                    .name
                    .substring(0, 1)
                    .toUpperCase();
                if (currentLetter != prevLetter) showHeader = true;
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (showHeader && _searchController.text.isEmpty)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 15, 20, 5),
                      child: Text(
                        currentLetter,
                        style: TextStyle(
                          color: MyColors.primaryColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ListTile(
                    onTap: () {
                      // Retourne la ville sélectionnée à la page précédente
                      Navigator.of(context).pop(city);
                    },
                    title: Text(
                      city.name,
                      style: TextStyle(
                        color: textColor,
                        fontWeight: FontWeight.w500,
                        fontSize: 18,
                      ),
                    ),
                    subtitle: Text(
                      city.region,
                      style: TextStyle(color: textColor.withOpacity(0.6)),
                    ),
                    trailing: Text(
                      timeString,
                      style: TextStyle(
                        color: textColor,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),

          // Barre de défilement A-Z (Uniquement si pas de recherche active)
          if (_searchController.text.isEmpty)
            Align(
              alignment: Alignment.centerRight,
              child: Container(
                margin: const EdgeInsets.only(right: 5),
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: _alphabet
                        .map((letter) => GestureDetector(
                              onTap: () => _scrollToLetter(letter),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 2, horizontal: 10),
                                child: Text(
                                  letter,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: MyColors.primaryColor,
                                  ),
                                ),
                              ),
                            ))
                        .toList(),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
