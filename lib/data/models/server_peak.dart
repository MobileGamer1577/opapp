// ═══════════════════════════════════════════════════════════════
//  server_peak.dart – Datenmodell für den Spieler-Rekord
//  (Quelle: eigenes opapp-api Backend, GET /server/peak)
//
//  ✅ HIER ÄNDERN: Felder ergänzen, falls das Backend erweitert wird
//  ❌ NICHT ÄNDERN: Klassenstruktur
//
//  API-FORMAT:
//    { "playerCount": 737, "achievedAt": 1783900800000 }
//  Noch kein Rekord erfasst (z.B. frisch deployter Worker, bevor der
//  erste Cron-Tick lief):
//    { "playerCount": null, "achievedAt": null }
// ═══════════════════════════════════════════════════════════════

class ServerPeak {
  final int? playerCount;
  final DateTime? achievedAt;

  const ServerPeak({required this.playerCount, required this.achievedAt});

  factory ServerPeak.fromJson(Map<String, dynamic> json) {
    final ms = json['achievedAt'];
    return ServerPeak(
      playerCount: (json['playerCount'] as num?)?.toInt(),
      achievedAt: ms is num
          ? DateTime.fromMillisecondsSinceEpoch(ms.toInt(), isUtc: true)
          : null,
    );
  }

  bool get hasRecord => playerCount != null && achievedAt != null;
}
