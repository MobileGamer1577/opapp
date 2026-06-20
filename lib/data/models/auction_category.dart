// ═══════════════════════════════════════════════════════════════
//  auction_category.dart – Datenmodell für eine Auktions-Kategorie
//
//  ✅ HIER ÄNDERN: Felder ergänzen falls API erweitert wird
//  ❌ NICHT ÄNDERN: Klassenstruktur
//
//  API-FORMAT (/auctions/categories) – BESTÄTIGT, vollständige Liste:
//    6 Top-Level-Kategorien (kein "parentCategory"):
//      - custom_items                    (Custom Items)   – ohne Kinder
//      - op_items                        (OP Items)       – ohne Kinder
//      - parent_tools_combat             (Werkzeuge & Kampf)
//      - parent_armor                    (Rüstungen)
//      - parent_cards_and_booster_packs  (Karten & Boosterpacks)
//      - parent_other                    (Anderes)
//    17 Unterkategorien (mit "parentCategory", z.B. "sub_helmets"
//    → "parent_armor"). Gruppen-Kategorien haben "matchTypes": []
//    und werden NIE direkt einem Item zugewiesen – ein Item trägt
//    immer den Schlüssel der konkretesten (Unter-)Kategorie.
//
//  "name" ist der Schlüssel, der im Auktions-Item unter "category"
//  steht (siehe auction_item.dart) – wird zum Filtern verwendet.
// ═══════════════════════════════════════════════════════════════

class AuctionCategory {
  final String name;
  final String displayName;
  final String? displayMaterial;
  final String icon;
  final String? parentCategory;
  final List<String> matchTypes;

  const AuctionCategory({
    required this.name,
    required this.displayName,
    this.displayMaterial,
    required this.icon,
    this.parentCategory,
    this.matchTypes = const [],
  });

  /// true wenn diese Kategorie eine Unterkategorie ist
  /// (z.B. "sub_helmets" gehört zu "parent_armor")
  bool get isSubCategory => parentCategory != null;

  factory AuctionCategory.fromJson(Map<String, dynamic> json) {
    return AuctionCategory(
      name:            json['name']?.toString() ?? '',
      displayName:     json['displayName']?.toString()
                     ?? json['name']?.toString()
                     ?? 'Sonstiges',
      displayMaterial: json['displayMaterial']?.toString(),
      icon:            json['icon']?.toString() ?? '',
      parentCategory:  json['parentCategory']?.toString(),
      matchTypes: (json['matchTypes'] as List?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
    );
  }
}

// ─── Kategorie-Baum (Top-Level + Unterkategorien) ────────────
//
//  Wird von der Filter-Leiste im Auktionshaus-Screen verwendet:
//  Reihe 1 zeigt die Top-Level-Gruppen, Reihe 2 (falls vorhanden)
//  die Unterkategorien der gerade gewählten Gruppe.

class AuctionCategoryGroup {
  final AuctionCategory category;
  final List<AuctionCategory> children;

  const AuctionCategoryGroup({
    required this.category,
    required this.children,
  });

  /// true wenn diese Top-Level-Kategorie Unterkategorien hat
  /// (z.B. "parent_armor" → Helme, Brustplatten, …).
  /// false bei eigenständigen Kategorien ohne Kinder
  /// (z.B. "custom_items", "op_items").
  bool get hasChildren => children.isNotEmpty;
}

/// Baut aus der flachen API-Liste eine zweistufige Struktur:
/// alle Top-Level-Kategorien (ohne parentCategory) + ihre jeweiligen
/// Kinder (Unterkategorien, deren parentCategory == top.name).
List<AuctionCategoryGroup> buildAuctionCategoryGroups(
  List<AuctionCategory> all,
) {
  final topLevel = all.where((c) => !c.isSubCategory).toList();
  return topLevel.map((top) {
    final children = all.where((c) => c.parentCategory == top.name).toList();
    return AuctionCategoryGroup(category: top, children: children);
  }).toList();
}
