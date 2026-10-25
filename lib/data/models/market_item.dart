// ═══════════════════════════════════════════════════════════════
//  market_item.dart – Datenmodell für einen Markt-Artikel
//
//  ✅ HIER ÄNDERN: Felder ergänzen (z.B. Preisverlauf später)
//  ❌ NICHT ÄNDERN: fromPriceEntry-Logik (orderSide-Zuordnung)
//
//  HERKUNFT DER DATEN (siehe market_repository.dart):
//    /market/prices liefert je Material genau 2 Einträge mit
//    "orderSide": "BUY" oder "SELL". Sind 0 Angebote aktiv,
//    liefert die API price: 0.0 → das Modell speichert diesen Wert
//    weiterhin 1:1 (keine Sonderbehandlung beim Parsen).
//    Das Icon kommt separat aus /market/items (Lookup per Material).
//
//  ÄNDERUNGEN (Markt-Update):
//    - NEU: totalOrders – Gesamtzahl aktiver Aufträge
//      (BUY.activeOrders + SELL.activeOrders). Basis für die
//      Sortierung "Meiste Aufträge" und die Anzeige "N Aufträge".
//      Kommt aus /market/prices, es sind KEINE Einzelabfragen von
//      /market/price/{material} nötig (gleiche Felder, ein Request).
//    - NEU: hasBuyPrice / hasSellPrice – false, wenn die API 0.0
//      liefert (keine aktiven Angebote auf dieser Seite).
//    - NEU: displayBuyPrice / displaySellPrice – formatierter Preis
//      mit zwei Nachkommastellen, bei fehlendem Preis ein "–" statt
//      "0,00 $" (wie in der offiziellen App).
// ═══════════════════════════════════════════════════════════════

import '../../core/app_format.dart';

class MarketItem {
  final String material;
  final String name;
  final String category;
  final String? icon;

  /// Kaufpreis – das zahlst du, wenn du das Item im Markt kaufst.
  final double buyPrice;
  final int buyOrders;

  /// Verkaufspreis – das bekommst du, wenn du das Item im Markt verkaufst.
  final double sellPrice;
  final int sellOrders;

  const MarketItem({
    required this.material,
    required this.name,
    required this.category,
    required this.icon,
    required this.buyPrice,
    required this.buyOrders,
    required this.sellPrice,
    required this.sellOrders,
  });

  /// Baut ein MarketItem aus einem Eintrag von /market/prices.
  /// [orders] ist die Liste mit den BUY/SELL-Objekten zu diesem Material.
  factory MarketItem.fromPriceEntry({
    required String material,
    required String category,
    required List<dynamic> orders,
    String? icon,
  }) {
    double buyPrice = 0.0;
    int buyOrders   = 0;
    double sellPrice = 0.0;
    int sellOrders    = 0;

    // Bewusst nicht auf Reihenfolge im Array verlassen, sondern
    // explizit nach orderSide unterscheiden (robuster falls die
    // API die Reihenfolge mal ändert).
    for (final raw in orders) {
      if (raw is! Map) continue;
      final side  = raw['orderSide']?.toString().toUpperCase();
      final price = (raw['price'] as num?)?.toDouble() ?? 0.0;
      final count = (raw['activeOrders'] as num?)?.toInt() ?? 0;

      if (side == 'BUY') {
        buyPrice  = price;
        buyOrders = count;
      } else if (side == 'SELL') {
        sellPrice  = price;
        sellOrders = count;
      }
    }

    return MarketItem(
      material:   material,
      name:       _formatMaterial(material),
      category:   category,
      icon:       icon,
      buyPrice:   buyPrice,
      buyOrders:  buyOrders,
      sellPrice:  sellPrice,
      sellOrders: sellOrders,
    );
  }

  /// ACACIA_LEAVES → Acacia Leaves
  static String _formatMaterial(String material) {
    if (material.isEmpty) return material;
    return material.split('_')
        .map((w) => w.isEmpty ? '' : '${w[0].toUpperCase()}${w.substring(1).toLowerCase()}')
        .join(' ');
  }

  bool get hasBuyOrders  => buyOrders > 0;
  bool get hasSellOrders => sellOrders > 0;

  /// Gesamtzahl aktiver Aufträge (Angebote + Kaufaufträge),
  /// z.B. Dirt: 3.109 + 24 = 3.133.
  int get totalOrders => buyOrders + sellOrders;

  /// false, wenn die API 0.0 geliefert hat (keine aktiven Angebote).
  bool get hasBuyPrice  => buyPrice > 0;
  bool get hasSellPrice => sellPrice > 0;

  /// z.B. "3,20 $" – oder "–", wenn kein Preis vorhanden ist.
  String get displayBuyPrice =>
      hasBuyPrice ? AppFormat.currency(buyPrice, decimals: 2) : '–';
  String get displaySellPrice =>
      hasSellPrice ? AppFormat.currency(sellPrice, decimals: 2) : '–';
}
