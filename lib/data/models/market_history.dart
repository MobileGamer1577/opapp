// ═══════════════════════════════════════════════════════════════
//  market_history.dart – Datenmodell für den Markt-Preisverlauf
//
//  ✅ HIER ÄNDERN: Zeitfenster der Zeiträume in pointsFor(),
//                  Berechnung der Statistiken in fromPoints()
//  ❌ NICHT ÄNDERN: Klassenstruktur
//
//  API-FORMAT (GET /market/history/{material}):
//    { "HOURLY":  [ {...}, ... ],   ← ca. die letzten 14 Tage
//      "DAILY":   [ {...}, ... ],   ← ca. die letzten 6 Monate
//      "WEEKLY":  [ {...}, ... ],   ← wird aktuell nicht genutzt
//      "MONTHLY": [ {...}, ... ] }  ← seit Aug. 2023
//    Jeder Punkt:
//      { "avgPrice": 671.7, "minPrice": 601, "maxPrice": 699.4,
//        "items": 7010, "transactions": 170,
//        "timestamp": "2026-10-08T19:00:00" }
//
//  ⚠️ ZEITSTEMPEL: Kommen OHNE Zeitzone. Sie entsprechen der
//  Berliner Ortszeit (Tages-Buckets liegen z.B. bei 02:00 = Mitter-
//  nacht UTC im Sommer). Sie werden deshalb als lokale Zeit gelesen.
//
//  ZUORDNUNG ZEITRAUM → DATENQUELLE (siehe pointsFor):
//    24 h  → HOURLY  (letzte 24 Stunden)
//    7 T   → HOURLY  (letzte 7 Tage)
//    30 T  → DAILY   (letzte 30 Tage)
//    Max   → MONTHLY (alle Punkte)
//  Das Zeitfenster hängt am NEUESTEN Datenpunkt der jeweiligen Reihe,
//  nicht an der Handy-Uhrzeit – so bleibt der Graph auch bei einer
//  verspäteten API gefüllt.
//
//  STATISTIKEN (siehe MarketHistoryStats.fromPoints):
//    Ø Preis        = nach Stückzahl (items) gewichteter Mittelwert
//    Veränderung    = letzter gegen ersten avgPrice, in Prozent
//    Tief / Hoch    = kleinster minPrice / größter maxPrice
//    Gehandelt      = Summe items
//    Transaktionen  = Summe transactions
// ═══════════════════════════════════════════════════════════════

/// Zeitraum-Auswahl im Preisverlauf (genau 4 Buttons).
enum MarketHistoryRange {
  h24('24 h'),
  d7('7 T'),
  d30('30 T'),
  max('Max');

  const MarketHistoryRange(this.label);
  final String label;
}

/// Ein Datenpunkt (ein Stunden-/Tages-/Monats-Bucket).
class MarketHistoryPoint {
  final DateTime timestamp;
  final double avgPrice;
  final double minPrice;
  final double maxPrice;

  /// Gehandelte Stückzahl in diesem Bucket.
  final int items;
  final int transactions;

  const MarketHistoryPoint({
    required this.timestamp,
    required this.avgPrice,
    required this.minPrice,
    required this.maxPrice,
    required this.items,
    required this.transactions,
  });

  /// Gibt null zurück, wenn der Zeitstempel fehlt oder nicht lesbar ist
  /// (ein kaputter Punkt soll nicht den ganzen Graphen verhindern).
  static MarketHistoryPoint? tryFromJson(Map<String, dynamic> json) {
    final parsed = DateTime.tryParse(json['timestamp']?.toString() ?? '');
    if (parsed == null) return null;
    return MarketHistoryPoint(
      // Ohne Zeitzone → bereits lokal. Falls die API künftig "Z"
      // mitliefert, wird sauber in lokale Zeit umgerechnet.
      timestamp:    parsed.isUtc ? parsed.toLocal() : parsed,
      avgPrice:     (json['avgPrice']     as num?)?.toDouble() ?? 0.0,
      minPrice:     (json['minPrice']     as num?)?.toDouble() ?? 0.0,
      maxPrice:     (json['maxPrice']     as num?)?.toDouble() ?? 0.0,
      items:        (json['items']        as num?)?.toInt()    ?? 0,
      transactions: (json['transactions'] as num?)?.toInt()    ?? 0,
    );
  }
}

/// Alle für die App relevanten Zeitreihen eines Items.
class MarketHistory {
  final List<MarketHistoryPoint> hourly;
  final List<MarketHistoryPoint> daily;
  final List<MarketHistoryPoint> monthly;

  const MarketHistory({
    required this.hourly,
    required this.daily,
    required this.monthly,
  });

  const MarketHistory.empty()
      : hourly = const [],
        daily = const [],
        monthly = const [];

  factory MarketHistory.fromJson(dynamic data) {
    if (data is! Map) return const MarketHistory.empty();
    return MarketHistory(
      hourly:  _parseSeries(data['HOURLY']),
      daily:   _parseSeries(data['DAILY']),
      monthly: _parseSeries(data['MONTHLY']),
    );
  }

  /// Liest eine Reihe defensiv: Unbekanntes wird übersprungen, das
  /// Ergebnis ist immer aufsteigend nach Zeit sortiert.
  static List<MarketHistoryPoint> _parseSeries(dynamic raw) {
    if (raw is! List) return const [];
    final points = <MarketHistoryPoint>[];
    for (final entry in raw) {
      if (entry is! Map) continue;
      final point =
          MarketHistoryPoint.tryFromJson(Map<String, dynamic>.from(entry));
      if (point != null) points.add(point);
    }
    points.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    return points;
  }

  /// Datenpunkte für den gewählten Zeitraum (siehe Datei-Kommentar).
  List<MarketHistoryPoint> pointsFor(MarketHistoryRange range) {
    switch (range) {
      case MarketHistoryRange.h24:
        return _lastWindow(hourly, const Duration(hours: 24));
      case MarketHistoryRange.d7:
        return _lastWindow(hourly, const Duration(days: 7));
      case MarketHistoryRange.d30:
        return _lastWindow(daily, const Duration(days: 30));
      case MarketHistoryRange.max:
        return monthly;
    }
  }

  static List<MarketHistoryPoint> _lastWindow(
    List<MarketHistoryPoint> series,
    Duration window,
  ) {
    if (series.isEmpty) return const [];
    final cutoff = series.last.timestamp.subtract(window);
    return series.where((p) => p.timestamp.isAfter(cutoff)).toList();
  }
}

/// Die sechs Kennzahlen unter dem Graphen.
class MarketHistoryStats {
  final double avgPrice;
  final double changePercent;
  final double lowPrice;
  final double highPrice;
  final int itemsTraded;
  final int transactions;

  const MarketHistoryStats({
    required this.avgPrice,
    required this.changePercent,
    required this.lowPrice,
    required this.highPrice,
    required this.itemsTraded,
    required this.transactions,
  });

  /// null, wenn für den Zeitraum keine Punkte vorliegen.
  static MarketHistoryStats? fromPoints(List<MarketHistoryPoint> points) {
    if (points.isEmpty) return null;

    var weightedSum = 0.0;
    var plainSum = 0.0;
    var itemSum = 0;
    var txSum = 0;
    var low = points.first.minPrice;
    var high = points.first.maxPrice;

    for (final p in points) {
      weightedSum += p.avgPrice * p.items;
      plainSum += p.avgPrice;
      itemSum += p.items;
      txSum += p.transactions;
      if (p.minPrice < low) low = p.minPrice;
      if (p.maxPrice > high) high = p.maxPrice;
    }

    // Ohne gehandelte Stücke gibt es kein Gewicht → einfacher Mittelwert.
    final avg = itemSum > 0 ? weightedSum / itemSum : plainSum / points.length;

    final first = points.first.avgPrice;
    final last = points.last.avgPrice;
    final change = first > 0 ? (last - first) / first * 100 : 0.0;

    return MarketHistoryStats(
      avgPrice:      avg,
      changePercent: change,
      lowPrice:      low,
      highPrice:     high,
      itemsTraded:   itemSum,
      transactions:  txSum,
    );
  }
}
