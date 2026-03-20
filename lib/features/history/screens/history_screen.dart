import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kamer_drive_final/core/constants/colors.dart';
import 'package:kamer_drive_final/core/utils/snackbar_utils.dart';
// N'oublie pas d'importer tes modèles (RentalBookingModel, SaleBookingModel, UnifiedHistoryItem, etc.)

// --- (Optionnel ici si déjà défini ailleurs) ---
class UnifiedHistoryItem {
  final String id;
  final String type; // "Location" ou "Vente"
  final String status;
  final String vehicleName;
  final String imageUrl;
  final String dateInfo;
  final double totalPrice;
  final bool isMyListing; // Vrai si je suis le proprio, Faux si je suis client
  final dynamic originalModel;

  UnifiedHistoryItem({
    required this.id,
    required this.type,
    required this.status,
    required this.vehicleName,
    required this.imageUrl,
    required this.dateInfo,
    required this.totalPrice,
    required this.isMyListing,
    required this.originalModel,
  });
}

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  // --- ÉTATS ---
  bool _isOwnerMode = false; // False = Vue Client, True = Vue Propriétaire
  String _selectedFilter = 'Toutes';
  final List<String> _filters = [
    'Toutes',
    'En cours/Attente',
    'Terminées',
    'Annulées',
  ];

  // --- DONNÉES STATIQUES DE TEST BÂTIES SUR TON MODÈLE ---
  final List<UnifiedHistoryItem> _allHistory = [
    // 1. CLIENT : Location en cours
    UnifiedHistoryItem(
      id: "H1",
      type: "Location",
      status: "En cours",
      vehicleName: "Toyota RAV4",
      imageUrl: "assets/images/car1.png",
      dateInfo: "12 Mars - 15 Mars",
      totalPrice: 135000,
      isMyListing: false,
      originalModel: null,
    ),
    // 2. CLIENT : Vente en négociation
    UnifiedHistoryItem(
      id: "H2",
      type: "Vente",
      status: "Négociation",
      vehicleName: "Mercedes Classe C",
      imageUrl: "assets/images/car2.png",
      dateInfo: "Initié le 10 Fév",
      totalPrice: 18000000,
      isMyListing: false,
      originalModel: null,
    ),
    // 3. PROPRIÉTAIRE : Demande de location en attente
    UnifiedHistoryItem(
      id: "H3",
      type: "Location",
      status: "En attente",
      vehicleName: "Suzuki Alto",
      imageUrl: "assets/images/car1.png",
      dateInfo: "20 Avril - 22 Avril",
      totalPrice: 60000,
      isMyListing: true,
      originalModel: null,
    ),
    // 4. PROPRIÉTAIRE : Vente, Fonds validés
    UnifiedHistoryItem(
      id: "H4",
      type: "Vente",
      status: "Fonds Validés",
      vehicleName: "Toyota Prado",
      imageUrl: "assets/images/car2.png",
      dateInfo: "Vendu le 05 Jan",
      totalPrice: 25000000,
      isMyListing: true,
      originalModel: null,
    ),
    // 5. CLIENT : Terminé
    UnifiedHistoryItem(
      id: "H5",
      type: "Location",
      status: "Terminé",
      vehicleName: "Kia Sportage",
      imageUrl: "assets/images/car1.png",
      dateInfo: "01 Jan - 05 Jan",
      totalPrice: 150000,
      isMyListing: false,
      originalModel: null,
    ),
  ];

  // --- LOGIQUE DE FILTRAGE MAPPÉE ---
  // Mappe les statuts réels complexes vers nos 3 filtres simples.
  bool _matchesFilter(String rawStatus) {
    if (_selectedFilter == 'Toutes') return true;

    if (_selectedFilter == 'Terminées') {
      return rawStatus == 'Terminé';
    }
    if (_selectedFilter == 'Annulées') {
      return rawStatus == 'Annulé';
    }
    if (_selectedFilter == 'En cours/Attente') {
      return [
        'En attente',
        'Confirmé',
        'En cours',
        'Négociation',
        'Réservé',
        'Fonds Validés',
      ].contains(rawStatus);
    }
    return false;
  }

  // --- ACTIONS DYNAMIQUES (SNACKBARS) ---
  void _executeAction(String message) {
    SnackbarUtils.showSuccess(context, message);
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    // 1. Filtrer par Rôle (Propriétaire vs Client) ET par Statut (_selectedFilter)
    List<UnifiedHistoryItem> displayedList = _allHistory.where((item) {
      bool roleMatch = item.isMyListing == _isOwnerMode;
      bool statusMatch = _matchesFilter(item.status);
      return roleMatch && statusMatch;
    }).toList();

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
              // --- 1. HEADER DÉGRADÉ ---
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
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
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
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Row(
                        children: [
                          const SizedBox(width: 20, height: 50),
                          const Text(
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

                    // --- 2. SÉLECTEUR DE RÔLE (CLIENT / PROPRIO) ---
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
                                    "Mes Réservations",
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

              // --- 3. BARRE DE FILTRES DES STATUTS ---
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

              // --- 4. LISTE DES RÉSULTATS ---
              Expanded(
                child: displayedList.isEmpty
                    ? _buildEmptyMessage()
                    : ListView.builder(
                        physics: const BouncingScrollPhysics(),
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
            ],
          ),
        ],
      ),
    );
  }

  // --- CARTE D'HISTORIQUE UNIFIÉE ---
  Widget _buildHistoryCard(UnifiedHistoryItem item) {
    // Thème (Location ou Vente)
    Color typeColor = item.type == 'Location'
        ? kPrimaryColor
        : Colors.orange.shade700;

    // Couleur du Statut
    Color statusColor;
    Color statusBgColor;
    if ([
      'En cours',
      'Négociation',
      'Fonds Validés',
      'Confirmé',
    ].contains(item.status)) {
      statusColor = Colors.blue.shade700;
      statusBgColor = Colors.blue.shade50;
    } else if (item.status == 'Terminé') {
      statusColor = Colors.green.shade700;
      statusBgColor = Colors.green.shade50;
    } else if (item.status == 'Annulé') {
      statusColor = Colors.red.shade700;
      statusBgColor = Colors.red.shade50;
    } else {
      // 'En attente', 'Réservé'
      statusColor = Colors.orange.shade700;
      statusBgColor = Colors.orange.shade50;
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
          // --- HAUT : INFOS VÉHICULE ---
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // Image du Véhicule
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    color: lPrimaryColor,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Image.asset(
                      item.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (c, e, s) => const Icon(
                        Icons.directions_car,
                        color: kPrimaryColor,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 15),
                // Détails
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

          // --- BAS : BOUTONS D'ACTION DYNAMIQUES ---
          _buildActionButtons(item),
        ],
      ),
    );
  }

  // --- LOGIQUE DES BOUTONS SELON LE RÔLE ET LE STATUT ---
  Widget _buildActionButtons(UnifiedHistoryItem item) {
    List<Widget> buttons = [];

    // --- VUE CLIENT ---
    if (!item.isMyListing) {
      if (item.type == 'Location' && item.status == 'En cours') {
        buttons.add(
          _actionBtn(
            "Arrêter",
            Colors.red,
            outlined: true,
            () => _executeAction("Demande d'arrêt anticipé envoyée."),
          ),
        );
        buttons.add(const SizedBox(width: 10));
        buttons.add(
          _actionBtn(
            "Prolonger",
            kPrimaryColor,
            outlined: false,
            () => _executeAction("Redirection vers la prolongation..."),
          ),
        );
      } else if (item.type == 'Vente' && item.status == 'Négociation') {
        buttons.add(
          _actionBtn(
            "Améliorer l'offre",
            Colors.orange.shade700,
            outlined: false,
            () => _executeAction("Redirection vers la négociation..."),
          ),
        );
      } else if (item.status == 'Terminé') {
        buttons.add(
          _actionBtn(
            "Noter l'expérience",
            Colors.black87,
            outlined: false,
            () => _executeAction("Ouverture du formulaire d'évaluation..."),
          ),
        );
      }
    }
    // --- VUE PROPRIÉTAIRE ---
    else {
      if (item.type == 'Location' && item.status == 'En attente') {
        buttons.add(
          _actionBtn(
            "Refuser",
            Colors.red,
            outlined: true,
            () => _executeAction("Demande refusée."),
          ),
        );
        buttons.add(const SizedBox(width: 10));
        buttons.add(
          _actionBtn(
            "Accepter",
            kPrimaryColor,
            outlined: false,
            () => _executeAction("Demande de location acceptée !"),
          ),
        );
      } else if (item.type == 'Vente' && item.status == 'Fonds Validés') {
        buttons.add(
          _actionBtn(
            "Confirmer livraison",
            Colors.green,
            outlined: false,
            () => _executeAction("Livraison confirmée. Clôture de la vente."),
          ),
        );
      } else if (item.status == 'Terminé') {
        buttons.add(
          _actionBtn(
            "Noter le client",
            Colors.black87,
            outlined: false,
            () => _executeAction("Ouverture de l'évaluation du client..."),
          ),
        );
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

  // --- WIDGET HELPER POUR GÉNÉRER UN BOUTON ---
  Widget _actionBtn(
    String label,
    Color color,
    VoidCallback onTap, {
    required bool outlined,
  }) {
    if (outlined) {
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
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 13,
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
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
      );
    }
  }

  Widget _buildEmptyMessage() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_outlined, size: 80, color: Colors.grey.shade300),
            const SizedBox(height: 20),
            Text(
              "Aucun élément trouvé pour cette section.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
