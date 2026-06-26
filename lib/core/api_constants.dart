// ═══════════════════════════════════════════════════════════════
//  api_constants.dart – Alle API-URLs und Timeouts
//
//  ✅ HIER ÄNDERN: Neue Endpunkte hinzufügen
//  ✅ HIER ÄNDERN: Refresh-Intervalle anpassen
//  ❌ NICHT ÄNDERN: Klassen-Struktur / Konstruktor
//
//  API-DOKUMENTATION:
//    /market/items        → alle Materialien mit Icon-URL (kein Preis!)
//    /market/categories   → alle Kategorien mit Name + Icon
//    /market/prices       → Kategorie → Material → [BUY, SELL] Preise
//    /auctions/active     → alle aktiven Auktionen (mit Enchants & Lore)
//    /auctions/categories → Auktions-Kategorien
//    /merchant/rates      → OPShard Wechselkurse
// ═══════════════════════════════════════════════════════════════

class ApiConstants {
  ApiConstants._();

  // ── Base URL ──────────────────────────────────────────────
  static const String baseUrl = 'https://api.opsucht.net';

  // ── Markt ─────────────────────────────────────────────────
  // /market/items      → nur Material + Icon (keine Preise!)
  // /market/categories → Kategorie-Namen + repräsentatives Icon
  // /market/prices     → die eigentlichen Kauf-/Verkaufspreise,
  //                      verschachtelt nach Kategorie → Material
  static const String marketItems      = '$baseUrl/market/items';
  static const String marketCategories = '$baseUrl/market/categories';
  static const String marketPrices     = '$baseUrl/market/prices';

  // ── Auktionshaus ──────────────────────────────────────────
  // /auctions         → gibt nur API-Dokumentation zurück (nicht verwenden)
  // /auctions/active  → alle aktiven Auktionen inkl. Enchants & Lore
  static const String auctionsActive     = '$baseUrl/auctions/active';
  static const String auctionsCategories = '$baseUrl/auctions/categories';

  // ── Merchant / OPShards ───────────────────────────────────
  static const String merchantRates = '$baseUrl/merchant/rates';

  // ── Externe Spieler-Namen-API (mc-api.io) ──────────────────
  // Löst eine Verkäufer-UUID in den aktuellen Spielernamen auf.
  // Limit: 500 Requests/Tag → IMMER über PlayerNameRepository
  // (mit 7-Tage-Cache) aufrufen, NIEMALS direkt!
  static const String _mcApiBaseUrl = 'https://mc-api.io';
  static String nameByUuid(String uuid) => '$_mcApiBaseUrl/name/$uuid';

  // ── Externe Links ─────────────────────────────────────────
  static const String websiteUrl = 'https://opsucht.net';
  static const String rulesUrl   = 'https://wiki.opsucht.net/regelwerk/';

  // ── Über-Screen: Entwickler-Links ──────────────────────────
  static const String bioUrl     = 'https://guns.lol/mobilegamer1577';
  static const String discordUrl = 'https://discord.gg/6zaJXKDqN4';
  static const String githubUrl  = 'https://github.com/MobileGamer1577/opapp';

  // ── Über-Screen: Credits (Datenquellen) ────────────────────
  // baseUrl, websiteUrl & rulesUrl sind oben bereits definiert
  // und werden im Credits-Bereich des Über-Screens wiederverwendet.
  static const String mcApiCreditUrl = 'https://mc-api.io';

  // ── Auto-Refresh Intervalle ───────────────────────────────
  static const Duration auctionRefreshInterval = Duration(seconds: 30);
  static const Duration ratesRefreshInterval   = Duration(minutes: 5);

  // ── HTTP Timeouts ─────────────────────────────────────────
  static const Duration connectTimeout = Duration(seconds: 10);
  static const Duration receiveTimeout = Duration(seconds: 15);
}
