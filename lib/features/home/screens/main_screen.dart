import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kamer_drive_final/core/constants/colors.dart';
import 'package:kamer_drive_final/features/notifications/providers/notification_provider.dart';
import 'package:provider/provider.dart';

class MainScreen extends StatefulWidget {
  // GoRouter va nous passer cet objet qui contient l'index actuel et le body
  final StatefulNavigationShell navigationShell;

  const MainScreen({Key? key, required this.navigationShell}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationProvider>().initPushNotifications();
    });
  }

  void _onTap(BuildContext context, int index) {
    // On ignore l'index 2 car c'est l'emplacement visuel du bouton +
    if (index == 2) return;

    // GoRouter gère le changement d'onglet !
    // initialLocation: true permet de remonter en haut de la page si on clique sur l'onglet déjà actif
    widget.navigationShell.goBranch(
      index,
      initialLocation: index == widget.navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,

      // --- CORPS DE LA PAGE ---
      // GoRouter injecte automatiquement la bonne page ici (avec son propre IndexedStack interne)
      body: widget.navigationShell,

      // --- BOUTON CENTRAL (FAB) ---
      floatingActionButton: SizedBox(
        height: 65,
        width: 65,
        child: FloatingActionButton(
          backgroundColor: kPrimaryColor,
          elevation: 5,
          shape: const CircleBorder(),
          onPressed: () async {
            final result = await context.push('/my_listings');
            if (result == 'goToProfile') {
              // Si on doit aller au profil, on demande à GoRouter d'ouvrir la branche 4 !
              widget.navigationShell.goBranch(4);
            }
          },
          child: const Icon(Icons.add, size: 35, color: Colors.white),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      // --- BARRE DE NAVIGATION ---
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: widget.navigationShell.currentIndex,
        onTap: (index) => _onTap(context, index),
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: kPrimaryColor,
        unselectedItemColor: Colors.grey,
        selectedFontSize: 12,
        unselectedFontSize: 12,
        showUnselectedLabels: true,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_filled),
            label: "Accueil",
          ),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: "Recherche"),
          BottomNavigationBarItem(
            icon: Icon(Icons.add, color: Colors.transparent),
            label: "",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: "Historique",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: "Profil",
          ),
        ],
      ),
    );
  }
}
