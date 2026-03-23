import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../../../models/vehicle_model.dart'; // Assure-toi d'avoir ce modèle

class VehicleProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  // final FirebaseStorage _storage = FirebaseStorage.instanceFor(
  //   bucket: "gs://kamer-drive-41b9b.firebasestorage.app",
  // );
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Fonction pour uploader UNE image et récupérer son URL
  Future<String> _uploadImage(File image, String path) async {
    try {
      Reference ref = _storage.ref().child(path);
      UploadTask uploadTask = ref.putFile(image);
      TaskSnapshot snapshot = await uploadTask.timeout(
        const Duration(seconds: 90),
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
    required bool withDriverOption,
    double? rentPriceWithDriver,
    double? salePrice,
    double? securityDeposit,
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
        withDriverOption: withDriverOption,
        rentPriceWithDriver: rentPriceWithDriver,
        isForSale: isForSale,
        salePrice: salePrice,
        seats: seats,
        gearbox: gearbox,
        fuelType: fuelType,
        securityDeposit: securityDeposit,
        hasAC: hasAC,
        reviews: [],
        createdAt: DateTime.now(), // Date de création fixée à "maintenant"
        updatedAt:
            DateTime.now(), // Date de mise à jour fixée à "maintenant".where('isAvailable', isEqualTo: true)
        isAvailable: false,
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
        .where('ownerId', isEqualTo: uid)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => VehicleModel.fromJson(doc.data()))
              .toList(),
        );
  } // --- METTRE À JOUR UN VÉHICULE ---

  Future<bool> _hasActiveBookings(String vehicleId) async {
    try {
      // 1. Vérifier les locations actives
      final rentQuery = await _firestore
          .collection('rental_bookings')
          .where('vehicleId', isEqualTo: vehicleId)
          .where('status', whereIn: ['En attente', 'Confirmé', 'En cours'])
          .get();

      if (rentQuery.docs.isNotEmpty) return true;

      // 2. Vérifier les ventes actives
      final saleQuery = await _firestore
          .collection('sale_bookings')
          .where('vehicleId', isEqualTo: vehicleId)
          .where('status', whereIn: ['Négociation', 'Fonds Validés'])
          .get();

      if (saleQuery.docs.isNotEmpty) return true;

      return false; // Le véhicule est totalement libre
    } catch (e) {
      debugPrint("Erreur lors de la vérification des réservations : $e");
      return true; // Par sécurité, on bloque si la vérification échoue
    }
  }

  // --- METTRE À JOUR UN VÉHICULE (AVEC PHOTOS OPTIONNELLES) ---
  Future<void> updateVehicleInfo(
    String vehicleId,
    Map<String, dynamic> updates, {
    Map<String, File>? newImages,
    Map<String, File>? newDocs,
  }) async {
    try {
      bool isBusy = await _hasActiveBookings(vehicleId);
      if (isBusy) {
        throw Exception(
          "Impossible : Ce véhicule a des transactions en cours.",
        );
      }

      // --- 1. GESTION DES NOUVELLES IMAGES DU VÉHICULE ---
      if (newImages != null && newImages.isNotEmpty) {
        // On récupère le véhicule actuel pour avoir son tableau d'images
        DocumentSnapshot doc = await _firestore
            .collection('vehicles')
            .doc(vehicleId)
            .get();
        List<dynamic> currentImages = doc.get('images') ?? [];
        // On s'assure que le tableau a la bonne taille (5 images)
        while (currentImages.length < 5) {
          currentImages.add("");
        }

        // Fonction locale d'upload
        Future<String> uploadToStorage(File file, String path) async {
          TaskSnapshot snapshot = await FirebaseStorage.instance
              .ref()
              .child(path)
              .putFile(file);
          return await snapshot.ref.getDownloadURL();
        }

        // On remplace spécifiquement l'image au bon index
        if (newImages.containsKey('front')) {
          currentImages[0] = await uploadToStorage(
            newImages['front']!,
            'vehicles/$vehicleId/front.jpg',
          );
        }
        if (newImages.containsKey('back')) {
          currentImages[1] = await uploadToStorage(
            newImages['back']!,
            'vehicles/$vehicleId/back.jpg',
          );
        }
        if (newImages.containsKey('left')) {
          currentImages[2] = await uploadToStorage(
            newImages['left']!,
            'vehicles/$vehicleId/left.jpg',
          );
        }
        if (newImages.containsKey('right')) {
          currentImages[3] = await uploadToStorage(
            newImages['right']!,
            'vehicles/$vehicleId/right.jpg',
          );
        }
        if (newImages.containsKey('interior')) {
          currentImages[4] = await uploadToStorage(
            newImages['interior']!,
            'vehicles/$vehicleId/interior.jpg',
          );
        }

        updates['images'] = currentImages;
      }

      // --- 2. GESTION DES NOUVEAUX DOCUMENTS ---
      if (newDocs != null && newDocs.isNotEmpty) {
        Future<String> uploadDoc(File file, String docName) async {
          TaskSnapshot snapshot = await FirebaseStorage.instance
              .ref()
              .child('vehicles/$vehicleId/docs_$docName.jpg')
              .putFile(file);
          return await snapshot.ref.getDownloadURL();
        }

        if (newDocs.containsKey('plate')) {
          updates['registrationPlateUrl'] = await uploadDoc(
            newDocs['plate']!,
            'plate',
          );
        }
        if (newDocs.containsKey('registration')) {
          updates['registrationDocumentUrl'] = await uploadDoc(
            newDocs['registration']!,
            'registration',
          );
        }
        if (newDocs.containsKey('insurance')) {
          updates['insuranceCertificateUrl'] = await uploadDoc(
            newDocs['insurance']!,
            'insurance',
          );
        }
      }

      updates['updatedAt'] = DateTime.now().toIso8601String();
      updates['validationStatus'] =
          "En attente"; // NOUVEAU : Si le proprio modifie, on repasse en attente de validation admin !

      await _firestore.collection('vehicles').doc(vehicleId).update(updates);
      notifyListeners();
    } catch (e) {
      debugPrint("Erreur Update Vehicle: $e");
      rethrow;
    }
  }

  // --- SUPPRIMER UN VÉHICULE ---
  Future<void> deleteVehicle(String vehicleId) async {
    try {
      // Vérification de sécurité !
      bool isBusy = await _hasActiveBookings(vehicleId);
      if (isBusy) {
        throw Exception(
          "Impossible : Ce véhicule a des transactions en cours. Terminez ou annulez-les d'abord.",
        );
      }

      await _firestore.collection('vehicles').doc(vehicleId).delete();
      notifyListeners();
    } catch (e) {
      debugPrint("Erreur Delete Vehicle: $e");
      rethrow;
    }
  }
}
