import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:kamer_drive_final/core/constants/colors.dart';
import '../../../models/notification_model.dart';
import '../providers/notification_provider.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    final notifProvider = context.watch<NotificationProvider>();
    final notifications = notifProvider.notifications;

    return Scaffold(
      backgroundColor: kBackgroundColor,
      body: Stack(
        children: [
          // --- BACKGROUND CIRCLES ---
          Positioned(
            left: -size.width * 0.3,
            bottom: size.height * 0.4,
            child: Container(
              width: size.width * 0.6,
              height: size.width * 0.6,
              decoration: const BoxDecoration(
                color: kSecondaryColor,
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            bottom: -size.width * 0.2,
            right: -size.width * 0.4,
            child: Container(
              width: size.width * 0.7,
              height: size.width * 0.7,
              decoration: const BoxDecoration(
                color: kSecondaryColor,
                shape: BoxShape.circle,
              ),
            ),
          ),

          // --- CONTENT ---
          Column(
            children: [
              // --- HEADER DÉGRADÉ ---
              Container(
                height: 120,
                width: double.infinity,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [kPrimaryColor, dPrimaryColor],
                  ),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                ),
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(
                                Icons.arrow_back_ios_new,
                                color: Colors.white,
                              ),
                              onPressed: () => context.pop(),
                            ),
                            const SizedBox(width: 5),
                            const Text(
                              "Mes Notifications",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        if (notifProvider.unreadCount > 0)
                          IconButton(
                            icon: const Icon(
                              Icons.done_all,
                              color: Colors.white,
                            ),
                            onPressed: () => notifProvider.markAllAsRead(),
                            tooltip: "Tout marquer comme lu",
                          ),
                      ],
                    ),
                  ),
                ),
              ),

              // --- LISTE ---
              Expanded(
                child: notifProvider.isLoading
                    ? const Center(
                        child: CircularProgressIndicator(color: kPrimaryColor),
                      )
                    : notifications.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        padding: const EdgeInsets.only(
                          top: 20,
                          bottom: 40,
                          left: 20,
                          right: 20,
                        ),
                        physics: const BouncingScrollPhysics(),
                        itemCount: notifications.length,
                        itemBuilder: (context, index) {
                          return _buildNotificationCard(
                            notifications[index],
                            notifProvider,
                          );
                        },
                      ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(
    NotificationModel notif,
    NotificationProvider provider,
  ) {
    Color iconColor;
    IconData icon;
    Color bgColor;

    switch (notif.type) {
      case NotificationType.success:
        iconColor = Colors.green.shade700;
        icon = Icons.check_circle;
        bgColor = Colors.green.shade50;
        break;
      case NotificationType.warning:
        iconColor = Colors.orange.shade700;
        icon = Icons.warning_rounded;
        bgColor = Colors.orange.shade50;
        break;
      case NotificationType.error:
        iconColor = Colors.red.shade700;
        icon = Icons.cancel;
        bgColor = Colors.red.shade50;
        break;
      case NotificationType.info:
      default:
        iconColor = kPrimaryColor;
        icon = Icons.info;
        bgColor = lPrimaryColor;
        break;
    }

    return Dismissible(
      key: Key(notif.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => provider.deleteNotification(notif.id),
      background: Container(
        margin: const EdgeInsets.only(bottom: 15),
        padding: const EdgeInsets.only(right: 20),
        alignment: Alignment.centerRight,
        decoration: BoxDecoration(
          color: Colors.red.shade50,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.red.shade200),
        ),
        child: Icon(Icons.delete_outline, color: Colors.red.shade700),
      ),
      child: GestureDetector(
        onTap: () {
          if (!notif.isRead) provider.markAsRead(notif.id);

          // Redirection propre si la route existe
          if (notif.route != null && notif.route!.isNotEmpty) {
            context.go(notif.route!);
          }
        },
        child: Container(
          margin: const EdgeInsets.only(bottom: 15),
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: notif.isRead ? Colors.white : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: notif.isRead
                  ? Colors.grey.shade200
                  : iconColor.withOpacity(0.5),
              width: notif.isRead ? 1.0 : 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: notif.isRead ? Colors.grey.shade100 : bgColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: notif.isRead ? Colors.grey.shade500 : iconColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            notif.title,
                            style: TextStyle(
                              fontWeight: notif.isRead
                                  ? FontWeight.w600
                                  : FontWeight.bold,
                              fontSize: 15,
                              color: notif.isRead
                                  ? Colors.grey.shade700
                                  : Colors.black87,
                            ),
                          ),
                        ),
                        if (!notif.isRead)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Colors.redAccent,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Text(
                      notif.message,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      DateFormat('dd MMM yyyy, HH:mm').format(notif.createdAt),
                      style: TextStyle(
                        color: Colors.grey.shade400,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.notifications_off_outlined,
          size: 60,
          color: Colors.grey.shade300,
        ),
        const SizedBox(height: 15),
        const Text(
          "Vous n'avez aucune notification.",
          style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
