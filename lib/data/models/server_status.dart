// ═══════════════════════════════════════════════════════════════
//  server_status.dart – Datenmodell für den Live-Serverstatus
//  (Quelle: mc-api.io)
//
//  ✅ HIER ÄNDERN: Felder ergänzen, falls später mehr gebraucht wird
//  ❌ NICHT ÄNDERN: Klassenstruktur
//
//  API-FORMAT (Auszug, siehe mc-api.io/server/java/{adresse}):
//    { "online": true, "onlinePlayers": 737, "maxPlayers": 738,
//      "version": "BungeeCord 1.8.x-26.x", ... }
//
//  "maxPlayers" wird bewusst NICHT geparst: Bei OPSUCHT ist das
//  technisch bedingt IMMER (onlinePlayers + 1) – keine echte
//  Kapazitätsangabe (live geprüft: 1260 online / 1261 max). Eine
//  "X von Y Spielern"-Anzeige wäre damit irreführend, deshalb zeigt
//  die App nur die reine Online-Zahl (siehe dashboard_screen.dart /
//  server_info_screen.dart).
//
//  ÄNDERUNGEN (Server-Info-Update):
//    - NEU: versionRange – aus dem "version"-Feld extrahiert &
//      aufbereitet. Rohwert ist z.B. "BungeeCord 1.8.x-26.x" (Prefix
//      "BungeeCord " UND die "1." vor der oberen Grenze fehlen oft).
//      _normalizeVersionRange() schneidet den Prefix ab (per Regex,
//      dadurch prefix-unabhängig) und ergänzt die obere Grenze auf
//      "1.26.x", FALLS sie als reines "NN.x" vorliegt und die untere
//      Grenze mit "1." beginnt – sonst wird defensiv der Rohwert
//      unverändert durchgereicht (kein Raten bei unbekanntem Format).
// ═══════════════════════════════════════════════════════════════

class ServerStatus {
  final bool online;
  final int onlinePlayers;

  /// Aufbereitete Versions-Spanne, z.B. "1.8.x – 1.26.x". null wenn
  /// die API kein (auswertbares) "version"-Feld liefert.
  final String? versionRange;

  const ServerStatus({
    required this.online,
    required this.onlinePlayers,
    this.versionRange,
  });

  factory ServerStatus.fromJson(Map<String, dynamic> json) {
    return ServerStatus(
      online: json['online'] == true,
      onlinePlayers: (json['onlinePlayers'] as num?)?.toInt() ?? 0,
      versionRange: _normalizeVersionRange(json['version']?.toString()),
    );
  }

  /// "BungeeCord 1.8.x-26.x" → "1.8.x – 1.26.x"
  ///
  /// Sucht per Regex direkt nach dem "X.x-Y.x"-Muster (ignoriert damit
  /// automatisch jeden Prefix wie "BungeeCord "). Liegt die obere
  /// Grenze als reines "NN.x" vor (kein Punkt davor) UND die untere
  /// Grenze beginnt mit "1.", wird die "1." ergänzt (Minecraft-
  /// Versionen starten aktuell immer mit "1."). Kein Treffer im
  /// Rohwert? Dann wird er unverändert zurückgegeben statt zu raten –
  /// besser eine unschöne Rohausgabe als eine falsche Kürzung.
  static String? _normalizeVersionRange(String? raw) {
    if (raw == null || raw.isEmpty) return null;

    final match =
        RegExp(r'(\d+(?:\.\d+)*\.x)-(\d+(?:\.\d+)*\.x)').firstMatch(raw);
    if (match == null) return raw;

    final lower = match.group(1)!;
    var upper = match.group(2)!;

    final upperIsBare = RegExp(r'^\d+\.x$').hasMatch(upper);
    if (upperIsBare && lower.startsWith('1.')) {
      upper = '1.$upper';
    }

    return '$lower \u2013 $upper';
  }
}
