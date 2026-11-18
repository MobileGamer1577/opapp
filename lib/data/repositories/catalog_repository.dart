// ═══════════════════════════════════════════════════════════════
//  catalog_repository.dart – Lädt die Item-Datenbank aus Supabase
//
//  ✅ HIER ÄNDERN: _select (Spalten/Embeds), _maxPages
//  ❌ NICHT ÄNDERN: Provider-Name catalogItemsProvider,
//                   itemsOfLatestImportDay()-Logik
//
//  ABLAUF:
//    1. GET {supabaseUrl}/rest/v1/items mit Embed der Fremdschlüssel
//       (categories(name), collections(name)) – ein einziger Request
//       liefert Items inkl. aufgelöster Kategorie-/Kollektionsnamen.
//    2. Seitenweise laden (limit/offset), bis keine Zeilen mehr
//       kommen. Supabase begrenzt Antworten standardmäßig auf 1000
//       Zeilen – ohne Paging würden größere Datenbestände still
//       abgeschnitten. Der Offset wächst um die TATSÄCHLICH erhaltene
//       Zeilenzahl, funktioniert also auch bei einem niedrigeren
//       Server-Limit.
//    3. Beide Tabs (Neu + Suche) teilen sich diesen EINEN Provider –
//       es gibt nur einen Ladevorgang pro Screen-Besuch.
//
//  ⚠️ VORAUSSETZUNG (Supabase): Auf den Tabellen items, categories
//  und collections muss für die Rolle "anon" eine SELECT-Policy
//  (Row Level Security) existieren, sonst liefert die API eine leere
//  Liste bzw. leere Namen. Schreibrechte sind für die App nicht nötig
//  und sollten für "anon" NICHT vergeben sein.
//
//  ⚠️ Die Spalte "recent_sales" steht bewusst NICHT in _select.
//
//  ÄNDERUNGEN (Item-Datenbank-Update):
//    - NEU: Datei.
// ═══════════════════════════════════════════════════════════════

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/catalog_item.dart';
import '../api_service.dart';
import '../../core/api_constants.dart';

/// Angefragte Zeilen pro Request (Supabase-Standardlimit).
const int _pageSize = 1000;

/// Sicherheitsgrenze gegen Endlosschleifen (50 × 1000 Items).
const int _maxPages = 50;

/// Spalten + Embeds. "recent_sales" fehlt absichtlich.
const String _select = 'id,name,minecraft_id,enchantments,lore_image_url,'
    'category_id,collection_id,created_at,price,'
    'categories(name),collections(name)';

final catalogItemsProvider =
    FutureProvider.autoDispose<List<CatalogItem>>((ref) async {
  final api = ApiService();
  ref.onDispose(api.dispose);

  final items = <CatalogItem>[];
  var offset = 0;

  for (var page = 0; page < _maxPages; page++) {
    final url = Uri.parse(ApiConstants.supabaseItemsEndpoint).replace(
      queryParameters: {
        'select': _select,
        // Stabile Reihenfolge, damit sich Seiten beim Paging nicht
        // überlappen (id als Tie-Breaker bei gleichem created_at).
        'order': 'created_at.desc,id.asc',
        'limit': '$_pageSize',
        'offset': '$offset',
      },
    ).toString();

    final data = await api.get(url, headers: ApiConstants.supabaseHeaders);
    if (data is! List || data.isEmpty) break;

    items.addAll(
      data
          .whereType<Map<String, dynamic>>()
          .map(CatalogItem.fromJson),
    );
    offset += data.length;
  }

  return items;
});

/// Liefert alle Items des NEUESTEN Import-Tages, sortiert nach
/// Uhrzeit absteigend (z.B. 18:45 vor 18:26).
///
/// Der "Tag" ist der Kalendertag des neuesten created_at in LOKALER
/// Zeitzone (CatalogItem.createdAt ist bereits lokal). Wird an einem
/// Tag nichts importiert, bleibt automatisch der letzte Import-Tag
/// der neueste – bis neue Items dazukommen.
List<CatalogItem> itemsOfLatestImportDay(List<CatalogItem> all) {
  final dated = all.where((i) => i.createdAt != null).toList();
  if (dated.isEmpty) return const [];

  var newest = dated.first.createdAt!;
  for (final item in dated) {
    if (item.createdAt!.isAfter(newest)) newest = item.createdAt!;
  }

  bool sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  final result = dated.where((i) => sameDay(i.createdAt!, newest)).toList()
    ..sort((a, b) => b.createdAt!.compareTo(a.createdAt!));
  return result;
}
