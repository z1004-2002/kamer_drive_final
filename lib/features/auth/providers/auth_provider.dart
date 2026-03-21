import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kamer_drive_final/models/auth_model.dart';
import 'package:kamer_drive_final/models/user_model.dart';

class AuthProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Stocke les données de l'utilisateur connecté
  UserModel? _currentUser;
  UserModel? get currentUser => _currentUser;

  // --- VÉRIFICATION AU LANCEMENT (AUTO-LOGIN) ---
  // Renvoie la route vers laquelle l'application doit aller
  Future<String> checkAuthStateAndRoute() async {
    User? firebaseUser = _auth.currentUser;

    // 1. S'il n'est pas connecté, on l'envoie vers l'onboarding
    if (firebaseUser == null) return '/onboarding';

    try {
      // 2. S'il est connecté, on récupère ses données
      DocumentSnapshot doc = await _firestore
          .collection('users')
          .doc(firebaseUser.uid)
          .get();

      if (doc.exists) {
        // On convertit les données Firestore en UserModel
        _currentUser = UserModel.fromJson(doc.data() as Map<String, dynamic>);
        notifyListeners(); // Met à jour l'interface partout

        // 3. On vérifie s'il a fini son profilage
        if (_currentUser!.isFirstConnection ||
            !_currentUser!.hasCompletedProfiling) {
          return '/profiling';
        }
        return '/home'; // Tout est bon, direction l'accueil !
      }
    } catch (e) {
      debugPrint("Erreur lors de la récupération de l'utilisateur: $e");
    }

    // En cas de problème de base de données, on le déconnecte par sécurité
    await _auth.signOut();
    return '/auth';
  }

  Future<void> signup(SignupModel data) async {
    try {
      // 1. Créer l'utilisateur dans Firebase Auth
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(
            email: data.email,
            password: data.password,
          );

      String uid = userCredential.user!.uid;

      // 2. Sauvegarder les infos initiales dans Firestore
      await _firestore.collection('users').doc(uid).set({
        'id': uid,
        'firstName': data.firstName,
        'lastName': data.lastName,
        'email': data.email,
        'phone': data.phone,
        'birthDate': data.birthDate,
        'avatarUrl': '',
        'address': '',
        'idDocuments': [],
        'proofOfAddress': [], // Optionnel
        'reviews': [],
        'createdAt': FieldValue.serverTimestamp(),
        'isFirstConnection':
            true, // Indique que l'utilisateur vient de s'inscrire
        'hasCompletedProfiling':
            false, // Vaudra "true" après l'écran des intentions
        'intents': [], // Liste vide par défaut
        'ownsVehicle': false, // False par défaut
      });
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        throw Exception('Cet email est déjà utilisé.');
      } else if (e.code == 'weak-password') {
        throw Exception('Le mot de passe est trop faible (min. 6 caractères).');
      } else {
        throw Exception(e.message ?? 'Erreur lors de l\'inscription.');
      }
    } catch (e) {
      throw Exception('Une erreur inattendue est survenue.');
    }
  }

  // --- CONNEXION ---
  // Renvoie "true" si l'utilisateur doit faire son profilage, "false" s'il va à l'accueil
  Future<bool> login(LoginModel data) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: data.emailOrPhone,
        password: data.password,
      );

      // On charge les données dans la variable globale
      DocumentSnapshot doc = await _firestore
          .collection('users')
          .doc(userCredential.user!.uid)
          .get();
      if (doc.exists) {
        _currentUser = UserModel.fromJson(doc.data() as Map<String, dynamic>);
        notifyListeners();
      }
      return false;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found' ||
          e.code == 'wrong-password' ||
          e.code == 'invalid-credential') {
        throw Exception('Email ou mot de passe incorrect.');
      } else {
        throw Exception(e.message ?? 'Erreur de connexion.');
      }
    } catch (e) {
      throw Exception('Une erreur inattendue est survenue.');
    }
  }

  Future<void> completeProfiling({
    required List<String> intents,
    required bool ownsVehicle,
  }) async {
    try {
      String uid = _auth.currentUser!.uid;

      // 1. Mise à jour dans la base de données Firestore
      await _firestore.collection('users').doc(uid).update({
        'intents': intents,
        'ownsVehicle': ownsVehicle,
        'isFirstConnection': false,
        'hasCompletedProfiling': true,
      });

      // 2. NOUVEAU : Mettre à jour l'utilisateur localement pour l'application
      DocumentSnapshot doc = await _firestore
          .collection('users')
          .doc(uid)
          .get();
      if (doc.exists) {
        _currentUser = UserModel.fromJson(doc.data() as Map<String, dynamic>);
        notifyListeners(); // Rafraîchit instantanément la HomeScreen !
      }
    } catch (e) {
      // J'ajoute le détail de l'erreur pour t'aider à débugger si ça plante
      debugPrint("Erreur de profilage : $e");
      throw Exception("Erreur lors de la mise à jour du profil.");
    }
  }

  // --- DÉCONNEXION ---
  Future<void> logout() async {
    try {
      // 1. Déconnexion de Firebase
      await _auth.signOut();

      // 2. On vide les données de l'utilisateur localement
      _currentUser = null;

      // 3. On avertit toute l'application que l'utilisateur n'est plus là
      notifyListeners();
    } catch (e) {
      debugPrint("Erreur lors de la déconnexion : $e");
      throw Exception("Impossible de se déconnecter pour le moment.");
    }
  }
}
