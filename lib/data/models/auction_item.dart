/// Repräsentiert eine laufende Auktion im OPSUCHT Auktionshaus
class AuctionItem {
  final String id;
  final String itemName;
  final String category;
  final double currentBid;
  final double? buyNowPrice;
  final int amount;
  final DateTime endsAt;
  final String sellerName;
  final List<String> enchants;
  final List<String> lore;

  const AuctionItem({
    required this.id,
    required this.itemName,
    required this.category,
    required this.currentBid,
    this.buyNowPrice,
    required this.amount,
    required this.endsAt,
    required this.sellerName,
    required this.enchants,
    required this.lore,
  });

  factory AuctionItem.fromJson(Map<String, dynamic> json) {
    return AuctionItem(
      id:           json['id']?.toString()        ?? '',
      itemName:     json['itemName']?.toString()  ?? 'Unbekanntes Item',
      category:     json['category']?.toString()  ?? 'Sonstiges',
      currentBid:   (json['currentBid']  as num?)?.toDouble() ?? 0.0,
      buyNowPrice:  (json['buyNowPrice'] as num?)?.toDouble(),
      amount:       (json['amount']      as num?)?.toInt() ?? 1,
      endsAt: json['endsAt'] != null
          ? DateTime.tryParse(json['endsAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      sellerName: json['sellerName']?.toString() ?? 'Unbekannt',
      enchants: (json['enchants'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      lore: (json['lore'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
    );
  }

  /// Verbleibende Zeit bis Auktionsende
  Duration get timeLeft => endsAt.difference(DateTime.now());

  bool get isExpired => timeLeft.isNegative;

  bool get hasEnchants => enchants.isNotEmpty;
  bool get hasLore      => lore.isNotEmpty;
  bool get hasBuyNow    => buyNowPrice != null;
}
