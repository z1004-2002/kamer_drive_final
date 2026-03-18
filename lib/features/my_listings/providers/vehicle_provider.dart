import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../../../models/vehicle_model.dart'; // Assure-toi d'avoir ce modèle

class VehicleProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instanceFor(
    bucket: "gs://kamer-drive-41b9b.firebasestorage.app",
  );
  // final FirebaseStorage _storage = FirebaseStorage.instance;

  // Fonction pour uploader UNE image et récupérer son URL
  Future<String> _uploadImage(File image, String path) async {
    try {
      Reference ref = _storage.ref().child(path);
      UploadTask uploadTask = ref.putFile(image);
      TaskSnapshot snapshot = await uploadTask.timeout(
        const Duration(seconds: 20),
        onTimeout: () => throw Exception("Temps d'attente dépassé (Timeout)"),
      );
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      debugPrint("🛑 Erreur Upload Storage ($path) : $e");
      throw Exception("Erreur lors de l'upload de l'image.");
    }
  }

  Future<void> submitVehicle({
    required String brand,
    required String modelName,
    required int year,
    required String description,
    required String city,
    required String address,
    required int seats,
    required String gearbox,
    required String fuelType,
    required bool hasAC,
    required bool isForRent,
    required bool isForSale,
    double? rentPrice,
    double? salePrice,
    required Map<String, File> vehicleImages,
    required Map<String, File> documents,
  }) async {
    try {
      String uid = _auth.currentUser!.uid;
      DocumentReference vehicleRef = _firestore.collection('vehicles').doc();
      String vehicleId = vehicleRef.id;

      // 1. Upload des photos
      List<String> imageUrls = [];
      for (var entry in vehicleImages.entries) {
        String url = await _uploadImage(
          entry.value,
          'vehicles/$vehicleId/photos/${entry.key}.jpg',
        );
        imageUrls.add(url);
      }

      // 2. Upload des documents
      String plateUrl = await _uploadImage(
        documents['plate']!,
        'vehicles/$vehicleId/docs/plate.jpg',
      );
      String regDocUrl = await _uploadImage(
        documents['registration']!,
        'vehicles/$vehicleId/docs/registration.jpg',
      );
      String insuranceUrl = await _uploadImage(
        documents['insurance']!,
        'vehicles/$vehicleId/docs/insurance.jpg',
      );

      // 3. Création du modèle complet
      final newVehicle = VehicleModel(
        id: vehicleId,
        ownerId: uid,
        brand: brand,
        modelName: modelName,
        year: year,
        description: description,
        city: city,
        address: address,
        images: imageUrls,
        registrationPlateUrl: plateUrl,
        registrationDocumentUrl: regDocUrl,
        insuranceCertificateUrl: insuranceUrl,
        validationStatus: "En attente",
        isForRent: isForRent,
        rentPricePerDay: rentPrice,
        isForSale: isForSale,
        salePrice: salePrice,
        seats: seats,
        gearbox: gearbox,
        fuelType: fuelType,
        hasAC: hasAC,
        reviews: [],
      );

      await vehicleRef.set(newVehicle.toJson());
      notifyListeners();
    } catch (e) {
      throw Exception("Erreur lors de l'enregistrement : $e");
    }
  }

  Stream<List<VehicleModel>> getMyVehicles() {
    String uid = _auth.currentUser!.uid;
    return _firestore
        .collection('vehicles')
        .where('ownerId', isEqualTo: uid) // Filtre par propriétaire
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => VehicleModel.fromJson(doc.data()))
              .toList(),
        );
  }
}
