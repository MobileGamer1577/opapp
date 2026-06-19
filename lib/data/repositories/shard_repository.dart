// ═══════════════════════════════════════════════════════════════
//  shard_repository.dart – Lädt die OPShard-Wechselkurse
//
//  ✅ HIER ÄNDERN: ratesRefreshInterval in api_constants.dart
//  ❌ NICHT ÄNDERN: Provider-Name shardRateProvider
//
//  API-FORMAT (bestätigt): /merchant/rates liefert immer eine
//  direkte Liste von Objekten – siehe shard_rate.dart für Details.
// ═══════════════════════════════════════════════════════════════

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/shard_rate.dart';
import '../api_service.dart';
import '../../core/api_constants.dart';

final shardRateProvider = FutureProvider.autoDispose<ShardRates>((ref) async {
  final api  = ApiService();
  final data = await api.get(ApiConstants.merchantRates);
  api.dispose();

  final fetched = DateTime.now();

  // Normalfall: direkte Liste [ {...}, {...} ]
  if (data is List) {
    final items = data
        .whereType<Map<String, dynamic>>()
        .map(ShardItem.fromJson)
        .toList();
    return ShardRates(items: items, fetchedAt: fetched);
  }

  // Fallback falls die API doch mal ein Objekt mit Listen-Key liefert
  if (data is Map && data['rates'] is List) {
    final items = (data['rates'] as List)
        .whereType<Map<String, dynamic>>()
        .map(ShardItem.fromJson)
        .toList();
    return ShardRates(items: items, fetchedAt: fetched);
  }

  return ShardRates(items: [], fetchedAt: fetched);
});
