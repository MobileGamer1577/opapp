// ═══════════════════════════════════════════════════════════════
//  shard_calculator_screen.dart – Wertstoff-Rechner
//
//  ✅ HIER ÄNDERN: Kartendesign
//  ❌ NICHT ÄNDERN: shardRateProvider/marketProvider-Aufrufe,
//                   calculateShardNeed()-Aufruf-Logik
//
//  ÄNDERUNGEN (Server-Status-Update / Wertstoff-Rechner):
//    - NEU: erreichbar über den Rechner-Button in der AppBar des
//      Wertstoffhändler-Screens UND als erste Karte im "Tools &
//      Hilfe"-Screen.
//    - Item-Auswahl ist dynamisch (alle aktuell live verfügbaren
//      Einträge aus /merchant/rates, inkl. künftiger RedCoins-Items –
//      kein hartkodierter Item-Katalog).
//    - Markt-Vergleich nutzt shard_calculator.dart: für die drei
//      Sammel-Items (Gräbergemisch/Holzbündel/Steinplatten) wird die
//      günstigste Rohstoff-Option ermittelt (siehe shard_recipe.dart),
//      für einfache Items (z.B. Diamant Block) direkt der Marktpreis
//      über die Material-ID. Ist beides nicht möglich, entfällt der
//      Marktvergleich – kein Fehler, nur Anzahl + Stacks/DKs.
// ═══════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/app_colors.dart';
import '../core/app_format.dart';
import '../data/repositories/shard_repository.dart';
import '../data/repositories/market_repository.dart';
import '../data/models/shard_rate.dart';
import '../data/models/market_item.dart';
import '../data/shard_calculator.dart';
import '../widgets/app_background.dart';

class ShardCalculatorScreen extends ConsumerStatefulWidget {
  const ShardCalculatorScreen({super.key});

  @override
  ConsumerState<ShardCalculatorScreen> createState() =>
      _ShardCalculatorScreenState();
}

class _ShardCalculatorScreenState extends ConsumerState<ShardCalculatorScreen> {
  final _amountCtrl = TextEditingController();
  ShardItem? _selected;

  @override
  void dispose() {
    _amountCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final shardAsync = ref.watch(shardRateProvider);
    final marketAsync = ref.watch(marketProvider);

    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(title: const Text('Wertstoff-Rechner')),
        body: shardAsync.when(
          data: (rates) {
            if (rates.items.isEmpty) {
              return const Center(child: Text('Keine Wechselkurse verfügbar'));
            }

            // Ausgewähltes Item beim ersten Build setzen bzw. auf das
            // erste zurückfallen, falls es (z.B. nach einem Reload)
            // nicht mehr in der aktuellen Liste ist.
            final stillValid =
                _selected != null && rates.items.any((i) => i.displayName == _selected!.displayName);
            if (!stillValid) _selected = rates.items.first;
            final selected = _selected!;

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text('Item wählen', style: theme.textTheme.titleMedium),
                const SizedBox(height: 10),
                _ItemSelector(
                  items: rates.items,
                  selected: selected,
                  onSelect: (item) => setState(() => _selected = item),
                ),
                const SizedBox(height: 20),
                Text(
                  'Zielmenge (${selected.currencyLabel})',
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _amountCtrl,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: 'z.B. 1000',
                    prefixIcon: Icon(
                      shardIconFor(selected.displayName, target: selected.target),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                _buildResult(theme, selected, marketAsync),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.cloud_off, color: AppColors.error, size: 40),
                const SizedBox(height: 12),
                Text(e.toString(), style: theme.textTheme.bodyMedium),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () => ref.invalidate(shardRateProvider),
                  child: const Text('Erneut versuchen'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildResult(
    ThemeData theme,
    ShardItem selected,
    AsyncValue<List<MarketItem>> marketAsync,
  ) {
    final amount = double.tryParse(_amountCtrl.text.replaceAll(',', '.'));
    if (amount == null || amount <= 0) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.04),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Text(
          'Gib eine Zielmenge ein, um die Berechnung zu sehen.',
          style: theme.textTheme.bodyMedium,
          textAlign: TextAlign.center,
        ),
      );
    }

    return marketAsync.when(
      data: (marketItems) {
        final result = calculateShardNeed(
          item: selected,
          targetAmount: amount,
          marketItems: marketItems,
        );
        return _ResultCard(item: selected, result: result);
      },
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(vertical: 20),
        child: Center(child: CircularProgressIndicator()),
      ),
      // Markt gerade nicht verfügbar? Trotzdem Anzahl/Stacks zeigen,
      // nur ohne Marktvergleich (siehe Datei-Kommentar oben).
      error: (_, __) => _ResultCard(
        item: selected,
        result: calculateShardNeed(
          item: selected,
          targetAmount: amount,
          marketItems: const [],
        ),
      ),
    );
  }
}

// ─── Item-Auswahl (horizontale Chips) ────────────────────────

class _ItemSelector extends StatelessWidget {
  final List<ShardItem> items;
  final ShardItem selected;
  final ValueChanged<ShardItem> onSelect;
  const _ItemSelector({
    required this.items,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 46,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final item = items[i];
          final isSelected = item.displayName == selected.displayName;
          return GestureDetector(
            onTap: () => onSelect(item),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.accent.withOpacity(0.20)
                    : AppColors.darkCard,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected
                      ? AppColors.accent.withOpacity(0.5)
                      : Colors.white.withOpacity(0.07),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    shardIconFor(item.displayName, target: item.target),
                    size: 16,
                    color: isSelected
                        ? AppColors.accentLight
                        : AppColors.darkTextSecondary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    item.displayName,
                    style: TextStyle(
                      color: isSelected
                          ? AppColors.accentLight
                          : AppColors.darkTextSecondary,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ─── Ergebnis-Karten ──────────────────────────────────────────

class _ResultCard extends StatelessWidget {
  final ShardItem item;
  final ShardCalculation result;
  const _ResultCard({required this.item, required this.result});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.accent.withOpacity(0.08),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.accent.withOpacity(0.2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Benötigte Menge', style: theme.textTheme.bodySmall),
              const SizedBox(height: 4),
              Text(
                '${result.itemsNeeded} \u00d7 ${item.displayName}',
                style: const TextStyle(
                  color: AppColors.accent,
                  fontWeight: FontWeight.w700,
                  fontSize: 20,
                ),
              ),
              const SizedBox(height: 8),
              Text(result.breakdown.display, style: theme.textTheme.bodyMedium),
            ],
          ),
        ),
        const SizedBox(height: 12),
        if (result.marketOption != null)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.success.withOpacity(0.08),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.success.withOpacity(0.2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Günstigste Option', style: theme.textTheme.bodySmall),
                const SizedBox(height: 4),
                Text(
                  result.marketOption!.label,
                  style: const TextStyle(
                    color: AppColors.success,
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${result.marketOption!.amountNeeded} \u00d7 '
                  '${AppFormat.currency(result.marketOption!.unitPrice, decimals: 2)}',
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  'Gesamtkosten: ${AppFormat.currency(result.marketOption!.totalCost, decimals: 2)}',
                  style: const TextStyle(
                    color: AppColors.gold,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          )
        else
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.04),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              'Für dieses Item ist aktuell kein Marktvergleich verfügbar.',
              style: theme.textTheme.bodyMedium,
            ),
          ),
      ],
    );
  }
}
