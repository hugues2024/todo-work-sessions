// lib/view/tasks/task_view.dart

// ignore_for_file: prefer_typing_uninitialized_variables, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';
import 'package:intl/intl.dart';

///
import '../../main.dart';
import '../../models/task.dart';
import '../../models/task_step.dart';
import '../../utils/colors.dart';
import '../../utils/constanst.dart';
import '../../utils/strings.dart';

// ignore: must_be_immutable
class TaskView extends StatefulWidget {
  TaskView({
    Key? key,
    required this.taskControllerForTitle,
    required this.taskControllerForSubtitle,
    required this.task,
  }) : super(key: key);

  TextEditingController? taskControllerForTitle;
  TextEditingController? taskControllerForSubtitle;
  final Task? task;

  @override
  State<TaskView> createState() => _TaskViewState();
}

class _TaskViewState extends State<TaskView> {
  var title;
  var subtitle;
  DateTime? time;
  DateTime? date;
  List<TaskStep> steps = [];
  final TextEditingController _stepController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Initialisation des valeurs pour l'édition
    title = widget.task?.title;
    subtitle = widget.task?.subtitle;
    time = widget.task?.createdAtTime;
    date = widget.task?.createdAtDate;
    steps = widget.task?.steps ?? [];

    // Normaliser les contrôleurs si édition
    if (widget.task != null) {
      widget.taskControllerForTitle?.text = widget.task?.title ?? "";
      widget.taskControllerForSubtitle?.text = widget.task?.subtitle ?? "";
    }
  }

  @override
  void dispose() {
    _stepController.dispose();
    super.dispose();
  }

  /// Vérifier si c'est une nouvelle tâche
  bool get isNewTask => widget.task == null;

  /// Show Selected Time As String Format
  String showTime(DateTime? time) {
    DateTime displayTime = time ?? widget.task?.createdAtTime ?? DateTime.now();
    return DateFormat('hh:mm a').format(displayTime).toString();
  }

  /// Show Selected Date As String Format
  String showDate(DateTime? date) {
    DateTime displayDate = date ?? widget.task?.createdAtDate ?? DateTime.now();
    return DateFormat.yMMMEd().format(displayDate).toString();
  }

  /// If any task already exist app will update it otherwise the app will add a new task
  dynamic saveOrUpdateTask() {
    if (widget.task != null) {
      // Mode édition
      try {
        widget.task?.title = title ?? widget.taskControllerForTitle?.text;
        widget.task?.subtitle = subtitle ?? widget.taskControllerForSubtitle?.text;
        
        // Si des étapes existent, on utilise la date de l'étape la plus tardive
        if (steps.isNotEmpty) {
          widget.task?.steps = steps;
          widget.task?.updateTaskDateTime();
        } else {
          // Sinon on utilise les dates manuellement définies
          widget.task?.createdAtTime = time!;
          widget.task?.createdAtDate = date!;
        }
        
        widget.task?.updateCompletionStatus();
        widget.task?.save();
        Navigator.of(context).pop();
      } catch (error) {
        nothingEnterOnUpdateTaskMode(context);
      }
    } else {
      // Mode Ajout
      if (title != null && subtitle != null && title!.isNotEmpty && subtitle!.isNotEmpty) {
        var task = Task.create(
          title: title,
          createdAtTime: time ?? DateTime.now(),
          createdAtDate: date ?? DateTime.now(),
          subtitle: subtitle,
          steps: steps,
        );
        // La date/heure est automatiquement mise à jour dans Task.create si des étapes existent
        BaseWidget.of(context).dataStore.addTask(task: task);
        Navigator.of(context).pop();
      } else {
        emptyFieldsWarning(context);
      }
    }
  }

  /// Delete Selected Task
  dynamic deleteTask() {
    return widget.task?.delete();
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
        appBar: const MyAppBar(),
        body: SizedBox(
          width: double.infinity,
          height: double.infinity,
          child: Center(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  /// new / update Task Text
                  _buildTopText(textTheme),

                  /// Middle Two TextFileds, Time And Date Selection Box
                  _buildMiddleTextFieldsANDTimeAndDateSelection(context, textTheme),

                  /// All Bottom Buttons
                  _buildBottomButtons(context),
                ],
              ),
            ),
          ),
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
          if (!isNewTask)
            Expanded(
              child: OutlinedButton.icon(
                icon: const Icon(Icons.delete_outline, color: MyColors.primaryColor),
                label: const Text(MyString.deleteTask, style: TextStyle(color: MyColors.primaryColor)),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: const BorderSide(color: MyColors.primaryColor, width: 2),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: () {
                  deleteTask();
                  Navigator.pop(context);
                },
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
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Middle Two TextFileds And Time And Date Selection Box
  SizedBox _buildMiddleTextFieldsANDTimeAndDateSelection(
      BuildContext context, TextTheme textTheme) {
    return SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Title of TextFiled
          Padding(
            padding: const EdgeInsets.only(left: 30, top: 10),
            child: Text(MyString.titleOfTitleTextField, style: textTheme.headlineMedium),
          ),

          /// Title TextField
          Container(
            width: MediaQuery.of(context).size.width,
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: TextFormField(
              controller: widget.taskControllerForTitle,
              maxLines: 3,
              style: const TextStyle(color: Colors.black),
              decoration: modernInput("Ex: Terminer le rapport"),
              onFieldSubmitted: (value) {
                setState(() {
                  title = value;
                });
                FocusManager.instance.primaryFocus?.unfocus();
              },
              onChanged: (value) {
                title = value;
              },
            ),
          ),

          const SizedBox(height: 10),

          /// Note TextField
          Container(
            width: MediaQuery.of(context).size.width,
            margin: const EdgeInsets.symmetric(horizontal: 20),
            child: TextFormField(
              controller: widget.taskControllerForSubtitle,
              maxLines: 3,
              style: const TextStyle(color: Colors.black),
              decoration: modernInput(MyString.addNote, prefixIcon: const Icon(Icons.bookmark_border, color: Colors.grey)),
              onFieldSubmitted: (value) {
                setState(() {
                  subtitle = value;
                });
              },
              onChanged: (value) {
                subtitle = value;
              },
            ),
          ),

          const SizedBox(height: 20),

          /// Time Picker
          GestureDetector(
            onTap: () {
              DatePicker.showTimePicker(context,
                  showTitleActions: true,
                  showSecondsColumn: false,
                  onChanged: (_) {}, onConfirm: (selectedTime) {
                setState(() {
                  time = selectedTime;
                });
                FocusManager.instance.primaryFocus?.unfocus();
              }, currentTime: time ?? DateTime.now());
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.fromLTRB(20, 10, 20, 10),
              width: double.infinity,
              height: 55,
              decoration: BoxDecoration(
                color: Colors.white,
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
                    child: Icon(Icons.access_time, color: MyColors.primaryColor),
                  ),
                  const SizedBox(width: 10),
                  Text(MyString.timeString, style: textTheme.headlineSmall),
                  Expanded(child: Container()),
                  Container(
                    margin: const EdgeInsets.only(right: 10),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: MyColors.primaryColor.withOpacity(0.1),
                    ),
                    child: Text(
                      showTime(time),
                      style: textTheme.titleSmall?.copyWith(color: MyColors.primaryColor),
                    ),
                  )
                ],
              ),
            ),
          ),

          /// Date Picker
          GestureDetector(
            onTap: () {
              DatePicker.showDatePicker(context,
                  showTitleActions: true,
                  minTime: DateTime.now(),
                  maxTime: DateTime(2030, 12, 31),
                  onChanged: (_) {}, onConfirm: (selectedDate) {
                setState(() {
                  date = selectedDate;
                });
                FocusManager.instance.primaryFocus?.unfocus();
              }, currentTime: date ?? DateTime.now());
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.fromLTRB(20, 10, 20, 20),
              width: double.infinity,
              height: 55,
              decoration: BoxDecoration(
                color: Colors.white,
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
                    child: Icon(Icons.calendar_today, color: MyColors.primaryColor),
                  ),
                  const SizedBox(width: 10),
                  Text(MyString.dateString, style: textTheme.headlineSmall),
                  Expanded(child: Container()),
                  Container(
                    margin: const EdgeInsets.only(right: 10),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: MyColors.primaryColor.withOpacity(0.1),
                    ),
                    child: Text(
                      showDate(date),
                      style: textTheme.titleSmall?.copyWith(color: MyColors.primaryColor),
                    ),
                  )
                ],
              ),
            ),
          ),

          /// Section Étapes
          _buildStepsSection(textTheme),
        ],
      ),
    );
  }

  /// Section pour gérer les étapes de la tâche
  Widget _buildStepsSection(TextTheme textTheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 30, top: 10),
          child: Row(
            children: [
              Text("Étapes de réalisation", style: textTheme.headlineMedium),
              const SizedBox(width: 10),
              if (steps.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: MyColors.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    "${steps.where((s) => s.isCompleted).length}/${steps.length}",
                    style: textTheme.bodySmall?.copyWith(color: MyColors.primaryColor),
                  ),
                ),
            ],
          ),
        ),

        /// Liste des étapes
        if (steps.isNotEmpty)
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(14),
            ),
            child: ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: steps.length,
              itemBuilder: (context, index) {
                final step = steps[index];
                return InkWell(
                  onTap: () => _editStepDateTime(step, index),
                  child: Container(
                    decoration: BoxDecoration(
                      border: index > 0 ? Border(top: BorderSide(color: Colors.grey.shade200)) : null,
                    ),
                    child: ListTile(
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
                            
                            // Vérifier si toutes les étapes sont complétées
                            if (widget.task != null) {
                              widget.task!.updateCompletionStatus();
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
                        ),
                      ),
                      subtitle: step.scheduledStartDate != null
                          ? Text(
                              "Échéance: ${DateFormat('dd/MM/yyyy').format(step.scheduledStartDate!)} ${step.scheduledStartTime != null ? DateFormat('HH:mm').format(step.scheduledStartTime!) : ''}",
                              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                            )
                          : Text(
                              "Appuyez pour définir une échéance",
                              style: TextStyle(fontSize: 12, color: Colors.grey.shade500, fontStyle: FontStyle.italic),
                            ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(
                              step.scheduledStartDate != null ? Icons.edit_calendar : Icons.calendar_today,
                              color: MyColors.primaryColor,
                              size: 20,
                            ),
                            onPressed: () => _editStepDateTime(step, index),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                            onPressed: () {
                              setState(() {
                                steps.removeAt(index);
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                );
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
                  decoration: modernInput("Nouvelle étape", prefixIcon: const Icon(Icons.format_list_numbered, color: Colors.grey)),
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
                      steps.add(TaskStep.create(title: _stepController.text.trim()));
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

  /// Éditer la date et l'heure d'une étape
  void _editStepDateTime(TaskStep step, int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Planifier l'étape"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.calendar_today, color: MyColors.primaryColor),
              title: const Text("Date d'échéance"),
              subtitle: Text(
                step.scheduledStartDate != null
                    ? DateFormat('dd/MM/yyyy').format(step.scheduledStartDate!)
                    : "Non définie",
              ),
              onTap: () {
                Navigator.pop(context);
                DatePicker.showDatePicker(
                  context,
                  showTitleActions: true,
                  minTime: DateTime.now(),
                  maxTime: DateTime(2030, 12, 31),
                  currentTime: step.scheduledStartDate ?? DateTime.now(),
                  onConfirm: (selectedDate) {
                    setState(() {
                      step.scheduledStartDate = selectedDate;
                    });
                  },
                );
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.access_time, color: MyColors.primaryColor),
              title: const Text("Heure d'échéance"),
              subtitle: Text(
                step.scheduledStartTime != null
                    ? DateFormat('HH:mm').format(step.scheduledStartTime!)
                    : "Non définie",
              ),
              onTap: () {
                Navigator.pop(context);
                DatePicker.showTimePicker(
                  context,
                  showTitleActions: true,
                  showSecondsColumn: false,
                  currentTime: step.scheduledStartTime ?? DateTime.now(),
                  onConfirm: (selectedTime) {
                    setState(() {
                      step.scheduledStartTime = selectedTime;
                    });
                  },
                );
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Fermer"),
          ),
        ],
      ),
    );
  }

  /// new / update Task Text
  Widget _buildTopText(TextTheme textTheme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
      child: Column(
        children: [
          Text(
            isNewTask ? MyString.addNewTask : MyString.updateCurrentTask,
            style: textTheme.titleLarge,
          ),
          
          // Barre de progression si c'est une tâche existante avec des étapes
          if (!isNewTask && widget.task != null && widget.task!.steps.isNotEmpty) ...[
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
                        "Progression",
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "${widget.task!.completionPercentage.toInt()}%",
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
                      value: widget.task!.completionPercentage / 100,
                      minHeight: 8,
                      backgroundColor: Colors.grey.shade300,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        widget.task!.isCompleted ? Colors.green : MyColors.primaryColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "${widget.task!.steps.where((s) => s.isCompleted).length}/${widget.task!.steps.length} étapes complétées",
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
}

/// AppBar moderne
class MyAppBar extends StatelessWidget implements PreferredSizeWidget {
  const MyAppBar({Key? key}) : super(key: key);

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