// ═══════════════════════════════════════════════════════════════
//  service_status_repository.dart – Prüft alle von der App genutzten
//  APIs auf Erreichbarkeit (Online/Offline) + Ping
//
//  ✅ HIER ÄNDERN: endpointGroups – Endpunkte ergänzen/entfernen/
//                  umbenennen. Test-Werte unten anpassen, falls sich
//                  die Beispiel-UUID/-XUID ändern sollen.
//  ❌ NICHT ÄNDERN: Provider-Name serviceCheckProvider
//
//  ÄNDERUNGEN (Progressiv-Update):
//    - NEU: Statt EINES großen Requests für alle Endpunkte (der die
//      ganze Seite hinter einem einzigen Ladespinner blockiert hat)
//      ist jeder Endpunkt jetzt sein EIGENER Riverpod-Provider
//      (FutureProvider.family<ServiceCheckResult, ServiceEndpoint>).
//      Der Screen baut sich dadurch SOFORT auf (endpointGroups ist
//      eine statische, synchron bekannte Liste) – jede einzelne Karte
//      zeigt "Wird überprüft…" und wechselt für sich zu Online/
//      Offline, sobald IHR Request fertig ist, unabhängig von allen
//      anderen.
//    - Umbenennungen: "Auktionen" → "Auktionshaus" (erster Endpunkt
//      im Auktionshaus-Bereich). Gruppe "Merchant-API" → "OPShards-
//      API", erster Endpunkt darin "Merchant" → "OPShards" (bessere,
//      einheitliche Bezeichnung – "Merchant" war der interne API-Name,
//      "OPShards" ist der Name, den die App überall sonst verwendet).
//    - Entfernt: "UUID (Name)" und "UUID (Name + Edition)" – werden
//      aktuell nirgends in der App gebraucht.
//
//  WARUM EIGENE HTTP-CALLS STATT ApiService:
//  ApiService wirft bei Nicht-200-Antworten eine typisierte Exception
//  und verliert dabei den genauen Status. Hier zählt aber jede
//  tatsächlich empfangene Antwort (auch 404/500) als "online" – nur
//  ein Timeout/Netzwerkfehler bedeutet "offline". Deshalb ein
//  schlanker, direkter http.get() mit Stopwatch.
//
//  PARAMETRISIERTE ENDPUNKTE:
//  Einige Routen brauchen einen echten Wert (Material, UUID, XUID),
//  sonst würde z.B. ein technisch erreichbarer Server einen 404
//  liefern, der in einem naiven Check falsch als "kaputt" interpretiert
//  werden könnte. Die Testwerte unten sind bewusst gewählt (siehe
//  Konstanten) und rein zum Zweck des Ping-Checks – sie lösen KEINE
//  echten App-Features aus.
// ═══════════════════════════════════════════════════════════════

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import '../models/service_status.dart';

/// Ein einzelner zu prüfender Endpunkt. Wird als Family-Parameter für
/// serviceCheckProvider verwendet – da endpointGroups eine `const`-
/// Liste ist, sind alle ServiceEndpoint-Instanzen kanonisiert (Dart
/// garantiert Objekt-Identität für identische const-Ausdrücke), daher
/// funktioniert die Standard-Gleichheit (==) hier zuverlässig als
/// Family-Key, ganz ohne manuelles Überschreiben von ==/hashCode.
class ServiceEndpoint {
  final String name;
  final String url;
  const ServiceEndpoint(this.name, this.url);
}

// ── Test-Werte für parametrisierte Routen ─────────────────────
const _testMaterial = 'DIAMOND_BLOCK';
const _testUuid = 'bef1d0a8-e281-4f69-9200-64e07c235c96';
const _testXuid = '2535459829090337';

// ── Zu prüfende Endpunkte, gruppiert nach API ─────────────────
const List<MapEntry<String, List<ServiceEndpoint>>> endpointGroups = [
  MapEntry('Markt-API', [
    ServiceEndpoint('Markt',        'https://api.opsucht.net/market'),
    ServiceEndpoint('Preise',       'https://api.opsucht.net/market/prices'),
    ServiceEndpoint('Kategorien',   'https://api.opsucht.net/market/categories'),
    ServiceEndpoint('Items',        'https://api.opsucht.net/market/items'),
    ServiceEndpoint('Preis (Item)', 'https://api.opsucht.net/market/price/$_testMaterial'),
    ServiceEndpoint('Preisverlauf', 'https://api.opsucht.net/market/history/$_testMaterial'),
  ]),
  MapEntry('Auktionshaus-API', [
    ServiceEndpoint('Auktionshaus',     'https://api.opsucht.net/auctions'),
    ServiceEndpoint('Kategorien',       'https://api.opsucht.net/auctions/categories'),
    ServiceEndpoint('Aktive Auktionen', 'https://api.opsucht.net/auctions/active'),
  ]),
  MapEntry('OPShards-API', [
    ServiceEndpoint('OPShards',     'https://api.opsucht.net/merchant/'),
    ServiceEndpoint('Wechselkurse', 'https://api.opsucht.net/merchant/rates'),
  ]),
  MapEntry('Spieler-API (mc-api.io)', [
    ServiceEndpoint('mc-api.io',     'https://mc-api.io'),
    ServiceEndpoint('Name (UUID)',   'https://mc-api.io/name/$_testUuid'),
    ServiceEndpoint('Name (XUID)',   'https://mc-api.io/name/$_testXuid'),
    ServiceEndpoint('Server-Status', 'https://mc-api.io/server/java/opsucht.net'),
  ]),
  MapEntry('OPAPP Shards-API (eigenes Backend)', [
    ServiceEndpoint('Allzeithoch', 'https://opapp-shards-api.px32.workers.dev/shards/ath'),
  ]),
];

/// Ein Provider PRO Endpunkt – ref.watch(serviceCheckProvider(endpoint))
/// in der jeweiligen Karte. ref.invalidate(serviceCheckProvider) (ohne
/// Argument) invalidiert automatisch ALLE aktuell beobachteten
/// Instanzen auf einmal (z.B. für den Refresh-Button/Pull-to-Refresh).
final serviceCheckProvider =
    FutureProvider.autoDispose.family<ServiceCheckResult, ServiceEndpoint>(
  (ref, endpoint) => _check(endpoint.name, endpoint.url),
);

Future<ServiceCheckResult> _check(String name, String url) async {
  final stopwatch = Stopwatch()..start();
  try {
    // Bewusst OHNE ApiService: jede empfangene Antwort (auch 4xx/5xx)
    // zählt als "online" – der Server ist erreichbar und antwortet.
    await http
        .get(Uri.parse(url), headers: {'Accept': '*/*', 'User-Agent': 'OPAPP/1.0'})
        .timeout(const Duration(seconds: 6));
    stopwatch.stop();
    return ServiceCheckResult(
      name: name,
      url: url,
      isOnline: true,
      pingMs: stopwatch.elapsedMilliseconds,
    );
  } catch (_) {
    stopwatch.stop();
    return ServiceCheckResult(name: name, url: url, isOnline: false, pingMs: null);
  }
}
