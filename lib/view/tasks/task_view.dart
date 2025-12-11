// lib/view/tasks/task_view.dart

// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart'; 
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';
import 'package:intl/intl.dart';

///
import '../../main.dart';
import '../../models/task.dart';
import '../../models/task_step.dart';
import '../../utils/colors.dart';
import '../../utils/constanst.dart';
import '../../utils/strings.dart';

class TaskView extends StatefulWidget {
  final Task? task;

  const TaskView({
    Key? key,
    this.task,
  }) : super(key: key);

  @override
  State<TaskView> createState() => _TaskViewState();
}

class _TaskViewState extends State<TaskView> {
  // Contrôleurs locaux pour les champs
  late TextEditingController _titleController;
  late TextEditingController _subtitleController;
  final TextEditingController _stepController = TextEditingController();

  // Variables d'état non-nullables (initialisées dans initState)
  late DateTime _selectedTime;
  late DateTime _selectedDate;
  List<TaskStep> _steps = [];

  // Clé pour le formulaire
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  /// Vérifier si c'est une nouvelle tâche
  bool get isNewTask => widget.task == null;

  @override
  void initState() {
    super.initState();
    final task = widget.task;

    // Initialisation des contrôleurs et de l'état
    _titleController = TextEditingController(text: task?.title ?? '');
    _subtitleController = TextEditingController(text: task?.subtitle ?? '');
    
    // Initialisation obligatoire de late variables
    _selectedTime = task?.createdAtTime ?? DateTime.now();
    _selectedDate = task?.createdAtDate ?? DateTime.now();
    
    if (task != null) {
      _steps = List.from(task.steps); // Copie pour pouvoir éditer l'état local
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _subtitleController.dispose();
    _stepController.dispose();
    super.dispose();
  }

  /// Show Selected Time As String Format
  String showTime(DateTime time) {
    // CORRECTION: La fonction accepte maintenant un DateTime non-nullable
    return DateFormat('hh:mm a').format(time).toString();
  }

  /// Show Selected Date As String Format
  String showDate(DateTime date) {
    // CORRECTION: La fonction accepte maintenant un DateTime non-nullable
    return DateFormat.yMMMEd().format(date).toString();
  }

  /// Fonction de sauvegarde ou de mise à jour
  void saveOrUpdateTask() {
    if (!_formKey.currentState!.validate()) {
      emptyFieldsWarning(context);
      return;
    }

    final title = _titleController.text.trim();
    final subtitle = _subtitleController.text.trim();

    if (isNewTask) {
      // MODE AJOUT
      var newTask = Task.create(
        title: title,
        createdAtTime: _selectedTime,
        createdAtDate: _selectedDate,
        subtitle: subtitle,
        steps: _steps,
      );
      
      // Met à jour la date/heure de la tâche si des étapes existent.
      // Attention: assurez-vous que la méthode updateTaskDateTime existe dans votre modèle Task
      newTask.updateTaskDateTime();
      
      BaseWidget.of(context).dataStore.addTask(task: newTask);

    } else {
      // MODE ÉDITION
      try {
        final existingTask = widget.task!;
        existingTask.title = title;
        existingTask.subtitle = subtitle;
        
        // Mettre à jour les étapes
        existingTask.steps = _steps;

        // Mise à jour de l'heure et de la date
        existingTask.createdAtTime = _selectedTime;
        existingTask.createdAtDate = _selectedDate;
        existingTask.updateTaskDateTime(); 

        existingTask.updateCompletionStatus();
        existingTask.save();
        
      } catch (error) {
        nothingEnterOnUpdateTaskMode(context);
      }
    }

    Navigator.of(context).pop();
  }

  /// Delete Selected Task
  void deleteTask() {
    if (!isNewTask) {
      widget.task?.delete();
      Navigator.pop(context);
    }
  }

  /// InputDecoration moderne
  InputDecoration modernInput(String hint, {Widget? prefixIcon}) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Theme.of(context).cardColor,
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
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.red, width: 1.8),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.red, width: 1.8),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var textTheme = Theme.of(context).textTheme;
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: const _MyAppBar(), // Utilise la nouvelle AppBar plus propre
        body: Form(
          key: _formKey,
          child: SizedBox(
            width: double.infinity,
            height: double.infinity,
            child: Center(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    /// New / Update Task Text & Progression Bar
                    _buildTopHeader(textTheme),

                    /// Middle TextFields, Time And Date Selection Box, Steps
                    _buildFormContent(context, textTheme),

                    /// All Bottom Buttons
                    _buildBottomButtons(context),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
  
  /// Middle TextFields, Time And Date Selection Box, Steps
  Widget _buildFormContent(BuildContext context, TextTheme textTheme) {
    return SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Title TextField
          _buildFormLabel(textTheme, MyString.titleOfTitleTextField),
          Container(
            width: MediaQuery.of(context).size.width,
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: TextFormField(
              controller: _titleController,
              maxLines: 3,
              style: textTheme.titleMedium,
              decoration: modernInput("Ex: Terminer le rapport"),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Le titre est obligatoire.';
                }
                return null;
              },
            ),
          ),

          const SizedBox(height: 10),

          /// Note TextField
          _buildFormLabel(textTheme, MyString.addNote),
          Container(
            width: MediaQuery.of(context).size.width,
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: TextFormField(
              controller: _subtitleController,
              maxLines: 3,
              style: textTheme.titleSmall,
              decoration: modernInput(
                MyString.addNoteHint, 
                prefixIcon: const Icon(Icons.bookmark_border, color: Colors.grey)
              ),
            ),
          ),

          const SizedBox(height: 20),

          /// Time Picker
          _buildTimeDateSelector(
            context: context,
            textTheme: textTheme,
            icon: Icons.access_time,
            title: MyString.timeString,
            value: showTime(_selectedTime), // CORRECTION: _selectedTime est non-nullable ici.
            onTap: () {
              DatePicker.showTimePicker(
                context,
                showTitleActions: true,
                showSecondsColumn: false,
                currentTime: _selectedTime,
                locale: LocaleType.fr, // ou votre locale
                onConfirm: (selectedTime) {
                  setState(() {
                    _selectedTime = selectedTime;
                  });
                },
              );
            },
          ),

          /// Date Picker
          _buildTimeDateSelector(
            context: context,
            textTheme: textTheme,
            icon: Icons.calendar_today,
            title: MyString.dateString,
            value: showDate(_selectedDate), // CORRECTION: _selectedDate est non-nullable ici.
            onTap: () {
              DatePicker.showDatePicker(
                context,
                showTitleActions: true,
                minTime: DateTime.now(),
                maxTime: DateTime(2030, 12, 31),
                currentTime: _selectedDate,
                locale: LocaleType.fr, // ou votre locale
                onConfirm: (selectedDate) {
                  setState(() {
                    _selectedDate = selectedDate;
                  });
                },
              );
            },
            isLast: true,
          ),

          /// Section Étapes
          _buildStepsSection(textTheme),
        ],
      ),
    );
  }
  
  /// Helper pour les labels de formulaire
  Padding _buildFormLabel(TextTheme textTheme, String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 30, top: 10),
      child: Text(text, style: textTheme.headlineMedium),
    );
  }

  /// Helper pour les sélecteurs de date/heure
  GestureDetector _buildTimeDateSelector({
    required BuildContext context,
    required TextTheme textTheme,
    required IconData icon,
    required String title,
    required String value,
    required VoidCallback onTap,
    bool isLast = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: EdgeInsets.fromLTRB(20, 10, 20, isLast ? 20 : 10),
        width: double.infinity,
        height: 55,
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          border: Border.all(color: Colors.grey.shade300, width: 1),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 5,
            ),
          ],
        ),
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 15),
              child: Icon(icon, color: MyColors.primaryColor),
            ),
            const SizedBox(width: 10),
            Text(title, style: textTheme.headlineSmall),
            Expanded(child: Container()),
            Container(
              margin: const EdgeInsets.only(right: 10),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: MyColors.primaryColor.withOpacity(0.1),
              ),
              child: Text(
                value,
                style: textTheme.titleSmall?.copyWith(color: MyColors.primaryColor),
              ),
            )
          ],
        ),
      ),
    );
  }

  /// All Bottom Buttons
  Padding _buildBottomButtons(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20, left: 20, right: 20),
      child: Row(
        children: [
          // Bouton Supprimer (uniquement en mode édition)
          if (!isNewTask)
            Expanded(
              child: OutlinedButton.icon(
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                label: const Text(MyString.deleteTask, style: TextStyle(color: Colors.red)),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: const BorderSide(color: Colors.red, width: 2),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: () => confirmDelete(context),
              ),
            ),

          if (!isNewTask) const SizedBox(width: 12),

          /// Add or Update Task Button
          Expanded(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: MyColors.primaryColor,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: saveOrUpdateTask,
              child: Text(
                isNewTask ? MyString.addTaskString : MyString.updateTaskString,
                style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  /// new / update Task Text and progress bar
  Widget _buildTopHeader(TextTheme textTheme) {
    // Calcul de la progression pour l'affichage
    int totalSteps = _steps.length;
    int completedSteps = _steps.where((s) => s.isCompleted).length;
    double percentage = totalSteps > 0 ? (completedSteps / totalSteps) * 100 : 0.0;
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Titre principal
          Text(
            isNewTask ? MyString.addNewTask : MyString.updateCurrentTask,
            style: textTheme.titleLarge?.copyWith(
              fontSize: 28, 
              fontWeight: FontWeight.bold,
            ),
          ),
          
          // Barre de progression si c'est une tâche existante avec des étapes
          if (!isNewTask && totalSteps > 0) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: MyColors.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Progression des étapes",
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "${percentage.toInt()}%",
                        style: textTheme.titleMedium?.copyWith(
                          color: MyColors.primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: percentage / 100,
                      minHeight: 8,
                      backgroundColor: Colors.grey.shade300,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        percentage == 100 ? Colors.green : MyColors.primaryColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "$completedSteps/$totalSteps étapes complétées",
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }


  /// Section pour gérer les étapes de la tâche
  Widget _buildStepsSection(TextTheme textTheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFormLabel(textTheme, MyString.stepsTitle), // Assurez-vous d'ajouter stepsTitle dans MyString

        /// Liste des étapes
        if (_steps.isNotEmpty)
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(14),
              color: Theme.of(context).cardColor,
            ),
            child: ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _steps.length,
              itemBuilder: (context, index) {
                final step = _steps[index];
                return _buildStepItem(step, index);
              },
            ),
          ),

        /// Ajouter une étape
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _stepController,
                  decoration: modernInput(
                    "Nouvelle étape", 
                    prefixIcon: const Icon(Icons.format_list_numbered, color: Colors.grey)
                  ),
                ),
              ),
              const SizedBox(width: 10),
              IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: MyColors.primaryColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.add, color: Colors.white),
                ),
                onPressed: () {
                  if (_stepController.text.trim().isNotEmpty) {
                    setState(() {
                      // Utiliser le constructeur de création
                      _steps.add(TaskStep.create(title: _stepController.text.trim()));
                      _stepController.clear();
                    });
                  }
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
  
  /// Item de la liste des étapes
  Widget _buildStepItem(TaskStep step, int index) {
    return Dismissible(
      key: ValueKey(step.title + index.toString()),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) {
        setState(() {
          _steps.removeAt(index);
          // La progression sera recalculée lors du save/update
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Étape supprimée')),
        );
      },
      background: Container(
        color: Colors.red.withOpacity(0.7),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 10),
        leading: Checkbox(
          value: step.isCompleted,
          onChanged: (value) {
            setState(() {
              step.isCompleted = value ?? false;
              if (step.isCompleted) {
                step.completedAt = DateTime.now();
              } else {
                step.completedAt = null;
              }
            });
          },
          activeColor: MyColors.primaryColor,
        ),
        title: Text(
          step.title,
          style: TextStyle(
            decoration: step.isCompleted ? TextDecoration.lineThrough : null,
            fontWeight: FontWeight.w500,
            color: step.isCompleted ? Colors.grey : Theme.of(context).textTheme.titleMedium?.color,
          ),
        ),
        subtitle: _buildStepSubtitle(step),
        trailing: IconButton(
          icon: Icon(
            step.scheduledStartDate != null ? Icons.edit_calendar : Icons.calendar_today,
            color: MyColors.primaryColor,
            size: 20,
          ),
          onPressed: () => _editStepDateTime(step),
        ),
      ),
    );
  }
  
  /// Sous-titre de l'étape
  Widget _buildStepSubtitle(TaskStep step) {
    String dateStr = step.scheduledStartDate != null 
        ? DateFormat('dd/MM/yyyy').format(step.scheduledStartDate!)
        : "Non définie";
    String timeStr = step.scheduledStartTime != null 
        ? DateFormat('HH:mm').format(step.scheduledStartTime!)
        : '';

    Color textColor = Colors.grey.shade600;
    String text = "Appuyez pour planifier";
    
    // Vérification de la date passée uniquement si elle est définie
    if (step.scheduledStartDate != null) {
      text = "Échéance: $dateStr $timeStr".trim();
      // On compare seulement la date pour éviter les problèmes de temps exact
      DateTime today = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
      DateTime scheduledDay = DateTime(step.scheduledStartDate!.year, step.scheduledStartDate!.month, step.scheduledStartDate!.day);

      if (scheduledDay.isBefore(today) && !step.isCompleted) {
        textColor = Colors.red.shade600; // En retard
      }
    } else {
      textColor = Colors.grey.shade500;
    }
    
    return Text(
      text,
      style: TextStyle(
        fontSize: 12, 
        color: textColor, 
        fontStyle: step.scheduledStartDate == null ? FontStyle.italic : FontStyle.normal
      ),
    );
  }

  /// Éditer la date et l'heure d'une étape (Modale)
  void _editStepDateTime(TaskStep step) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
      ),
      builder: (context) {
        // État temporaire pour la bottom sheet
        DateTime? tempDate = step.scheduledStartDate;
        DateTime? tempTime = step.scheduledStartTime;
        
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setStateModal) {
            return Padding(
              padding: EdgeInsets.only(
                top: 20,
                left: 20,
                right: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Planifier l'étape: ${step.title}", 
                    style: Theme.of(context).textTheme.titleLarge),
                  const Divider(height: 30),

                  // Sélecteur de date
                  ListTile(
                    leading: const Icon(Icons.calendar_today, color: MyColors.primaryColor),
                    title: const Text("Date d'échéance"),
                    subtitle: Text(
                      tempDate != null
                          ? DateFormat('dd/MM/yyyy').format(tempDate!) // Assert non-null
                          : "Non définie",
                    ),
                    onTap: () {
                      DatePicker.showDatePicker(
                        context,
                        showTitleActions: true,
                        minTime: DateTime.now(),
                        maxTime: DateTime(2030, 12, 31),
                        currentTime: tempDate ?? DateTime.now(),
                        onConfirm: (selectedDate) {
                          setStateModal(() {
                            tempDate = selectedDate;
                          });
                        },
                      );
                    },
                  ),
                  
                  // Sélecteur d'heure
                  ListTile(
                    leading: const Icon(Icons.access_time, color: MyColors.primaryColor),
                    title: const Text("Heure d'échéance"),
                    subtitle: Text(
                      tempTime != null
                          ? DateFormat('HH:mm').format(tempTime!) // Assert non-null
                          : "Non définie",
                    ),
                    onTap: () {
                      DatePicker.showTimePicker(
                        context,
                        showTitleActions: true,
                        showSecondsColumn: false,
                        currentTime: tempTime ?? DateTime.now(),
                        onConfirm: (selectedTime) {
                          setStateModal(() {
                            tempTime = selectedTime;
                          });
                        },
                      );
                    },
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Bouton de confirmation
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() { // Mise à jour de l'état principal du TaskView
                          step.scheduledStartDate = tempDate;
                          step.scheduledStartTime = tempTime;
                        });
                        Navigator.pop(context); // Ferme la bottom sheet
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: MyColors.primaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text("Confirmer", style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // Dialogue de confirmation de suppression
  void confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirmer la suppression"),
          content: const Text("Êtes-vous sûr de vouloir supprimer cette tâche ?"),
          actions: <Widget>[
            TextButton(
              child: const Text("Annuler"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text("Supprimer", style: TextStyle(color: Colors.red)),
              onPressed: () {
                Navigator.of(context).pop(); // Ferme le dialogue
                deleteTask(); // Supprime la tâche et navigue en arrière
              },
            ),
          ],
        );
      },
    );
  }
}


/// AppBar personnalisée
class _MyAppBar extends StatelessWidget implements PreferredSizeWidget {
  const _MyAppBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 0,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      foregroundColor: MyColors.primaryColor,
      leading: IconButton(
        icon: const Icon(CupertinoIcons.chevron_back, size: 24),
        onPressed: () => Navigator.pop(context),
      ),
      // Le titre est maintenant dans le corps (body) pour un meilleur look moderne
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(56);
}