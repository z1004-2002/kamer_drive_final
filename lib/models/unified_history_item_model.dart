class UnifiedHistoryItem {
  final String bookingId; // NOUVEAU : ID de la réservation
  final String
  vehicleId; // NOUVEAU : ID de la voiture (pour remettre isAvailable à true)
  final String type; // "Location" ou "Vente"
  final String status;
  final String vehicleName;
  final String imageUrl;
  final String dateInfo;
  final double totalPrice;
  final dynamic originalModel;
  final String ownerId;
  final String clientId;
  final DateTime createdAt; // Pour trier du plus récent au plus ancien

  UnifiedHistoryItem({
    required this.bookingId,
    required this.vehicleId,
    required this.type,
    required this.status,
    required this.vehicleName,
    required this.imageUrl,
    required this.dateInfo,
    required this.totalPrice,
    required this.originalModel,
    required this.ownerId,
    required this.clientId,
    required this.createdAt,
  });
}
