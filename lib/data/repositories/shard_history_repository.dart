// ═══════════════════════════════════════════════════════════════
//  shard_history_repository.dart – Lädt den Kursverlauf eines Items
//  aus dem eigenen opapp-shards-api Backend (Cloudflare Worker + D1)
//
//  ✅ HIER ÄNDERN: nichts Spezielles nötig, läuft automatisch
//  ❌ NICHT ÄNDERN: Provider-Name shardHistoryProvider
//
//  ShardHistoryQuery kombiniert Item-Schlüssel + Zeitraum (7/30 Tage)
//  als Family-Parameter – braucht eine eigene ==/hashCode-Implemen-
//  tierung, damit Riverpod für dieselbe Kombination denselben
//  gecachten Request wiederverwendet (z.B. beim Zurückwechseln von
//  30 auf 7 Tage im selben Sheet).
//
//  Bewusst NICHT über shardRateProvider mit-geladen: Der Kursverlauf
//  wird nur bei Bedarf (Tap auf ein Item + Auswahl 7/30 Tage) im
//  Detail-Sheet geladen, nicht beim normalen Öffnen des OPShards-
//  Screens.
// ═══════════════════════════════════════════════════════════════

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/shard_history_point.dart';
import '../api_service.dart';
import '../../core/api_constants.dart';

class ShardHistoryQuery {
  final String itemKey;
  final int days;
  const ShardHistoryQuery(this.itemKey, this.days);

  @override
  bool operator ==(Object other) =>
      other is ShardHistoryQuery &&
      other.itemKey == itemKey &&
      other.days == days;

  @override
  int get hashCode => Object.hash(itemKey, days);
}

final shardHistoryProvider = FutureProvider.autoDispose
    .family<List<ShardHistoryPoint>, ShardHistoryQuery>((ref, query) async {
  final api  = ApiService();
  final data = await api.get(
    ApiConstants.shardsHistory(query.itemKey, days: query.days),
  );
  api.dispose();

  if (data is List) {
    return data
        .whereType<Map<String, dynamic>>()
        .map(ShardHistoryPoint.fromJson)
        .toList();
  }
  return [];
});
