// lib/view/tasks/task_view.dart

// ignore_for_file: must_be_immutable, use_build_context_synchronously

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../../../main.dart';
import '../../../models/task.dart';
import '../../../utils/colors.dart';
import '../../../utils/strings.dart';
import 'widgets/task_form_section.dart';
import 'widgets/timer_section.dart'; // NOUVEAU

class TaskView extends StatefulWidget {
  final Task? task; // Tâche passée pour la modification (si non null)

  const TaskView({Key? key, this.task}) : super(key: key);

  @override
  State<TaskView> createState() => _TaskViewState();
}

class _TaskViewState extends State<TaskView> with SingleTickerProviderStateMixin {
  final _titleController = TextEditingController();
  final _noteController = TextEditingController(); 
  
  int _currentIndex = 0; // 0: Formulaire, 1: Minuteur

  DateTime? _selectedStartDate; 
  DateTime? _selectedEndDate;   
  
  bool get isUpdateMode => widget.task != null; 
  bool get showTimerView => _currentIndex == 1; 

  @override
  void initState() {
    super.initState();
    
    if (isUpdateMode) {
      _titleController.text = widget.task!.title;
      _noteController.text = widget.task!.subtitle;
      
      _selectedStartDate = widget.task!.startDate; 
      _selectedEndDate = widget.task!.endDate;
    } 
  }

  @override
  void dispose() {
    _titleController.dispose();
    _noteController.dispose();
    super.dispose();
  }
  
  void _updateDateTime(DateTime? start, DateTime? end) {
    setState(() {
      _selectedStartDate = start;
      _selectedEndDate = end;
    });
  }

  Future<void> _saveTask(BuildContext context) async {
    final base = BaseWidget.of(context).dataStore;
    final title = _titleController.text.trim();
    final subtitle = _noteController.text.trim();

    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(MyString.emptyFields),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }
    
    final Task newTask;
    
    if (isUpdateMode) {
      widget.task!.title = title;
      widget.task!.subtitle = subtitle;
      widget.task!.startDate = _selectedStartDate; 
      widget.task!.endDate = _selectedEndDate;
      
      await base.updateTask(task: widget.task!);
      newTask = widget.task!;

    } else {
      newTask = Task.create(
        title: title,
        subtitle: subtitle, 
        startDate: _selectedStartDate, 
        endDate: _selectedEndDate, 
      );
      await base.addTask(task: newTask);
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(MyString.successMessage),
        backgroundColor: MyColors.primaryColor,
        duration: const Duration(seconds: 2),
      ),
    );

    Navigator.of(context).pop(); 
  }

  Widget _buildBody() {
    if (isUpdateMode && _currentIndex == 1) {
      return TimerSection(task: widget.task!);
    } else {
      return TaskFormSection(
        task: widget.task,
        titleController: _titleController,
        noteController: _noteController,
        onDateTimeChanged: _updateDateTime,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    
    final String titleText = isUpdateMode && _currentIndex == 0
        ? MyString.updateCurrentTask 
        : isUpdateMode && _currentIndex == 1
            ? MyString.timerTitle 
            : MyString.addNewTask;
    
    final String buttonText = isUpdateMode ? MyString.updateTaskString : MyString.addTaskString;

    // Le texte à afficher à côté de la flèche de retour
    final Widget appBarTitleContent = isUpdateMode
        ? Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Texte "Modifier tâche" à côté de la flèche (partie du titre)
              Text(
                titleText, 
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: MyColors.primaryColor,
                  // Réduit la taille pour donner plus d'espace au leading
                  fontSize: 18, 
                ),
              ),
            ],
          )
        : Text(
            titleText, 
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: MyColors.primaryColor)
          );

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: !isUpdateMode, 
        
        // 🎯 LEADING OPTIMISÉ (Utilise l'IconButton par défaut pour la flèche de retour)
        leading: isUpdateMode
            ? IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios,
                  color: MyColors.primaryColor,
                ),
                onPressed: () => Navigator.of(context).pop(),
              )
            : null,
        
        // 🎯 TITRE DÉPLACÉ À GAUCHE POUR ACCUEILLIR LE TEXTE "Modifier tâche"
        title: appBarTitleContent,
        
        // Réduit l'espacement entre le leading et le title
        titleSpacing: isUpdateMode ? 0 : NavigationToolbar.kMiddleSpacing, 

        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        
        actions: isUpdateMode
            ? [
                // 1. Icône Modifier (Formulaire)
                Tooltip(
                  message: MyString.editTab,
                  child: IconButton(
                    icon: Icon(
                      CupertinoIcons.square_list,
                      color: _currentIndex == 0 ? MyColors.primaryColor : Colors.grey,
                    ),
                    onPressed: () => setState(() => _currentIndex = 0),
                  ),
                ),
                
                // 2. Icône Minuteur
                Tooltip(
                  message: MyString.timerTitle,
                  child: IconButton(
                    icon: Icon(
                      CupertinoIcons.timer,
                      color: _currentIndex == 1 ? MyColors.primaryColor : Colors.grey,
                    ),
                    onPressed: () => setState(() => _currentIndex = 1),
                  ),
                ),
                const SizedBox(width: 8),
              ]
            : null,
      ),
      
      body: _buildBody(),
      
      floatingActionButton: !showTimerView ? Padding(
        padding: const EdgeInsets.only(bottom: 20, left: 30),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => _saveTask(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: MyColors.primaryColor,
              padding: const EdgeInsets.symmetric(vertical: 18),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
            child: Text(
              buttonText,
              style: const TextStyle(
                color: Colors.white, 
                fontSize: 18, 
                fontWeight: FontWeight.bold
              ),
            ),
          ),
        ),
      ) : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}