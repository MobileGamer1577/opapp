/// Alle API-Endpunkte und Konfiguration für OPSUCHT.NET
class ApiConstants {
  ApiConstants._(); // Keine Instanz erlaubt

  // ─── Base URLs ─────────────────────────────────────────────
  static const String baseUrl = 'https://api.opsucht.net';

  // ─── Endpunkte ─────────────────────────────────────────────
  static const String market = '$baseUrl/market';
  static const String auctions = '$baseUrl/auctions';
  static const String merchantRates = '$baseUrl/merchant/rates';

  // ─── Externer Link ─────────────────────────────────────────
  static const String websiteUrl = 'https://opsucht.net';
  static const String rulesUrl =
      'https://wiki.opsucht.net/regelwerk/'; // Anpassen

  // ─── Polling-Intervalle ────────────────────────────────────
  static const Duration auctionRefreshInterval = Duration(seconds: 30);
  static const Duration ratesRefreshInterval = Duration(minutes: 5);

  // ─── HTTP Timeouts ─────────────────────────────────────────
  static const Duration connectTimeout = Duration(seconds: 10);
  static const Duration receiveTimeout = Duration(seconds: 15);
}
