//lib/utils/strings.dart
class MyString {
  static const String mainTitle = "Mes Tâches";
  static const String deletedTask = "Cette tâche a été supprimée";
  static const String doneAllTask = "Vous avez terminé toutes les tâches !👌";
  static const String addNewTask = "Ajouter une nouvelle ";
  static const String updateCurrentTask = "Modifier tâche";
  static const String taskStrnig = "Tâche";
  static const String titleOfTitleTextField = "Qu'avez-vous prévu aujourd'hui 😇?";
  static const String addNote = 'Ajouter une note';
  static const String timeString = "Heure";
  static const String dateString = "Date";
  static const String deleteTask = "Supprimer la Tâche";
  static const String addTaskString = "Ajouter la Tâche";
  static const String updateTaskString = "Modifier la Tâche";
  static const String oopsMsg = "Oups !";
  static const String areYouSure = "Êtes-vous sûr(e) ?";
  // --- NOUVELLES STRINGS POUR WORK SESSION ---
  static const String addNewSession = "Nouvelle ";
  static const String updateCurrentSession = "Mise à jour ";
  static const String addSessionString = "Ajouter Session";
  static const String updateSessionString = "Modifier Session";
  static const String description = "Description / Objectifs"; //
// --- NOUVELLES STRINGS POUR LE PROFIL ---
  static const String addNewProfile = "Nouveau Profil";
  static const String updateProfile = "Modifier Profil";
  static const String profile = "Profil";
  static const String settings = "Paramètres";
  // NOUVELLES STRINGS POUR WORK_SESSION_VIEW
  static const String sessionsTitle = "Historique des Sessions";
  static const String noSessionsYet = "Aucune session de travail enregistrée.\nDémarrez une nouvelle session pour commencer le suivi !";
  static const String deletedSession = "Session supprimée";
  // NOUVELLES STRINGS POUR SESSION_CREATION_VIEW
  static const String newSessionTitle = "Nouvelle Session";
  static const String createSessionBtn = "CRÉER";
  static const String sessionTitle = "Titre de la Session";
  static const String sessionDescription = "Description / Objectif";
  static const String durationSettings = "Paramètres de Durée";
  static const String scheduledStart = "Début Planifié";
  static const String chooseTime = "Choisir la date et l'heure";
  static const String startSessionAndSave = "DÉMARRER";
  // NOUVELLES STRINGS POUR TASK_VIEW
  static const String addNoteHint = "Ajouter des notes, idées, ou contexte...";
  static const String stepsTitle = "Étapes de réalisation";

  static const String allTasks = "Toutes les tâches";
  
  // --- LIBELLÉS AUTHENTIFICATION / PROFIL ---
  static const String loginTitle = "Se Connecter";
  static const String signupTitle = "S'Inscrire";
  static const String email = "Adresse Email";
  static const String password = "Mot de Passe";
  
  // --- MESSAGES D'ERREUR ---
  static const String emptyFields = "Veuillez remplir tous les champs obligatoires.";
  static const String authError = "Erreur d'authentification. Veuillez vérifier vos informations.";
  static const String loginFailed = "Connexion échouée : Email ou mot de passe incorrect.";
  static const String signupFailed = "Inscription échouée : Cet email est déjà utilisé.";

  // NOUVEAUX STRINGS POUR TASK_VIEW
  static const String startDate = 'Date de début';
  static const String endDate = 'Date de fin';
  static const String successMessage = 'Tâche enregistrée avec succès !';
  static const String editTab = 'Modifier';
  static const String sessionTab = 'Chronomètre';
  static const String startSession = 'Démarrer la Session';
  static const String stopSession = 'Arrêter la Session';
  static const String viewTask = 'Voir la tâche';
  
  // NOUVEAUX STRINGS POUR HOME_VIEW
  static const String tasksTab = 'Tâches';
  static const String timeMenu = 'Horloge';
  static const String calendarMenu = 'Calendrier';

  // NOUVEAUX STRINGS POUR TASK_VIEW
  static const String taskTitleHint = "Ex: Préparer la présentation pour 14h"; // Nouvelle suggestion de hint

  // ===================================
  // NOUVELLES VARIABLES POUR LE CHRONOMÈTRE
  // ===================================
  
  // Utilisé dans TaskSessionSection.dart pour les boutons
  static const String continueSession = 'Continuer';
  static const String resetTask = 'Réinitialiser'; // Utilisé comme alternative à Stopper si le temps est enregistré mais en pause

  static const String timerTitle = 'Minuteur de Tâche'; // NOUVEAU
}