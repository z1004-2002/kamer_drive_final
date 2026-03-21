import 'review_model.dart';

class VehicleModel {
  final String id;
  final String ownerId;
  final String brand;
  final String modelName;
  final int year;
  final String city;
  final String address;
  final List<String> images;

  // NOUVEAU : Description libre par le propriétaire
  final String description;

  // Documents obligatoires pour la validation admin
  final String registrationPlateUrl;
  final String registrationDocumentUrl;
  final String insuranceCertificateUrl;

  // Statut de validation (En attente, Validé, Rejeté)
  final String validationStatus;

  // Configuration Location
  final bool isForRent;
  final double? rentPricePerDay;
  final double? securityDeposit;
  final double? rentPriceWithDriver;
  final bool? withDriverOption;

  // Configuration Vente
  final bool isForSale;
  final double? salePrice;

  // Spécifications techniques
  final int seats;
  final String gearbox;
  final String fuelType;
  final bool hasAC;

  // Évaluations
  final List<ReviewModel> reviews;
  // NOUVEAU : Dates de suivi
  final DateTime createdAt;
  final DateTime updatedAt;

  VehicleModel({
    required this.id,
    required this.ownerId,
    required this.brand,
    required this.modelName,
    required this.year,
    required this.city,
    required this.address,
    required this.images,
    required this.description,
    required this.registrationPlateUrl,
    required this.registrationDocumentUrl,
    required this.insuranceCertificateUrl,
    required this.validationStatus,
    required this.isForRent,
    this.rentPricePerDay,
    this.securityDeposit,
    this.withDriverOption,
    this.rentPriceWithDriver,
    required this.isForSale,
    this.salePrice,
    required this.seats,
    required this.gearbox,
    required this.fuelType,
    required this.hasAC,
    required this.reviews,
    required this.createdAt, // <-- Ajouté ici
    required this.updatedAt, // <-- Ajouté ici
  });

  factory VehicleModel.fromJson(Map<String, dynamic> json) {
    return VehicleModel(
      id: json['id'] ?? '',
      ownerId: json['ownerId'] ?? '',
      brand: json['brand'] ?? '',
      modelName: json['modelName'] ?? '',
      year: json['year'] ?? 2020,
      city: json['city'] ?? '',
      address: json['address'] ?? '',
      images: List<String>.from(json['images'] ?? []),

      // Extraction de la description (avec valeur par défaut)
      description:
          json['description'] ??
          'Aucune description fournie par le propriétaire.',

      registrationPlateUrl: json['registrationPlateUrl'] ?? '',
      registrationDocumentUrl: json['registrationDocumentUrl'] ?? '',
      insuranceCertificateUrl: json['insuranceCertificateUrl'] ?? '',
      validationStatus: json['validationStatus'] ?? 'En attente',
      isForRent: json['isForRent'] ?? false,
      rentPricePerDay: json['rentPricePerDay']?.toDouble(),
      securityDeposit: json['securityDeposit']?.toDouble(),
      rentPriceWithDriver: json['rentPriceWithDriver']?.toDouble(),
      withDriverOption: json['withDriverOption'],
      isForSale: json['isForSale'] ?? false,
      salePrice: json['salePrice']?.toDouble(),
      seats: json['seats'] ?? 5,
      gearbox: json['gearbox'] ?? 'Manuelle',
      fuelType: json['fuelType'] ?? 'Essence',
      hasAC: json['hasAC'] ?? true,
      reviews:
          (json['reviews'] as List<dynamic>?)
              ?.map((e) => ReviewModel.fromJson(e))
              .toList() ??
          [],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ownerId': ownerId,
      'brand': brand,
      'modelName': modelName,
      'year': year,
      'city': city,
      'address': address,
      'images': images,

      'description': description,

      'registrationPlateUrl': registrationPlateUrl,
      'registrationDocumentUrl': registrationDocumentUrl,
      'insuranceCertificateUrl': insuranceCertificateUrl,
      'validationStatus': validationStatus,
      'isForRent': isForRent,
      'rentPricePerDay': rentPricePerDay,
      'securityDeposit': securityDeposit,
      'withDriverOption': withDriverOption,
      'rentPriceWithDriver': rentPriceWithDriver,
      'isForSale': isForSale,
      'salePrice': salePrice,
      'seats': seats,
      'gearbox': gearbox,
      'fuelType': fuelType,
      'hasAC': hasAC,
      'reviews': reviews.map((e) => e.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
