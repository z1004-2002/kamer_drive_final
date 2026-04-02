import 'package:cloud_firestore/cloud_firestore.dart';

enum NotificationType { info, success, warning, error }

class NotificationModel {
  final String id;
  final String userId; // Destinataire de la notification
  final String title;
  final String message;
  final NotificationType type;
  final DateTime createdAt;
  final bool isRead;
  final String? route; // La route pour la redirection (ex: '/history')

  NotificationModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.message,
    required this.type,
    required this.createdAt,
    this.isRead = false,
    this.route,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json, String docId) {
    return NotificationModel(
      id: docId,
      userId: json['userId'] ?? '',
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      type: _parseType(json['type']),
      createdAt: json['createdAt'] != null
          ? (json['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      isRead: json['isRead'] ?? false,
      route: json['route'],
    );
  }

  Map<String, dynamic> toJson() => {
    'userId': userId,
    'title': title,
    'message': message,
    'type': type.toString().split('.').last,
    'createdAt': Timestamp.fromDate(createdAt),
    'isRead': isRead,
    'route': route,
  };

  static NotificationType _parseType(String? typeStr) {
    switch (typeStr) {
      case 'success':
        return NotificationType.success;
      case 'warning':
        return NotificationType.warning;
      case 'error':
        return NotificationType.error;
      case 'info':
      default:
        return NotificationType.info;
    }
  }
}
