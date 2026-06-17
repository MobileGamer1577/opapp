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
    // ── Das Item ist ein verschachteltes Objekt ───────────
    // API-Format: { "item": { "displayName": "...", "lore": [...], ... } }
    final itemData = json['item'] as Map<String, dynamic>? ?? {};

    // Name aus item.displayName oder Fallbacks
    final itemName = itemData['displayName']?.toString()
                  ?? itemData['name']?.toString()
                  ?? json['itemName']?.toString()
                  ?? json['name']?.toString()
                  ?? _formatMaterial(itemData['material']?.toString() ?? '')
                  ?? 'Unbekanntes Item';

    // Menge aus verschachteltem item oder direkt
    final amount = (itemData['amount'] as num?)?.toInt()
                ?? (json['amount']    as num?)?.toInt()
                ?? 1;

    // Lore: Liste, leere Strings rausfiltern
    final lore = _parseStringList(itemData['lore'] ?? json['lore'])
        .where((s) => s.isNotEmpty)
        .toList();

    // Enchants: kann {} (Map) oder [] (Liste) sein
    final enchants = _parseEnchants(
      itemData['enchantments'] ?? itemData['enchants'] ??
      json['enchantments']    ?? json['enchants'],
    );

    // Endzeit
    final endsAtRaw = json['endsAt']?.toString()
                   ?? json['end_time']?.toString()
                   ?? json['expiry']?.toString()
                   ?? json['expires']?.toString();
    final endsAt = endsAtRaw != null
        ? DateTime.tryParse(endsAtRaw) ?? DateTime.now()
        : DateTime.now();

    // Verkäufer – kann UUID oder Name sein
    final sellerName = json['sellerName']?.toString()
                    ?? json['seller']?.toString()
                    ?? json['owner']?.toString()
                    ?? 'Unbekannt';

    return AuctionItem(
      id:          json['id']?.toString() ?? json['uuid']?.toString() ?? '',
      itemName:    itemName,
      category:    json['category']?.toString() ?? 'Sonstiges',
      currentBid:  (json['currentBid']  as num?)?.toDouble()
                ?? (json['bid']         as num?)?.toDouble()
                ?? (json['current_bid'] as num?)?.toDouble()
                ?? 0.0,
      buyNowPrice: (json['buyNowPrice'] as num?)?.toDouble()
                ?? (json['buyNow']      as num?)?.toDouble()
                ?? (json['buy_now']     as num?)?.toDouble(),
      amount:      amount,
      endsAt:      endsAt,
      sellerName:  sellerName,
      enchants:    enchants,
      lore:        lore,
    );
  }

  // ── Hilfsmethoden ──────────────────────────────────────

  /// ACACIA_LEAVES → Acacia Leaves
  static String? _formatMaterial(String? material) {
    if (material == null || material.isEmpty) return null;
    return material.split('_')
        .map((w) => w.isEmpty ? '' : '${w[0].toUpperCase()}${w.substring(1).toLowerCase()}')
        .join(' ');
  }

  /// Parst Lore-Listen
  static List<String> _parseStringList(dynamic raw) {
    if (raw is List) return raw.map((e) => e.toString()).toList();
    if (raw is String && raw.isNotEmpty) return [raw];
    return [];
  }

  /// Parst Enchants – kann [] Liste oder {} Map sein
  static List<String> _parseEnchants(dynamic raw) {
    if (raw is List) {
      return raw.map((e) => e.toString()).toList();
    }
    if (raw is Map && raw.isNotEmpty) {
      // { "SHARPNESS": 5, "UNBREAKING": 3 } → ["Sharpness 5", "Unbreaking 3"]
      return raw.entries.map((e) {
        final name = e.key.toString().split('_')
            .map((w) => '${w[0].toUpperCase()}${w.substring(1).toLowerCase()}')
            .join(' ');
        return '$name ${e.value}';
      }).toList();
    }
    return [];
  }

  Duration get timeLeft  => endsAt.difference(DateTime.now());
  bool get isExpired     => timeLeft.isNegative;
  bool get hasEnchants   => enchants.isNotEmpty;
  bool get hasLore       => lore.isNotEmpty;
  bool get hasBuyNow     => buyNowPrice != null;
}
