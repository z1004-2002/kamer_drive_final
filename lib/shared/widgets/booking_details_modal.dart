import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kamer_drive_final/core/constants/colors.dart';
import '../../models/unified_history_item_model.dart';

void showBookingDetailsModal(BuildContext context, UnifiedHistoryItem item) {
  // 1. DÉTERMINER LES RÔLES
  String targetUserId = item.isMyListing ? item.clientId : item.ownerId;
  String targetRole = item.isMyListing
      ? (item.type == 'Location' ? 'Locataire' : 'Acheteur')
      : 'Propriétaire';

  // 2. CODE COULEUR POUR LE TYPE DE TRANSACTION
  Color typeColor = item.type == 'Location'
      ? kPrimaryColor
      : Colors.orange.shade700;

  // 3. CODE COULEUR STRICT POUR LE STATUT (Vert, Orange, Rouge)
  Color statusColor;
  Color statusBgColor;
  IconData statusIcon;

  if ([
    'Terminé',
    'Confirmé',
    'Fonds Validés',
    'En cours',
  ].contains(item.status)) {
    statusColor = Colors.green.shade700;
    statusBgColor = Colors.green.shade50;
    statusIcon = Icons.check_circle;
  } else if (['Annulé', 'Rejeté'].contains(item.status)) {
    statusColor = Colors.red.shade700;
    statusBgColor = Colors.red.shade50;
    statusIcon = Icons.cancel;
  } else {
    // En attente, Négociation, Réservé
    statusColor = Colors.orange.shade700;
    statusBgColor = Colors.orange.shade50;
    statusIcon = Icons.schedule;
  }

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) {
      return Container(
        height: MediaQuery.of(context).size.height * 0.88,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Petite barre de drag en haut
            Center(
              child: Container(
                width: 50,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 15),

            // --- HEADER : TITRE ET BADGE DE STATUT ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Détails de la ${item.type}",
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      "ID: ${item.bookingId}",
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 11,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),
                // BADGE DE STATUT AVEC CODE COULEUR
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: statusBgColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: statusColor.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(statusIcon, size: 14, color: statusColor),
                      const SizedBox(width: 5),
                      Text(
                        item.status.toUpperCase(),
                        style: TextStyle(
                          color: statusColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 30),

            // --- CORPS DE LA MODALE ---
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. LE VÉHICULE CONCERNÉ
                    const Text(
                      "Véhicule",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: Colors.grey.shade200),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.02),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: lPrimaryColor,
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: item.imageUrl.startsWith('http')
                                  ? Image.network(
                                      item.imageUrl,
                                      fit: BoxFit.cover,
                                    )
                                  : Image.asset(
                                      'assets/images/placeholder.png',
                                      fit: BoxFit.cover,
                                    ),
                            ),
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.vehicleName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.calendar_month,
                                      size: 14,
                                      color: Colors.grey.shade500,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      item.dateInfo,
                                      style: TextStyle(
                                        color: Colors.grey.shade600,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: typeColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  child: Text(
                                    item.type,
                                    style: TextStyle(
                                      color: typeColor,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 25),

                    // 2. DÉTAILS FINANCIERS
                    const Text(
                      "Récapitulatif financier",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: statusBgColor.withOpacity(
                          0.5,
                        ), // Le fond s'adapte au statut !
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: statusColor.withOpacity(0.3)),
                      ),
                      child: Column(
                        children: [
                          if (item.type == 'Location') ...[
                            _buildInfoRow(
                              "Caution exigée",
                              "${item.originalModel['securityDeposit']?.toInt() ?? 0} FCFA",
                              icon: Icons.shield_outlined,
                            ),
                            const SizedBox(height: 12),
                            _buildInfoRow(
                              "Chauffeur inclus",
                              item.originalModel['includesDriver'] == true
                                  ? "Oui"
                                  : "Non",
                              icon: Icons.person_outline,
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              child: Divider(
                                color: statusColor.withOpacity(0.2),
                              ),
                            ),
                          ],
                          _buildInfoRow(
                            "Total ${item.type == 'Vente' ? 'proposé' : 'à payer'}",
                            "${item.totalPrice.toInt()} FCFA",
                            isBold: true,
                            color:
                                statusColor, // Le prix prend la couleur du statut
                            icon: Icons.payments_outlined,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 25),

                    // 3. L'AUTRE PARTIE (FutureBuilder)
                    Text(
                      "Contact du $targetRole",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 10),
                    FutureBuilder<DocumentSnapshot>(
                      future: FirebaseFirestore.instance
                          .collection('users')
                          .doc(targetUserId)
                          .get(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        if (!snapshot.hasData || !snapshot.data!.exists) {
                          return Container(
                            padding: const EdgeInsets.all(15),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: const Text(
                              "Informations utilisateur indisponibles.",
                              style: TextStyle(color: Colors.grey),
                            ),
                          );
                        }

                        final user =
                            snapshot.data!.data() as Map<String, dynamic>;
                        return Container(
                          padding: const EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(color: Colors.grey.shade200),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.02),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 28,
                                backgroundColor: lPrimaryColor,
                                backgroundImage:
                                    user['avatarUrl']?.isNotEmpty == true
                                    ? NetworkImage(user['avatarUrl'])
                                    : null,
                                child: user['avatarUrl']?.isEmpty == true
                                    ? const Icon(
                                        Icons.person,
                                        color: kPrimaryColor,
                                        size: 30,
                                      )
                                    : null,
                              ),
                              const SizedBox(width: 15),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "${user['firstName']} ${user['lastName']}",
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(4),
                                          decoration: BoxDecoration(
                                            color: Colors.green.shade50,
                                            shape: BoxShape.circle,
                                          ),
                                          child: Icon(
                                            Icons.phone,
                                            size: 12,
                                            color: Colors.green.shade700,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          user['phone'] ?? 'Non renseigné',
                                          style: TextStyle(
                                            color: Colors.grey.shade700,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(4),
                                          decoration: BoxDecoration(
                                            color: Colors.blue.shade50,
                                            shape: BoxShape.circle,
                                          ),
                                          child: Icon(
                                            Icons.email,
                                            size: 12,
                                            color: Colors.blue.shade700,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            user['email'] ?? '',
                                            style: TextStyle(
                                              color: Colors.grey.shade700,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),

            // BOUTON FERMER EN BAS
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey.shade100,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                child: Text(
                  "Fermer les détails",
                  style: TextStyle(
                    color: Colors.grey.shade800,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}

// Helper mis à jour pour inclure une icône
Widget _buildInfoRow(
  String label,
  String value, {
  bool isBold = false,
  Color color = Colors.black87,
  IconData? icon,
}) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Row(
        children: [
          if (icon != null) ...[
            Icon(icon, size: 16, color: Colors.grey.shade500),
            const SizedBox(width: 8),
          ],
          Text(
            label,
            style: TextStyle(color: Colors.grey.shade700, fontSize: 14),
          ),
        ],
      ),
      Text(
        value,
        style: TextStyle(
          fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
          fontSize: isBold ? 18 : 14,
          color: color,
        ),
      ),
    ],
  );
}
