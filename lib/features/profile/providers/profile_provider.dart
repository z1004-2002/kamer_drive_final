import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
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

  Future<void> updateProfile({
    required String firstName,
    required String lastName,
    required String phone,
    required String address,
    required bool ownsVehicle, // <--- NOUVEAU
    File? newAvatarFile,
  }) async {
    User? user = _auth.currentUser;
    if (user == null) return;

    try {
      String? avatarUrlToSave = _currentUser?.avatarUrl;

      if (newAvatarFile != null) {
        final storageRef = _storage.ref().child('users/${user.uid}/avatar.jpg');
        UploadTask uploadTask = storageRef.putFile(newAvatarFile);
        TaskSnapshot snapshot = await uploadTask.timeout(
          const Duration(seconds: 15),
        );
        avatarUrlToSave = await snapshot.ref.getDownloadURL();
      }

      await _firestore.collection('users').doc(user.uid).update({
        'firstName': firstName,
        'lastName': lastName,
        'phone': phone,
        'address': address,
        'ownsVehicle': ownsVehicle, // <--- NOUVEAU
        if (avatarUrlToSave != null) 'avatarUrl': avatarUrlToSave,
      });

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

  // --- UPLOAD DES DOCUMENTS D'IDENTITÉ ---
  Future<void> uploadIdentityDocuments({
    File? idFront,
    File? idBack,
    File? passport, // <--- NOUVEAU
    File? licenseFront,
    File? licenseBack,
  }) async {
    User? user = _auth.currentUser;
    if (user == null) return;

    try {
      Map<String, String> uploadedDocs = {};

      Future<void> uploadDoc(File file, String name) async {
        final storageRef = _storage.ref().child(
          'users/${user.uid}/documents/$name.jpg',
        );
        UploadTask uploadTask = storageRef.putFile(file);
        TaskSnapshot snapshot = await uploadTask.timeout(
          const Duration(seconds: 20),
        );
        String url = await snapshot.ref.getDownloadURL();
        uploadedDocs[name] = url;
      }

      // Upload conditionnel des fichiers
      if (idFront != null) await uploadDoc(idFront, 'id_front');
      if (idBack != null) await uploadDoc(idBack, 'id_back');
      if (passport != null)
        await uploadDoc(passport, 'passport'); // <--- NOUVEAU
      if (licenseFront != null) await uploadDoc(licenseFront, 'license_front');
      if (licenseBack != null) await uploadDoc(licenseBack, 'license_back');

      if (uploadedDocs.isEmpty) return;

      Map<String, dynamic> currentDocs = Map<String, dynamic>.from(
        _currentUser?.idDocuments ?? <String, dynamic>{},
      );
      currentDocs.addAll(uploadedDocs);

      await _firestore.collection('users').doc(user.uid).update({
        'idDocuments': currentDocs,
      });

      await fetchUserProfile();
    } catch (e) {
      debugPrint("Erreur upload documents : $e");
      throw Exception(
        "Impossible d'envoyer les documents. Vérifiez votre connexion.",
      );
    }
  }
}
