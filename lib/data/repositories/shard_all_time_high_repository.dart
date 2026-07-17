// ═══════════════════════════════════════════════════════════════
//  shard_all_time_high_repository.dart – Lädt die Allzeithochs aus
//  dem eigenen opapp-shards-api Backend (Cloudflare Worker + D1)
//
//  ✅ HIER ÄNDERN: nichts Spezielles nötig, läuft automatisch
//  ❌ NICHT ÄNDERN: Provider-Name shardAllTimeHighProvider
//
//  Gibt eine Map (item_key → ShardAllTimeHigh) statt einer Liste
//  zurück, damit shards_screen.dart pro Item in O(1) nachschlagen
//  kann. Abgleich läuft über ShardItem.athKey (siehe shard_rate.dart)
//  gegen den item_key aus dem Backend – beide Seiten verwenden
//  bewusst dieselbe Ableitungslogik (Material-ID oder extrahierter
//  Anzeigename bei Custom-Items).
//
//  Bewusst NICHT über den normalen shardRateProvider mit-geladen:
//  Schlägt dieser Request fehl (Backend down, kein Netz), soll der
//  restliche OPShards-Screen trotzdem ganz normal funktionieren –
//  nur das Allzeithoch im Detail-Sheet zeigt dann einen Fehler.
// ═══════════════════════════════════════════════════════════════

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/shard_all_time_high.dart';
import '../api_service.dart';
import '../../core/api_constants.dart';

final shardAllTimeHighProvider =
    FutureProvider.autoDispose<Map<String, ShardAllTimeHigh>>((ref) async {
  final api  = ApiService();
  final data = await api.get(ApiConstants.shardsAth);
  api.dispose();

  if (data is List) {
    final entries = data
        .whereType<Map<String, dynamic>>()
        .map(ShardAllTimeHigh.fromJson)
        .where((e) => e.itemKey.isNotEmpty);
    return {for (final e in entries) e.itemKey: e};
  }
  return {};
});
