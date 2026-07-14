// ═══════════════════════════════════════════════════════════════
//  number_format_repository.dart – Einstellung für die Preis-Anzeige
//
//  ✅ HIER ÄNDERN: Persistenz-Key, Default-Modus
//  ❌ NICHT ÄNDERN: Provider-Name numberFormatProvider
//
//  ABLAUF:
//    1. App-Start: State ist sofort NumberFormatMode.standard
//       (build() muss synchron liefern, SharedPreferences ist async)
//    2. Im Hintergrund wird der gespeicherte Wert geladen – falls
//       "compact" gespeichert war, wechselt der State automatisch
//       (kein sichtbares Flackern, da der Default ohnehin meist passt)
//    3. setMode() ändert den State SOFORT (UI reagiert instant) und
//       schreibt den neuen Wert danach in SharedPreferences
//
//  VERWENDUNG:
//    final mode = ref.watch(numberFormatProvider);
//    AppFormat.currencyAuto(item.currentBid, mode: mode);
//
//    // Modus ändern (z.B. im Einstellungen-Screen):
//    ref.read(numberFormatProvider.notifier)
//        .setMode(NumberFormatMode.compact);
//
//  SETUP:
//    flutter pub add shared_preferences   (bereits vorhanden)
// ═══════════════════════════════════════════════════════════════

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/app_format.dart';

// ── Interner Persistenz-Key in SharedPreferences ──────────────
const _prefsKey = 'number_format_mode_v1';

final numberFormatProvider =
    NotifierProvider<NumberFormatNotifier, NumberFormatMode>(
  NumberFormatNotifier.new,
);

class NumberFormatNotifier extends Notifier<NumberFormatMode> {
  @override
  NumberFormatMode build() {
    // build() muss synchron sein → Default zurückgeben, danach
    // im Hintergrund den gespeicherten Wert nachladen (falls vorhanden).
    _loadSavedMode();
    return NumberFormatMode.standard;
  }

  Future<void> _loadSavedMode() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_prefsKey);
    if (saved == NumberFormatMode.compact.name) {
      state = NumberFormatMode.compact;
    }
  }

  /// Setzt den Anzeige-Modus (Standard/Kurzschreibweise) und
  /// speichert ihn dauerhaft für zukünftige App-Starts.
  Future<void> setMode(NumberFormatMode mode) async {
    state = mode; // Sofortiges UI-Update, noch bevor gespeichert wurde
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, mode.name);
  }
}
