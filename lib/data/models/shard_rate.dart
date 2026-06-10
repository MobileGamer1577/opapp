/// OPShard Wechselkurs vom Händler
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
    // Flexible Feldnamen: rate, shardsPerCoin, value, exchange_rate
    final rate = (json['rate']          as num?)?.toDouble()
              ?? (json['shardsPerCoin'] as num?)?.toDouble()
              ?? (json['value']         as num?)?.toDouble()
              ?? (json['exchange_rate'] as num?)?.toDouble()
              ?? 1.0;

    return ShardRate(
      shardsPerCoin: rate,
      coinsPerShard: rate > 0 ? 1.0 / rate : 0.0,
      fetchedAt:     DateTime.now(),
    );
  }

  String get displayRate =>
      '1 Coin = ${shardsPerCoin.toStringAsFixed(2)} OPShards';
}
