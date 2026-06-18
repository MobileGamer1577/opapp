// ═══════════════════════════════════════════════════════════════
//  shard_rate.dart – Datenmodell für OPShard-Wechselkurse
//
//  ✅ HIER ÄNDERN: Neue Feldnamen in fromJson ergänzen
//  ❌ NICHT ÄNDERN: ShardRates / ShardItem Klassenstruktur
//
//  HINWEIS:
//  Falls das API-Format von /merchant/rates unbekannt ist, greift
//  ein automatischer Fallback: das erste Textfeld wird als Name,
//  das erste Zahlenfeld als Rate verwendet.
// ═══════════════════════════════════════════════════════════════

/// Ein einzelnes Item mit seinem OPShard-Wechselkurs
class ShardItem {
  final String material;
  final String displayName;
  final double rate; // Wert in OPShards

  const ShardItem({
    required this.material,
    required this.displayName,
    required this.rate,
  });

  factory ShardItem.fromJson(Map<String, dynamic> json) {
    // ── 1) Bekannte Feldnamen versuchen ──────────────────────
    String? material = json['material']?.toString()
                  ?? json['item']?.toString()
                  ?? json['itemId']?.toString()
                  ?? json['itemName']?.toString()
                  ?? json['type']?.toString()
                  ?? json['key']?.toString();

    String? name = json['displayName']?.toString()
               ?? json['name']?.toString()
               ?? json['label']?.toString();

    double? rate = (json['rate']        as num?)?.toDouble()
              ?? (json['value']        as num?)?.toDouble()
              ?? (json['shards']       as num?)?.toDouble()
              ?? (json['shardRate']    as num?)?.toDouble()
              ?? (json['opShards']     as num?)?.toDouble()
              ?? (json['exchangeRate'] as num?)?.toDouble()
              ?? (json['price']        as num?)?.toDouble();

    // ── 2) Unbekanntes Format? Erstes Text-/Zahlenfeld nehmen ───
    // Verhindert "Unbekannt"/"0" wenn die API andere Keys nutzt.
    if (name == null && material == null) {
      for (final v in json.values) {
        if (v is String && v.isNotEmpty) {
          name = v;
          break;
        }
      }
    }
    if (rate == null) {
      for (final v in json.values) {
        if (v is num) {
          rate = v.toDouble();
          break;
        }
      }
    }

    final resolvedMaterial = material ?? '';
    final resolvedName     = name ?? _formatMaterial(resolvedMaterial);

    return ShardItem(
      material:    resolvedMaterial,
      displayName: resolvedName,
      rate:        rate ?? 0.0,
    );
  }

  static String _formatMaterial(String m) {
    if (m.isEmpty) return 'Unbekannt';
    return m.split('_')
        .map((w) => w.isEmpty ? '' : '${w[0].toUpperCase()}${w.substring(1).toLowerCase()}')
        .join(' ');
  }

  /// z.B. "8 OPShards" oder "8.15 OPShards"
  String get displayRate =>
      '${rate % 1 == 0 ? rate.toStringAsFixed(0) : rate.toStringAsFixed(2)} OPShards';
}

/// Alle OPShard-Wechselkurse vom Händler
class ShardRates {
  final List<ShardItem> items;
  final DateTime fetchedAt;

  const ShardRates({required this.items, required this.fetchedAt});

  /// Erstes Item – für Dashboard-Banner
  ShardItem? get first => items.isNotEmpty ? items.first : null;
}
