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
    // Flexible Feldnamen – API kann verschiedene Keys verwenden
    final id = json['material']?.toString()
             ?? json['id']?.toString()
             ?? json['name']?.toString()
             ?? '';

    final name = json['displayName']?.toString()
               ?? json['name']?.toString()
               ?? json['material']?.toString()
               ?? 'Unbekannt';

    // Kaufpreis: buy, buyPrice, buy_price
    final buyPrice = (json['buy']      as num?)?.toDouble()
                  ?? (json['buyPrice'] as num?)?.toDouble()
                  ?? (json['buy_price'] as num?)?.toDouble();

    // Verkaufspreis: sell, sellPrice, sell_price
    final sellPrice = (json['sell']       as num?)?.toDouble()
                   ?? (json['sellPrice']  as num?)?.toDouble()
                   ?? (json['sell_price'] as num?)?.toDouble();

    return MarketItem(
      id:        id,
      name:      name,
      category:  json['category']?.toString() ?? 'Sonstiges',
      buyPrice:  buyPrice,
      sellPrice: sellPrice,
      stock:     (json['amount'] as num?)?.toInt()
              ?? (json['stock']  as num?)?.toInt()
              ?? 0,
    );
  }

  double get lowestPrice => [
    if (buyPrice  != null) buyPrice!,
    if (sellPrice != null) sellPrice!,
  ].fold(double.infinity, (a, b) => a < b ? a : b);
}
