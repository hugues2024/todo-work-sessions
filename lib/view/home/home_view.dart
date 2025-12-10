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
import '../details/details_view.dart'; 
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
          /// Top Section Of Home page : Header modernisé avec carte
          FadeInDown(
            duration: const Duration(milliseconds: 800),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: MyColors.primaryGradientColor,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: MyColors.primaryColor.withOpacity(0.3),
                    blurRadius: 15,
                    spreadRadius: -5,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                children: [
                  /// Grand cercle de progression
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 70,
                        height: 70,
                        child: CircularProgressIndicator(
                          valueColor: const AlwaysStoppedAnimation(Colors.white),
                          backgroundColor: Colors.white.withOpacity(0.3),
                          strokeWidth: 6,
                          value: checkDoneTask(tasks) / valueOfTheIndicator(tasks),
                        ),
                      ),
                      Text(
                        '${((checkDoneTask(tasks) / valueOfTheIndicator(tasks)) * 100).toInt()}%',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 20),

                  /// Textes avec meilleure hiérarchie
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          MyString.mainTitle,
                          style: textTheme.displayLarge?.copyWith(
                            color: Colors.white,
                            fontSize: 24,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          "${checkDoneTask(tasks)} sur ${tasks.length} ${MyString.taskStrnig.toLowerCase()}${tasks.length > 1 ? 's' : ''}",
                          style: textTheme.titleMedium?.copyWith(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  /// Badge de progression
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle, color: Colors.white, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          '${checkDoneTask(tasks)}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          /// Bottom ListView : Tasks
          Expanded(
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
            decoration: BoxDecoration(
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
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 3),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 10,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: CircleAvatar(
                          radius: 50,
                          backgroundImage: AssetImage(displayImage),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        displayName,
                        style: textTheme.displayMedium?.copyWith(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        displayProfession,
                        style: textTheme.titleMedium?.copyWith(
                          color: Colors.white.withOpacity(0.85),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                
                Container(
                  margin: const EdgeInsets.symmetric(
                    vertical: 30,
                    horizontal: 16,
                  ),
                  width: double.infinity,
                  height: 300,
                  child: ListView.builder(
                      itemCount: icons.length,
                      physics: const NeverScrollableScrollPhysics(),
                      itemBuilder: (ctx, i) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () => navigateTo(context, i),
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: ListTile(
                                    dense: false,
                                    leading: Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.25),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Icon(
                                        icons[i],
                                        color: Colors.white,
                                        size: 24,
                                      ),
                                    ),
                                    title: Text(
                                      texts[i],
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 17,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    trailing: const Icon(
                                      Icons.arrow_forward_ios,
                                      color: Colors.white,
                                      size: 18,
                                    )),
                              ),
                            ),
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

/// Floating Action Button avec animation
class FAB extends StatelessWidget {
  const FAB({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Bounce(
      duration: const Duration(milliseconds: 1500),
      infinite: true,
      child: GestureDetector(
        onTap: () {
          Navigator.of(context).push(
            CupertinoPageRoute(
              builder: (context) => TaskView(
                taskControllerForSubtitle: null,
                taskControllerForTitle: null,
                task: null,
              ),
            ),
          );
        },
        child: Container(
          width: 65,
          height: 65,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: MyColors.primaryGradientColor,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: MyColors.primaryColor.withOpacity(0.4),
                blurRadius: 15,
                spreadRadius: 2,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: const Center(
            child: Icon(
              Icons.add,
              color: Colors.white,
              size: 32,
            ),
          ),
        ),
      ),
    );
  }
}