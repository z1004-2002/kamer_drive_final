import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../models/rental_booking_model.dart';
import '../../../models/sale_booking_model.dart';

class BookingProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // --- 1. CRÉER UNE RÉSERVATION (LOCATION) ---
  Future<void> createRentalBooking(RentalBookingModel booking) async {
    try {
      // On s'assure que l'utilisateur est connecté
      if (_auth.currentUser == null)
        throw Exception("Utilisateur non connecté.");

      // On enregistre dans une collection dédiée
      await _firestore
          .collection('rental_bookings')
          .doc(booking.id)
          .set(booking.toJson());

      notifyListeners();
    } catch (e) {
      debugPrint("Erreur createRentalBooking: $e");
      throw Exception("Impossible de créer la réservation.");
    }
  }

  // --- 2. CRÉER UNE OFFRE D'ACHAT (VENTE) ---
  Future<void> createSaleBooking(SaleBookingModel booking) async {
    try {
      if (_auth.currentUser == null)
        throw Exception("Utilisateur non connecté.");

      await _firestore
          .collection('sale_bookings')
          .doc(booking.id)
          .set(booking.toJson());

      notifyListeners();
    } catch (e) {
      debugPrint("Erreur createSaleBooking: $e");
      throw Exception("Impossible d'envoyer l'offre d'achat.");
    }
  }

  // Pour la suite, tu pourras ajouter ici des Streams :
  // Stream<List<RentalBookingModel>> getMyRentalBookings() { ... }
}
