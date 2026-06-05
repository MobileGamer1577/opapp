import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/shard_rate.dart';
import '../api_service.dart';
import '../../core/api_constants.dart';

final shardRateProvider = FutureProvider.autoDispose<ShardRate>((ref) async {
  final api  = ApiService();
  final data = await api.get(ApiConstants.merchantRates);
  api.dispose();

  if (data is Map<String, dynamic>) {
    return ShardRate.fromJson(data);
  }
  // Fallback wenn API eine Liste zurückgibt
  if (data is List && data.isNotEmpty && data.first is Map) {
    return ShardRate.fromJson(data.first as Map<String, dynamic>);
  }
  throw Exception('Unbekanntes API-Format für Merchant Rates');
});
