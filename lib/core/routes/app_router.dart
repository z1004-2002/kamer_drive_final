import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// --- IMPORTS DES SCREENS ---
import 'package:kamer_drive_final/features/auth/screens/auth_screen.dart';
import 'package:kamer_drive_final/features/booking/screens/rental_booking_screen.dart';
import 'package:kamer_drive_final/features/booking/screens/sale_booking_screen.dart';
import 'package:kamer_drive_final/features/home/screens/main_screen.dart';
import 'package:kamer_drive_final/features/home/screens/home_screen.dart'; // Ajouté
import 'package:kamer_drive_final/features/search/screens/search_screen.dart'; // Ajouté
import 'package:kamer_drive_final/features/history/screens/history_screen.dart'; // Ajouté
import 'package:kamer_drive_final/features/profile/screens/profile_screen.dart'; // Ajouté
import 'package:kamer_drive_final/features/my_listings/screens/add_vehicle_screen.dart';
import 'package:kamer_drive_final/features/my_listings/screens/edit_vehicle_screen.dart';
import 'package:kamer_drive_final/features/my_listings/screens/my_listings_screen.dart';
import 'package:kamer_drive_final/features/notifications/screens/notification_screen.dart';
import 'package:kamer_drive_final/features/onboarding/screens/profiling_screen.dart';
import 'package:kamer_drive_final/features/profile/screens/document_upload_screen.dart';
import 'package:kamer_drive_final/features/profile/screens/edit_profile_screen.dart';
import 'package:kamer_drive_final/features/profile/screens/help_support_screen.dart';
import 'package:kamer_drive_final/features/profile/screens/privacy_policy_screen.dart';
import 'package:kamer_drive_final/features/onboarding/screens/splash_screen.dart';
import 'package:kamer_drive_final/features/onboarding/screens/onboarding_screen.dart';
import 'package:kamer_drive_final/models/vehicle_model.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/',
    errorBuilder: (context, state) =>
        const Scaffold(body: Center(child: Text("Page introuvable"))),

    routes: [
      // 1. Routes classiques (Plein écran)
      GoRoute(
        path: '/',
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        name: 'onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/auth',
        name: 'auth',
        builder: (context, state) => const AuthScreen(),
      ),
      GoRoute(
        path: '/profiling',
        name: 'profiling',
        builder: (context, state) => const ProfilingScreen(),
      ),

      // ====================================================================
      // 2. LA NAVIGATION PAR ONGLETS (BOTTOM NAVIGATION BAR)
      // ====================================================================
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          // Le MainScreen devient juste le "cadre" qui contient la barre du bas
          return MainScreen(navigationShell: navigationShell);
        },
        branches: [
          // Index 0 : Accueil
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home',
                builder: (context, state) => HomeScreen(
                  // GoRouter gère maintenant la redirection vers la recherche !
                  onNavigateToSearch: () => context.go('/search'),
                ),
              ),
            ],
          ),
          // Index 1 : Recherche
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/search',
                builder: (context, state) => const SearchScreen(),
              ),
            ],
          ),
          // Index 2 : Le bouton "+" au centre (route fantôme)
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/dummy_add',
                builder: (context, state) => const SizedBox.shrink(),
              ),
            ],
          ),
          // Index 3 : Historique
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/history',
                name: 'history',
                builder: (context, state) => const HistoryScreen(),
              ),
            ],
          ),
          // Index 4 : Profil
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                name: 'profile',
                builder: (context, state) => const ProfileScreen(),
              ),
            ],
          ),
        ],
      ),
      // ====================================================================

      // 3. Autres pages pleines (sans la barre du bas)
      GoRoute(
        path: '/my_listings',
        name: 'my_listings',
        builder: (context, state) => const MyListingsScreen(),
      ),
      GoRoute(
        path: '/add_vehicle',
        name: 'add_vehicle',
        builder: (context, state) => const AddVehicleScreen(),
      ),
      GoRoute(
        path: '/edit_profile',
        name: 'edit_profile',
        builder: (context, state) => const EditProfileScreen(),
      ),
      GoRoute(
        path: '/documents',
        name: 'documents',
        builder: (context, state) => const DocumentUploadScreen(),
      ),
      GoRoute(
        path: '/help',
        name: 'help',
        builder: (context, state) => const HelpSupportScreen(),
      ),
      GoRoute(
        path: '/privacy_policy',
        name: 'privacy_policy',
        builder: (context, state) => const PrivacyPolicyScreen(),
      ),
      GoRoute(
        path: '/notifications',
        name: 'notifications',
        builder: (context, state) => const NotificationScreen(),
      ),

      GoRoute(
        path: '/rental_booking',
        builder: (context, state) {
          final vehicle = state.extra as VehicleModel;
          return RentalBookingScreen(vehicle: vehicle);
        },
      ),
      GoRoute(
        path: '/sale_booking',
        builder: (context, state) {
          final vehicle = state.extra as VehicleModel;
          return SaleBookingScreen(vehicle: vehicle);
        },
      ),
      GoRoute(
        path: '/edit_vehicle',
        name: 'edit_vehicle',
        builder: (context, state) {
          final vehicle = state.extra as VehicleModel;
          return EditVehicleScreen(vehicle: vehicle);
        },
      ),
    ],
  );
}
