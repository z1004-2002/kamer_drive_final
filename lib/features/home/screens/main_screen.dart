import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kamer_drive_final/core/constants/colors.dart';
import 'package:kamer_drive_final/features/profile/screens/profile_screen.dart';
import 'package:kamer_drive_final/features/search/screens/search_screen.dart';
import 'package:kamer_drive_final/models/user_model.dart';
import 'home_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _navIndex = 0;

  // Un faux utilisateur pour le MVP (A remplacer par l'utilisateur connecté via Provider)
  final user = UserModel(
    id: "1",
    firstName: 'Francis',
    lastName: '2G',
    email: 'f2g@kamerdrive.com',
    phone: '690000000',
    avatarUrl: 'https://picsum.photos/200',
    address: '',
    idDocuments: {},
    reviews: [],
    isFirstConnection: false,
    hasCompletedProfiling: true,
    intents: [],
    ownsVehicle: false,
    createdAt: DateTime.now(),
  );

  // Fonction pour changer d'onglet
  void navigateToTab(int index) {
    // Si on clique sur l'élément du milieu (index 2), on ne fait rien
    if (index == 2) return;

    setState(() {
      _navIndex = index;
    });
  }

  // La liste des pages pour le IndexedStack
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      HomeScreen(onNavigateToSearch: () => navigateToTab(1)),
      const SearchScreen(),
      const SizedBox.shrink(), // Dummy pour l'index 2 (le bouton +)
      const Center(child: Text("Historique")), // const HistoryScreen(),
      ProfileScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,

      // --- CORPS DE LA PAGE ---
      // IndexedStack permet de garder l'état de la page (ex: position du scroll)
      body: IndexedStack(index: _navIndex, children: _pages),

      // --- BOUTON CENTRAL (FAB) ---
      floatingActionButton: SizedBox(
        height: 65,
        width: 65,
        child: FloatingActionButton(
          backgroundColor: kPrimaryColor,
          elevation: 5,
          shape: const CircleBorder(), // Parfaitement rond
          onPressed: () {
            // Navigation vers l'ajout de véhicule (Vente/Location)
            context.push('/my_listings');
          },
          child: const Icon(Icons.add, size: 35, color: Colors.white),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      // --- BARRE DE NAVIGATION ---
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _navIndex,
        onTap: navigateToTab,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: kPrimaryColor,
        unselectedItemColor: Colors.grey, // Remplacer par kTextGrey si tu l'as
        selectedFontSize: 12,
        unselectedFontSize: 12,
        showUnselectedLabels: true,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_filled),
            label: "Accueil",
          ),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: "Recherche"),

          // --- ELEMENT INVISIBLE (DUMMY) ---
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
