// ═══════════════════════════════════════════════════════════════
//  market_repository.dart – Lädt & kombiniert die Markt-Daten
//
//  ✅ HIER ÄNDERN: ggf. Caching ergänzen
//  ❌ NICHT ÄNDERN: Kombinations-Logik (3 Endpunkte → 1 Liste)
//
//  ABLAUF:
//    1. /market/prices  → Kategorie → Material → [BUY, SELL]
//    2. /market/items   → Material → Icon-URL (Lookup-Map)
//    3. Beide kombinieren zu einer flachen List<MarketItem>
//
//  /market/categories wird separat geladen (marketCategoriesProvider)
//  für die Kategorie-Filter-Chips inkl. Icon.
// ═══════════════════════════════════════════════════════════════

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/market_item.dart';
import '../models/market_category.dart';
import '../api_service.dart';
import '../../core/api_constants.dart';

final marketProvider = FutureProvider.autoDispose<List<MarketItem>>((ref) async {
  final repo = MarketRepository(ApiService());
  ref.onDispose(repo.dispose);
  return repo.fetchItems();
});

final marketCategoriesProvider =
    FutureProvider.autoDispose<List<MarketCategory>>((ref) async {
  final repo = MarketRepository(ApiService());
  ref.onDispose(repo.dispose);
  return repo.fetchCategories();
});

class MarketRepository {
  final ApiService _api;
  MarketRepository(this._api);

  Future<List<MarketItem>> fetchItems() async {
    // Preise und Icons parallel laden
    final results = await Future.wait([
      _api.get(ApiConstants.marketPrices),
      _api.get(ApiConstants.marketItems),
    ]);

    final pricesData = results[0];
    final itemsData  = results[1];

    // ── Icon-Lookup: Material → Icon-URL ────────────────────
    final iconMap = <String, String>{};
    if (itemsData is List) {
      for (final entry in itemsData) {
        if (entry is Map) {
          final mat  = entry['material']?.toString();
          final icon = entry['icon']?.toString();
          if (mat != null && icon != null) iconMap[mat] = icon;
        }
      }
    }

    // ── Preise: { Kategorie: { Material: [BUY, SELL] } } ───
    final items = <MarketItem>[];
    if (pricesData is Map) {
      pricesData.forEach((category, materials) {
        if (materials is Map) {
          materials.forEach((material, orders) {
            if (orders is List) {
              final mat = material.toString();
              items.add(MarketItem.fromPriceEntry(
                material: mat,
                category: category.toString(),
                orders:   orders,
                icon:     iconMap[mat],
              ));
            }
          });
        }
      });
    }

    return items;
  }

  Future<List<MarketCategory>> fetchCategories() async {
    final data = await _api.get(ApiConstants.marketCategories);
    if (data is List) {
      return data
          .whereType<Map<String, dynamic>>()
          .map(MarketCategory.fromJson)
          .toList();
    }
    return [];
  }

  void dispose() => _api.dispose();
}
