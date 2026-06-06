// ═══════════════════════════════════════════════════════════════
//  api_constants.dart – Alle API-URLs und Timeouts
//
//  ✅ HIER ÄNDERN: Neue Endpunkte hinzufügen
//  ✅ HIER ÄNDERN: Refresh-Intervalle anpassen
//  ❌ NICHT ÄNDERN: Klassen-Struktur / Konstruktor
//
//  NEUEN ENDPUNKT HINZUFÜGEN:
//    static const String meinEndpunkt = '$baseUrl/mein-pfad';
//  Danach in einem Repository verwenden:
//    api.get(ApiConstants.meinEndpunkt)
// ═══════════════════════════════════════════════════════════════

/// Alle API-Endpunkte und Konfiguration für OPSUCHT.NET
class ApiConstants {
  ApiConstants._(); // Private Konstruktor – keine Instanz möglich

  // ── Base URL ──────────────────────────────────────────────
  // Alle Endpunkte bauen auf dieser URL auf.
  // Wenn sich die Domain ändert, nur hier anpassen.
  static const String baseUrl = 'https://api.opsucht.net';

  // ── API Endpunkte ─────────────────────────────────────────
  // Format: static const String name = '$baseUrl/pfad';
  static const String market        = '$baseUrl/market';
  static const String auctions      = '$baseUrl/auctions';
  static const String merchantRates = '$baseUrl/merchant/rates';
  // ← Neue Endpunkte hier ergänzen

  // ── Externe Links (für url_launcher) ─────────────────────
  static const String websiteUrl = 'https://opsucht.net';
  static const String rulesUrl   = 'https://wiki.opsucht.net/regelwerk/';

  // ── Auto-Refresh Intervalle ───────────────────────────────
  // Wie oft sollen Live-Daten automatisch neu geladen werden?
  static const Duration auctionRefreshInterval = Duration(seconds: 30);
  static const Duration ratesRefreshInterval   = Duration(minutes: 5);

  // ── HTTP Timeouts ─────────────────────────────────────────
  // Wie lange maximal auf eine API-Antwort warten?
  // Bei schlechter Verbindung: erhöhen (z.B. 20 Sekunden)
  static const Duration connectTimeout = Duration(seconds: 10);
  static const Duration receiveTimeout = Duration(seconds: 15);
}
