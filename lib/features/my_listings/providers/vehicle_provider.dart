import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:kamer_drive_final/models/vehicle_model.dart';

class VehicleProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // --- UPLOAD D'UNE IMAGE SUR FIREBASE STORAGE ---
  Future<String> _uploadImage(File imageFile, String folderPath) async {
    String fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
    Reference ref = _storage.ref().child('$folderPath/$fileName');
    
    UploadTask uploadTask = ref.putFile(imageFile);
    TaskSnapshot snapshot = await uploadTask;
    return await snapshot.ref.getDownloadURL();
  }

  // --- CRÉATION DU VÉHICULE ---
  Future<void> addVehicle({
    required String brand,
    required String modelName,
    required int year,
    required bool isForRent,
    required bool isForSale,
    required List<File> vehicleImages, // Les 4 photos + intérieur
    required File registrationPlate,
    required File registrationDocument,
    required File insuranceCertificate,
  }) async {
    try {
      String uid = _auth.currentUser!.uid;
      String vehicleId = _firestore.collection('vehicles').doc().id; // Génère un ID unique

      // 1. Upload de toutes les images en parallèle (pour aller plus vite)
      List<String> imageUrls = [];
      for (File img in vehicleImages) {
        String url = await _uploadImage(img, 'vehicles/$vehicleId/photos');
        imageUrls.add(url);
      }

      String plateUrl = await _uploadImage(registrationPlate, 'vehicles/$vehicleId/documents');
      String documentUrl = await _uploadImage(registrationDocument, 'vehicles/$vehicleId/documents');
      String insuranceUrl = await _uploadImage(insuranceCertificate, 'vehicles/$vehicleId/documents');

      // 2. Création du modèle
      final newVehicle = VehicleModel(
        id: vehicleId,
        ownerId: uid,
        brand: brand,
        modelName: modelName,
        year: year,
        city: "Non définie",
        address: "Non définie",
        images: imageUrls,
        registrationPlateUrl: plateUrl,
        registrationDocumentUrl: documentUrl,
        insuranceCertificateUrl: insuranceUrl,
        validationStatus: 'En attente', // Statut obligatoire selon le cahier des charges
        isForRent: isForRent,
        isForSale: isForSale,
        seats: 5,
        gearbox: 'Manuelle',
        fuelType: 'Essence',
        hasAC: true,
        reviews: [],
      );

      // 3. Sauvegarde dans Firestore
      await _firestore.collection('vehicles').doc(vehicleId).set(newVehicle.toJson());

    } catch (e) {
      throw Exception("Erreur lors de la création du véhicule : $e");
    }
  }
}