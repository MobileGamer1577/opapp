import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/auction_item.dart';
import '../api_service.dart';
import '../../core/api_constants.dart';

final auctionsProvider =
    AsyncNotifierProvider.autoDispose<AuctionsNotifier, List<AuctionItem>>(
  AuctionsNotifier.new,
);

class AuctionsNotifier extends AutoDisposeAsyncNotifier<List<AuctionItem>> {
  Timer? _timer;

  @override
  Future<List<AuctionItem>> build() async {
    _timer = Timer.periodic(ApiConstants.auctionRefreshInterval, (_) {
      ref.invalidateSelf();
    });
    ref.onDispose(() => _timer?.cancel());
    return _fetch();
  }

  Future<List<AuctionItem>> _fetch() async {
    final api = ApiService();
    // Korrekter Endpunkt: /auctions/active (nicht /auctions)
    final data = await api.get(ApiConstants.auctionsActive);
    api.dispose();

    // Direkte Liste: [ {...}, {...} ]
    if (data is List) {
      return data
          .whereType<Map<String, dynamic>>()
          .map(AuctionItem.fromJson)
          .toList();
    }
    // Objekt mit auctions-Key: { "auctions": [...] }
    if (data is Map && data['auctions'] is List) {
      return (data['auctions'] as List)
          .whereType<Map<String, dynamic>>()
          .map(AuctionItem.fromJson)
          .toList();
    }
    // Objekt mit data-Key: { "data": [...] }
    if (data is Map && data['data'] is List) {
      return (data['data'] as List)
          .whereType<Map<String, dynamic>>()
          .map(AuctionItem.fromJson)
          .toList();
    }
    return [];
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_fetch);
  }
}
