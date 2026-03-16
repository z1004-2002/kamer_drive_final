import 'package:kamer_drive_final/models/review_model.dart';

class UserModel {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String avatarUrl;
  final String address;
  final List<String> idDocuments; // URLs des pièces d'identité (CNI, Passeport...)
  final List<String>? proofOfAddress; // URLs des justificatifs (Facture ENEO, etc.) - Optionnel
  final List<ReviewModel> reviews; // Liste des ratings avec commentaires

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
      reviews: (json['reviews'] as List<dynamic>?)
              ?.map((e) => ReviewModel.fromJson(e))
              .toList() ?? [],
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
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
      'createdAt': createdAt.toIso8601String(),
    };
  }
}