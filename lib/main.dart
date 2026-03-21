import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:kamer_drive_final/core/routes/app_router.dart';
import 'package:kamer_drive_final/features/auth/providers/auth_provider.dart';
import 'package:kamer_drive_final/features/booking/providers/booking_provider.dart';
import 'package:kamer_drive_final/features/home/providers/home_provider.dart';
import 'package:kamer_drive_final/features/my_listings/providers/vehicle_provider.dart';
import 'package:kamer_drive_final/features/profile/providers/profile_provider.dart';
import 'package:kamer_drive_final/features/search/provider/search_provider.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => VehicleProvider()),
        ChangeNotifierProvider(create: (_) => ProfileProvider()),
        ChangeNotifierProvider(create: (_) => HomeProvider()),
        ChangeNotifierProvider(create: (_) => SearchProvider()),
        ChangeNotifierProvider(create: (_) => BookingProvider()),
      ],
      child: const KamerDriveApp(),
    ),
  );
}

class KamerDriveApp extends StatelessWidget {
  const KamerDriveApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Utilisation de MaterialApp.router
    return MaterialApp.router(
      title: 'KamerDrive',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFF009688),
        scaffoldBackgroundColor: const Color(0xFFF5F6F8),
      ),
      // On passe la configuration de GoRouter
      routerConfig: AppRouter.router,
    );
  }
}
