import 'package:cloud_firestore/cloud_firestore.dart';

import 'review_model.dart'; // N'oublie pas cet import

class UserModel {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String avatarUrl;
  
  // Infos Sécurité / Vérification
  final String address;
  final List<String> idDocuments;
  final List<String>? proofOfAddress;
  final List<ReviewModel> reviews;

  // --- NOUVEAUX CHAMPS DE PROFILAGE ---
  final bool isFirstConnection;
  final bool hasCompletedProfiling;
  final List<String> intents;
  final bool ownsVehicle;

  final DateTime createdAt;

  UserModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.avatarUrl,
    required this.address,
    required this.idDocuments,
    this.proofOfAddress,
    required this.reviews,
    required this.isFirstConnection,
    required this.hasCompletedProfiling,
    required this.intents,
    required this.ownsVehicle,
    required this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      avatarUrl: json['avatarUrl'] ?? '',
      address: json['address'] ?? '',
      idDocuments: List<String>.from(json['idDocuments'] ?? []),
      proofOfAddress: json['proofOfAddress'] != null ? List<String>.from(json['proofOfAddress']) : null,
      reviews: (json['reviews'] as List<dynamic>?)?.map((e) => ReviewModel.fromJson(e)).toList() ?? [],
      isFirstConnection: json['isFirstConnection'] ?? true,
      hasCompletedProfiling: json['hasCompletedProfiling'] ?? false,
      intents: List<String>.from(json['intents'] ?? []),
      ownsVehicle: json['ownsVehicle'] ?? false,
      
      // --- LA CORRECTION EST ICI ---
      createdAt: json['createdAt'] != null 
          ? (json['createdAt'] is Timestamp 
              ? (json['createdAt'] as Timestamp).toDate() // Si c'est un Timestamp Firebase
              : DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()) // Si c'est un String
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'phone': phone,
      'avatarUrl': avatarUrl,
      'address': address,
      'idDocuments': idDocuments,
      'proofOfAddress': proofOfAddress,
      'reviews': reviews.map((e) => e.toJson()).toList(),
 
      'isFirstConnection': isFirstConnection,
      'hasCompletedProfiling': hasCompletedProfiling,
      'intents': intents,
      'ownsVehicle': ownsVehicle,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}