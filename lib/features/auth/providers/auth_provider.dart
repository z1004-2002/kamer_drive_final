import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kamer_drive_final/models/auth_model.dart';

class AuthProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> signup(SignupModel data) async {
    try {
      // 1. Créer l'utilisateur dans Firebase Auth
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
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
        'isFirstConnection': true,          // Indique que l'utilisateur vient de s'inscrire
        'hasCompletedProfiling': false,     // Vaudra "true" après l'écran des intentions
        'intents': [],                      // Liste vide par défaut
        'ownsVehicle': false,               // False par défaut
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

      String uid = userCredential.user!.uid;

      // Récupérer les données de l'utilisateur depuis Firestore
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(uid).get();

      if (userDoc.exists) {
        // Comme demandé, on se base UNIQUEMENT sur isFirstConnection
        bool isFirstConnection = userDoc.get('isFirstConnection') ?? true;
        return isFirstConnection;
      }

      return false; // Par défaut, on l'envoie à l'accueil

    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found' || e.code == 'wrong-password' || e.code == 'invalid-credential') {
        throw Exception('Email ou mot de passe incorrect.');
      } else {
        throw Exception(e.message ?? 'Erreur de connexion.');
      }
    } catch (e) {
      throw Exception('Une erreur inattendue est survenue.');
    }
  }

  // --- FINALISER LE PROFILAGE ---
  Future<void> completeProfiling({required List<String> intents, required bool ownsVehicle}) async {
    try {
      String uid = _auth.currentUser!.uid;

      await _firestore.collection('users').doc(uid).update({
        'intents': intents,
        'ownsVehicle': ownsVehicle,
        'isFirstConnection': false, // <--- TRÈS IMPORTANT : On le passe à false ici !
        'hasCompletedProfiling': false,
      });
      
    } catch (e) {
      throw Exception('Erreur lors de la mise à jour du profil.');
    }
  }
}