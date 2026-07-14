// ═══════════════════════════════════════════════════════════════
//  app_format.dart – Zentrale Formatierungshelfer
//
//  ✅ HIER ÄNDERN: Formatierung anpassen (Tausendertrenner, Komma,
//                  Kurzschreibweise-Suffixe wie "Mio."/"k")
//  ❌ NICHT ÄNDERN: Klassenname AppFormat / NumberFormatMode
//
//  GRUNDREGEL:
//  Niemals Preise direkt in Screens formatieren.
//  Immer AppFormat.xyz verwenden – so reicht eine Änderung hier.
//
//  ÄNDERUNGEN (Preisformat-Update):
//    - NEU: Tausenderpunkte in der Standard-Anzeige
//      (40.000.000 $ statt 40000000 $)
//    - NEU: Komma als Dezimaltrenner bei Centbeträgen (10.982,72 $)
//    - NEU: NumberFormatMode (standard / compact) – die aktuelle
//      Nutzer-Auswahl kommt aus numberFormatProvider, siehe
//      data/repositories/number_format_repository.dart
//    - NEU: compactCurrency() – kürzt große Beträge ab:
//        1.000    – 999.999   → z.B. "10,9k $"
//        ab 1.000.000         → z.B. "5,2 Mio. $"
//    - NEU: currencyAuto() – wählt automatisch zwischen currency()
//      und compactCurrency(), je nach übergebenem NumberFormatMode
//
//  VERWENDUNG:
//    AppFormat.currency(1500000)          → "1.500.000 $"
//    AppFormat.currency(14.5, decimals:2) → "14,50 $"
//    AppFormat.compactCurrency(10900)     → "10,9k $"
//    AppFormat.compactCurrency(40000000)  → "40 Mio. $"
//    AppFormat.currencyAuto(betrag, mode: mode)
//    AppFormat.dateTime(dt)               → "18.06.2026, 08:08 Uhr"
// ═══════════════════════════════════════════════════════════════

/// Steuert, ob Preise ausgeschrieben (Standard) oder abgekürzt
/// (Kurzschreibweise, z.B. "10,9k $") angezeigt werden.
/// Wird dauerhaft über numberFormatProvider gespeichert
/// (siehe data/repositories/number_format_repository.dart).
enum NumberFormatMode { standard, compact }

abstract class AppFormat {
  /// Formatiert einen Betrag als Spielwährung im Standard-Format:
  /// Punkte als Tausendertrenner, Komma als Dezimaltrenner.
  ///
  /// [decimals] steuert Nachkommastellen (Standard: 0 für Auktionen,
  /// 2 für Marktpreise).
  static String currency(double amount, {int decimals = 0}) {
    final isNegative = amount < 0;
    final fixed       = amount.abs().toStringAsFixed(decimals);
    final dotIndex    = fixed.indexOf('.');

    final intPart = dotIndex == -1 ? fixed : fixed.substring(0, dotIndex);
    final decPart = dotIndex == -1 ? ''    : fixed.substring(dotIndex + 1);

    final grouped = _groupThousands(intPart);
    final result  = decPart.isEmpty ? grouped : '$grouped,$decPart';
    return '${isNegative ? '-' : ''}$result \$';
  }

  /// Kurzschreibweise für große Beträge:
  ///   < 1.000          → normale currency()-Darstellung (kein Sinn
  ///                       in einer Kürzung bei kleinen Zahlen)
  ///   1.000 – 999.999  → z.B. "10,9k $"
  ///   ab 1.000.000     → z.B. "5,2 Mio. $"
  ///
  /// ✅ HIER ÄNDERN: Suffix "Mio." z.B. zu "m" ändern, falls gewünscht,
  /// oder eine weitere Stufe für Milliarden ("Mrd.") ergänzen.
  static String compactCurrency(double amount) {
    final isNegative = amount < 0;
    final abs        = amount.abs();

    final String result;
    if (abs >= 1000000) {
      result = '${_trimDecimal(abs / 1000000)} Mio.';
    } else if (abs >= 1000) {
      result = '${_trimDecimal(abs / 1000)}k';
    } else {
      return currency(amount);
    }
    return '${isNegative ? '-' : ''}$result \$';
  }

  /// Wählt automatisch zwischen currency() und compactCurrency(),
  /// je nach aktuell gewählter Anzeige-Einstellung (siehe
  /// numberFormatProvider). Screens müssen so nicht selbst
  /// zwischen den beiden Modi unterscheiden.
  static String currencyAuto(
    double amount, {
    required NumberFormatMode mode,
    int decimals = 0,
  }) {
    return mode == NumberFormatMode.compact
        ? compactCurrency(amount)
        : currency(amount, decimals: decimals);
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

  // ── Interne Hilfsmethoden ─────────────────────────────────

  /// Fügt Tausenderpunkte in einen reinen Ziffern-String ein,
  /// z.B. "40000000" → "40.000.000"
  static String _groupThousands(String digits) {
    final buffer = StringBuffer();
    final len = digits.length;
    for (int i = 0; i < len; i++) {
      if (i > 0 && (len - i) % 3 == 0) buffer.write('.');
      buffer.write(digits[i]);
    }
    return buffer.toString();
  }

  /// Eine Nachkommastelle mit Komma statt Punkt; überflüssiges
  /// ",0" wird entfernt. Beispiele: 10.9 → "10,9", 40.0 → "40"
  static String _trimDecimal(double v) {
    var s = v.toStringAsFixed(1);
    if (s.endsWith('.0')) s = s.substring(0, s.length - 2);
    return s.replaceAll('.', ',');
  }
}
