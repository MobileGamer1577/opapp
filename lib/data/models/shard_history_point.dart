// ═══════════════════════════════════════════════════════════════
//  shard_history_point.dart – Datenmodell für einen Kursverlauf-Punkt
//  (aus dem eigenen opapp-shards-api Backend)
//
//  ✅ HIER ÄNDERN: Felder ergänzen, falls das Backend erweitert wird
//  ❌ NICHT ÄNDERN: Klassenstruktur
//
//  API-FORMAT (GET /shards/history/{itemKey}?days=7|30):
//    [ { "fetched_at": 1783900800000, "rate": 13.4, "base": 12 }, ... ]
//    fetched_at ist der Anfang des jeweiligen Zeit-Buckets (Unix-
//    Millisekunden) – der Worker aggregiert serverseitig (stündlich
//    bei ≤7 Tagen, sonst täglich), rate/base sind bereits gemittelt.
// ═══════════════════════════════════════════════════════════════

class ShardHistoryPoint {
  final double rate;
  final double base;
  final DateTime fetchedAt;

  const ShardHistoryPoint({
    required this.rate,
    required this.base,
    required this.fetchedAt,
  });

  factory ShardHistoryPoint.fromJson(Map<String, dynamic> json) {
    final ms = (json['fetched_at'] as num?)?.toInt() ?? 0;
    return ShardHistoryPoint(
      rate:      (json['rate'] as num?)?.toDouble() ?? 0.0,
      base:      (json['base'] as num?)?.toDouble() ?? 0.0,
      fetchedAt: DateTime.fromMillisecondsSinceEpoch(ms, isUtc: true),
    );
  }
}
