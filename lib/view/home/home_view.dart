// lib/view/home/home_view.dart

// ignore_for_file: must_be_immutable, use_build_context_synchronously

import 'package:animate_do/animate_do.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter_slider_drawer/flutter_slider_drawer.dart';

///
import '../../main.dart';
import '../../models/task.dart';
import '../../models/user_profile.dart'; 
import '../../utils/colors.dart';
import '../../utils/constanst.dart';
import '../../utils/strings.dart';
import '../../view/home/widgets/task_widget.dart';
import '../../view/tasks/task_view.dart';
import '../../view/profile/profile_view.dart'; 
import '../../view/settings/settings_view.dart'; 
import '../../view/details/details_view.dart'; 
import '../../view/work_session/work_session_view.dart'; 


class HomeView extends StatefulWidget {
  const HomeView({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _HomeViewState createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  GlobalKey<SliderDrawerState> dKey = GlobalKey<SliderDrawerState>();

  /// Checking Done Tasks
  int checkDoneTask(List<Task> task) {
    int i = 0;
    for (Task doneTasks in task) {
      if (doneTasks.isCompleted) {
        i++;
      }
    }
    return i;
  }

  /// Checking The Value Of the Circle Indicator
  dynamic valueOfTheIndicator(List<Task> task) {
    if (task.isNotEmpty) {
      return task.length;
    } else {
      return 3;
    }
  }

  @override
  Widget build(BuildContext context) {
    final base = BaseWidget.of(context);
    var textTheme = Theme.of(context).textTheme;

    return ValueListenableBuilder(
        valueListenable: base.dataStore.listenToTask(),
        builder: (ctx, Box<Task> box, Widget? child) {
          var tasks = box.values.toList();

          /// Sort Task List
          tasks.sort(((a, b) => a.createdAtDate.compareTo(b.createdAtDate)));

          return Scaffold(
            backgroundColor: Colors.white,

            /// Floating Action Button
            floatingActionButton: const FAB(),

            /// Body
            body: SliderDrawer(
              isDraggable: false,
              key: dKey,
              animationDuration: 1000,

              /// My AppBar
              appBar: MyAppBar(
                drawerKey: dKey,
              ),

              /// My Drawer Slider
              slider: MySlider(drawerKey: dKey), 

              /// Main Body
              child: _buildBody(
                tasks,
                base,
                textTheme,
              ),
            ),
          );
        });
  }

  /// Main Body
  SizedBox _buildBody(
    List<Task> tasks,
    BaseWidget base,
    TextTheme textTheme,
  ) {
    return SizedBox(
      width: double.infinity,
      height: double.infinity,
      child: Column(
        children: [
          /// Top Section Of Home page : Text, Progrss Indicator
          Container(
            margin: const EdgeInsets.fromLTRB(55, 0, 0, 0),
            width: double.infinity,
            height: 100,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                /// CircularProgressIndicator
                SizedBox(
                  width: 25,
                  height: 25,
                  child: CircularProgressIndicator(
                    valueColor: const AlwaysStoppedAnimation(MyColors.primaryColor),
                    backgroundColor: Colors.grey,
                    value: checkDoneTask(tasks) / valueOfTheIndicator(tasks),
                  ),
                ),
                const SizedBox(
                  width: 25,
                ),

                /// Texts
                Column(
  mainAxisAlignment: MainAxisAlignment.center,
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    
    Text(MyString.mainTitle, style: textTheme.displayLarge),
    const SizedBox(
      height: 3,
    ),
    Text("${checkDoneTask(tasks)} sur ${tasks.length} ${MyString.taskStrnig.toLowerCase()}${tasks.length > 1 ? 's' : ''}", // Texte mis à jour pour être précis en français
        style: textTheme.titleMedium),
  ],
)
              ],
            ),
          ),

          /// Divider
          const Padding(
            padding: EdgeInsets.only(top: 10),
            child: Divider(
              thickness: 2,
              indent: 100,
            ),
          ),

          /// Bottom ListView : Tasks
          SizedBox(
            width: double.infinity,
            // Hauteur ajustée pour être moins rigide sur différents écrans
            height: MediaQuery.of(context).size.height * 0.65, 
            child: tasks.isNotEmpty
                ? ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    itemCount: tasks.length,
                    itemBuilder: (BuildContext context, int index) {
                      var task = tasks[index];

                      return Dismissible(
                        direction: DismissDirection.horizontal,
                        background: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.delete_outline,
                              color: Colors.grey,
                            ),
                            const SizedBox(
                              width: 8,
                            ),
                            Text(MyString.deletedTask,
                                style: const TextStyle(
                                  color: Colors.grey,
                                ))
                          ],
                        ),
                        onDismissed: (direction) {
                          base.dataStore.deleteTask(task: task);
                        },
                        key: Key(task.id),
                        child: TaskWidget(
                          task: tasks[index],
                        ),
                      );
                    },
                  )

                /// if All Tasks Done Show this Widgets
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      /// Lottie
                      FadeIn(
                        child: SizedBox(
                          width: 200,
                          height: 200,
                          child: Lottie.asset(
                            lottieURL,
                            animate: tasks.isNotEmpty ? false : true,
                          ),
                        ),
                      ),

                      /// Bottom Texts
                      FadeInUp(
                        from: 30,
                        child: const Text(MyString.doneAllTask),
                      ),
                    ],
                  ),
          )
        ],
      ),
    );
  }
}

/// My Drawer Slider (CORRIGÉ ET MIS À JOUR)
class MySlider extends StatelessWidget {
  MySlider({
    Key? key,
    required this.drawerKey, 
  }) : super(key: key);
  
  final GlobalKey<SliderDrawerState> drawerKey; 

  /// Icons (5 ÉLÉMENTS)
  final List<IconData> icons = const [ 
    CupertinoIcons.house_fill, // Accueil
    CupertinoIcons.clock_fill, // Session de travail
    CupertinoIcons.person_fill, // Profil
    CupertinoIcons.settings, // Paramètres
    CupertinoIcons.info_circle_fill, // Détails
  ];

  /// Texts (5 ÉLÉMENTS)
  final List<String> texts = const [
    "Accueil",
    "Session de travail",
    "Profil",
    "Paramètres",
    "Détails",
  ];

  // Map des vues vers les pages (5 ÉLÉMENTS)
  final List<Widget> destinations = const [
    HomeView(), 
    WorkSessionView(),
    ProfileView(),
    SettingsView(),
    DetailsView(),
  ];

  /// Fonction de Navigation
  void navigateTo(BuildContext context, int index) {
    // 1. Fermer le tiroir
    drawerKey.currentState!.closeSlider();

    // 2. Naviguer vers la nouvelle destination
    // Si c'est 'Accueil' (index 0), on remplace juste la page actuelle par elle-même,
    // ou plus simplement, on ne fait rien pour éviter des navigations inutiles.
    if (index != 0) {
      // Utilisez push pour ajouter la nouvelle page à la pile
      Navigator.of(context).push(
        CupertinoPageRoute(builder: (context) => destinations[index]),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    var textTheme = Theme.of(context).textTheme;

    // Utilisation de ValueListenableBuilder pour écouter les changements dans la Hive Box du profil
    return ValueListenableBuilder<Box<UserProfile>>(
        valueListenable: BaseWidget.of(context).dataStore.listenToUserProfile(),
        builder: (context, box, child) {
          // Utilisation de get(key, defaultValue: null) ou getAt(0) est OK
          // On suppose que le profil est stocké à l'index 0 si la boîte n'est pas vide.
          // 👈 CORRECTION CLÉ ICI : ON VÉRIFIE SI LA BOX EST VIDE AVANT D'ACCÉDER À L'INDEX 0
          final UserProfile? profile = box.isNotEmpty ? box.getAt(0) : null;

          final bool profileExists = profile != null && profile.name != null && profile.name!.isNotEmpty;
          
          final String displayName = profileExists 
              ? profile.name! 
              : "Ajouter votre Nom !";
          
          final String displayProfession = profileExists 
              ? profile.profession ?? "Profession non définie"
              : "Cliquez ici pour compléter votre profil";
          
          // Utilisez l'image de profil si elle est définie, sinon l'image par défaut.
          // Note : Cette logique suppose que l'AssetImage fonctionne.
          final String displayImage = profile?.imagePath ?? 'assets/img/main.png';

          return Container(
            padding: const EdgeInsets.symmetric(vertical: 90),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                  colors: MyColors.primaryGradientColor,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight),
            ),
            child: Column(
              children: [
                GestureDetector(
                  onTap: () => navigateTo(context, 2), // 2 = Index de 'Profil'
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundImage: AssetImage(displayImage),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        displayName,
                        style: textTheme.displayMedium?.copyWith(color: Colors.white), // Couleur blanche ajoutée pour lisibilité sur dégradé
                      ),
                      Text(
                        displayProfession,
                        style: textTheme.titleMedium?.copyWith(color: Colors.white70), // Couleur blanche subtile
                      ),
                    ],
                  ),
                ),
                
                Container(
                  margin: const EdgeInsets.symmetric(
                    vertical: 30,
                    horizontal: 10,
                  ),
                  width: double.infinity,
                  height: 300,
                  child: ListView.builder(
                      itemCount: icons.length, // L'itemCount est maintenant 5, ce qui correspond à toutes les listes
                      physics: const NeverScrollableScrollPhysics(),
                      itemBuilder: (ctx, i) {
                        return InkWell(
                          onTap: () => navigateTo(context, i), // Navigue vers l'index correspondant
                          child: Container(
                            margin: const EdgeInsets.all(5),
                            child: ListTile(
                                leading: Icon(
                                  icons[i],
                                  color: Colors.white,
                                  size: 30,
                                ),
                                title: Text(
                                  texts[i],
                                  style: const TextStyle(
                                    color: Colors.white,
                                  ),
                                )),
                          ),
                        );
                      }),
                )
              ],
            ),
          );
        });
  }
}

/// My App Bar
class MyAppBar extends StatefulWidget implements PreferredSizeWidget { 
  MyAppBar({Key? key, 
    required this.drawerKey,
  }) : super(key: key);
  
  final GlobalKey<SliderDrawerState> drawerKey; 

  @override
  State<MyAppBar> createState() => _MyAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(100);
}

class _MyAppBarState extends State<MyAppBar>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;
  bool isDrawerOpen = false;

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  /// toggle for drawer and icon aniamtion
  void toggle() {
    setState(() {
      isDrawerOpen = !isDrawerOpen;
      if (isDrawerOpen) {
        controller.forward();
        widget.drawerKey.currentState!.openSlider();
      } else {
        controller.reverse();
        widget.drawerKey.currentState!.closeSlider();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    var base = BaseWidget.of(context).dataStore.box;
    return SizedBox(
      width: double.infinity,
      height: 132,
      child: Padding(
        padding: const EdgeInsets.only(top: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            /// Animated Icon - Menu & Close
            Padding(
              padding: const EdgeInsets.only(left: 20),
              child: IconButton(
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  icon: AnimatedIcon(
                    icon: AnimatedIcons.menu_close,
                    progress: controller,
                    size: 40,
                  ),
                  onPressed: toggle),
            ),

            /// Delete Icon
            Padding(
              padding: const EdgeInsets.only(right: 20),
              child: GestureDetector(
                onTap: () {
                  base.isEmpty
                      ? warningNoTask(context)
                      : deleteAllTask(context);
                },
                child: const Icon(
                  CupertinoIcons.trash,
                  size: 40,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Floating Action Button
class FAB extends StatelessWidget {
  const FAB({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          CupertinoPageRoute(
            builder: (context) => TaskView( // DOIT ÊTRE IMPORTÉ DANS CE FICHIER
              taskControllerForSubtitle: null,
              taskControllerForTitle: null,
              task: null,
            ),
          ),
        );
      },
      child: Material(
        borderRadius: BorderRadius.circular(15),
        elevation: 10,
        child: Container(
          width: 70,
          height: 70,
          decoration: BoxDecoration(
            color: MyColors.primaryColor,
            borderRadius: BorderRadius.circular(15),
          ),
          child: const Center(
              child: Icon(
            Icons.add,
            color: Colors.white,
          )),
        ),
      ),
    );
  }
}