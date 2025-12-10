
// lib/view/work_session/session_create_view.dart

// ignore_for_file: prefer_typing_uninitialized_variables, use_build_context_synchronously

import 'package:flutter/material.dart';

///
import '../../main.dart';
import '../../models/work_session.dart';
import '../../utils/colors.dart';
import '../../utils/constanst.dart';
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
  bool get isNewSession => widget.session == null;

  /// Ajouter ou Mettre à jour la session
  dynamic saveOrUpdateSession() {
    final dataStore = BaseWidget.of(context).dataStore;

    if (widget.session != null) {
      // Mise à jour
      widget.session!.title = title;
      widget.session!.description = description;
      widget.session!.workDurationMinutes = int.tryParse(_workDurationController.text) ?? 25;
      widget.session!.breakDurationMinutes = int.tryParse(_breakDurationController.text) ?? 5;
      
      widget.session?.save();
      Navigator.of(context).pop();
    } else {
      // Création
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
        emptyFieldsWarning(context);
      }
    }
  }
  
  /// Supprimer la Session
  dynamic deleteSession() {
    return widget.session?.delete();
  }

  /// InputDecoration moderne
  InputDecoration modernInput(String hint, {Widget? prefixIcon}) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.grey.shade100,
      contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      prefixIcon: prefixIcon,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: MyColors.primaryColor, width: 1.8),
      ),
    );
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
              // Texte d'en-tête
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

  Widget _buildTopText(TextTheme textTheme) {
    return Center(
      child: Text(
        isNewSession ? MyString.addNewSession : MyString.updateCurrentSession,
        style: textTheme.titleLarge,
      ),
    );
  }

  Widget _buildTitleAndDescriptionFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(MyString.titleOfTitleTextField, style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 10),
        TextField(
          controller: _titleController,
          onChanged: (value) => title = value,
          decoration: modernInput("Ex: Deep Work Session"),
        ),
        const SizedBox(height: 20),

        Text(MyString.description, style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 10),
        TextField(
          controller: _descriptionController,
          maxLines: 4,
          onChanged: (value) => description = value,
          decoration: modernInput("Description et objectifs"),
        ),
      ],
    );
  }

  Widget _buildDurationSelectors(TextTheme textTheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Durée de Travail (min)", style: textTheme.headlineMedium),
        const SizedBox(height: 10),
        TextField(
          controller: _workDurationController,
          keyboardType: TextInputType.number,
          decoration: modernInput("Ex: 25 minutes", prefixIcon: const Icon(Icons.timer)),
          onChanged: (value) => workDurationMinutes = int.tryParse(value) ?? 25,
        ),
        const SizedBox(height: 20),

        Text("Durée de Pause (min)", style: textTheme.headlineMedium),
        const SizedBox(height: 10),
        TextField(
          controller: _breakDurationController,
          keyboardType: TextInputType.number,
          decoration: modernInput("Ex: 5 minutes", prefixIcon: const Icon(Icons.coffee)),
          onChanged: (value) => breakDurationMinutes = int.tryParse(value) ?? 5,
        ),
      ],
    );
  }

  Padding _buildBottomButtons(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        mainAxisAlignment: isNewSession
            ? MainAxisAlignment.center
            : MainAxisAlignment.spaceEvenly,
        children: [
          if (!isNewSession)
            OutlinedButton.icon(
              icon: const Icon(Icons.delete_outline, color: MyColors.primaryColor),
              label: const Text(MyString.deleteTask, style: TextStyle(color: MyColors.primaryColor)),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(150, 55),
                side: const BorderSide(color: MyColors.primaryColor, width: 2),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              onPressed: () {
                deleteSession();
                Navigator.pop(context);
              },
            ),

          /// Add or Update Session Button
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: MyColors.primaryColor,
              minimumSize: const Size(150, 55),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            onPressed: saveOrUpdateSession,
            child: Text(
              isNewSession ? MyString.addSessionString : MyString.updateSessionString,
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}

/// AppBar moderne
class SessionCreateAppBar extends StatelessWidget implements PreferredSizeWidget {
  const SessionCreateAppBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.white,
      foregroundColor: Colors.black87,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 22),
        onPressed: () => Navigator.pop(context),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(56);
}
