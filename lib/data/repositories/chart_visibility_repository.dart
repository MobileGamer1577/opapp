// ═══════════════════════════════════════════════════════════════
//  chart_visibility_repository.dart – Einstellung: Kursverlauf-Graph
//  im OPShards-Detail-Sheet ein-/ausblenden
//
//  ✅ HIER ÄNDERN: Persistenz-Key, Default-Wert
//  ❌ NICHT ÄNDERN: Provider-Name chartVisibilityProvider
//
//  ABLAUF (gleiches Muster wie number_format_repository.dart):
//    1. App-Start: State ist sofort `true` (Graph an) – build() muss
//       synchron liefern, SharedPreferences ist async.
//    2. Im Hintergrund wird der gespeicherte Wert geladen – falls
//       zuvor deaktiviert, wechselt der State automatisch (kein
//       sichtbares Flackern, da der Default ohnehin meist passt).
//    3. setEnabled() ändert den State SOFORT (UI reagiert instant)
//       und schreibt den neuen Wert danach in SharedPreferences.
//
//  VERWENDUNG:
//    final chartEnabled = ref.watch(chartVisibilityProvider);
//    if (chartEnabled) ... // Kursverlauf-Sektion anzeigen
//
//    // Umschalten (z.B. im Erscheinungsbild-Screen):
//    ref.read(chartVisibilityProvider.notifier).setEnabled(false);
//
//  SETUP:
//    flutter pub add shared_preferences   (bereits vorhanden)
// ═══════════════════════════════════════════════════════════════

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ── Interner Persistenz-Key in SharedPreferences ──────────────
const _prefsKey = 'shard_chart_visible_v1';

// ── Standard: Graph ist an, solange nichts anderes gespeichert ist ──
const _defaultEnabled = true;

final chartVisibilityProvider =
    NotifierProvider<ChartVisibilityNotifier, bool>(
  ChartVisibilityNotifier.new,
);

class ChartVisibilityNotifier extends Notifier<bool> {
  @override
  bool build() {
    // build() muss synchron sein → Default zurückgeben, danach
    // im Hintergrund den gespeicherten Wert nachladen (falls vorhanden).
    _loadSavedValue();
    return _defaultEnabled;
  }

  Future<void> _loadSavedValue() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getBool(_prefsKey);
    if (saved != null) {
      state = saved;
    }
  }

  /// Schaltet den Kursverlauf-Graph an/aus und speichert die Wahl
  /// dauerhaft für zukünftige App-Starts.
  Future<void> setEnabled(bool enabled) async {
    state = enabled; // Sofortiges UI-Update, noch bevor gespeichert wurde
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefsKey, enabled);
  }
}
