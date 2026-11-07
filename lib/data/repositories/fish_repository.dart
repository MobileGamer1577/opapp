// ═══════════════════════════════════════════════════════════════
//  fish_repository.dart – Fortschritt im Fischerei-Logbuch
//  (lokal gespeichert)
//
//  ✅ HIER ÄNDERN: Persistenz-Key (nur mit Migration!)
//  ❌ NICHT ÄNDERN: Provider-Name fishLogProvider
//
//  Gespeichert wird (SharedPreferences, nur auf dem Gerät):
//    - gefangene Fische (Liste der Fisch-Namen, siehe FishSpecies.name)
//
//  Anders als beim Mobdex gibt es hier KEINEN Cooldown und keinen
//  automatischen Reset – das Ingame-Logbuch (/logbuch) wird nicht
//  zurückgesetzt, der Fortschritt bleibt dauerhaft. Löschen geht nur
//  manuell über resetAll() (Button in der AppBar des Screens).
//
//  ABLAUF (gleiches Muster wie mobdex_repository.dart):
//    build() liefert synchron einen leeren State (loaded = false),
//    danach lädt _load() die gespeicherten Werte. Der Screen zeigt bis
//    dahin einen Ladekreis, damit nichts Ungeladenes überschrieben wird.
//
//  VERWENDUNG:
//    final state = ref.watch(fishLogProvider);
//    ref.read(fishLogProvider.notifier).toggle(fish.name);
//
//  SETUP:
//    flutter pub add shared_preferences   (bereits vorhanden)
//
//  ÄNDERUNGEN (Fischerei-Logbuch-Update):
//    - NEU: Datei.
// ═══════════════════════════════════════════════════════════════

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../fish_data.dart';

// ── Interner Persistenz-Key in SharedPreferences ──────────────
const _caughtKey = 'fish_caught_v1';

final fishLogProvider = NotifierProvider<FishLogNotifier, FishLogState>(
  FishLogNotifier.new,
);

class FishLogState {
  /// false, solange die gespeicherten Werte noch geladen werden.
  final bool loaded;

  /// Namen der gefangenen Fische (siehe FishSpecies.name).
  final Set<String> caught;

  const FishLogState({
    this.loaded = false,
    this.caught = const <String>{},
  });

  FishLogState copyWith({bool? loaded, Set<String>? caught}) {
    return FishLogState(
      loaded: loaded ?? this.loaded,
      caught: caught ?? this.caught,
    );
  }

  int get caughtCount => caught.length;
  int get totalCount => kFishSpecies.length;
  bool get isComplete => caught.length >= kFishSpecies.length;
}

class FishLogNotifier extends Notifier<FishLogState> {
  @override
  FishLogState build() {
    _load();
    return const FishLogState();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();

    // Defensiv: nur Namen übernehmen, die es in der Fisch-Liste noch
    // gibt (falls ein Fisch später umbenannt/entfernt wird).
    final validNames = kFishSpecies.map((f) => f.name).toSet();
    final caught = (prefs.getStringList(_caughtKey) ?? const <String>[])
        .where(validNames.contains)
        .toSet();

    state = FishLogState(loaded: true, caught: caught);
  }

  /// Hakt einen Fisch ab bzw. wieder ab.
  void toggle(String fishName) {
    if (!state.loaded) return;

    final caught = {...state.caught};
    if (!caught.remove(fishName)) caught.add(fishName);

    state = state.copyWith(caught: caught);
    _persist();
  }

  /// Löscht alle Haken.
  void resetAll() {
    if (!state.loaded) return;
    state = state.copyWith(caught: <String>{});
    _persist();
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_caughtKey, state.caught.toList());
  }
}
