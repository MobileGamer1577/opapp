// ═══════════════════════════════════════════════════════════════
//  currency_color_repository.dart – Einstellung: Währungsfarben im
//  Wertstoffhändler (OPShards/RedCoins) ein-/ausblenden
//
//  ✅ HIER ÄNDERN: Persistenz-Key, Default-Wert
//  ❌ NICHT ÄNDERN: Provider-Name currencyColorProvider
//
//  ABLAUF (gleiches Muster wie chart_visibility_repository.dart):
//    1. App-Start: State ist sofort `true` (Farben an) – build() muss
//       synchron liefern, SharedPreferences ist async.
//    2. Im Hintergrund wird der gespeicherte Wert geladen – falls
//       zuvor deaktiviert, wechselt der State automatisch (kein
//       sichtbares Flackern, da der Default ohnehin meist passt).
//    3. setEnabled() ändert den State SOFORT (UI reagiert instant)
//       und schreibt den neuen Wert danach in SharedPreferences.
//
//  Betrifft: Kachel-Liste + Detail-Sheet (inkl. Kursverlauf-Graph)
//  im Wertstoffhändler-Screen UND das Live-Kurs-Banner auf dem
//  Dashboard (siehe shards_screen.dart / dashboard_screen.dart).
//  Ausgeschaltet → überall der bisherige einheitliche Lila-Akzent
//  (AppColors.accent), keine Farbtrennung nach Währung.
//
//  VERWENDUNG:
//    final colorsEnabled = ref.watch(currencyColorProvider);
//    final accent = colorsEnabled ? item.currencyColor : AppColors.accent;
//
//    // Umschalten (z.B. im Erscheinungsbild-Screen):
//    ref.read(currencyColorProvider.notifier).setEnabled(false);
//
//  SETUP:
//    flutter pub add shared_preferences   (bereits vorhanden)
// ═══════════════════════════════════════════════════════════════

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ── Interner Persistenz-Key in SharedPreferences ──────────────
const _prefsKey = 'currency_color_coding_v1';

// ── Standard: Farbtrennung ist an, solange nichts anderes gespeichert ist ──
const _defaultEnabled = true;

final currencyColorProvider = NotifierProvider<CurrencyColorNotifier, bool>(
  CurrencyColorNotifier.new,
);

class CurrencyColorNotifier extends Notifier<bool> {
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

  /// Schaltet die Währungsfarben an/aus und speichert die Wahl
  /// dauerhaft für zukünftige App-Starts.
  Future<void> setEnabled(bool enabled) async {
    state = enabled; // Sofortiges UI-Update, noch bevor gespeichert wurde
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefsKey, enabled);
  }
}
