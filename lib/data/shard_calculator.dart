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
//  MARKT-VERGLEICH – DREI FÄLLE:
//    1. Item hat ein Rezept (shardRecipes, z.B. Holzbündel) →
//       günstigste der Rohstoff-Optionen auf dem Markt suchen.
//    2. Item hat KEIN Rezept, aber eine eigene Material-ID
//       (z.B. Diamant Block) → direkt über die Material-ID im Markt
//       nachschlagen (kein Rezept nötig, gilt auch automatisch für
//       künftige RedCoins-Items, da diese normale, direkt kaufbare
//       Minecraft-Items sind).
//    3. Weder Rezept noch Markt-Treffer → Marktvergleich entfällt,
//       Rechner zeigt trotzdem Anzahl + Stacks/DKs (kein Fehler).
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

/// Günstigste Markt-Option für die Zielmenge (entweder eine
/// Rezept-Option oder das Item selbst bei einfachen Items).
class CheapestMarketOption {
  final String label; // z.B. "Eichenstamm" oder der Item-Name selbst
  final double unitPrice; // Kaufpreis pro Stück auf dem Markt
  final int amountNeeded; // Gesamtmenge dieses Rohstoffs
  final double totalCost;

  const CheapestMarketOption({
    required this.label,
    required this.unitPrice,
    required this.amountNeeded,
    required this.totalCost,
  });
}

/// Ergebnis einer Rechner-Anfrage.
class ShardCalculation {
  final int itemsNeeded;
  final StackBreakdown breakdown;
  final CheapestMarketOption? marketOption; // null = kein Marktvergleich möglich

  const ShardCalculation({
    required this.itemsNeeded,
    required this.breakdown,
    required this.marketOption,
  });
}

/// Berechnet, wie viele [item] für [targetAmount] Wertstoffhändler-
/// Währung benötigt werden, plus (falls möglich) den günstigsten
/// Markt-Weg dorthin.
ShardCalculation calculateShardNeed({
  required ShardItem item,
  required double targetAmount,
  required List<MarketItem> marketItems,
}) {
  final itemsNeeded = item.rate > 0 ? (targetAmount / item.rate).ceil() : 0;
  final breakdown = StackBreakdown.fromCount(itemsNeeded);

  final recipe = shardRecipes[item.displayName];
  CheapestMarketOption? marketOption;

  if (recipe != null) {
    // Sammel-Item: günstigste der Rohstoff-Optionen suchen (immer nur
    // EINE Sorte, keine Mischung – siehe Datei-Kommentar in shard_recipe.dart).
    for (final option in recipe.options) {
      final marketItem = _findMarketItem(marketItems, option.material);
      if (marketItem == null || !marketItem.hasBuyOrders) continue;

      final amountNeeded = itemsNeeded * recipe.amountPerUnit;
      final totalCost = marketItem.buyPrice * amountNeeded;

      if (marketOption == null || totalCost < marketOption.totalCost) {
        marketOption = CheapestMarketOption(
          label: option.displayName,
          unitPrice: marketItem.buyPrice,
          amountNeeded: amountNeeded,
          totalCost: totalCost,
        );
      }
    }
  } else if (item.material.isNotEmpty) {
    // Einfaches Item (z.B. Diamant Block, Netherite Barren, oder ein
    // künftiges RedCoins-Item): direkt über die eigene Material-ID
    // nachschlagen – kein Rezept nötig.
    final marketItem = _findMarketItem(marketItems, item.material);
    if (marketItem != null && marketItem.hasBuyOrders) {
      marketOption = CheapestMarketOption(
        label: item.displayName,
        unitPrice: marketItem.buyPrice,
        amountNeeded: itemsNeeded,
        totalCost: marketItem.buyPrice * itemsNeeded,
      );
    }
  }
  // Weder Rezept noch Markt-Treffer über material → marketOption bleibt
  // null, der Rechner zeigt dann nur Anzahl + Stacks/DKs (siehe UI).

  return ShardCalculation(
    itemsNeeded: itemsNeeded,
    breakdown: breakdown,
    marketOption: marketOption,
  );
}

MarketItem? _findMarketItem(List<MarketItem> items, String material) {
  for (final m in items) {
    if (m.material == material) return m;
  }
  return null;
}
