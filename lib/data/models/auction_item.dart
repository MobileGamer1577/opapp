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
    // Flexible Feldnamen – API kann verschiedene Keys verwenden
    final itemName = json['itemName']?.toString() ??
        json['name']?.toString() ??
        json['item']?.toString() ??
        json['title']?.toString() ??
        'Unbekanntes Item';

    final currentBid = (json['currentBid'] as num?)?.toDouble() ??
        (json['bid'] as num?)?.toDouble() ??
        (json['current_bid'] as num?)?.toDouble() ??
        (json['price'] as num?)?.toDouble() ??
        0.0;

    final buyNowPrice = (json['buyNowPrice'] as num?)?.toDouble() ??
        (json['buyNow'] as num?)?.toDouble() ??
        (json['buy_now'] as num?)?.toDouble() ??
        (json['instantBuy'] as num?)?.toDouble();

    // Endzeit: endsAt, end_time, expiry, expiration, expires
    final endsAtRaw = json['endsAt']?.toString() ??
        json['end_time']?.toString() ??
        json['expiry']?.toString() ??
        json['expiration']?.toString() ??
        json['expires']?.toString();

    final endsAt = endsAtRaw != null
        ? DateTime.tryParse(endsAtRaw) ?? DateTime.now()
        : DateTime.now();

    final sellerName = json['sellerName']?.toString() ??
        json['seller']?.toString() ??
        json['owner']?.toString() ??
        json['creator']?.toString() ??
        'Unbekannt';

    // Enchants und Lore als flexible Liste
    List<String> parseStringList(dynamic raw) {
      if (raw is List) return raw.map((e) => e.toString()).toList();
      if (raw is String && raw.isNotEmpty) return [raw];
      return [];
    }

    return AuctionItem(
      id: json['id']?.toString() ?? json['uuid']?.toString() ?? '',
      itemName: itemName,
      category: json['category']?.toString() ?? 'Sonstiges',
      currentBid: currentBid,
      buyNowPrice: buyNowPrice,
      amount: (json['amount'] as num?)?.toInt() ??
          (json['quantity'] as num?)?.toInt() ??
          (json['count'] as num?)?.toInt() ??
          1,
      endsAt: endsAt,
      sellerName: sellerName,
      enchants: parseStringList(json['enchants'] ?? json['enchantments']),
      lore: parseStringList(json['lore'] ?? json['description']),
    );
  }

  /// Verbleibende Zeit bis Auktionsende
  Duration get timeLeft => endsAt.difference(DateTime.now());

  bool get isExpired => timeLeft.isNegative;
  bool get hasEnchants => enchants.isNotEmpty;
  bool get hasLore => lore.isNotEmpty;
  bool get hasBuyNow => buyNowPrice != null;
}
