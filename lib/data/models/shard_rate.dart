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
    final material = json['material']?.toString() ?? '';
    final name = json['displayName']?.toString()
               ?? json['name']?.toString()
               ?? _formatMaterial(material);
    final rate = (json['rate']   as num?)?.toDouble()
              ?? (json['value']  as num?)?.toDouble()
              ?? (json['shards'] as num?)?.toDouble()
              ?? 0.0;
    return ShardItem(material: material, displayName: name, rate: rate);
  }

  static String _formatMaterial(String m) {
    if (m.isEmpty) return 'Unbekannt';
    return m.split('_')
        .map((w) => w.isEmpty ? '' : '${w[0].toUpperCase()}${w.substring(1).toLowerCase()}')
        .join(' ');
  }

  /// z.B. "8.15 OPShards"
  String get displayRate => '${rate % 1 == 0 ? rate.toStringAsFixed(0) : rate.toStringAsFixed(2)} OPShards';
}

/// Alle OPShard-Wechselkurse vom Händler
class ShardRates {
  final List<ShardItem> items;
  final DateTime fetchedAt;

  const ShardRates({required this.items, required this.fetchedAt});

  /// Erstes Item – für Dashboard-Banner
  ShardItem? get first => items.isNotEmpty ? items.first : null;
}
