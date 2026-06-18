// ═══════════════════════════════════════════════════════════════
//  app_format.dart – Zentrale Formatierungshelfer
//
//  ✅ HIER ÄNDERN: Formatierung anpassen (z.B. Tausenderpunkte)
//  ❌ NICHT ÄNDERN: Klassenname AppFormat
//
//  VERWENDUNG:
//    AppFormat.currency(1500000)          → "1500000 $"
//    AppFormat.currency(14.5, decimals:2) → "14.50 $"
// ═══════════════════════════════════════════════════════════════

abstract class AppFormat {
  /// Formatiert einen Betrag als Spielwährung.
  ///
  /// [decimals] steuert Nachkommastellen (Standard: 0 für Auktionen,
  /// 2 für Marktpreise).
  ///
  /// Für Tausenderpunkte (z.B. "1.500.000 $") hier anpassen –
  /// alle Screens übernehmen die Änderung automatisch.
  static String currency(double amount, {int decimals = 0}) {
    return '${amount.toStringAsFixed(decimals)} \$';
  }
}
