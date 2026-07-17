// ═══════════════════════════════════════════════════════════════
//  service_status_repository.dart – Prüft alle von der App genutzten
//  APIs auf Erreichbarkeit (Online/Offline) + Ping
//
//  ✅ HIER ÄNDERN: _endpointGroups – Endpunkte ergänzen/entfernen/
//                  umbenennen. Test-Werte unten anpassen, falls sich
//                  die Beispiel-UUID/-Namen ändern sollen.
//  ❌ NICHT ÄNDERN: Provider-Name serviceStatusProvider
//
//  WARUM EIGENE HTTP-CALLS STATT ApiService:
//  ApiService wirft bei Nicht-200-Antworten eine typisierte Exception
//  und verliert dabei den genauen Status. Hier zählt aber jede
//  tatsächlich empfangene Antwort (auch 404/500) als "online" – nur
//  ein Timeout/Netzwerkfehler bedeutet "offline". Deshalb ein
//  schlanker, direkter http.get() mit Stopwatch.
//
//  PARAMETRISIERTE ENDPUNKTE:
//  Einige Routen brauchen einen echten Wert (Material, UUID, XUID,
//  Spielername), sonst würde z.B. ein technisch erreichbarer Server
//  einen 404 liefern, der in einem naiven Check falsch als "kaputt"
//  interpretiert werden könnte. Die Testwerte unten sind bewusst
//  gewählt (siehe Konstanten) und rein zum Zweck des Ping-Checks –
//  sie lösen KEINE echten App-Features aus.
// ═══════════════════════════════════════════════════════════════

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import '../models/service_status.dart';

class _Endpoint {
  final String name;
  final String url;
  const _Endpoint(this.name, this.url);
}

// ── Test-Werte für parametrisierte Routen ─────────────────────
const _testMaterial = 'DIAMOND_BLOCK';
const _testPlayerName = 'ByteException_';
const _testUuid = 'bef1d0a8-e281-4f69-9200-64e07c235c96';
const _testXuid = '2535459829090337';

// ── Zu prüfende Endpunkte, gruppiert nach API ─────────────────
const List<MapEntry<String, List<_Endpoint>>> _endpointGroups = [
  MapEntry('Markt-API', [
    _Endpoint('Markt',            'https://api.opsucht.net/market'),
    _Endpoint('Preise',           'https://api.opsucht.net/market/prices'),
    _Endpoint('Kategorien',       'https://api.opsucht.net/market/categories'),
    _Endpoint('Items',            'https://api.opsucht.net/market/items'),
    _Endpoint('Preis (Item)',     'https://api.opsucht.net/market/price/$_testMaterial'),
    _Endpoint('Preisverlauf',     'https://api.opsucht.net/market/history/$_testMaterial'),
  ]),
  MapEntry('Auktionshaus-API', [
    _Endpoint('Auktionen',        'https://api.opsucht.net/auctions'),
    _Endpoint('Kategorien',       'https://api.opsucht.net/auctions/categories'),
    _Endpoint('Aktive Auktionen', 'https://api.opsucht.net/auctions/active'),
  ]),
  MapEntry('Merchant-API', [
    _Endpoint('Merchant',         'https://api.opsucht.net/merchant/'),
    _Endpoint('Wechselkurse',     'https://api.opsucht.net/merchant/rates'),
  ]),
  MapEntry('Spieler-API (mc-api.io)', [
    _Endpoint('mc-api.io',             'https://mc-api.io'),
    _Endpoint('UUID (Name)',           'https://mc-api.io/uuid/$_testPlayerName'),
    _Endpoint('UUID (Name + Edition)', 'https://mc-api.io/uuid/$_testPlayerName/java'),
    _Endpoint('Name (UUID)',           'https://mc-api.io/name/$_testUuid'),
    _Endpoint('Name (XUID)',           'https://mc-api.io/name/$_testXuid'),
    _Endpoint('Server-Status',         'https://mc-api.io/server/java/opsucht.net'),
  ]),
  MapEntry('OPAPP Shards-API (eigenes Backend)', [
    _Endpoint('Allzeithoch', 'https://opapp-shards-api.px32.workers.dev/shards/ath'),
  ]),
];

final serviceStatusProvider =
    FutureProvider.autoDispose<List<ServiceGroup>>((ref) async {
  // Alle Gruppen UND alle Endpunkte innerhalb einer Gruppe parallel
  // prüfen (Future.wait) – hält die Ladezeit trotz ~15 Endpunkten kurz.
  final groups = await Future.wait(_endpointGroups.map((entry) async {
    final results = await Future.wait(
      entry.value.map((e) => _check(e.name, e.url)),
    );
    return ServiceGroup(label: entry.key, services: results);
  }));

  return groups;
});

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
