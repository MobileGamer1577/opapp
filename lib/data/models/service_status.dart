// ═══════════════════════════════════════════════════════════════
//  service_status.dart – Datenmodell für einen API-Verfügbarkeits-Check
//
//  ✅ HIER ÄNDERN: Felder ergänzen (z.B. HTTP-Statuscode separat
//                  anzeigen, falls später gewünscht)
//  ❌ NICHT ÄNDERN: Klassenstruktur
//
//  ÄNDERUNGEN (Progressiv-Update):
//    - ServiceGroup entfernt – die Gruppierung läuft jetzt direkt über
//      endpointGroups in service_status_repository.dart (statische
//      Struktur, kein gebündeltes Fetch-Ergebnis mehr nötig, da jeder
//      Endpunkt einzeln und unabhängig geprüft wird).
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
