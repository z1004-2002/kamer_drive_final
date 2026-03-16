import 'package:kamer_drive_final/models/review_model.dart';

class VehicleModel {
  final String id;
  final String ownerId;
  final String brand;
  final String modelName;
  final int year;
  final String city;
  final String address;
  final List<String> images; // 4 angles + intérieur
  
  // Documents obligatoires pour la validation admin
  final String registrationPlateUrl; // Plaque d'immatriculation
  final String registrationDocumentUrl; // Carte grise
  final String insuranceCertificateUrl; // Attestation d'assurance
  final String validationStatus;

  // Configuration Location
  final bool isForRent;
  final double? rentPricePerDay;
  final double? securityDeposit;
  final bool? withDriverOption;

  // Configuration Vente
  final bool isForSale;
  final double? salePrice;

  // Spécifications
  final int seats;
  final String gearbox;
  final String fuelType;
  final bool hasAC;

  // NOUVEAU : Liste des ratings et commentaires de la voiture
  final List<ReviewModel> reviews; 

  VehicleModel({
    required this.id,
    required this.ownerId,
    required this.brand,
    required this.modelName,
    required this.year,
    required this.city,
    required this.address,
    required this.images,
    required this.registrationPlateUrl,
    required this.registrationDocumentUrl,
    required this.insuranceCertificateUrl,
    required this.validationStatus,
    required this.isForRent,
    this.rentPricePerDay,
    this.securityDeposit,
    this.withDriverOption,
    required this.isForSale,
    this.salePrice,
    required this.seats,
    required this.gearbox,
    required this.fuelType,
    required this.hasAC,
    required this.reviews,
  });

  factory VehicleModel.fromJson(Map<String, dynamic> json) {
    return VehicleModel(
      // ... (Même logique de parsing sécurisée que les autres modèles)
      id: json['id'] ?? '',
      ownerId: json['ownerId'] ?? '',
      brand: json['brand'] ?? '',
      modelName: json['modelName'] ?? '',
      year: json['year'] ?? 2020,
      city: json['city'] ?? '',
      address: json['address'] ?? '',
      images: List<String>.from(json['images'] ?? []),
      registrationPlateUrl: json['registrationPlateUrl'] ?? '',
      registrationDocumentUrl: json['registrationDocumentUrl'] ?? '',
      insuranceCertificateUrl: json['insuranceCertificateUrl'] ?? '',
      validationStatus: json['validationStatus'] ?? 'En attente',
      isForRent: json['isForRent'] ?? false,
      rentPricePerDay: json['rentPricePerDay']?.toDouble(),
      securityDeposit: json['securityDeposit']?.toDouble(),
      withDriverOption: json['withDriverOption'],
      isForSale: json['isForSale'] ?? false,
      salePrice: json['salePrice']?.toDouble(),
      seats: json['seats'] ?? 5,
      gearbox: json['gearbox'] ?? 'Manuelle',
      fuelType: json['fuelType'] ?? 'Essence',
      hasAC: json['hasAC'] ?? true,
      reviews: (json['reviews'] as List<dynamic>?)?.map((e) => ReviewModel.fromJson(e)).toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      // ... (mapping inverse)
      'id': id,
      'ownerId': ownerId,
      'brand': brand,
      'modelName': modelName,
      'year': year,
      'images': images,
      'registrationPlateUrl': registrationPlateUrl,
      'registrationDocumentUrl': registrationDocumentUrl,
      'insuranceCertificateUrl': insuranceCertificateUrl,
      'validationStatus': validationStatus,
      'isForRent': isForRent,
      'rentPricePerDay': rentPricePerDay,
      'isForSale': isForSale,
      'salePrice': salePrice,
      'reviews': reviews.map((e) => e.toJson()).toList(),
    };
  }
}