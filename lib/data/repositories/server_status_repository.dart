// ═══════════════════════════════════════════════════════════════
//  server_status_repository.dart – Live-Serverstatus (mc-api.io) +
//  Spieler-Rekord & Tages-Peak (eigenes opapp-api Backend) + Release-
//  Datum + Farmwelt-Version
//
//  ✅ HIER ÄNDERN: serverReleaseDate, farmWorldVersion
//  ❌ NICHT ÄNDERN: Provider-Namen serverStatusProvider/
//                   serverPeakProvider/serverPeakTodayProvider
//
//  DREI GETRENNTE QUELLEN:
//    - Live-Status (online, Spielerzahl gerade jetzt, Versions-Spanne)
//      kommt DIREKT von mc-api.io – wird nicht von uns gespeichert,
//      ist einfach der aktuelle Live-Wert. Automatischer Refresh alle
//      30s (ApiConstants.serverStatusRefreshInterval), gleiches
//      Timer-Muster wie AuctionsNotifier in auction_repository.dart.
//    - Der Spieler-REKORD (höchste je gemessene Spielerzahl + Datum,
//      ALL-TIME) kommt aus dem eigenen opapp-api Backend (GET
//      /server/peak), das dafür selbst im 1-Minuten-Cron bei
//      mc-api.io pollt und nur bei neuem Rekord in D1 schreibt
//      (siehe worker.js, pollPlayerPeak – opapp-api Repo).
//    - Der Tages-Peak (höchste Spielerzahl HEUTE) kommt aus demselben
//      Backend (GET /server/peak/today, NEU) – eigene D1-Tabelle
//      (daily_peak) mit einer Zeile pro Kalendertag, Tagesgrenze ist
//      Europe/Berlin Mitternacht (NICHT UTC), siehe berlinDateString()
//      im Worker.
//
//  HINWEIS ZU "maxPlayers": mc-api.io liefert zwar ein maxPlayers-
//  Feld, das ist bei OPSUCHT aber KEINE feste Server-Kapazität,
//  sondern technisch bedingt immer genau (aktuelle Spielerzahl + 1)
//  – deshalb wird es bewusst gar nicht erst geparst (siehe
//  ServerStatus.fromJson in server_status.dart).
//
//  ÄNDERUNGEN (Server-Info-Update):
//    - NEU: serverPeakTodayProvider – nutzt dasselbe ServerPeak-
//      Modell wie serverPeakProvider (identisches JSON-Format), nur
//      anderer Endpunkt.
//    - NEU: farmWorldVersion – statische Konstante, kommt NICHT aus
//      der API (kein passendes Feld), rein manuell gepflegt.
//    - NEU: nextServerBirthdayNumber() – wievielter Geburtstag das
//      nächste Jubiläum ist (z.B. 8), für die Anzeige "...bis zum
//      8. Geburtstag" statt nur "...zum nächsten Jubiläum".
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

/// ✅ HIER ÄNDERN: Version, auf der die Farmwelten aktuell laufen.
/// Kommt NICHT aus der API (kein passendes Feld in der mc-api.io-
/// Antwort) – rein manuell gepflegt, analog zu serverReleaseDate.
const String farmWorldVersion = '1.21.11';

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

/// Wievielter Geburtstag [nextServerBirthday] ist, z.B. 8 (Server
/// gegründet 2018, nächstes Jubiläum fällt ins Jahr 2026). Fällt das
/// Jubiläum auf HEUTE, liefert das automatisch die korrekte aktuelle
/// Zahl (nextServerBirthday() gibt dann ja bereits das heutige Datum
/// zurück statt eines künftigen).
int nextServerBirthdayNumber() =>
    nextServerBirthday().year - serverReleaseDate.year;

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

// ── Spieler-Rekord All-Time (eigenes opapp-api Backend) ────────
final serverPeakProvider = FutureProvider.autoDispose<ServerPeak>((ref) async {
  final api = ApiService();
  final data = await api.get(ApiConstants.serverPeak);
  api.dispose();
  if (data is Map<String, dynamic>) {
    return ServerPeak.fromJson(data);
  }
  return const ServerPeak(playerCount: null, achievedAt: null);
});

// ── Spieler-Rekord HEUTE (eigenes opapp-api Backend) ────────────
// ✅ NEU (Server-Info-Update): Gleiches ServerPeak-Modell wie der
// All-Time-Rekord oben – nur anderer Endpunkt. Tagesgrenze ist
// Europe/Berlin Mitternacht (serverseitig im Worker berechnet, siehe
// berlinDateString() in worker.js), NICHT UTC.
final serverPeakTodayProvider =
    FutureProvider.autoDispose<ServerPeak>((ref) async {
  final api = ApiService();
  final data = await api.get(ApiConstants.serverPeakToday);
  api.dispose();
  if (data is Map<String, dynamic>) {
    return ServerPeak.fromJson(data);
  }
  return const ServerPeak(playerCount: null, achievedAt: null);
});
