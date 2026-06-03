import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/auction_item.dart';
import '../services/api_service.dart';
import '../../core/constants/api_constants.dart';

// ─── Provider mit automatischem 30s-Refresh ─────────────────
final auctionsProvider =
    AsyncNotifierProvider.autoDispose<AuctionsNotifier, List<AuctionItem>>(
  AuctionsNotifier.new,
);

class AuctionsNotifier extends AutoDisposeAsyncNotifier<List<AuctionItem>> {
  Timer? _timer;

  @override
  Future<List<AuctionItem>> build() async {
    // Auto-Refresh alle 30 Sekunden
    _timer = Timer.periodic(ApiConstants.auctionRefreshInterval, (_) {
      ref.invalidateSelf(); // löst einen neuen build() aus
    });

    ref.onDispose(() => _timer?.cancel());
    return _fetchAuctions();
  }

  Future<List<AuctionItem>> _fetchAuctions() async {
    final api  = ApiService();
    final data = await api.get(ApiConstants.auctions);
    api.dispose();

    if (data is List) {
      return data
          .whereType<Map<String, dynamic>>()
          .map(AuctionItem.fromJson)
          .toList();
    }
    if (data is Map && data['auctions'] is List) {
      return (data['auctions'] as List)
          .whereType<Map<String, dynamic>>()
          .map(AuctionItem.fromJson)
          .toList();
    }
    return [];
  }

  /// Manuelles Refresh (Pull-to-Refresh)
  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_fetchAuctions);
  }
}
