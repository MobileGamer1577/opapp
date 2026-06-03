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
    return MarketItem(
      id:        json['id']?.toString()       ?? '',
      name:      json['name']?.toString()     ?? 'Unbekannt',
      category:  json['category']?.toString() ?? 'Sonstiges',
      buyPrice:  (json['buyPrice']  as num?)?.toDouble(),
      sellPrice: (json['sellPrice'] as num?)?.toDouble(),
      stock:     (json['stock']     as num?)?.toInt() ?? 0,
    );
  }

  /// Gibt den günstigeren der beiden Preise zurück (für Sortierung)
  double get lowestPrice => [
    if (buyPrice  != null) buyPrice!,
    if (sellPrice != null) sellPrice!,
  ].fold(double.infinity, (a, b) => a < b ? a : b);
}
