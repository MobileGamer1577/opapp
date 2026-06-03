/// Aktueller Wechselkurs des OPShard-Händlers
class ShardRate {
  final double shardsPerCoin;
  final double coinsPerShard;
  final DateTime fetchedAt;

  const ShardRate({
    required this.shardsPerCoin,
    required this.coinsPerShard,
    required this.fetchedAt,
  });

  factory ShardRate.fromJson(Map<String, dynamic> json) {
    // Anpassen sobald echte API-Struktur bekannt ist
    final rate = (json['rate'] as num?)?.toDouble() ?? 1.0;
    return ShardRate(
      shardsPerCoin: rate,
      coinsPerShard: rate > 0 ? 1.0 / rate : 0.0,
      fetchedAt:     DateTime.now(),
    );
  }

  /// Formatierter String: "1 Coin = X Shards"
  String get displayRate =>
      '1 Coin = ${shardsPerCoin.toStringAsFixed(2)} Shards';
}
