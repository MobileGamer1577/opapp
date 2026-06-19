// ═══════════════════════════════════════════════════════════════
//  shard_rate.dart – Datenmodell für OPShard-Wechselkurse
//
//  ✅ HIER ÄNDERN: _nameOverrides für neue Items mit eigenem
//                  Anzeigenamen ergänzen
//  ✅ HIER ÄNDERN: shardIcons für neue Items ein Icon ergänzen
//  ❌ NICHT ÄNDERN: ShardRates / ShardItem Klassenstruktur
//
//  API-FORMAT (bestätigt, siehe /merchant/rates):
//    [ { "source": "diamond_block", "target": "opshards",
//        "base": 8, "exchangeRate": 8.56 }, ... ]
//
//  "source" ist entweder:
//    - eine einfache Material-ID (z.B. "diamond_block")
//    - oder ein kompletter Minecraft-NBT-String für Custom-Items
//      (z.B. 'minecraft:paper[custom_name={... text: "Gräbergemisch" ...}]')
//      → der lesbare Name wird daraus extrahiert (_extractNbtText)
//
//  "base" = Kurs bei neutralem Stand, "exchangeRate" = aktueller Kurs.
//  changePercent zeigt die Abweichung der beiden zueinander.
// ═══════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';

/// Bekannte Items mit eigenem (deutschem) Anzeigenamen statt der
/// automatisch formatierten Material-ID.
const Map<String, String> _nameOverrides = {
  'diamond_block':   'Diamant Block',
  'netherite_ingot': 'Netherite Barren',
};

/// Icon je Item – Schlüssel ist der finale Anzeigename.
/// Unbekannte Items bekommen automatisch Icons.diamond (Fallback).
const Map<String, IconData> shardIcons = {
  'Diamant Block':    Icons.view_in_ar_rounded,
  'Netherite Barren': Icons.token_rounded,
  'Gräbergemisch':    Icons.grain_rounded,
  'Holzbündel':       Icons.forest_rounded,
  'Steinplatten':     Icons.layers_rounded,
};

IconData shardIconFor(String displayName) => shardIcons[displayName] ?? Icons.diamond;

/// Ein einzelnes Item mit seinem OPShard-Wechselkurs
class ShardItem {
  /// Rohe Material-ID (z.B. "diamond_block"). Bei Custom-Items leer,
  /// da der NBT-String kein sinnvoller Schlüssel ist.
  final String material;
  final String displayName;
  final double rate; // aktueller Kurs (exchangeRate)
  final double base;  // Basiskurs (Kurs bei neutralem Stand)

  const ShardItem({
    required this.material,
    required this.displayName,
    required this.rate,
    required this.base,
  });

  factory ShardItem.fromJson(Map<String, dynamic> json) {
    final rawSource = json['source']?.toString()
                   ?? json['material']?.toString()
                   ?? json['item']?.toString()
                   ?? json['itemId']?.toString()
                   ?? json['itemName']?.toString()
                   ?? json['type']?.toString()
                   ?? json['key']?.toString()
                   ?? '';

    // Custom-Items liefern den Namen als NBT-String (enthält "[" und
    // meist "custom_name") statt einer einfachen Material-ID.
    final isNbt = rawSource.contains('[') || rawSource.contains('custom_name');
    final nbtName = isNbt ? _extractNbtText(rawSource) : null;

    // Bei Custom-Items gibt es keine sinnvolle Material-ID → leer lassen.
    final material = isNbt ? '' : rawSource;

    double? rate = (json['exchangeRate'] as num?)?.toDouble()
              ?? (json['rate']         as num?)?.toDouble()
              ?? (json['value']        as num?)?.toDouble()
              ?? (json['shards']       as num?)?.toDouble();

    double? base = (json['base']      as num?)?.toDouble()
               ?? (json['baseRate']  as num?)?.toDouble()
               ?? (json['basePrice'] as num?)?.toDouble();

    // Unbekanntes Format? Erstes Zahlenfeld als Kurs nehmen.
    if (rate == null) {
      for (final v in json.values) {
        if (v is num) { rate = v.toDouble(); break; }
      }
    }

    final apiName = json['displayName']?.toString()
                ?? json['name']?.toString()
                ?? json['label']?.toString();

    final displayName = _nameOverrides[material]
                      ?? apiName
                      ?? nbtName
                      ?? _formatMaterial(material);

    return ShardItem(
      material:    material,
      displayName: displayName,
      rate:        rate ?? 0.0,
      // Kein expliziter Basiswert in der API? Dann Basis = aktueller
      // Kurs setzen (zeigt dann neutral "0%" statt eines falschen Werts).
      base: base ?? rate ?? 0.0,
    );
  }

  /// Extrahiert den lesbaren Namen aus einem Minecraft-NBT-String, z.B.
  /// 'minecraft:paper[custom_name={extra: [{... text: "Gräbergemisch" ...}], text: ""}]'
  /// → "Gräbergemisch" (nimmt das erste NICHT-leere "text": "..." Feld)
  static String? _extractNbtText(String source) {
    final matches = RegExp(r'text:\s*"([^"]*)"').allMatches(source);
    for (final m in matches) {
      final text = m.group(1);
      if (text != null && text.isNotEmpty) return text;
    }
    return null;
  }

  /// iron_ingot → Iron Ingot (Fallback für Items ohne _nameOverrides-Eintrag)
  static String _formatMaterial(String m) {
    if (m.isEmpty) return 'Unbekannt';
    return m.split('_')
        .map((w) => w.isEmpty ? '' : '${w[0].toUpperCase()}${w.substring(1).toLowerCase()}')
        .join(' ');
  }

  // ── Berechnete Eigenschaften ──────────────────────────

  /// Abweichung vom Basiswert, z.B. 0.07 = +7%
  double get changePercent => base > 0 ? (rate - base) / base : 0.0;
  bool get isAboveBase => rate > base;
  bool get isBelowBase => rate < base;

  static String _fmt(double v) =>
      v % 1 == 0 ? v.toStringAsFixed(0) : v.toStringAsFixed(2);

  /// z.B. "8.56 OPShards"
  String get displayRate => '${_fmt(rate)} OPShards';
  /// z.B. "8 OPShards"
  String get displayBase => '${_fmt(base)} OPShards';
  /// z.B. "+7.0%" oder "-3.2%"
  String get displayChange {
    final pct = changePercent * 100;
    final sign = pct > 0 ? '+' : '';
    return '$sign${pct.toStringAsFixed(1)}%';
  }
}

/// Alle OPShard-Wechselkurse vom Händler
class ShardRates {
  final List<ShardItem> items;
  final DateTime fetchedAt;

  const ShardRates({required this.items, required this.fetchedAt});

  /// Erstes Item (API-Reihenfolge) – generischer Fallback
  ShardItem? get first => items.isNotEmpty ? items.first : null;

  /// Item mit dem aktuell besten Kurs (höchster Aufschlag auf den
  /// Basiswert) – wird im Dashboard-Banner angezeigt.
  ShardItem? get best {
    if (items.isEmpty) return null;
    return items.reduce((a, b) => a.changePercent >= b.changePercent ? a : b);
  }
}
