import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// Importe tes écrans actuels
import '../../features/onboarding/screens/splash_screen.dart';
import '../../features/onboarding/screens/onboarding_screen.dart';

// Importe tes futurs écrans (à décommenter plus tard)
// import '../../features/auth/screens/login_screen.dart';
// import '../../features/home/screens/main_screen.dart';

class AppRouter {
  // Définition du routeur
  static final GoRouter router = GoRouter(
    initialLocation: '/', // La route de départ (Splash Screen)
    
    // Ajout d'une gestion globale des erreurs (si une page n'existe pas)
    errorBuilder: (context, state) => const Scaffold(
      body: Center(child: Text("Page introuvable")),
    ),

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

      // 3. Auth Screen (Placeholder pour la suite)
      /*
      GoRoute(
        path: '/auth',
        name: 'auth',
        builder: (context, state) => const LoginScreen(),
      ),
      */

      // 4. Main Home Screen (Placeholder pour la suite)
      /*
      GoRoute(
        path: '/home',
        name: 'home',
        builder: (context, state) => const MainScreen(),
      ),
      */
    ],

    // C'est ici qu'on mettra la logique "Redirect" plus tard.
    // Ex: redirect: (context, state) { if (!isLoggedIn) return '/auth'; return null; }
  );
}