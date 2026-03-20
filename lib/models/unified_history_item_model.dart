class UnifiedHistoryItem {
  final String id;
  final String type; // "Location" ou "Vente"
  final String status;
  final String vehicleName;
  final String imageUrl;
  final String dateInfo;
  final double totalPrice;
  final dynamic originalModel;

  // NOUVEAU: Permet de savoir qui est concerné dans ce mock
  final String ownerId;
  final String clientId;

  UnifiedHistoryItem({
    required this.id,
    required this.type,
    required this.status,
    required this.vehicleName,
    required this.imageUrl,
    required this.dateInfo,
    required this.totalPrice,
    required this.originalModel,
    required this.ownerId,
    required this.clientId,
  });
}
