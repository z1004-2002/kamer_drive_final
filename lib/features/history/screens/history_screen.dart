import 'package:flutter/material.dart';
import 'package:kamer_drive_final/models/unified_history_item_model.dart';
import 'package:kamer_drive_final/shared/widgets/booking_details_modal.dart';
import 'package:provider/provider.dart';
import 'package:kamer_drive_final/core/constants/colors.dart';
import 'package:kamer_drive_final/core/utils/snackbar_utils.dart';
import '../providers/history_provider.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  bool _isOwnerMode = false;
  String _selectedFilter = 'Toutes';
  final List<String> _filters = [
    'Toutes',
    'En cours/Attente',
    'Terminées',
    'Annulées',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HistoryProvider>().fetchUserHistory();
    });
  }

  // --- FILTRES MIS À JOUR AVEC LES NOUVEAUX STATUTS ---
  bool _matchesFilter(String rawStatus) {
    if (_selectedFilter == 'Toutes') return true;
    if (_selectedFilter == 'Terminées') return rawStatus == 'Terminé';
    if (_selectedFilter == 'Annulées') {
      return rawStatus == 'Annulé' || rawStatus == 'Rejeté';
    }
    if (_selectedFilter == 'En cours/Attente') {
      return [
        'En attente',
        'Confirmé',
        'Négociation',
        'Offre Acceptée',
        'Fonds Validés',
        'En cours',
        'Véhicule Rendu',
      ].contains(rawStatus);
    }
    return false;
  }

  Future<void> _handleBookingAction(
    UnifiedHistoryItem item,
    String newStatus,
    bool makeAvailable,
    String successMessage,
  ) async {
    try {
      // Le code est beaucoup plus propre ici maintenant !
      await context.read<HistoryProvider>().updateBookingStatus(
        item: item,
        newStatus: newStatus,
        makeVehicleAvailable: makeAvailable,
      );

      if (mounted) SnackbarUtils.showSuccess(context, successMessage);
    } catch (e) {
      if (mounted) {
        SnackbarUtils.showError(context, "Erreur lors de l'opération.");
      }
    }
  }

  void _showConfirmationDialog({
    required String title,
    required String message,
    required VoidCallback onConfirm,
    bool isDestructive = false,
  }) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        content: Text(
          message,
          style: TextStyle(color: Colors.grey.shade700, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Annuler", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              onConfirm();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: isDestructive ? Colors.red : kPrimaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 0,
            ),
            child: const Text(
              "Confirmer",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    final historyProvider = context.watch<HistoryProvider>();

    List<UnifiedHistoryItem> sourceList = _isOwnerMode
        ? historyProvider.ownerHistory
        : historyProvider.clientHistory;
    List<UnifiedHistoryItem> displayedList = sourceList
        .where((item) => _matchesFilter(item.status))
        .toList();

    return Scaffold(
      backgroundColor: kBackgroundColor,
      body: Stack(
        children: [
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
          Column(
            children: [
              // --- HEADER ---
              Container(
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).padding.top,
                  bottom: 20,
                ),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [kPrimaryColor, dPrimaryColor],
                  ),
                  borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(30),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 10,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 30),
                      child: Row(
                        children: [
                          SizedBox(height: 50),
                          Text(
                            "Mon Historique",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 15),
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      padding: const EdgeInsets.all(4),
                      height: 45,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () => setState(() => _isOwnerMode = false),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: !_isOwnerMode
                                      ? Colors.white
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Center(
                                  child: Text(
                                    "Mes Achats/Locations",
                                    style: TextStyle(
                                      color: !_isOwnerMode
                                          ? kPrimaryColor
                                          : Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () => setState(() => _isOwnerMode = true),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: _isOwnerMode
                                      ? Colors.white
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Center(
                                  child: Text(
                                    "Mes Véhicules",
                                    style: TextStyle(
                                      color: _isOwnerMode
                                          ? kPrimaryColor
                                          : Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // --- BARRE DE FILTRES ---
              Container(
                height: 45,
                margin: const EdgeInsets.only(top: 15),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  itemCount: _filters.length,
                  itemBuilder: (context, index) {
                    bool isSelected = _selectedFilter == _filters[index];
                    return GestureDetector(
                      onTap: () =>
                          setState(() => _selectedFilter = _filters[index]),
                      child: Container(
                        margin: const EdgeInsets.only(right: 10),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected ? kPrimaryColor : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected
                                ? kPrimaryColor
                                : Colors.grey.shade300,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            _filters[index],
                            style: TextStyle(
                              color: isSelected
                                  ? Colors.white
                                  : Colors.grey.shade700,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              // --- LISTE DES RÉSULTATS ---
              Expanded(
                child: historyProvider.isLoadingHistory
                    ? const Center(
                        child: CircularProgressIndicator(color: kPrimaryColor),
                      )
                    : displayedList.isEmpty
                    ? _buildEmptyMessage()
                    : RefreshIndicator(
                        onRefresh: () =>
                            context.read<HistoryProvider>().fetchUserHistory(),
                        color: kPrimaryColor,
                        child: ListView.builder(
                          physics: const AlwaysScrollableScrollPhysics(
                            parent: BouncingScrollPhysics(),
                          ),
                          padding: const EdgeInsets.only(
                            top: 15,
                            bottom: 40,
                            left: 20,
                            right: 20,
                          ),
                          itemCount: displayedList.length,
                          itemBuilder: (context, index) =>
                              _buildHistoryCard(displayedList[index]),
                        ),
                      ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- DESIGN DE LA CARTE ---
  Widget _buildHistoryCard(UnifiedHistoryItem item) {
    Color typeColor = item.type == 'Location'
        ? kPrimaryColor
        : Colors.orange.shade700;
    Color statusColor =
        Colors.orange.shade700; // Couleur par défaut pour l'attente

    // Couleurs adaptées au nouveau flux
    if ([
      'Confirmé',
      'Offre Acceptée',
      'Fonds Validés',
      'En cours',
      'Véhicule Rendu',
    ].contains(item.status)) {
      statusColor = Colors.blue.shade700;
    } else if (item.status == 'Terminé') {
      statusColor = Colors.green.shade700;
    } else if (['Annulé', 'Rejeté'].contains(item.status)) {
      statusColor = Colors.red.shade700;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: () => showBookingDetailsModal(context, item),
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      color: lPrimaryColor,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: item.imageUrl.startsWith('http')
                          ? Image.network(item.imageUrl, fit: BoxFit.cover)
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
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                item.vehicleName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: typeColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
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
                        const SizedBox(height: 5),
                        Text(
                          item.dateInfo,
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          "${item.totalPrice.toInt()} FCFA",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Row(
                          children: [
                            Icon(Icons.circle, color: statusColor, size: 8),
                            const SizedBox(width: 5),
                            Text(
                              item.status,
                              style: TextStyle(
                                color: statusColor,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          _buildActionButtons(item),
        ],
      ),
    );
  }

  // --- LOGIQUE METIER : MACHINE À ÉTATS ---
  Widget _buildActionButtons(UnifiedHistoryItem item) {
    List<Widget> buttons = [];
    bool isOwner = item.isMyListing;

    // ==========================================
    // 1. FLUX LOCATION
    // ==========================================
    if (item.type == 'Location') {
      if (!isOwner) {
        // --- VUE CLIENT (Location) ---
        if (item.status == 'En attente') {
          buttons.add(
            _actionBtn(
              "Annuler la demande",
              Colors.red,
              true,
              () => _showConfirmationDialog(
                title: "Annuler",
                message: "Voulez-vous annuler votre demande de réservation ?",
                isDestructive: true,
                onConfirm: () => _handleBookingAction(
                  item,
                  "Annulé",
                  true,
                  "Demande annulée.",
                ),
              ),
            ),
          );
        } else if (item.status == 'Fonds Validés') {
          // Étape 4: Client récupère le véhicule
          buttons.add(
            _actionBtn(
              "J'ai récupéré le véhicule",
              kPrimaryColor,
              false,
              () => _showConfirmationDialog(
                title: "Véhicule récupéré",
                message:
                    "Confirmez-vous que le propriétaire vous a remis les clés et le véhicule ?",
                onConfirm: () => _handleBookingAction(
                  item,
                  "En cours",
                  false,
                  "Bonne route !",
                ),
              ),
            ),
          );
        } else if (item.status == 'Véhicule Rendu') {
          // Étape 6 (Finale): Client confirme avoir reçu la caution
          buttons.add(
            _actionBtn(
              "Caution récupérée",
              Colors.green,
              false,
              () => _showConfirmationDialog(
                title: "Caution récupérée",
                message:
                    "Confirmez-vous avoir récupéré votre caution ? Cela clôturera le dossier.",
                onConfirm: () => _handleBookingAction(
                  item,
                  "Terminé",
                  true,
                  "Location terminée avec succès !",
                ),
              ),
            ),
          );
        }
      } else {
        // --- VUE PROPRIÉTAIRE (Location) ---
        if (item.status == 'En attente') {
          // Étape 2: Proprio accepte ou refuse
          buttons.add(
            _actionBtn(
              "Refuser",
              Colors.red,
              true,
              () => _showConfirmationDialog(
                title: "Refuser",
                message: "Voulez-vous rejeter cette demande ?",
                isDestructive: true,
                onConfirm: () => _handleBookingAction(
                  item,
                  "Rejeté",
                  true,
                  "Demande refusée.",
                ),
              ),
            ),
          );
          buttons.add(const SizedBox(width: 10));
          buttons.add(
            _actionBtn(
              "Accepter",
              kPrimaryColor,
              false,
              () => _showConfirmationDialog(
                title: "Accepter",
                message: "Voulez-vous accepter cette location ?",
                onConfirm: () => _handleBookingAction(
                  item,
                  "Confirmé",
                  false,
                  "Location acceptée !",
                ),
              ),
            ),
          );
        } else if (item.status == 'Confirmé') {
          // Étape 3: Proprio reçoit l'argent
          buttons.add(
            _actionBtn(
              "Paiement & Caution reçus",
              Colors.blue,
              false,
              () => _showConfirmationDialog(
                title: "Paiement reçu",
                message:
                    "Confirmez-vous avoir reçu l'argent et la caution du client ?",
                onConfirm: () => _handleBookingAction(
                  item,
                  "Fonds Validés",
                  false,
                  "Fonds validés ! Au client de confirmer la remise des clés.",
                ),
              ),
            ),
          );
        } else if (item.status == 'En cours') {
          // Étape 5: Proprio confirme le retour du véhicule
          buttons.add(
            _actionBtn(
              "Véhicule restitué",
              Colors.orange.shade700,
              false,
              () => _showConfirmationDialog(
                title: "Retour du véhicule",
                message:
                    "Le client vous a-t-il bien ramené le véhicule ? (N'oubliez pas de lui rendre sa caution)",
                onConfirm: () => _handleBookingAction(
                  item,
                  "Véhicule Rendu",
                  false,
                  "Véhicule rendu, en attente de la confirmation du client.",
                ),
              ),
            ),
          );
        }
      }
    }
    // ==========================================
    // 2. FLUX VENTE
    // ==========================================
    else if (item.type == 'Vente') {
      if (!isOwner) {
        // --- VUE ACHETEUR (Vente) ---
        if (item.status == 'Négociation') {
          buttons.add(
            _actionBtn(
              "Annuler l'offre",
              Colors.red,
              true,
              () => _showConfirmationDialog(
                title: "Annuler l'offre",
                message: "Voulez-vous annuler votre offre d'achat ?",
                isDestructive: true,
                onConfirm: () => _handleBookingAction(
                  item,
                  "Annulé",
                  true,
                  "Offre annulée.",
                ),
              ),
            ),
          );
        } else if (item.status == 'Fonds Validés') {
          // Étape finale : L'acheteur confirme qu'il a eu la voiture
          buttons.add(
            _actionBtn(
              "Véhicule réceptionné",
              Colors.green,
              false,
              () => _showConfirmationDialog(
                title: "Confirmation d'achat",
                message:
                    "Confirmez-vous avoir reçu le véhicule et les documents ? Cela clôturera la transaction.",
                onConfirm: () => _handleBookingAction(
                  item,
                  "Terminé",
                  false,
                  "Félicitations pour votre achat !",
                ),
              ),
            ),
          );
        }
      } else {
        // --- VUE VENDEUR (Vente) ---
        if (item.status == 'Négociation') {
          // Étape 2: Vendeur accepte l'offre
          buttons.add(
            _actionBtn(
              "Refuser",
              Colors.red,
              true,
              () => _showConfirmationDialog(
                title: "Refuser",
                message: "Voulez-vous rejeter cette offre ?",
                isDestructive: true,
                onConfirm: () => _handleBookingAction(
                  item,
                  "Rejeté",
                  true,
                  "Offre refusée.",
                ),
              ),
            ),
          );
          buttons.add(const SizedBox(width: 10));
          buttons.add(
            _actionBtn(
              "Accepter l'offre",
              kPrimaryColor,
              false,
              () => _showConfirmationDialog(
                title: "Accepter",
                message: "Accepter cette offre d'achat ?",
                onConfirm: () => _handleBookingAction(
                  item,
                  "Offre Acceptée",
                  false,
                  "Offre acceptée, en attente du paiement.",
                ),
              ),
            ),
          );
        } else if (item.status == 'Offre Acceptée') {
          // Étape 3: Vendeur confirme l'argent
          buttons.add(
            _actionBtn(
              "Fonds reçus",
              Colors.blue,
              false,
              () => _showConfirmationDialog(
                title: "Fonds reçus",
                message: "Confirmez-vous avoir reçu la totalité du paiement ?",
                onConfirm: () => _handleBookingAction(
                  item,
                  "Fonds Validés",
                  false,
                  "Paiement validé. À l'acheteur de confirmer la réception.",
                ),
              ),
            ),
          );
        }
      }
    }

    if (buttons.isEmpty) return const SizedBox.shrink();

    return Column(
      children: [
        Divider(height: 1, color: Colors.grey.shade200),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: buttons
                .map((b) => b is SizedBox ? b : Expanded(child: b))
                .toList(),
          ),
        ),
      ],
    );
  }

  Widget _actionBtn(
    String label,
    Color color,
    bool isOutlined,
    VoidCallback onTap,
  ) {
    if (isOutlined) {
      return OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: color.withOpacity(0.5)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.symmetric(vertical: 10),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      );
    } else {
      return ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.symmetric(vertical: 10),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      );
    }
  }

  Widget _buildEmptyMessage() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox_outlined, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 20),
          Text(
            "Aucun élément trouvé.",
            style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
          ),
        ],
      ),
    );
  }
}
