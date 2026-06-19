// ═══════════════════════════════════════════════════════════════
//  market_category.dart – Datenmodell für eine Markt-Kategorie
//
//  ✅ HIER ÄNDERN: Felder ergänzen falls API erweitert wird
//  ❌ NICHT ÄNDERN: Klassenstruktur
//
//  API-FORMAT (/market/categories):
//    [ { "name": "Holz", "material": "NETHERITE_AXE",
//        "icon": "https://img.mc-api.io/netherite_axe.png" }, ... ]
//
//  "material" ist nur das Icon-Item für die Kategorie-Anzeige,
//  hat sonst keine Bedeutung (z.B. zeigt "Holz" eine Axt).
// ═══════════════════════════════════════════════════════════════

class MarketCategory {
  final String name;
  final String icon;

  const MarketCategory({required this.name, required this.icon});

  factory MarketCategory.fromJson(Map<String, dynamic> json) {
    return MarketCategory(
      name: json['name']?.toString() ?? 'Sonstiges',
      icon: json['icon']?.toString() ?? '',
    );
  }
}
