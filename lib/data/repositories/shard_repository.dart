import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/shard_rate.dart';
import '../api_service.dart';
import '../../core/api_constants.dart';

final shardRateProvider = FutureProvider.autoDispose<ShardRate>((ref) async {
  final api  = ApiService();
  // /merchant/rates ist bereits der korrekte Endpunkt
  final data = await api.get(ApiConstants.merchantRates);
  api.dispose();

  // Direkte Map: { "rate": 2.5 }
  if (data is Map<String, dynamic>) {
    return ShardRate.fromJson(data);
  }
  // Liste mit erstem Element: [ { "rate": 2.5 } ]
  if (data is List && data.isNotEmpty) {
    if (data.first is Map<String, dynamic>) {
      return ShardRate.fromJson(data.first as Map<String, dynamic>);
    }
    // Liste von Zahlen: [2.5]
    if (data.first is num) {
      final rate = (data.first as num).toDouble();
      return ShardRate(
        shardsPerCoin: rate,
        coinsPerShard: rate > 0 ? 1.0 / rate : 0.0,
        fetchedAt: DateTime.now(),
      );
    }
  }
  throw Exception('Unbekanntes API-Format für Merchant Rates');
});
