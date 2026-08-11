// ═══════════════════════════════════════════════════════════════
//  server_status.dart – Datenmodell für den Live-Serverstatus
//  (Quelle: mc-api.io)
//
//  ✅ HIER ÄNDERN: Felder ergänzen, falls später mehr gebraucht wird
//  ❌ NICHT ÄNDERN: Klassenstruktur
//
//  API-FORMAT (Auszug, siehe mc-api.io/server/java/{adresse}):
//    { "online": true, "onlinePlayers": 737, "maxPlayers": 738, ... }
//
//  "maxPlayers" wird bewusst NICHT geparst: Bei OPSUCHT ist das
//  technisch bedingt IMMER (onlinePlayers + 1) – keine echte
//  Kapazitätsangabe. Eine "X von Y Spielern"-Anzeige wäre damit
//  irreführend, deshalb zeigt die App nur die reine Online-Zahl
//  (siehe dashboard_screen.dart / server_info_screen.dart).
// ═══════════════════════════════════════════════════════════════

class ServerStatus {
  final bool online;
  final int onlinePlayers;

  const ServerStatus({required this.online, required this.onlinePlayers});

  factory ServerStatus.fromJson(Map<String, dynamic> json) {
    return ServerStatus(
      online: json['online'] == true,
      onlinePlayers: (json['onlinePlayers'] as num?)?.toInt() ?? 0,
    );
  }
}
