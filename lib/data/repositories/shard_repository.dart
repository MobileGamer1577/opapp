import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/shard_rate.dart';
import '../api_service.dart';
import '../../core/api_constants.dart';

final shardRateProvider = FutureProvider.autoDispose<ShardRates>((ref) async {
  final api  = ApiService();
  final data = await api.get(ApiConstants.merchantRates);
  api.dispose();

  final fetched = DateTime.now();

  // Liste von Rate-Objekten: [ {"material":"...", "rate": 8.15}, ... ]
  if (data is List && data.isNotEmpty) {
    if (data.first is Map<String, dynamic>) {
      final items = (data as List)
          .whereType<Map<String, dynamic>>()
          .map(ShardItem.fromJson)
          .toList();
      return ShardRates(items: items, fetchedAt: fetched);
    }
  }

  // Map mit Material-Keys: { "DIAMOND_BLOCK": 8.15, ... }
  if (data is Map<String, dynamic>) {
    // Versuche als ShardItem-Objekt zu parsen
    try {
      return ShardRates(
        items: [ShardItem.fromJson(data)],
        fetchedAt: fetched,
      );
    } catch (_) {}

    // Alternativ: flache Map { "MATERIAL": rate }
    final items = data.entries
        .where((e) => e.value is num)
        .map((e) => ShardItem(
              material:    e.key,
              displayName: e.key.split('_')
                  .map((w) => w.isEmpty ? '' : '${w[0].toUpperCase()}${w.substring(1).toLowerCase()}')
                  .join(' '),
              rate:        (e.value as num).toDouble(),
            ))
        .toList();
    if (items.isNotEmpty) return ShardRates(items: items, fetchedAt: fetched);
  }

  return ShardRates(items: [], fetchedAt: fetched);
});
