import 'review_model.dart'; // Assure-toi d'importer le ReviewModel

class RentalBookingModel {
  final String id;
  final String vehicleId;
  final String ownerId;
  final String tenantId; // Le locataire
  
  // Détails de la location
  final DateTime startDate;
  final DateTime endDate;
  final bool includesDriver;
  
  // Tarification
  final double totalPrice;
  final double securityDeposit; // La caution
  
  // Statut ("En attente", "Confirmé", "En cours", "Terminé", "Annulé")
  final String status;
  
  // Étapes de validation (Cahier des charges)
  final bool checkInValidated; // Prise en charge validée par les deux
  final bool checkOutValidated; // Restitution validée par les deux
  final bool depositRefunded; // Caution remboursée
  
  // Évaluations spécifiques à cette location
  final List<ReviewModel> reviews; 
  final DateTime createdAt;

  RentalBookingModel({
    required this.id,
    required this.vehicleId,
    required this.ownerId,
    required this.tenantId,
    required this.startDate,
    required this.endDate,
    required this.includesDriver,
    required this.totalPrice,
    required this.securityDeposit,
    required this.status,
    required this.checkInValidated,
    required this.checkOutValidated,
    required this.depositRefunded,
    required this.reviews,
    required this.createdAt,
  });

  factory RentalBookingModel.fromJson(Map<String, dynamic> json) {
    return RentalBookingModel(
      id: json['id'] ?? '',
      vehicleId: json['vehicleId'] ?? '',
      ownerId: json['ownerId'] ?? '',
      tenantId: json['tenantId'] ?? '',
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      includesDriver: json['includesDriver'] ?? false,
      totalPrice: (json['totalPrice'] ?? 0.0).toDouble(),
      securityDeposit: (json['securityDeposit'] ?? 0.0).toDouble(),
      status: json['status'] ?? 'En attente',
      checkInValidated: json['checkInValidated'] ?? false,
      checkOutValidated: json['checkOutValidated'] ?? false,
      depositRefunded: json['depositRefunded'] ?? false,
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
      'tenantId': tenantId,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'includesDriver': includesDriver,
      'totalPrice': totalPrice,
      'securityDeposit': securityDeposit,
      'status': status,
      'checkInValidated': checkInValidated,
      'checkOutValidated': checkOutValidated,
      'depositRefunded': depositRefunded,
      'reviews': reviews.map((e) => e.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
    };
  }
}