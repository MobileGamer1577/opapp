// ═══════════════════════════════════════════════════════════════
//  server_status_repository.dart – Live-Serverstatus (mc-api.io) +
//  Spieler-Rekord (eigenes opapp-api Backend) + Release-Datum
//
//  ✅ HIER ÄNDERN: serverReleaseDate
//  ❌ NICHT ÄNDERN: Provider-Namen serverStatusProvider/serverPeakProvider
//
//  ZWEI GETRENNTE QUELLEN:
//    - Live-Status (online, Spielerzahl gerade jetzt) kommt DIREKT
//      von mc-api.io – wird nicht von uns gespeichert, ist einfach
//      der aktuelle Live-Wert. Automatischer Refresh alle 30s
//      (ApiConstants.serverStatusRefreshInterval), gleiches
//      Timer-Muster wie AuctionsNotifier in auction_repository.dart.
//    - Der Spieler-REKORD (höchste je gemessene Spielerzahl + Datum)
//      kommt aus dem eigenen opapp-api Backend (GET /server/peak),
//      das dafür selbst im 1-Minuten-Cron bei mc-api.io pollt und
//      nur bei neuem Rekord in D1 schreibt (siehe worker.js,
//      pollPlayerPeak – opapp-api Repo).
//
//  HINWEIS ZU "maxPlayers": mc-api.io liefert zwar ein maxPlayers-
//  Feld, das ist bei OPSUCHT aber KEINE feste Server-Kapazität,
//  sondern technisch bedingt immer genau (aktuelle Spielerzahl + 1)
//  – deshalb wird es bewusst gar nicht erst geparst (siehe
//  ServerStatus.fromJson in server_status.dart).
// ═══════════════════════════════════════════════════════════════

import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/server_status.dart';
import '../models/server_peak.dart';
import '../api_service.dart';
import '../../core/api_constants.dart';

/// ✅ HIER ÄNDERN: Datum, an dem der Server gegründet wurde – Basis
/// für den Geburtstags-Countdown im Server-Info-Screen.
final DateTime serverReleaseDate = DateTime(2018, 10, 23);

/// Nächstes Jubiläum (Tag+Monat von [serverReleaseDate]) – dieses
/// Jahr, falls noch nicht vorbei, sonst nächstes Jahr.
DateTime nextServerBirthday() {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  var next = DateTime(now.year, serverReleaseDate.month, serverReleaseDate.day);
  if (next.isBefore(today)) {
    next = DateTime(now.year + 1, serverReleaseDate.month, serverReleaseDate.day);
  }
  return next;
}

// ── Live-Status (mc-api.io) ────────────────────────────────────
final serverStatusProvider =
    AsyncNotifierProvider.autoDispose<ServerStatusNotifier, ServerStatus>(
  ServerStatusNotifier.new,
);

class ServerStatusNotifier extends AutoDisposeAsyncNotifier<ServerStatus> {
  Timer? _timer;

  @override
  Future<ServerStatus> build() async {
    _timer = Timer.periodic(
      ApiConstants.serverStatusRefreshInterval,
      (_) => ref.invalidateSelf(),
    );
    ref.onDispose(() => _timer?.cancel());
    return _fetch();
  }

  Future<ServerStatus> _fetch() async {
    final api = ApiService();
    final data = await api.get(ApiConstants.serverStatusUrl);
    api.dispose();
    if (data is Map<String, dynamic>) {
      return ServerStatus.fromJson(data);
    }
    return const ServerStatus(online: false, onlinePlayers: 0);
  }
}

// ── Spieler-Rekord (eigenes opapp-api Backend) ─────────────────
final serverPeakProvider = FutureProvider.autoDispose<ServerPeak>((ref) async {
  final api = ApiService();
  final data = await api.get(ApiConstants.serverPeak);
  api.dispose();
  if (data is Map<String, dynamic>) {
    return ServerPeak.fromJson(data);
  }
  return const ServerPeak(playerCount: null, achievedAt: null);
});
