// ═══════════════════════════════════════════════════════════════
//  shard_rate.dart – Datenmodell für OPShard-Wechselkurse
//
//  ✅ HIER ÄNDERN: _nameOverrides für neue Items mit eigenem
//                  Anzeigenamen ergänzen
//  ✅ HIER ÄNDERN: shardIcons für neue Items ein Icon ergänzen
//  ✅ HIER ÄNDERN: _currencyLabels / _currencyColors für neue
//                  Wertstoffhändler-Währungen ergänzen (siehe
//                  Redcoins-Update unten)
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
//
//  ÄNDERUNGEN (Allzeithoch-Update):
//    - NEU: athKey – stabiler Schlüssel für den Abgleich mit dem
//      opapp-shards-api Backend (Allzeithoch-Tracking). MUSS exakt
//      mit extractItemKey() in worker.js übereinstimmen (gleiches
//      Prinzip: Material-ID bei normalen Items, extrahierter
//      Anzeigename bei Custom-Items) – siehe dortiger Kommentar.
//
//  ÄNDERUNGEN (Redcoins-Update):
//    - NEU: "target"-Feld wird jetzt ausgewertet (vorher ignoriert,
//      da bisher immer "opshards"). Der Wertstoffhändler kennt jetzt
//      zwei Server-Währungen: "opshards" und "redcoins".
//    - NEU: target – rohe Währungs-ID aus der API (z.B. "opshards",
//      "redcoins"). Fehlt das Feld (ältere/unerwartete API-Antwort),
//      wird "opshards" angenommen (Rückwärtskompatibilität).
//    - NEU: currencyLabel / currencyColor – lösen "target" über eine
//      Lookup-Map auf. WICHTIG: Das ist bewusst KEIN Enum, sondern
//      String-basiert mit Fallback – taucht später eine dritte
//      Währung in der API auf, crasht nichts, sie bekommt nur einen
//      neutralen Akzent (AppColors.accent) und einen automatisch
//      großgeschriebenen Namen, bis hier ein eigener Eintrag ergänzt
//      wird. Erfüllt die Anforderung "dynamische Skalierung" auch für
//      künftige, heute noch unbekannte Währungen – nicht nur für neue
//      Items innerhalb der zwei bekannten.
//    - displayRate / displayBase zeigen jetzt currencyLabel statt
//      fest "OPShards" (z.B. "12.40 RedCoins" bei Redcoins-Items).
//    - shardIconFor() bekommt einen optionalen target-Parameter für
//      ein währungsspezifisches Fallback-Icon (Diamant für OPShards,
//      Münze für RedCoins), falls kein Name-Override in shardIcons
//      passt.
// ═══════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import '../../core/app_colors.dart';

/// Bekannte Items mit eigenem (deutschem) Anzeigenamen statt der
/// automatisch formatierten Material-ID.
const Map<String, String> _nameOverrides = {
  'diamond_block':   'Diamant Block',
  'netherite_ingot': 'Netherite Barren',
};

/// Icon je Item – Schlüssel ist der finale Anzeigename.
/// Unbekannte Items bekommen automatisch ein währungsspezifisches
/// Fallback-Icon (siehe _fallbackIconFor unten).
const Map<String, IconData> shardIcons = {
  'Diamant Block':    Icons.view_in_ar_rounded,
  'Netherite Barren': Icons.token_rounded,
  'Gräbergemisch':    Icons.grain_rounded,
  'Holzbündel':       Icons.forest_rounded,
  'Steinplatten':     Icons.layers_rounded,
};

/// ✅ HIER ÄNDERN: Anzeigename je Wertstoffhändler-Währung.
/// Unbekannte "target"-Werte fallen automatisch auf eine großge-
/// schriebene Version des rohen Werts zurück (siehe currencyLabelFor).
const Map<String, String> _currencyLabels = {
  'opshards': 'OPShards',
  'redcoins': 'RedCoins',
};

/// ✅ HIER ÄNDERN: Akzentfarbe je Wertstoffhändler-Währung.
/// Passendes Gegenstück in app_colors.dart: AppColors.currencyOpshards
/// / AppColors.currencyRedcoins. Neue Währung → dort UND hier ergänzen.
const Map<String, Color> _currencyColors = {
  'opshards': AppColors.currencyOpshards,
  'redcoins': AppColors.currencyRedcoins,
};

/// Löst eine rohe "target"-Kennung in den Anzeigenamen auf, z.B.
/// "redcoins" → "RedCoins". Unbekannte Währungen (noch keine eigene
/// Zuordnung oben) werden automatisch großgeschrieben statt zu
/// crashen, z.B. "diamonds" → "Diamonds".
String currencyLabelFor(String target) {
  final known = _currencyLabels[target];
  if (known != null) return known;
  if (target.isEmpty) return 'Unbekannt';
  return '${target[0].toUpperCase()}${target.substring(1)}';
}

/// Löst eine rohe "target"-Kennung in die Akzentfarbe auf. Unbekannte
/// Währungen bekommen AppColors.accent (neutrales Lila) statt zu
/// crashen – bis hier ein eigener Eintrag ergänzt wird.
Color currencyColorFor(String target) => _currencyColors[target] ?? AppColors.accent;

/// Icon für ein Item: zuerst Name-Override aus [shardIcons], sonst ein
/// währungsspezifisches Fallback-Icon (Diamant für OPShards, Münze für
/// RedCoins, neutrales Icon für unbekannte künftige Währungen).
IconData shardIconFor(String displayName, {String target = 'opshards'}) {
  return shardIcons[displayName] ?? _fallbackIconFor(target);
}

IconData _fallbackIconFor(String target) {
  switch (target) {
    case 'redcoins':
      return Icons.paid_rounded;
    case 'opshards':
      return Icons.diamond;
    default:
      return Icons.category_outlined; // unbekannte künftige Währung
  }
}

/// Ein einzelnes Item mit seinem OPShard-Wechselkurs
class ShardItem {
  /// Rohe Material-ID (z.B. "diamond_block"). Bei Custom-Items leer,
  /// da der NBT-String kein sinnvoller Schlüssel ist.
  final String material;
  final String displayName;
  final double rate; // aktueller Kurs (exchangeRate)
  final double base;  // Basiskurs (Kurs bei neutralem Stand)

  /// Rohe Währungs-ID aus der API, z.B. "opshards" oder "redcoins".
  /// Fehlt "target" in der API-Antwort, wird "opshards" angenommen
  /// (Rückwärtskompatibilität – das Feld gab es schon vorher in der
  /// API, war aber immer "opshards" und wurde deshalb nie ausgewertet).
  final String target;

  const ShardItem({
    required this.material,
    required this.displayName,
    required this.rate,
    required this.base,
    required this.target,
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

    // NEU (Redcoins-Update): "target" gab es schon vorher in der API,
    // war aber immer "opshards" und wurde deshalb nie ausgewertet.
    // Fehlt es (unerwartete/ältere Antwort), wird "opshards" angenommen.
    final target = json['target']?.toString().toLowerCase() ?? 'opshards';

    return ShardItem(
      material:    material,
      displayName: displayName,
      rate:        rate ?? 0.0,
      // Kein expliziter Basiswert in der API? Dann Basis = aktueller
      // Kurs setzen (zeigt dann neutral "0%" statt eines falschen Werts).
      base: base ?? rate ?? 0.0,
      target: target,
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

  /// Stabiler Schlüssel für den Abgleich mit dem opapp-shards-api
  /// Allzeithoch-Backend: bei normalen Items die Material-ID, bei
  /// Custom-Items der Anzeigename. MUSS mit extractItemKey() in
  /// worker.js übereinstimmen (siehe opapp-shards-api Repo)!
  ///
  /// ⚠️ Absichtlich NICHT um "target" erweitert (siehe Redcoins-
  /// Update-Kommentar oben in der Datei) – der Worker kennt "target"
  /// nach aktuellem Stand nicht, eine Änderung hier ohne passende
  /// Worker-Anpassung würde den Abgleich komplett brechen statt nur
  /// ein (unwahrscheinliches) Kollisions-Risiko zu lösen.
  String get athKey => material.isNotEmpty ? material : displayName;

  /// Anzeigename der Währung dieses Items, z.B. "OPShards" oder
  /// "RedCoins". Siehe currencyLabelFor() oben.
  String get currencyLabel => currencyLabelFor(target);

  /// Akzentfarbe der Währung dieses Items. Siehe currencyColorFor() oben.
  Color get currencyColor => currencyColorFor(target);

  static String _fmt(double v) =>
      v % 1 == 0 ? v.toStringAsFixed(0) : v.toStringAsFixed(2);

  /// z.B. "8.56 OPShards" oder "12.40 RedCoins" – Einheit richtet sich
  /// jetzt nach der Währung des Items (siehe currencyLabel).
  String get displayRate => '${_fmt(rate)} $currencyLabel';
  /// z.B. "8 OPShards" oder "10 RedCoins"
  String get displayBase => '${_fmt(base)} $currencyLabel';
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
  /// Basiswert) – wird im Dashboard-Banner angezeigt. Vergleicht
  /// bewusst währungsübergreifend (höchste prozentuale Abweichung
  /// zählt, unabhängig davon ob OPShards oder RedCoins).
  ShardItem? get best {
    if (items.isEmpty) return null;
    return items.reduce((a, b) => a.changePercent >= b.changePercent ? a : b);
  }
}
