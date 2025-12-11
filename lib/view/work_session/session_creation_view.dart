// lib/view/work_session/session_creation_view.dart

// ignore_for_file: prefer_typing_uninitialized_variables, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';
import 'package:intl/intl.dart';
import 'package:flutter/cupertino.dart';

///
import '../../main.dart';
import '../../models/work_session.dart';
import '../../utils/colors.dart';
import '../../utils/constanst.dart';
import '../../utils/strings.dart';

// ignore: must_be_immutable
class SessionCreationView extends StatefulWidget {
  // Les sessions sont toujours créées ici, donc pas besoin de paramètres d'édition
  const SessionCreationView({Key? key}) : super(key: key);

  @override
  State<SessionCreationView> createState() => _SessionCreationViewState();
}

class _SessionCreationViewState extends State<SessionCreationView> {
  // Contrôleurs pour les champs de texte
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController workDurationController = TextEditingController(text: '25'); // Valeur par défaut
  TextEditingController breakDurationController = TextEditingController(text: '5'); // Valeur par défaut

  // Paramètres de session
  DateTime? scheduledStart; // Date de début planifiée (optionnel)

  // Clé pour le formulaire
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    // Par défaut, la session démarre maintenant.
    scheduledStart = DateTime.now();
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    workDurationController.dispose();
    breakDurationController.dispose();
    super.dispose();
  }

  // Fonction pour créer et enregistrer la session
  Future<void> _createWorkSession() async {
    if (_formKey.currentState!.validate()) {
      final base = BaseWidget.of(context);

      final String title = titleController.text;
      final String description = descriptionController.text.isEmpty ? 'Aucune description' : descriptionController.text;
      final int workDuration = int.tryParse(workDurationController.text) ?? 25;
      final int breakDuration = int.tryParse(breakDurationController.text) ?? 5;

      // Création de la nouvelle session
      final newSession = WorkSession.create(
        title: title,
        description: description,
        workDurationMinutes: workDuration,
        breakDurationMinutes: breakDuration,
      );

      // Enregistrement dans Hive
      await base.dataStore.addSession(session: newSession);

      // Afficher un message de succès et naviguer en arrière
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Session "$title" créée avec succès !'),
          duration: const Duration(seconds: 2),
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    var textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        // Laissez le bouton de retour par défaut (il permet de revenir à WorkSessionView)
        leading: IconButton(
          icon: const Icon(CupertinoIcons.chevron_back, color: MyColors.primaryColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          MyString.newSessionTitle, // Ex: "Nouvelle Session"
          style: textTheme.headlineMedium,
        ),
        actions: [
          // Bouton ENREGISTRER / CRÉER
          TextButton(
            onPressed: _createWorkSession,
            child: Text(
              MyString.createSessionBtn, // Ex: "CRÉER"
              style: textTheme.titleMedium?.copyWith(
                color: MyColors.primaryColor,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ---------------------
                // 1. TITRE DE LA SESSION
                // ---------------------
                Text(MyString.sessionTitle, style: textTheme.titleMedium),
                const SizedBox(height: 10),
                TextFormField(
                  controller: titleController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Le titre de la session est requis.';
                    }
                    return null;
                  },
                  decoration: const InputDecoration(
                    hintText: 'Ex: Pomodoro pour le projet Flutter',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 30),

                // ---------------------
                // 2. DESCRIPTION
                // ---------------------
                Text(MyString.sessionDescription, style: textTheme.titleMedium),
                const SizedBox(height: 10),
                TextFormField(
                  controller: descriptionController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    hintText: 'Ex: Coder la vue de création de session.',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 30),

                // ---------------------
                // 3. DURÉES (Travail & Pause)
                // ---------------------
                Text(MyString.durationSettings, style: textTheme.titleMedium),
                const SizedBox(height: 10),
                Row(
                  children: [
                    // Durée de Travail
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(right: 10.0),
                        child: TextFormField(
                          controller: workDurationController,
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (int.tryParse(value ?? '') == null || (int.tryParse(value ?? '') ?? 0) <= 0) {
                              return 'Doit être un nombre > 0';
                            }
                            return null;
                          },
                          decoration: const InputDecoration(
                            labelText: 'Travail (min)',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ),
                    // Durée de Pause
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 10.0),
                        child: TextFormField(
                          controller: breakDurationController,
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (int.tryParse(value ?? '') == null || (int.tryParse(value ?? '') ?? 0) < 0) {
                              return 'Doit être un nombre >= 0';
                            }
                            return null;
                          },
                          decoration: const InputDecoration(
                            labelText: 'Pause (min)',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),

                // ---------------------
                // 4. DATE DE DÉBUT PLANIFIÉE (Optionnel)
                // ---------------------
                Text(MyString.scheduledStart, style: textTheme.titleMedium),
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: () {
                    DatePicker.showDateTimePicker(
                      context,
                      showTitleActions: true,
                      minTime: DateTime.now().subtract(const Duration(hours: 1)),
                      maxTime: DateTime.now().add(const Duration(days: 365)),
                      onConfirm: (date) {
                        setState(() {
                          scheduledStart = date;
                        });
                      },
                      currentTime: scheduledStart,
                      locale: LocaleType.fr, // Assurez-vous d'avoir 'fr' si vous utilisez français
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.access_time),
                        const SizedBox(width: 10),
                        Text(
                          scheduledStart == null
                              ? MyString.chooseTime
                              : DateFormat('dd MMM yyyy, HH:mm').format(scheduledStart!),
                          style: textTheme.titleMedium,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 50),

                // ---------------------
                // 5. BOUTON DE CRÉATION FINAL
                // ---------------------
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _createWorkSession,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: MyColors.primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      MyString.startSessionAndSave, // Ex: "DÉMARRER LA SESSION"
                      style: textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
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