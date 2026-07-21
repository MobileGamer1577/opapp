// ═══════════════════════════════════════════════════════════════
//  service_status_repository.dart – Prüft alle von der App genutzten
//  APIs auf Erreichbarkeit (Online/Offline) + Ping
//
//  ✅ HIER ÄNDERN: endpointGroups – Endpunkte ergänzen/entfernen/
//                  umbenennen. Test-Werte unten anpassen, falls sich
//                  die Beispiel-UUID/-XUID ändern sollen.
//  ❌ NICHT ÄNDERN: Provider-Name serviceStatusControllerProvider
//
//  ÄNDERUNGEN (Sequenziell-Update):
//    - NEU: Statt alle Endpunkte gleichzeitig zu prüfen (paralleler
//      .family-Provider), verwaltet jetzt ein ServiceStatusController
//      EINE interne Warteschlange – IMMER nur ein Request gleich-
//      zeitig, der nächste startet erst, wenn der vorherige eine
//      Antwort (Erfolg oder Fehler) geliefert hat.
//    - NEU: Ein Endpunkt landet erst dann in der Warteschlange, wenn
//      seine Karte im Screen tatsächlich gebaut wird – siehe
//      service_status_screen.dart (ListView.builder + requestCheck()
//      beim ersten Build einer Karte). Beim Scrollen kommen so
//      nach und nach neue Endpunkte dazu, nicht alle auf einmal.
//    - NEU: Einmal geprüfte Endpunkte werden für die Dauer der
//      Session gecacht (kein erneuter Request beim Zurückscrollen).
//      Der Cache lebt im Provider-State (autoDispose) → wird
//      automatisch geleert, sobald der Dienstverfügbarkeit-Screen
//      verlassen wird.
//    - Ersetzt den bisherigen serviceCheckProvider (FutureProvider.
//      family, alle parallel) komplett.
//    - Umbenennungen: "Auktionen" → "Auktionshaus", Gruppe "Merchant-
//      API" → "OPShards-API", Endpunkt "Merchant" → "OPShards".
//    - Entfernt: "UUID (Name)" und "UUID (Name + Edition)".
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

/// Ein einzelner zu prüfender Endpunkt. Wird als Map-Key im Cache
/// verwendet – da endpointGroups eine `const`-Liste ist, sind alle
/// ServiceEndpoint-Instanzen kanonisiert (Dart garantiert Objekt-
/// Identität für identische const-Ausdrücke), daher funktioniert die
/// Standard-Gleichheit (==) hier zuverlässig als Map-Key, ganz ohne
/// manuelles Überschreiben von ==/hashCode.
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

/// Verwaltet eine sequenzielle Warteschlange + einen Session-Cache.
/// State: Map von Endpunkt → Ergebnis. Wert `null` bedeutet "in der
/// Warteschlange / wird gerade geprüft", ein fehlender Key bedeutet
/// "noch nie angefragt" (beide Fälle werden im Screen identisch als
/// "Wird überprüft…" dargestellt).
class ServiceStatusController
    extends AutoDisposeNotifier<Map<ServiceEndpoint, ServiceCheckResult?>> {
  final List<ServiceEndpoint> _queue = [];
  bool _isProcessing = false;

  @override
  Map<ServiceEndpoint, ServiceCheckResult?> build() => {};

  /// Meldet einen Endpunkt zur Prüfung an. Kein Effekt, falls er schon
  /// geprüft wurde ODER schon in der Warteschlange steht – dadurch ist
  /// es sicher, requestCheck() bei jedem (Wieder-)Aufbau einer Karte
  /// erneut aufzurufen.
  void requestCheck(ServiceEndpoint endpoint) {
    if (state.containsKey(endpoint)) return;
    state = {...state, endpoint: null};
    _queue.add(endpoint);
    _processQueue();
  }

  /// Für den Refresh-Button: kompletter Cache-Reset, alle Endpunkte
  /// (auch aktuell nicht sichtbare) werden neu in die Warteschlange
  /// gestellt und der Reihe nach neu geprüft.
  void refreshAll() {
    state = {};
    _queue.clear();
    for (final group in endpointGroups) {
      for (final endpoint in group.value) {
        requestCheck(endpoint);
      }
    }
  }

  Future<void> _processQueue() async {
    if (_isProcessing) return;
    _isProcessing = true;
    while (_queue.isNotEmpty) {
      final endpoint = _queue.removeAt(0);
      final result = await _check(endpoint.name, endpoint.url);
      state = {...state, endpoint: result};
    }
    _isProcessing = false;
  }
}

final serviceStatusControllerProvider = NotifierProvider.autoDispose<
    ServiceStatusController, Map<ServiceEndpoint, ServiceCheckResult?>>(
  ServiceStatusController.new,
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
