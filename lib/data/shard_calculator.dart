// ═══════════════════════════════════════════════════════════════
//  shard_calculator.dart – Rechenlogik für den Wertstoff-Rechner
//
//  ✅ HIER ÄNDERN: Rundungsverhalten, Stack-/DK-Größen
//  ❌ NICHT ÄNDERN: Grundformel (itemsNeeded, Markt-Vergleich)
//
//  Reine Berechnungsfunktionen, keine Provider – wird direkt aus
//  shard_calculator_screen.dart mit den bereits geladenen Daten aus
//  shardRateProvider + marketProvider aufgerufen.
//
//  ÄNDERUNGEN (Rechner-Umbau):
//    - NEU: calculateShardOptions() ersetzt calculateShardNeed().
//      Statt EINES Items wird jetzt für die gewählte Währung
//      ("opshards" / "redcoins" / künftige) JEDES Item aus
//      /merchant/rates durchgerechnet, das aktuell im Markt kaufbar
//      ist. Das Ergebnis ist eine nach Gesamtkosten sortierte Liste
//      (günstigste Option zuerst).
//    - DYNAMISCH: Es gibt keinen hartkodierten Item-Katalog. Ein Item
//      erscheint nur, wenn
//        a) sein "target" zur gewählten Währung passt UND
//        b) es ein Rezept hat (shard_recipe.dart) und mindestens ein
//           Rohstoff davon im Markt kaufbar ist, ODER es eine eigene
//           Material-ID hat und diese im Markt kaufbar ist.
//      Neue Redcoin-Items (normale Minecraft-Items) tauchen so ohne
//      Code-Änderung automatisch auf, sobald sie in /merchant/rates
//      UND im Markt vorhanden sind. "Kaufbar" = Kaufpreis > 0 und
//      mindestens ein aktives Angebot (MarketItem.hasBuyOrders).
//    - 🐛 Material-Abgleich ist jetzt unabhängig von Groß-/Klein-
//      schreibung und einem "minecraft:"-Prefix. /merchant/rates
//      liefert z.B. "diamond_block", der Markt "DIAMOND_BLOCK" – der
//      bisherige exakte Vergleich konnte solche Items nie finden.
//    - NEU: ShardOption enthält Stückzahl, Stacks, erhaltene Menge,
//      Übertrag (erhalten − Ziel) und Gesamtkosten. Die Differenz zur
//      günstigsten Option wird erst im Screen gebildet.
//    - Entfernt: ShardCalculation, CheapestMarketOption,
//      calculateShardNeed (nur vom Rechner-Screen verwendet).
//    - NEU: availableCurrencies() – Liste der Umschalter-Währungen
//      (Shards + Redcoins immer, weitere automatisch aus der API).
// ═══════════════════════════════════════════════════════════════

import 'models/market_item.dart';
import 'models/shard_rate.dart';
import 'shard_recipe.dart';

const int stackSize = 64;
const int doubleChestSize = 3456; // 54 Stacks × 64

/// Ergebnis der Stack-/Doppelkisten-Umrechnung.
class StackBreakdown {
  final int doubleChests;
  final int stacks;
  final int loose;

  const StackBreakdown({
    required this.doubleChests,
    required this.stacks,
    required this.loose,
  });

  factory StackBreakdown.fromCount(int count) {
    final dc = count ~/ doubleChestSize;
    final remainderAfterDc = count % doubleChestSize;
    final stacks = remainderAfterDc ~/ stackSize;
    final loose = remainderAfterDc % stackSize;
    return StackBreakdown(doubleChests: dc, stacks: stacks, loose: loose);
  }

  /// z.B. "2 Doppelkisten, 14 Stacks, 23 Stück"
  String get display {
    final parts = <String>[];
    if (doubleChests > 0) {
      parts.add('$doubleChests Doppelkiste${doubleChests == 1 ? '' : 'n'}');
    }
    if (stacks > 0) {
      parts.add('$stacks Stack${stacks == 1 ? '' : 's'}');
    }
    if (loose > 0 || parts.isEmpty) {
      parts.add('$loose Stück');
    }
    return parts.join(', ');
  }
}

/// Eine berechnete Option (= eine Ergebnis-Karte im Rechner).
class ShardOption {
  /// Das Wertstoffhändler-Item, das abgegeben wird.
  final ShardItem item;

  /// Benötigte Stückzahl dieses Items (aufgerundet, mindestens 1).
  final int itemsNeeded;
  final StackBreakdown breakdown;

  /// Erhaltene Menge (itemsNeeded × Kurs), auf 2 Nachkommastellen.
  final double received;

  /// Übertrag = erhalten − Zielmenge (immer ≥ 0), auf 2 Nachkommastellen.
  final double carry;

  /// Marktkosten für EIN Item (bei Rezepten: Rohstoffpreis × Menge je Einheit).
  final double unitCost;

  /// Marktkosten für alle benötigten Items.
  final double totalCost;

  /// Nur bei Rezept-Items: günstigster Rohstoff (z.B. "Fichtenstamm"),
  /// Menge je Einheit, Gesamtmenge und deren Stack-Aufteilung.
  final String? rawLabel;
  final int? rawPerUnit;
  final int? rawTotal;
  final StackBreakdown? rawBreakdown;

  const ShardOption({
    required this.item,
    required this.itemsNeeded,
    required this.breakdown,
    required this.received,
    required this.carry,
    required this.unitCost,
    required this.totalCost,
    this.rawLabel,
    this.rawPerUnit,
    this.rawTotal,
    this.rawBreakdown,
  });

  bool get usesRecipe => rawLabel != null;
}

/// Währungen für den Umschalter: Shards und Redcoins sind IMMER dabei
/// (auch wenn die API gerade keine Items dafür liefert), weitere
/// "target"-Werte aus /merchant/rates kommen automatisch dazu.
List<String> availableCurrencies(List<ShardItem> items) {
  final result = <String>['opshards', 'redcoins'];
  final extra = items
      .map((i) => i.target)
      .where((t) => t.isNotEmpty && !result.contains(t))
      .toSet()
      .toList()
    ..sort();
  return [...result, ...extra];
}

/// "minecraft:Diamond_Block" → "diamond_block"
String _normalizeMaterial(String material) {
  var s = material.trim().toLowerCase();
  if (s.startsWith('minecraft:')) s = s.substring('minecraft:'.length);
  return s;
}

double _round2(double v) => (v * 100).round() / 100;

/// Berechnet für [currency] (z.B. "opshards") alle Optionen, mit denen
/// [targetAmount] erreicht werden kann. Sortiert nach Gesamtkosten
/// aufsteigend (günstigste zuerst), bei Gleichstand nach Name.
List<ShardOption> calculateShardOptions({
  required List<ShardItem> items,
  required String currency,
  required double targetAmount,
  required List<MarketItem> marketItems,
}) {
  if (targetAmount <= 0) return const [];

  // Markt einmal in eine Lookup-Map umbauen (statt je Item die ganze
  // Liste zu durchsuchen).
  final market = <String, MarketItem>{};
  for (final m in marketItems) {
    market.putIfAbsent(_normalizeMaterial(m.material), () => m);
  }

  /// Gibt das Markt-Item nur zurück, wenn es aktuell wirklich kaufbar ist.
  MarketItem? buyable(String material) {
    final m = market[_normalizeMaterial(material)];
    if (m == null || !m.hasBuyOrders || !m.hasBuyPrice) return null;
    return m;
  }

  final options = <ShardOption>[];

  for (final item in items) {
    if (item.target != currency || item.rate <= 0) continue;

    // Aufrunden; kleine Gleitkomma-Ungenauigkeit abziehen, damit z.B.
    // 100 / 12,5 nicht fälschlich auf 9 statt 8 aufgerundet wird.
    var itemsNeeded = (targetAmount / item.rate - 1e-9).ceil();
    if (itemsNeeded < 1) itemsNeeded = 1;

    final received = _round2(itemsNeeded * item.rate);
    final carry = _round2(received - targetAmount);
    final breakdown = StackBreakdown.fromCount(itemsNeeded);

    final recipe = shardRecipes[item.displayName];

    if (recipe != null) {
      // Sammel-Item: günstigste Rohstoff-Sorte (immer nur EINE Sorte,
      // keine Mischung – siehe shard_recipe.dart).
      RecipeOption? bestOption;
      MarketItem? bestMarket;
      for (final option in recipe.options) {
        final m = buyable(option.material);
        if (m == null) continue;
        if (bestMarket == null || m.buyPrice < bestMarket.buyPrice) {
          bestOption = option;
          bestMarket = m;
        }
      }
      if (bestOption == null || bestMarket == null) continue;

      final rawTotal = itemsNeeded * recipe.amountPerUnit;
      options.add(ShardOption(
        item: item,
        itemsNeeded: itemsNeeded,
        breakdown: breakdown,
        received: received,
        carry: carry,
        unitCost: bestMarket.buyPrice * recipe.amountPerUnit,
        totalCost: bestMarket.buyPrice * rawTotal,
        rawLabel: bestOption.displayName,
        rawPerUnit: recipe.amountPerUnit,
        rawTotal: rawTotal,
        rawBreakdown: StackBreakdown.fromCount(rawTotal),
      ));
    } else if (item.material.isNotEmpty) {
      // Einfaches Item (Diamant Block, Netherite Barren, künftige
      // Redcoin-Items …): direkt über die eigene Material-ID.
      final m = buyable(item.material);
      if (m == null) continue;

      options.add(ShardOption(
        item: item,
        itemsNeeded: itemsNeeded,
        breakdown: breakdown,
        received: received,
        carry: carry,
        unitCost: m.buyPrice,
        totalCost: m.buyPrice * itemsNeeded,
      ));
    }
    // Weder Rezept noch Material (z.B. unbekanntes Custom-Item) →
    // kein Marktpreis möglich, Item erscheint nicht im Rechner.
  }

  options.sort((a, b) {
    final byCost = a.totalCost.compareTo(b.totalCost);
    return byCost != 0
        ? byCost
        : a.item.displayName.compareTo(b.item.displayName);
  });
  return options;
}
