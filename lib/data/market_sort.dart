// ═══════════════════════════════════════════════════════════════
//  market_sort.dart – Sortier-Optionen & Sortierlogik für den Markt
//
//  ✅ HIER ÄNDERN: Labels der Optionen, weitere Optionen ergänzen
//  ❌ NICHT ÄNDERN: Logik "Preis 0 → ans Ende" in _comparePrice
//
//  Wird von der Markt-Hauptseite ("Meistgehandelt" = Top 10 nach
//  mostOrders) und der Markt-Liste (Sortier-Sheet) gemeinsam genutzt.
//
//  SORTIERUNG "MEISTE AUFTRÄGE":
//    Gesamtzahl = BUY.activeOrders + SELL.activeOrders
//    (siehe MarketItem.totalOrders), absteigend.
//
//  PREIS-SORTIERUNGEN:
//    Items ohne Preis (API liefert 0.0, in der UI als "–" gezeigt)
//    stehen IMMER am Ende – sowohl auf- als auch absteigend, sonst
//    würden bei "Kaufpreis aufsteigend" lauter Items ohne Preis
//    ganz oben stehen.
//
//  Gleichstand → alphabetisch nach Name (stabile, vorhersehbare
//  Reihenfolge).
// ═══════════════════════════════════════════════════════════════

import 'models/market_item.dart';

enum MarketSort {
  mostOrders,
  nameAsc,
  buyAsc,
  buyDesc,
  sellAsc,
  sellDesc;

  String get label {
    switch (this) {
      case MarketSort.mostOrders:
        return 'Meiste Aufträge';
      case MarketSort.nameAsc:
        return 'Name (A–Z)';
      case MarketSort.buyAsc:
        return 'Kaufpreis aufsteigend';
      case MarketSort.buyDesc:
        return 'Kaufpreis absteigend';
      case MarketSort.sellAsc:
        return 'Verkaufspreis aufsteigend';
      case MarketSort.sellDesc:
        return 'Verkaufspreis absteigend';
    }
  }
}

/// Gibt eine NEUE, sortierte Liste zurück (die übergebene bleibt
/// unverändert).
List<MarketItem> sortMarketItems(List<MarketItem> items, MarketSort sort) {
  final sorted = [...items];

  int byName(MarketItem a, MarketItem b) =>
      a.name.toLowerCase().compareTo(b.name.toLowerCase());

  sorted.sort((a, b) {
    final int primary;
    switch (sort) {
      case MarketSort.mostOrders:
        primary = b.totalOrders.compareTo(a.totalOrders);
        break;
      case MarketSort.nameAsc:
        primary = byName(a, b);
        break;
      case MarketSort.buyAsc:
        primary = _comparePrice(a.buyPrice, b.buyPrice, ascending: true);
        break;
      case MarketSort.buyDesc:
        primary = _comparePrice(a.buyPrice, b.buyPrice, ascending: false);
        break;
      case MarketSort.sellAsc:
        primary = _comparePrice(a.sellPrice, b.sellPrice, ascending: true);
        break;
      case MarketSort.sellDesc:
        primary = _comparePrice(a.sellPrice, b.sellPrice, ascending: false);
        break;
    }
    return primary != 0 ? primary : byName(a, b);
  });

  return sorted;
}

/// Vergleicht zwei Preise; Preise <= 0 ("–") landen immer hinten.
int _comparePrice(double a, double b, {required bool ascending}) {
  final aHas = a > 0;
  final bHas = b > 0;
  if (!aHas && !bHas) return 0;
  if (!aHas) return 1;
  if (!bHas) return -1;
  return ascending ? a.compareTo(b) : b.compareTo(a);
}
