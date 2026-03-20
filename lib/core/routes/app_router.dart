import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kamer_drive_final/features/auth/screens/auth_screen.dart';
import 'package:kamer_drive_final/features/booking/screens/rental_booking_screen.dart';
import 'package:kamer_drive_final/features/booking/screens/sale_booking_screen.dart';
import 'package:kamer_drive_final/features/home/screens/main_screen.dart';
import 'package:kamer_drive_final/features/my_listings/screens/add_vehicle_screen.dart';
import 'package:kamer_drive_final/features/my_listings/screens/my_listings_screen.dart';
import 'package:kamer_drive_final/features/onboarding/screens/profiling_screen.dart';
import 'package:kamer_drive_final/features/profile/screens/document_upload_screen.dart';
import 'package:kamer_drive_final/features/profile/screens/edit_profile_screen.dart';
import 'package:kamer_drive_final/features/profile/screens/help_support_screen.dart';
import 'package:kamer_drive_final/features/profile/screens/privacy_policy_screen.dart';
import 'package:kamer_drive_final/models/vehicle_model.dart';

// Importe tes écrans actuels
import '../../features/onboarding/screens/splash_screen.dart';
import '../../features/onboarding/screens/onboarding_screen.dart';

class AppRouter {
  // Définition du routeur
  static final GoRouter router = GoRouter(
    initialLocation: '/', // La route de départ (Splash Screen)
    // Ajout d'une gestion globale des erreurs (si une page n'existe pas)
    errorBuilder: (context, state) =>
        const Scaffold(body: Center(child: Text("Page introuvable"))),

    routes: [
      // 1. Splash Screen
      GoRoute(
        path: '/',
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),

      // 2. Onboarding Screen
      GoRoute(
        path: '/onboarding',
        name: 'onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),

      // 3. Auth Screen
      GoRoute(
        path: '/auth',
        name: 'auth',
        builder: (context, state) => const AuthScreen(),
      ),

      // 4. Profiling Screen
      GoRoute(
        path: '/profiling',
        name: 'profiling',
        builder: (context, state) => const ProfilingScreen(),
      ),

      // 5. Main Home Screen
      GoRoute(
        path: '/home',
        name: 'home',
        builder: (context, state) => const MainScreen(),
      ),

      // 6. My Listings & Add Vehicle Screens
      GoRoute(
        path: '/my_listings',
        name: 'my_listings',
        builder: (context, state) => const MyListingsScreen(),
      ),

      // 7. Add Vehicle Screen
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
        path: '/rental_booking',
        builder: (context, state) {
          // On récupère l'objet VehicleModel passé en paramètre "extra"
          final vehicle = state.extra as VehicleModel;
          return RentalBookingScreen(vehicle: vehicle);
        },
      ),
      GoRoute(
        path: '/sale_booking',
        builder: (context, state) {
          // On prépare déjà la route pour l'écran de vente qu'on va créer
          final vehicle = state.extra as VehicleModel;
          return SaleBookingScreen(vehicle: vehicle);
        },
      ),
    ],

    // C'est ici qu'on mettra la logique "Redirect" plus tard.
    // Ex: redirect: (context, state) { if (!isLoggedIn) return '/auth'; return null; }
  );
}
