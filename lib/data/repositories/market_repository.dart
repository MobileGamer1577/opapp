import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/market_item.dart';
import '../services/api_service.dart';
import '../../core/constants/api_constants.dart';

// ─── Provider ───────────────────────────────────────────────
final marketProvider = FutureProvider.autoDispose<List<MarketItem>>((ref) async {
  final repo = MarketRepository(ApiService());
  ref.onDispose(repo.dispose);
  return repo.fetchItems();
});

// ─── Repository ─────────────────────────────────────────────
class MarketRepository {
  final ApiService _api;
  MarketRepository(this._api);

  Future<List<MarketItem>> fetchItems() async {
    final data = await _api.get(ApiConstants.market);

    if (data is List) {
      return data
          .whereType<Map<String, dynamic>>()
          .map(MarketItem.fromJson)
          .toList();
    }
    // Manche APIs liefern { "items": [...] }
    if (data is Map && data['items'] is List) {
      return (data['items'] as List)
          .whereType<Map<String, dynamic>>()
          .map(MarketItem.fromJson)
          .toList();
    }
    return [];
  }

  void dispose() => _api.dispose();
}
