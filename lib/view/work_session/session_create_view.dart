// lib/view/work_session/session_create_view.dart

// ignore_for_file: prefer_typing_uninitialized_variables, use_build_context_synchronously

import 'package:flutter/material.dart';

///
import '../../main.dart';
import '../../models/work_session.dart';
import '../../utils/colors.dart';
import '../../utils/constanst.dart'; // Pour emptyFieldsWarning, etc.
import '../../utils/strings.dart'; 

// ignore: must_be_immutable
class SessionCreateView extends StatefulWidget {
  SessionCreateView({
    Key? key,
    required this.session,
  }) : super(key: key);

  final WorkSession? session;

  @override
  State<SessionCreateView> createState() => _SessionCreateViewState();
}

class _SessionCreateViewState extends State<SessionCreateView> {
  late String title;
  late String description;
  late int workDurationMinutes;
  late int breakDurationMinutes;

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  
  // Contrôleurs pour les durées, initialisés à 25/5 par défaut si nouvelle session
  final TextEditingController _workDurationController = TextEditingController(text: '25');
  final TextEditingController _breakDurationController = TextEditingController(text: '5');


  @override
  void initState() {
    super.initState();
    bool isEditing = widget.session != null;

    _titleController.text = isEditing ? widget.session!.title : '';
    _descriptionController.text = isEditing ? widget.session!.description : '';
    _workDurationController.text = isEditing ? widget.session!.workDurationMinutes.toString() : '25';
    _breakDurationController.text = isEditing ? widget.session!.breakDurationMinutes.toString() : '5';

    title = _titleController.text;
    description = _descriptionController.text;
    workDurationMinutes = int.tryParse(_workDurationController.text) ?? 25;
    breakDurationMinutes = int.tryParse(_breakDurationController.text) ?? 5;
  }

  /// Si une Session existe déjà (mode mise à jour)
  bool isSessionAlreadyExistBool() {
    return widget.session == null;
  }

  /// Ajouter ou Mettre à jour la session
  dynamic saveOrUpdateSession() {
    final dataStore = BaseWidget.of(context).dataStore;

    // Mise à jour
    if (widget.session != null) {
      widget.session!.title = title;
      widget.session!.description = description;
      widget.session!.workDurationMinutes = int.tryParse(_workDurationController.text) ?? 25;
      widget.session!.breakDurationMinutes = int.tryParse(_breakDurationController.text) ?? 5;
      
      widget.session?.save();
      Navigator.of(context).pop();
    } 
    // Création
    else {
      if (title.isNotEmpty && description.isNotEmpty) {
        var session = WorkSession.create(
          title: title,
          description: description,
          workDurationMinutes: int.tryParse(_workDurationController.text) ?? 25,
          breakDurationMinutes: int.tryParse(_breakDurationController.text) ?? 5,
        );
        dataStore.addSession(session: session);
        Navigator.of(context).pop();
      } else {
        emptyFieldsWarning(context); // Doit être implémenté dans utils/constanst.dart
      }
    }
  }
  
  /// Supprimer la Session
  dynamic deleteSession() {
    return widget.session?.delete();
  }


  @override
  Widget build(BuildContext context) {
    var textTheme = Theme.of(context).textTheme;
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: const SessionCreateAppBar(),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Texte d'en-tête (Nouvelle session / Modifier session)
              _buildTopText(textTheme),
              
              const SizedBox(height: 30),
              
              // Champs Titre et Description
              _buildTitleAndDescriptionFields(),

              const SizedBox(height: 30),

              // Sélecteurs de Durée
              _buildDurationSelectors(textTheme),
              
              const SizedBox(height: 50),

              // Boutons
              _buildBottomButtons(context),
            ],
          ),
        ),
      ),
    );
  }

  
  // ... Méthodes de construction des widgets ...
  
  Widget _buildTopText(TextTheme textTheme) {
    return Center(
      child: Text(
        isSessionAlreadyExistBool() ? MyString.addNewSession : MyString.updateCurrentSession,
        style: textTheme.titleLarge,
      ),
    );
  }

  Widget _buildTitleAndDescriptionFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(MyString.titleOfTitleTextField, style: Theme.of(context).textTheme.headlineMedium),
        TextField(
          controller: _titleController,
          onChanged: (value) => title = value,
          decoration: const InputDecoration(hintText: "Nom de la session (ex: Deep Work)"),
        ),
        const SizedBox(height: 20),

        Text(MyString.description, style: Theme.of(context).textTheme.headlineMedium),
        TextField(
          controller: _descriptionController,
          maxLines: 4,
          onChanged: (value) => description = value,
          decoration: const InputDecoration(hintText: "Description et objectifs"),
        ),
      ],
    );
  }

  Widget _buildDurationSelectors(TextTheme textTheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Durée de Travail (min)", style: textTheme.headlineMedium),
        TextField(
          controller: _workDurationController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            hintText: "Ex: 25 (minutes)",
            prefixIcon: Icon(Icons.work)
          ),
          onChanged: (value) => workDurationMinutes = int.tryParse(value) ?? 25,
        ),
        const SizedBox(height: 20),

        Text("Durée de Pause (min)", style: textTheme.headlineMedium),
        TextField(
          controller: _breakDurationController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            hintText: "Ex: 5 (minutes)",
            prefixIcon: Icon(Icons.coffee)
          ),
          onChanged: (value) => breakDurationMinutes = int.tryParse(value) ?? 5,
        ),
      ],
    );
  }


  Padding _buildBottomButtons(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        mainAxisAlignment: isSessionAlreadyExistBool()
            ? MainAxisAlignment.center
            : MainAxisAlignment.spaceEvenly,
        children: [
          isSessionAlreadyExistBool()
              ? Container()

              /// Delete Session Button
              : Container(
                  width: 150,
                  height: 55,
                  decoration: BoxDecoration(
                      border:
                          Border.all(color: MyColors.primaryColor, width: 2),
                      borderRadius: BorderRadius.circular(15)),
                  child: MaterialButton(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    onPressed: () {
                      deleteSession();
                      Navigator.pop(context);
                    },
                    child: Row(
                      children: const [
                        Icon(Icons.close, color: MyColors.primaryColor),
                        SizedBox(width: 5),
                        Text(MyString.deleteTask, style: TextStyle(color: MyColors.primaryColor)),
                      ],
                    ),
                  ),
                ),

          /// Add or Update Session Button
          MaterialButton(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            minWidth: 150,
            height: 55,
            onPressed: saveOrUpdateSession,
            color: MyColors.primaryColor,
            child: Text(
              isSessionAlreadyExistBool()
                  ? MyString.addSessionString
                  : MyString.updateSessionString,
              style: const TextStyle(
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// AppBar
class SessionCreateAppBar extends StatelessWidget implements PreferredSizeWidget {
  const SessionCreateAppBar({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 150,
      child: Padding(
        padding: const EdgeInsets.only(top: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 20),
              child: GestureDetector(
                onTap: () {
                  Navigator.of(context).pop();
                },
                child: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  size: 50,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(100);
}