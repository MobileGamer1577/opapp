import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/market_item.dart';
import '../api_service.dart';
import '../../core/api_constants.dart';

final marketProvider = FutureProvider.autoDispose<List<MarketItem>>((ref) async {
  final repo = MarketRepository(ApiService());
  ref.onDispose(repo.dispose);
  return repo.fetchItems();
});

class MarketRepository {
  final ApiService _api;
  MarketRepository(this._api);

  Future<List<MarketItem>> fetchItems() async {
    // Korrekter Endpunkt: /market/items (nicht /market)
    final data = await _api.get(ApiConstants.marketItems);

    // Direkte Liste: [ {...}, {...} ]
    if (data is List) {
      return data
          .whereType<Map<String, dynamic>>()
          .map(MarketItem.fromJson)
          .toList();
    }
    // Objekt mit items-Key: { "items": [...] }
    if (data is Map && data['items'] is List) {
      return (data['items'] as List)
          .whereType<Map<String, dynamic>>()
          .map(MarketItem.fromJson)
          .toList();
    }
    // Objekt mit data-Key: { "data": [...] }
    if (data is Map && data['data'] is List) {
      return (data['data'] as List)
          .whereType<Map<String, dynamic>>()
          .map(MarketItem.fromJson)
          .toList();
    }
    return [];
  }

  void dispose() => _api.dispose();
}
