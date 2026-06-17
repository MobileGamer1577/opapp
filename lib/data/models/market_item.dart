/// Repräsentiert einen Artikel im OPSUCHT Markt
class MarketItem {
  final String id;
  final String name;
  final String category;
  final double? buyPrice;
  final double? sellPrice;
  final int stock;

  const MarketItem({
    required this.id,
    required this.name,
    required this.category,
    this.buyPrice,
    this.sellPrice,
    required this.stock,
  });

  factory MarketItem.fromJson(Map<String, dynamic> json) {
    // Rohname aus API (meistens ACACIA_LEAVES oder ähnlich)
    final rawId = json['material']?.toString() ?? json['id']?.toString() ?? '';

    // Anzeigename: displayName falls vorhanden, sonst Material formatieren
    final name = json['displayName']?.toString()
               ?? json['name']?.toString()
               ?? _formatMaterial(rawId)
               ?? rawId;

    // Kaufpreis – verschiedene Feldnamen
    final buyPrice = (json['buyPrice']  as num?)?.toDouble()
                  ?? (json['buy']       as num?)?.toDouble()
                  ?? (json['buy_price'] as num?)?.toDouble();

    // Verkaufspreis – verschiedene Feldnamen
    final sellPrice = (json['sellPrice']  as num?)?.toDouble()
                   ?? (json['sell']       as num?)?.toDouble()
                   ?? (json['sell_price'] as num?)?.toDouble();

    return MarketItem(
      id:        rawId,
      name:      name,
      category:  json['category']?.toString() ?? 'Sonstiges',
      buyPrice:  buyPrice,
      sellPrice: sellPrice,
      stock:     (json['amount'] as num?)?.toInt()
              ?? (json['stock']  as num?)?.toInt()
              ?? 0,
    );
  }

  /// ACACIA_LEAVES → Acacia Leaves
  static String _formatMaterial(String material) {
    if (material.isEmpty) return material;
    return material.split('_')
        .map((w) => w.isEmpty ? '' : '${w[0].toUpperCase()}${w.substring(1).toLowerCase()}')
        .join(' ');
  }
}
