// ═══════════════════════════════════════════════════════════════
//  shard_all_time_high.dart – Datenmodell für das Allzeithoch eines
//  OPShard-Items (aus dem eigenen opapp-shards-api Backend)
//
//  ✅ HIER ÄNDERN: Felder ergänzen, falls das Backend erweitert wird
//  ❌ NICHT ÄNDERN: itemKey MUSS mit ShardItem.athKey (shard_rate.dart)
//                   und extractItemKey() im Worker übereinstimmen –
//                   sonst findet der Abgleich in shards_screen.dart
//                   das passende Item nicht.
//
//  API-FORMAT (GET /shards/ath, siehe opapp-shards-api Repo):
//    [ { "item_key": "diamond_block", "rate": 13.6, "base": 12,
//        "achieved_at": 1783900800000 }, ... ]
//    achieved_at ist ein Unix-Zeitstempel in Millisekunden (UTC).
//    ⚠️ Enthält KEIN Währungsfeld – der Worker kennt "target" nach
//    aktuellem Stand nicht (separates Repo). Die Einheit für die
//    Anzeige kommt deshalb vom zugehörigen ShardItem, siehe
//    displayRateFor() unten und shards_screen.dart.
//
//  ÄNDERUNGEN (Redcoins-Update):
//    - NEU: displayRateFor(currencyLabel) – wie displayRate, aber mit
//      übergebener Einheit statt fest "OPShards". displayRate bleibt
//      als rückwärtskompatibler Alias (nimmt "OPShards" an) erhalten,
//      wird aber im Detail-Sheet nicht mehr direkt verwendet – siehe
//      shards_screen.dart (dort: ath.displayRateFor(item.currencyLabel)).
// ═══════════════════════════════════════════════════════════════

class ShardAllTimeHigh {
  final String itemKey;
  final double rate;
  final double base;
  final DateTime achievedAt;

  const ShardAllTimeHigh({
    required this.itemKey,
    required this.rate,
    required this.base,
    required this.achievedAt,
  });

  factory ShardAllTimeHigh.fromJson(Map<String, dynamic> json) {
    final achievedAtMs = (json['achieved_at'] as num?)?.toInt() ?? 0;
    return ShardAllTimeHigh(
      itemKey:    json['item_key']?.toString() ?? '',
      rate:       (json['rate'] as num?)?.toDouble() ?? 0.0,
      base:       (json['base'] as num?)?.toDouble() ?? 0.0,
      achievedAt: DateTime.fromMillisecondsSinceEpoch(achievedAtMs, isUtc: true),
    );
  }

  /// Abweichung des Rekord-Kurses vom damaligen Basiswert,
  /// z.B. 0.133 = +13,3% (siehe shard_rate.dart – gleiches Prinzip).
  double get changePercent => base > 0 ? (rate - base) / base : 0.0;

  static String _fmt(double v) =>
      v % 1 == 0 ? v.toStringAsFixed(0) : v.toStringAsFixed(2);

  /// z.B. "13.6 OPShards" – rückwärtskompatibler Alias für
  /// displayRateFor('OPShards'). Für RedCoins-Items unbedingt
  /// displayRateFor(item.currencyLabel) verwenden (siehe
  /// shards_screen.dart), sonst steht bei RedCoins-Items fälschlich
  /// "OPShards" dran.
  String get displayRate => displayRateFor('OPShards');

  /// z.B. "13.6 RedCoins" – [currencyLabel] kommt vom zugehörigen
  /// ShardItem, da die ATH-Daten selbst keine Währung kennen (siehe
  /// Datei-Kommentar oben).
  String displayRateFor(String currencyLabel) => '${_fmt(rate)} $currencyLabel';

  /// z.B. "+13.3%"
  String get displayChange {
    final pct = changePercent * 100;
    final sign = pct > 0 ? '+' : '';
    return '$sign${pct.toStringAsFixed(1)}%';
  }
}
