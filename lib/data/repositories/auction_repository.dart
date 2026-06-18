// ═══════════════════════════════════════════════════════════════
//  auction_repository.dart – Daten & Auto-Refresh für Auktionen
//
//  ✅ HIER ÄNDERN: auctionRefreshInterval in api_constants.dart
//  ❌ NICHT ÄNDERN: Provider-Struktur / _parseItems
// ═══════════════════════════════════════════════════════════════

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

    final items = _parseItems(data);

    // ── Abgelaufene Auktionen ausfiltern ────────────────────
    // isExpired ist nur true wenn endsAt BEKANNT und vergangen.
    // Unbekannte Endzeit (endsAt == null) bleibt sichtbar.
    return items.where((item) => !item.isExpired).toList();
  }

  /// Parst die API-Antwort unabhängig davon, ob sie eine direkte
  /// Liste oder ein Objekt mit Listen-Key ist.
  List<AuctionItem> _parseItems(dynamic data) {
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
