import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
// TODO: Assure-toi que le chemin vers UserModel est correct
import '../../../models/user_model.dart';

class ProfileProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instanceFor(
    bucket: "gs://kamer-drive-41b9b.firebasestorage.app",
  );

  UserModel? _currentUser;
  UserModel? get currentUser => _currentUser;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  ProfileProvider() {
    // Charge le profil automatiquement si un utilisateur est déjà connecté
    fetchUserProfile();
  }

  // --- RÉCUPÉRER LE PROFIL ---
  Future<void> fetchUserProfile() async {
    User? user = _auth.currentUser;
    if (user != null) {
      try {
        DocumentSnapshot doc = await _firestore
            .collection('users')
            .doc(user.uid)
            .get();
        if (doc.exists) {
          // On s'assure que ton UserModel a bien une méthode fromJson
          _currentUser = UserModel.fromJson(doc.data() as Map<String, dynamic>);
          notifyListeners();
        }
      } catch (e) {
        debugPrint("Erreur lors de la récupération du profil : $e");
      }
    }
  }

  // --- METTRE À JOUR LE PROFIL ---
  Future<void> updateProfile({
    required String firstName,
    required String lastName,
    required String phone,
    required String address,
    File? newAvatarFile,
  }) async {
    User? user = _auth.currentUser;
    if (user == null) return;

    try {
      String? avatarUrlToSave = _currentUser?.avatarUrl;

      // 1. Upload de la nouvelle photo si sélectionnée
      if (newAvatarFile != null) {
        final storageRef = _storage.ref().child('users/${user.uid}/avatar.jpg');
        UploadTask uploadTask = storageRef.putFile(newAvatarFile);
        TaskSnapshot snapshot = await uploadTask.timeout(
          const Duration(seconds: 15),
        );
        avatarUrlToSave = await snapshot.ref.getDownloadURL();
      }

      // 2. Mise à jour dans Firestore
      await _firestore.collection('users').doc(user.uid).update({
        'firstName': firstName,
        'lastName': lastName,
        'phone': phone,
        'address': address,
        if (avatarUrlToSave != null) 'avatarUrl': avatarUrlToSave,
      });

      // 3. Recharger le profil pour mettre à jour l'interface
      await fetchUserProfile();
    } catch (e) {
      debugPrint("Erreur updateProfile : $e");
      throw Exception("Impossible de mettre à jour le profil.");
    }
  }

  // --- NETTOYER LE PROFIL (À appeler lors de la déconnexion) ---
  void clearProfile() {
    _currentUser = null;
    notifyListeners();
  }
}
