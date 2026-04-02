import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart'; // NOUVEAU
import '../../../models/notification_model.dart';

class NotificationProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  // Plugin pour les notifications système du téléphone
  final FlutterLocalNotificationsPlugin _localNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  List<NotificationModel> _notifications = [];
  List<NotificationModel> get notifications => _notifications;

  int get unreadCount => _notifications.where((n) => !n.isRead).length;
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  StreamSubscription? _notifSubscription;
  bool _isInitialLoad = true; // Pour ne pas sonner pour les vieilles notifs

  Future<void> initPushNotifications() async {
    final user = _auth.currentUser;
    if (user == null) return;

    // A. Configuration Android (Nouvelle icône blanche)
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@drawable/ic_notification');

    // B. Configuration iOS (NOUVEAU)
    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        );

    // C. Initialisation globale
    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    await _localNotificationsPlugin.initialize(initSettings);

    // Demande d'autorisation système pour FCM
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      String? token = await _messaging.getToken();
      if (token != null) {
        await _firestore.collection('users').doc(user.uid).update({
          'fcmToken': token,
        });
      }
      _messaging.onTokenRefresh.listen((newToken) {
        _firestore.collection('users').doc(user.uid).update({
          'fcmToken': newToken,
        });
      });
    }

    // Lancer l'écoute de Firestore
    fetchMyNotifications();
  }

  // --- 2. ÉCOUTE FIRESTORE ET DÉCLENCHEMENT TÉLÉPHONE ---
  void fetchMyNotifications() {
    final user = _auth.currentUser;
    if (user == null) return;

    _isLoading = true;
    notifyListeners();

    _notifSubscription?.cancel();

    _notifSubscription = _firestore
        .collection('notifications')
        .where('userId', isEqualTo: user.uid)
        // SUPPRESSION DE ORDERBY POUR ÉVITER L'ERREUR D'INDEX FIRESTORE !
        .snapshots()
        .listen((snapshot) {
          // 1. Déclencher une sonnerie/bannière pour les NOUVELLES notifications
          if (!_isInitialLoad) {
            for (var change in snapshot.docChanges) {
              if (change.type == DocumentChangeType.added) {
                final data = change.doc.data();
                if (data != null) {
                  _showSystemNotification(data['title'], data['message']);
                }
              }
            }
          }
          _isInitialLoad = false;

          // 2. Récupérer et convertir les données
          List<NotificationModel> temp = snapshot.docs
              .map((doc) => NotificationModel.fromJson(doc.data(), doc.id))
              .toList();

          // 3. LE TRI SE FAIT ICI, CÔTÉ APPLICATION ! (Résout le bug Firebase)
          temp.sort((a, b) => b.createdAt.compareTo(a.createdAt));

          _notifications = temp;
          _isLoading = false;
          notifyListeners();
        });
  }

  // --- FONCTION MAGIQUE : FAIT APPARAÎTRE LA NOTIFICATION SUR L'ÉCRAN ---
  Future<void> _showSystemNotification(String? title, String? body) async {
    // Détails pour Android
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'kamer_drive_channel',
          'KamerDrive Notifications',
          importance: Importance.max,
          priority: Priority.high,
          icon: '@drawable/ic_notification', // Utilise la nouvelle icône
          color: Color(
            0xFF00B050,
          ), // Remplace par la valeur HEX de ton kPrimaryColor
        );

    // Détails pour iOS (NOUVEAU)
    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotificationsPlugin.show(
      DateTime.now().millisecond,
      title ?? 'Nouvelle alerte',
      body ?? '',
      details,
    );
  }

  // --- 3. ACTIONS UTILISATEUR ---
  Future<void> markAsRead(String notifId) async {
    await _firestore.collection('notifications').doc(notifId).update({
      'isRead': true,
    });
  }

  Future<void> markAllAsRead() async {
    final unreadNotifs = _notifications.where((n) => !n.isRead).toList();
    final batch = _firestore.batch();
    for (var notif in unreadNotifs) {
      final docRef = _firestore.collection('notifications').doc(notif.id);
      batch.update(docRef, {'isRead': true});
    }
    await batch.commit();
  }

  Future<void> deleteNotification(String notifId) async {
    await _firestore.collection('notifications').doc(notifId).delete();
  }

  // --- 4. ENVOYER UNE NOTIFICATION ---
  Future<void> sendNotification({
    required String targetUserId,
    required String title,
    required String message,
    required NotificationType type,
    String? route,
  }) async {
    try {
      final newDoc = _firestore.collection('notifications').doc();
      final notif = NotificationModel(
        id: newDoc.id,
        userId: targetUserId,
        title: title,
        message: message,
        type: type,
        createdAt: DateTime.now(),
        route: route,
      );
      await newDoc.set(notif.toJson());
    } catch (e) {
      debugPrint("Erreur lors de l'envoi de la notification : $e");
    }
  }

  @override
  void dispose() {
    _notifSubscription?.cancel();
    super.dispose();
  }
}
