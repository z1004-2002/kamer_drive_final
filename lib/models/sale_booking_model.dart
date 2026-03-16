import 'review_model.dart';

class SaleBookingModel {
  final String id;
  final String vehicleId;
  final String ownerId; // Le vendeur
  final String buyerId; // L'acheteur
  
  // Tarification
  final double agreedPrice; // Le prix après négociation
  
  // Statut ("Négociation", "Réservé", "Fonds Validés", "Terminé", "Annulé")
  final String status;
  
  // Étapes de validation (Cahier des charges)
  final bool fundsReceived; // Le vendeur valide la réception des fonds
  final bool vehicleReceived; // L'acheteur valide la réception de la voiture
  final bool ownershipTransferred; // Le transfert de propriété numérique est fait
  
  // Évaluations spécifiques à cette vente
  final List<ReviewModel> reviews; 
  final DateTime createdAt;

  SaleBookingModel({
    required this.id,
    required this.vehicleId,
    required this.ownerId,
    required this.buyerId,
    required this.agreedPrice,
    required this.status,
    required this.fundsReceived,
    required this.vehicleReceived,
    required this.ownershipTransferred,
    required this.reviews,
    required this.createdAt,
  });

  factory SaleBookingModel.fromJson(Map<String, dynamic> json) {
    return SaleBookingModel(
      id: json['id'] ?? '',
      vehicleId: json['vehicleId'] ?? '',
      ownerId: json['ownerId'] ?? '',
      buyerId: json['buyerId'] ?? '',
      agreedPrice: (json['agreedPrice'] ?? 0.0).toDouble(),
      status: json['status'] ?? 'Négociation',
      fundsReceived: json['fundsReceived'] ?? false,
      vehicleReceived: json['vehicleReceived'] ?? false,
      ownershipTransferred: json['ownershipTransferred'] ?? false,
      reviews: (json['reviews'] as List<dynamic>?)
              ?.map((e) => ReviewModel.fromJson(e))
              .toList() ?? [],
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'vehicleId': vehicleId,
      'ownerId': ownerId,
      'buyerId': buyerId,
      'agreedPrice': agreedPrice,
      'status': status,
      'fundsReceived': fundsReceived,
      'vehicleReceived': vehicleReceived,
      'ownershipTransferred': ownershipTransferred,
      'reviews': reviews.map((e) => e.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
    };
  }
}