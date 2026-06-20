// ═══════════════════════════════════════════════════════════════
//  app_format.dart – Zentrale Formatierungshelfer
//
//  ✅ HIER ÄNDERN: Formatierung anpassen (z.B. Tausenderpunkte)
//  ❌ NICHT ÄNDERN: Klassenname AppFormat
//
//  VERWENDUNG:
//    AppFormat.currency(1500000)          → "1500000 $"
//    AppFormat.currency(14.5, decimals:2) → "14.50 $"
//    AppFormat.dateTime(dt)               → "18.06.2026, 08:08 Uhr"
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

  /// Formatiert Datum + Uhrzeit im deutschen Format,
  /// z.B. "18.06.2026, 08:08 Uhr".
  ///
  /// WICHTIG: Vorher .toLocal() aufrufen, falls das DateTime (wie
  /// die Auktions-Timestamps) als UTC vom Server kommt – sonst wird
  /// die UTC-Zeit statt der lokalen Zeit angezeigt.
  static String dateTime(DateTime dt) {
    final d   = dt.day.toString().padLeft(2, '0');
    final m   = dt.month.toString().padLeft(2, '0');
    final y   = dt.year.toString();
    final h   = dt.hour.toString().padLeft(2, '0');
    final min = dt.minute.toString().padLeft(2, '0');
    return '$d.$m.$y, $h:$min Uhr';
  }
}
