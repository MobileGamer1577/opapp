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
//
//  ÄNDERUNGEN (Allzeithoch-Update):
//    - NEU: eigenes Backend "opapp-shards-api" (Cloudflare Worker + D1,
//      separates Repo) – trackt Allzeithoch & Kursverlauf der OPShards-
//      Wechselkurse, da die offizielle OPSUCHT-API selbst keine
//      Historie liefert. Läuft komplett unabhängig im Hintergrund
//      (Cron-Job alle 15 Min.), die App liest hier NUR (GET).
//
//  ÄNDERUNGEN (Server-Status-Update):
//    - Eigenes Backend umbenannt: "opapp-shards-api" → "opapp-api"
//      (deckt jetzt neben den OPShard-Kursen auch den Server-
//      Spieler-Rekord ab, der alte Name war nicht mehr treffend).
//      ⚠️ Auf Backend-Seite unbedingt die Deploy-Reihenfolge aus dem
//      Kommentar in wrangler.toml (opapp-api-Repo) beachten, bevor
//      diese URL live geht!
//    - NEU: serverStatusUrl – Live-Serverstatus direkt von mc-api.io
//      (Online-Status + aktuelle Spielerzahl). Bewusst NICHT
//      "opsucht.net" sondern "bc4.opsucht.iwmedia.ovh" (auf Wunsch).
//    - NEU: serverPeak – Spieler-Rekord (höchste je gemessene
//      Online-Spielerzahl + Datum) aus dem eigenen opapp-api Backend.
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

  // ── OPAPP-Backend (eigenes Repo, Cloudflare Worker + D1) ──
  // ✅ Umbenannt von "opapp-shards-api" zu "opapp-api" (Server-
  // Status-Update) – deckt inzwischen mehr als nur Shard-Kurse ab.
  // Pollt selbstständig per Cron die OPSUCHT-API + mc-api.io und
  // speichert Allzeithoch, Kursverlauf und den Spieler-Rekord – die
  // App ruft hier NUR lesend ab, schreibt niemals selbst.
  static const String _backendBaseUrl = 'https://opapp-api.px32.workers.dev';

  /// GET → Liste aller Allzeithochs, siehe ShardAllTimeHigh.fromJson
  static const String shardsAth = '$_backendBaseUrl/shards/ath';

  /// GET → Kursverlauf für ein einzelnes Item (für den künftigen Graphen).
  /// [itemKey] muss mit ShardItem.athKey (shard_rate.dart) übereinstimmen.
  static String shardsHistory(String itemKey, {int days = 30}) =>
      '$_backendBaseUrl/shards/history/${Uri.encodeComponent(itemKey)}?days=$days';

  /// GET → Spieler-Rekord (höchste je gemessene Online-Spielerzahl +
  /// Datum), siehe ServerPeak.fromJson.
  static const String serverPeak = '$_backendBaseUrl/server/peak';

  // ── Live-Serverstatus (mc-api.io) ──────────────────────────
  // ✅ HIER ÄNDERN: Server-Adresse. Bewusst "bc4.opsucht.iwmedia.ovh"
  // statt "opsucht.net" (auf Wunsch) – dieselbe Adresse verwendet
  // auch der Worker (PLAYER_STATUS_URL in worker.js, opapp-api Repo)
  // für die Rekord-Erfassung.
  static const String serverStatusUrl =
      'https://mc-api.io/server/java/bc4.opsucht.iwmedia.ovh';

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
  static const Duration serverStatusRefreshInterval = Duration(seconds: 30);

  // ── HTTP Timeouts ─────────────────────────────────────────
  static const Duration connectTimeout = Duration(seconds: 10);
  static const Duration receiveTimeout = Duration(seconds: 15);
}
