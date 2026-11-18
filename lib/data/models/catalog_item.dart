// ═══════════════════════════════════════════════════════════════
//  catalog_item.dart – Datenmodell für ein Item der Item-Datenbank
//  (Quelle: Supabase, Tabelle "items", BETA)
//
//  ✅ HIER ÄNDERN: Felder ergänzen, falls die Tabelle erweitert wird
//  ❌ NICHT ÄNDERN: Klassenstruktur
//
//  API-FORMAT (Supabase REST, GET /rest/v1/items mit Embed):
//    [ { "id": "…uuid…", "name": "Excalibur",
//        "minecraft_id": "minecraft:netherite_sword",
//        "enchantments": ["Schärfe V", "Haltbarkeit III"],
//        "lore_image_url": "https://…", "category_id": "…",
//        "collection_id": null, "created_at": "2026-11-17T17:45:00+00:00",
//        "price": 1500000,
//        "categories":  { "name": "Waffen" },
//        "collections": null }, ... ]
//
//  "categories" / "collections" sind eingebettete Objekte (Embed über
//  die Fremdschlüssel, siehe catalog_repository.dart). Bei fehlender
//  Zuordnung (collection_id == null) kommt null zurück.
//
//  ⚠️ Die Spalte "recent_sales" wird bewusst NICHT abgefragt und
//  nirgends im Modell geführt (Vorgabe: in der App komplett ignorieren).
//
//  ÄNDERUNGEN (Item-Datenbank-Update):
//    - NEU: Datei.
//    - createdAt wird sofort in lokale Zeit umgerechnet – alle
//      Kalendertag-Vergleiche (Tab "Neu") laufen damit in der
//      Zeitzone des Geräts.
// ═══════════════════════════════════════════════════════════════

import 'dart:convert';

class CatalogItem {
  final String id;
  final String name;

  /// z.B. "minecraft:netherite_sword" (leer, falls nicht gesetzt).
  final String minecraftId;

  /// Verzauberungen als fertige Texte (leer = keine).
  final List<String> enchantments;

  /// URL des Lore-Bildes, null wenn nicht gesetzt.
  final String? loreImageUrl;

  /// Aufgelöster Kategorie-Name (null = nicht auflösbar).
  final String? categoryName;

  /// Aufgelöster Kollektions-Name (null = keine Kollektion).
  final String? collectionName;

  /// Importzeitpunkt in LOKALER Zeit (null = nicht lesbar).
  final DateTime? createdAt;

  /// Preis in $, null = kein Preis vorhanden.
  final int? price;

  const CatalogItem({
    required this.id,
    required this.name,
    required this.minecraftId,
    required this.enchantments,
    required this.loreImageUrl,
    required this.categoryName,
    required this.collectionName,
    required this.createdAt,
    required this.price,
  });

  factory CatalogItem.fromJson(Map<String, dynamic> json) {
    return CatalogItem(
      id:             json['id']?.toString() ?? '',
      name:           _nonEmpty(json['name']?.toString()) ?? 'Unbekanntes Item',
      minecraftId:    json['minecraft_id']?.toString().trim() ?? '',
      enchantments:   _parseStringList(json['enchantments']),
      loreImageUrl:   _nonEmpty(json['lore_image_url']?.toString()),
      categoryName:   _embeddedName(json['categories']),
      collectionName: _embeddedName(json['collections']),
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? '')
          ?.toLocal(),
      price: _parseInt(json['price']),
    );
  }

  // ── Hilfsmethoden ──────────────────────────────────────

  static String? _nonEmpty(String? s) {
    final t = s?.trim();
    return (t == null || t.isEmpty) ? null : t;
  }

  static int? _parseInt(dynamic raw) {
    if (raw is num) return raw.toInt();
    if (raw is String) return num.tryParse(raw.trim())?.toInt();
    return null;
  }

  /// Liest den Namen aus einem Embed – normalerweise ein Objekt
  /// {"name": "…"}, defensiv wird auch eine Liste mit einem Objekt
  /// akzeptiert.
  static String? _embeddedName(dynamic raw) {
    if (raw is Map) return _nonEmpty(raw['name']?.toString());
    if (raw is List && raw.isNotEmpty && raw.first is Map) {
      return _nonEmpty((raw.first as Map)['name']?.toString());
    }
    return null;
  }

  /// jsonb-Array aus Strings → List<String>. Kommt das Array doch als
  /// JSON-Text an, wird es zusätzlich dekodiert.
  static List<String> _parseStringList(dynamic raw) {
    if (raw is List) {
      return raw
          .map((e) => e.toString().trim())
          .where((s) => s.isNotEmpty)
          .toList();
    }
    if (raw is String && raw.trim().isNotEmpty) {
      try {
        final decoded = jsonDecode(raw);
        if (decoded is List) return _parseStringList(decoded);
      } catch (_) {
        // kein JSON → als einzelner Eintrag behandeln
      }
      return [raw.trim()];
    }
    return const [];
  }
}
