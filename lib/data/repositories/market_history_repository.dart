// ═══════════════════════════════════════════════════════════════
//  market_history_repository.dart – Lädt den Preisverlauf eines
//  Markt-Items (GET /market/history/{material})
//
//  ✅ HIER ÄNDERN: nichts Spezielles nötig, läuft automatisch
//  ❌ NICHT ÄNDERN: Provider-Name marketHistoryProvider
//
//  EIN Request liefert alle Zeitreihen (HOURLY, DAILY, WEEKLY,
//  MONTHLY). Der Zeitraum-Wechsel im Detail-Screen (24 h / 7 T /
//  30 T / Max) wählt danach nur lokal die passende Reihe aus
//  (siehe MarketHistory.pointsFor) – kein erneutes Laden nötig.
//
//  Wird erst geladen, wenn der Detail-Screen eines Items geöffnet
//  wird, nicht beim normalen Öffnen des Marktes. Als family über
//  die Material-ID gecacht, solange der Screen offen ist.
// ═══════════════════════════════════════════════════════════════

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/market_history.dart';
import '../api_service.dart';
import '../../core/api_constants.dart';

final marketHistoryProvider = FutureProvider.autoDispose
    .family<MarketHistory, String>((ref, material) async {
  final api = ApiService();
  try {
    final data = await api.get(ApiConstants.marketHistory(material));
    return MarketHistory.fromJson(data);
  } finally {
    api.dispose();
  }
});
