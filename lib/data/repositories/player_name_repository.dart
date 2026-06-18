// ═══════════════════════════════════════════════════════════════
//  player_name_repository.dart – Spieler-UUID → aktueller Name
//
//  ✅ HIER ÄNDERN: _cacheDuration anpassen
//  ❌ NICHT ÄNDERN: Cache-Key / _CachedName-Struktur
//
//  ABLAUF:
//    1. UUID im lokalen Cache vorhanden und < 7 Tage alt?
//       → Name sofort zurückgeben (kein API-Request)
//    2. Cache fehlt oder abgelaufen?
//       → GET https://mc-api.io/name/{uuid}, Ergebnis speichern.
//       → Nach Umbenennung wird der Name nach 7 Tagen aktualisiert.
//    3. API nicht erreichbar (Limit, kein Internet)?
//       → Alten Cache-Wert nutzen, sonst UUID kürzen als Fallback.
//
//  VERWENDUNG:
//    final nameAsync = ref.watch(playerNameProvider(item.sellerId));
//    final name = nameAsync.when(
//      data:    (n) => n,
//      loading: () => 'Lädt...',
//      error:   (_, __) => 'Unbekannt',
//    );
//
//  SETUP:
//    flutter pub add shared_preferences
// ═══════════════════════════════════════════════════════════════

import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../api_service.dart';
import '../../core/api_constants.dart';

// ── Interner Cache-Key in SharedPreferences ───────────────────
const _cacheKey = 'player_name_cache_v1';

// ── Cache-Dauer: Nach 7 Tagen wird der Name neu abgerufen ─────
// (fängt Umbenennungen auf, ohne das API-Tageslimit zu sprengen)
const _cacheDuration = Duration(days: 7);

// ── Provider (mit UUID als Parameter) ────────────────────────
// Riverpod dedupliziert automatisch: Mehrere Karten mit derselben
// UUID teilen sich die selbe Future und den selben Cache-Eintrag.
final playerNameProvider =
    FutureProvider.autoDispose.family<String, String>((ref, uuid) {
  return PlayerNameRepository().resolve(uuid);
});

// ── Repository ────────────────────────────────────────────────
class PlayerNameRepository {
  /// Löst eine UUID in den aktuellen Spielernamen auf.
  /// Gibt im schlimmsten Fall eine gekürzte UUID zurück (niemals null).
  Future<String> resolve(String uuid) async {
    if (uuid.isEmpty) return 'Unbekannt';

    final prefs  = await SharedPreferences.getInstance();
    final cached = _readEntry(prefs, uuid);

    // Cache-Treffer und noch nicht abgelaufen → sofort zurückgeben
    if (cached != null &&
        DateTime.now().difference(cached.fetchedAt) < _cacheDuration) {
      return cached.name;
    }

    // API-Request
    try {
      final api  = ApiService();
      final data = await api.get(ApiConstants.nameByUuid(uuid));
      api.dispose();

      final name = _extractName(data);
      if (name != null && name.isNotEmpty) {
        await _writeEntry(
          prefs,
          uuid,
          _CachedName(name: name, fetchedAt: DateTime.now()),
        );
        return name;
      }
    } catch (_) {
      // Netzwerkfehler oder API-Tageslimit (500/Tag) erreicht –
      // alter Cache-Wert oder gekürzte UUID wird verwendet.
    }

    return cached?.name ?? _shortenUuid(uuid);
  }

  // ── Name aus verschiedenen API-Antwortformaten lesen ─────

  /// mc-api.io gibt entweder direkt einen String oder ein Objekt zurück.
  String? _extractName(dynamic data) {
    if (data is String && data.isNotEmpty) return data;
    if (data is Map) {
      final n = data['name']        ??
                data['username']    ??
                data['playerName']  ??
                data['displayName'];
      if (n != null) return n.toString();
    }
    return null;
  }

  /// Fallback: "8d3f2c1a-..." → "8d3f2c1a…"
  String _shortenUuid(String uuid) =>
      uuid.length > 8 ? '${uuid.substring(0, 8)}\u2026' : uuid;

  // ── SharedPreferences-Hilfsmethoden ──────────────────────

  Map<String, dynamic> _readAll(SharedPreferences prefs) {
    final raw = prefs.getString(_cacheKey);
    if (raw == null) return {};
    try {
      return jsonDecode(raw) as Map<String, dynamic>;
    } catch (_) {
      return {};
    }
  }

  _CachedName? _readEntry(SharedPreferences prefs, String uuid) {
    final entry = _readAll(prefs)[uuid];
    if (entry == null) return null;
    try {
      return _CachedName.fromJson(entry as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  Future<void> _writeEntry(
    SharedPreferences prefs,
    String uuid,
    _CachedName entry,
  ) async {
    // Immer neu laden bevor schreiben, damit parallele Writes sich
    // nicht gegenseitig überschreiben.
    final all = _readAll(prefs);
    all[uuid] = entry.toJson();
    await prefs.setString(_cacheKey, jsonEncode(all));
  }
}

// ── Internes Cache-Modell ─────────────────────────────────────

class _CachedName {
  final String name;
  final DateTime fetchedAt;

  _CachedName({required this.name, required this.fetchedAt});

  factory _CachedName.fromJson(Map<String, dynamic> json) => _CachedName(
        name:      json['name'] as String,
        fetchedAt: DateTime.parse(json['fetchedAt'] as String),
      );

  Map<String, dynamic> toJson() => {
        'name':      name,
        'fetchedAt': fetchedAt.toIso8601String(),
      };
}
