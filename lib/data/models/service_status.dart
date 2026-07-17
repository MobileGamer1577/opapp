// ═══════════════════════════════════════════════════════════════
//  service_status.dart – Datenmodell für einen API-Verfügbarkeits-Check
//
//  ✅ HIER ÄNDERN: Felder ergänzen (z.B. HTTP-Statuscode separat
//                  anzeigen, falls später gewünscht)
//  ❌ NICHT ÄNDERN: Klassenstruktur
// ═══════════════════════════════════════════════════════════════

/// Ergebnis eines einzelnen Erreichbarkeits-Checks.
class ServiceCheckResult {
  final String name;
  final String url;
  final bool isOnline;

  /// Antwortzeit in Millisekunden. null wenn offline (Timeout/Fehler).
  final int? pingMs;

  const ServiceCheckResult({
    required this.name,
    required this.url,
    required this.isOnline,
    this.pingMs,
  });
}

/// Eine Gruppe von Checks (z.B. "Markt-API", "Spieler-API (mc-api.io)").
class ServiceGroup {
  final String label;
  final List<ServiceCheckResult> services;

  const ServiceGroup({required this.label, required this.services});
}
