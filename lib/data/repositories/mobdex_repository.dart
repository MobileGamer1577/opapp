// ═══════════════════════════════════════════════════════════════
//  mobdex_repository.dart – Fortschritt im Mobdex (lokal gespeichert)
//
//  ✅ HIER ÄNDERN: Persistenz-Keys (nur mit Migration!)
//  ❌ NICHT ÄNDERN: Provider-Name mobdexProvider
//
//  Gespeichert wird (SharedPreferences, nur auf dem Gerät):
//    - gefangene Mobs (Liste der Mob-Namen)
//    - Abschlusszeitpunkt (wann der letzte Mob abgehakt wurde)
//
//  COOLDOWN-LOGIK (Entscheidung Mobdex-Update):
//    1. Sobald der LETZTE Mob abgehakt wird, startet automatisch der
//       Cooldown (kMobdexCooldown = 21 Tage, siehe mobdex_data.dart).
//    2. Während des Cooldowns sind die Haken gesperrt (toggle() tut
//       nichts) – sonst würde ein versehentliches Abwählen den
//       Cooldown löschen und ein erneutes Anhaken ihn neu starten.
//       Korrekturen sind über resetAll() möglich.
//    3. Nach Ablauf werden ALLE Haken automatisch zurückgesetzt.
//       Das passiert beim Laden, beim Abhaken und über checkExpiry()
//       (Minuten-Timer im Screen). Danach steht resetNotice = true,
//       bis der Nutzer es wegklickt.
//
//  ÄNDERUNGEN (Mobdex-Überarbeitung):
//    - XP-Meilenstein komplett entfernt (State-Feld, setHunterXp und
//      Persistenz). Ein alter gespeicherter XP-Wert wird beim Laden
//      einmalig gelöscht.
//
//  ABLAUF (gleiches Muster wie number_format_repository.dart):
//    build() liefert synchron einen leeren State (loaded = false),
//    danach lädt _load() die gespeicherten Werte. Der Screen zeigt bis
//    dahin einen Ladekreis, damit nichts Ungeladenes überschrieben wird.
//
//  VERWENDUNG:
//    final state = ref.watch(mobdexProvider);
//    ref.read(mobdexProvider.notifier).toggle(mob.name);
//
//  SETUP:
//    flutter pub add shared_preferences   (bereits vorhanden)
// ═══════════════════════════════════════════════════════════════

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../mobdex_data.dart';

// ── Interne Persistenz-Keys in SharedPreferences ──────────────
const _caughtKey = 'mobdex_caught_v1';
const _completedKey = 'mobdex_completed_at_v1';
// Alter XP-Key (XP-Feld wurde entfernt) – wird beim Laden einmalig
// aufgeräumt, damit keine Altdaten auf dem Gerät liegen bleiben.
const _legacyXpKey = 'mobdex_hunter_xp_v1';

final mobdexProvider = NotifierProvider<MobdexNotifier, MobdexState>(
  MobdexNotifier.new,
);

class MobdexState {
  /// false, solange die gespeicherten Werte noch geladen werden.
  final bool loaded;

  /// Namen der gefangenen Mobs (siehe MobdexMob.name).
  final Set<String> caught;

  /// Zeitpunkt, zu dem der letzte Mob abgehakt wurde (Cooldown-Start).
  /// null = Mobdex ist (noch) nicht vollständig.
  final DateTime? completedAt;

  /// true, wenn der Mobdex nach Ablauf des Cooldowns gerade automatisch
  /// zurückgesetzt wurde (einmaliger Hinweis, wird nicht gespeichert).
  final bool resetNotice;

  const MobdexState({
    this.loaded = false,
    this.caught = const <String>{},
    this.completedAt,
    this.resetNotice = false,
  });

  MobdexState copyWith({
    bool? loaded,
    Set<String>? caught,
    DateTime? completedAt,
    bool clearCompletedAt = false,
    bool? resetNotice,
  }) {
    return MobdexState(
      loaded: loaded ?? this.loaded,
      caught: caught ?? this.caught,
      completedAt: clearCompletedAt ? null : (completedAt ?? this.completedAt),
      resetNotice: resetNotice ?? this.resetNotice,
    );
  }

  int get caughtCount => caught.length;
  int get totalCount => kMobdexMobs.length;
  bool get isComplete => caught.length >= kMobdexMobs.length;

  /// Ende des Cooldowns, null wenn keiner läuft/gelaufen ist.
  DateTime? get cooldownEndsAt => completedAt?.add(kMobdexCooldown);

  /// true, solange der Cooldown noch nicht abgelaufen ist.
  bool get cooldownActive {
    final ends = cooldownEndsAt;
    return ends != null && DateTime.now().isBefore(ends);
  }
}

class MobdexNotifier extends Notifier<MobdexState> {
  @override
  MobdexState build() {
    _load();
    return const MobdexState();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_legacyXpKey);

    // Defensiv: nur Namen übernehmen, die es in der Mob-Liste noch gibt
    // (falls ein Mob später umbenannt/entfernt wird).
    final validNames = kMobdexMobs.map((m) => m.name).toSet();
    final caught = (prefs.getStringList(_caughtKey) ?? const <String>[])
        .where(validNames.contains)
        .toSet();

    final completedMs = prefs.getInt(_completedKey);
    DateTime? completedAt = completedMs == null
        ? null
        : DateTime.fromMillisecondsSinceEpoch(completedMs);
    // Kamen später neue Mobs dazu, ist der Mobdex nicht mehr vollständig.
    if (caught.length < kMobdexMobs.length) completedAt = null;

    final loaded = MobdexState(
      loaded: true,
      caught: caught,
      completedAt: completedAt,
    );

    final next = _applyExpiry(loaded);
    state = next;
    if (!identical(next, loaded)) _persist();
  }

  /// Setzt den Mobdex zurück, falls der Cooldown abgelaufen ist.
  /// Gibt denselben State zurück, wenn nichts zu tun ist.
  MobdexState _applyExpiry(MobdexState s) {
    final ends = s.cooldownEndsAt;
    if (ends == null || DateTime.now().isBefore(ends)) return s;
    return s.copyWith(
      caught: <String>{},
      clearCompletedAt: true,
      resetNotice: true,
    );
  }

  /// Prüft, ob der Cooldown abgelaufen ist, und setzt dann zurück.
  /// true, wenn gerade zurückgesetzt wurde. Wird minütlich vom Screen
  /// aufgerufen (die App kann ja tagelang im Hintergrund offen sein).
  bool checkExpiry() {
    if (!state.loaded) return false;
    final next = _applyExpiry(state);
    if (identical(next, state)) return false;
    state = next;
    _persist();
    return true;
  }

  /// Hakt einen Mob ab bzw. wieder ab. Während des Cooldowns gesperrt.
  void toggle(String mobName) {
    if (!state.loaded) return;
    checkExpiry();
    if (state.cooldownActive) return;

    final caught = {...state.caught};
    if (!caught.remove(mobName)) caught.add(mobName);

    final complete = caught.length >= kMobdexMobs.length;
    state = state.copyWith(
      caught: caught,
      // Letzter Mob abgehakt → Cooldown startet jetzt.
      completedAt: complete ? DateTime.now() : null,
      clearCompletedAt: !complete,
      resetNotice: false,
    );
    _persist();
  }

  /// Löscht alle Haken UND den Cooldown.
  void resetAll() {
    if (!state.loaded) return;
    state = state.copyWith(
      caught: <String>{},
      clearCompletedAt: true,
      resetNotice: false,
    );
    _persist();
  }

  /// Blendet den Hinweis "Cooldown abgelaufen" aus.
  void dismissResetNotice() {
    if (!state.resetNotice) return;
    state = state.copyWith(resetNotice: false);
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_caughtKey, state.caught.toList());
    final completedAt = state.completedAt;
    if (completedAt == null) {
      await prefs.remove(_completedKey);
    } else {
      await prefs.setInt(_completedKey, completedAt.millisecondsSinceEpoch);
    }
  }
}
