// ═══════════════════════════════════════════════════════════════
//  shard_calculator_screen.dart – Wertstoff-Rechner
//
//  ✅ HIER ÄNDERN: Kartendesign, Texte
//  ❌ NICHT ÄNDERN: shardRateProvider/marketProvider-Aufrufe,
//                   calculateShardOptions()-Aufruf-Logik
//
//  AUFBAU:
//    1. Währungs-Umschalter (Shards / Redcoins, weitere Währungen aus
//       der API erscheinen automatisch – siehe availableCurrencies())
//    2. Ein freies Eingabefeld für die Zielmenge (z.B. 1250)
//    3. Ergebnis-Karten untereinander, günstigste Option zuerst
//
//  ÄNDERUNGEN (Rechner-Umbau, grundlegend):
//    - Item-Auswahl (Chips) entfällt komplett: Statt EIN Item zu
//      wählen, werden jetzt ALLE aktuell kaufbaren Optionen der
//      gewählten Währung als Karten gezeigt (siehe
//      calculateShardOptions() in shard_calculator.dart).
//    - NEU: Währungs-Umschalter oben. Farben folgen – wie im
//      Wertstoffhändler – der Einstellung "Währungsfarben"
//      (currencyColorProvider); ausgeschaltet → einheitlich Lila.
//    - NEU: Jede Karte zeigt Stückzahl (+ Stacks ab 64 Stück),
//      Marktpreis, Gesamtkosten, erhaltene Shards/Redcoins mit genauem
//      Übertrag und – außer bei der günstigsten Option – die
//      Kosten-Differenz zur günstigsten.
//    - Preise laufen über AppFormat.currencyAuto() und beachten damit
//      die Einstellung "Zahlenformat". Gesamtkosten und Differenz
//      werden auf ganze $ gerundet, der Stückpreis bleibt exakt.
//    - Eingabe: "1250", "1.250" (Tausenderpunkt) und "1250,5" werden
//      verstanden. Nicht kaufbare Items (kein Marktpreis) werden
//      bewusst ausgeblendet statt mit Platzhalter angezeigt.
//    - Ohne Marktdaten (Fehler) gibt es keine Preise – daher jetzt eine
//      Fehlermeldung mit "Erneut versuchen" statt eines Teilergebnisses.
// ═══════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/app_colors.dart';
import '../core/app_format.dart';
import '../data/repositories/shard_repository.dart';
import '../data/repositories/market_repository.dart';
import '../data/repositories/number_format_repository.dart';
import '../data/repositories/currency_color_repository.dart';
import '../data/models/shard_rate.dart';
import '../data/models/market_item.dart';
import '../data/shard_calculator.dart';
import '../widgets/app_background.dart';
import '../widgets/market_item_tile.dart' show formatCount;

class ShardCalculatorScreen extends ConsumerStatefulWidget {
  const ShardCalculatorScreen({super.key});

  @override
  ConsumerState<ShardCalculatorScreen> createState() =>
      _ShardCalculatorScreenState();
}

class _ShardCalculatorScreenState extends ConsumerState<ShardCalculatorScreen> {
  final _amountCtrl = TextEditingController();

  /// Gewählte Währung ("target"-Kennung aus der API).
  String _currency = 'opshards';

  @override
  void dispose() {
    _amountCtrl.dispose();
    super.dispose();
  }

  /// Liest die Eingabe tolerant: "1250", "1.250", "1.250.000", "1250,5".
  /// Ein Punkt gilt nur dann als Tausendertrenner, wenn danach genau
  /// drei Ziffern folgen (sonst Dezimalpunkt).
  double? _parseAmount(String raw) {
    var s = raw.trim().replaceAll(' ', '');
    if (s.isEmpty) return null;
    if (RegExp(r'^\d{1,3}(\.\d{3})+$').hasMatch(s)) {
      s = s.replaceAll('.', '');
    }
    s = s.replaceAll(',', '.');
    return double.tryParse(s);
  }

  @override
  Widget build(BuildContext context) {
    final theme         = Theme.of(context);
    final shardAsync    = ref.watch(shardRateProvider);
    final marketAsync   = ref.watch(marketProvider);
    final colorsEnabled = ref.watch(currencyColorProvider);
    final formatMode    = ref.watch(numberFormatProvider);

    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(title: const Text('Wertstoff-Rechner')),
        body: shardAsync.when(
          data: (rates) {
            if (rates.items.isEmpty) {
              return const Center(child: Text('Keine Wechselkurse verfügbar'));
            }

            final currencies = availableCurrencies(rates.items);
            final currency =
                currencies.contains(_currency) ? _currency : currencies.first;
            final accent =
                colorsEnabled ? currencyColorFor(currency) : AppColors.accent;

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // ─── Währungs-Umschalter ──────────────────────
                _CurrencyToggle(
                  currencies:    currencies,
                  selected:      currency,
                  colorsEnabled: colorsEnabled,
                  onSelect:      (c) => setState(() => _currency = c),
                ),
                const SizedBox(height: 14),

                // ─── Zieleingabe ──────────────────────────────
                _AmountCard(
                  controller: _amountCtrl,
                  currency:   currency,
                  accent:     accent,
                  onChanged:  (_) => setState(() {}),
                ),
                const SizedBox(height: 20),

                // ─── Ergebnis ─────────────────────────────────
                _buildResult(
                  theme:       theme,
                  items:       rates.items,
                  currency:    currency,
                  marketAsync: marketAsync,
                  formatMode:  formatMode,
                  accent:      accent,
                ),
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

  Widget _buildResult({
    required ThemeData theme,
    required List<ShardItem> items,
    required String currency,
    required AsyncValue<List<MarketItem>> marketAsync,
    required NumberFormatMode formatMode,
    required Color accent,
  }) {
    final label  = currencyLabelFor(currency);
    final amount = _parseAmount(_amountCtrl.text);

    if (amount == null || amount <= 0) {
      return _InfoBox(
        text: 'Gib eine Zielmenge ein, um die Berechnung zu sehen.',
      );
    }

    return marketAsync.when(
      data: (marketItems) {
        final options = calculateShardOptions(
          items:        items,
          currency:     currency,
          targetAmount: amount,
          marketItems:  marketItems,
        );

        if (options.isEmpty) {
          return _InfoBox(
            text: 'Aktuell gibt es keine kaufbaren Optionen für $label.',
          );
        }

        final cheapestCost = options.first.totalCost;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 10),
              child: Text(
                '${options.length} Option${options.length == 1 ? '' : 'en'}'
                ' für ${AppFormat.number(amount)} $label',
                style: theme.textTheme.bodySmall,
              ),
            ),
            for (int i = 0; i < options.length; i++)
              _OptionCard(
                option:       options[i],
                isCheapest:   i == 0,
                showBadge:    i == 0 && options.length > 1,
                cheapestCost: cheapestCost,
                mode:         formatMode,
                accent:       accent,
              ),
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                'Preise: aktueller Kaufpreis im Markt (Sofort kaufen). '
                'Quelle: OPSUCHT API.',
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: AppColors.darkTextHint),
              ),
            ),
          ],
        );
      },
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color:        Colors.white.withOpacity(0.04),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            const Icon(Icons.cloud_off, color: AppColors.error, size: 32),
            const SizedBox(height: 8),
            Text(
              'Marktpreise konnten nicht geladen werden.',
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => ref.invalidate(marketProvider),
              child: const Text('Erneut versuchen'),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Preis-Formatierung (nur für diesen Screen) ───────────────
// Folgt der Einstellung "Zahlenformat". [whole] rundet auf ganze $
// (Gesamtkosten/Differenz); sonst bleiben Cent-Beträge erhalten.

String _money(double v, NumberFormatMode mode, {bool whole = false}) {
  final value = whole ? v.roundToDouble() : v;
  return AppFormat.currencyAuto(
    value,
    mode:     mode,
    decimals: value % 1 == 0 ? 0 : 2,
  );
}

// ─── Währungs-Umschalter ──────────────────────────────────────

class _CurrencyToggle extends StatelessWidget {
  final List<String> currencies;
  final String selected;
  final bool colorsEnabled;
  final ValueChanged<String> onSelect;
  const _CurrencyToggle({
    required this.currencies,
    required this.selected,
    required this.colorsEnabled,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color:        AppColors.darkCard,
        borderRadius: BorderRadius.circular(16),
        border:       Border.all(color: Colors.white.withOpacity(0.07)),
      ),
      child: Row(
        children: [
          for (int i = 0; i < currencies.length; i++) ...[
            if (i > 0) const SizedBox(width: 4),
            Expanded(
              child: _CurrencyTab(
                target:        currencies[i],
                selected:      currencies[i] == selected,
                colorsEnabled: colorsEnabled,
                onTap:         () => onSelect(currencies[i]),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _CurrencyTab extends StatelessWidget {
  final String target;
  final bool selected, colorsEnabled;
  final VoidCallback onTap;
  const _CurrencyTab({
    required this.target,
    required this.selected,
    required this.colorsEnabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = colorsEnabled ? currencyColorFor(target) : AppColors.accent;
    final fg    = selected ? color : AppColors.darkTextSecondary;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration:  const Duration(milliseconds: 180),
        padding:   const EdgeInsets.symmetric(vertical: 12),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? color.withOpacity(0.18) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? color.withOpacity(0.50) : Colors.transparent,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Leerer Anzeigename → es greift das währungsspezifische
            // Fallback-Icon (Diamant / Münze / neutral).
            Icon(shardIconFor('', target: target), size: 18, color: fg),
            const SizedBox(width: 8),
            Text(
              currencyLabelFor(target),
              style: TextStyle(
                color:      fg,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                fontSize:   14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Eingabe-Karte (Zielmenge) ────────────────────────────────

class _AmountCard extends StatelessWidget {
  final TextEditingController controller;
  final String currency;
  final Color accent;
  final ValueChanged<String> onChanged;
  const _AmountCard({
    required this.controller,
    required this.currency,
    required this.accent,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color:        AppColors.darkCard,
        borderRadius: BorderRadius.circular(18),
        border:       Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color:        accent.withOpacity(0.14),
              borderRadius: BorderRadius.circular(14),
              border:       Border.all(color: accent.withOpacity(0.25)),
            ),
            child: Icon(shardIconFor('', target: currency),
                color: accent, size: 26),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Wie viele ${currencyLabelFor(currency)} brauchst du?',
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 8),
                TextField(
                  controller:   controller,
                  onChanged:    onChanged,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9.,\s]')),
                  ],
                  style: const TextStyle(
                    color:      Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize:   20,
                  ),
                  decoration: InputDecoration(
                    hintText:  'z.B. 1250',
                    fillColor: AppColors.darkBackground,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Hinweis-Box (leer / keine Optionen) ──────────────────────

class _InfoBox extends StatelessWidget {
  final String text;
  const _InfoBox({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color:        Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodyMedium,
        textAlign: TextAlign.center,
      ),
    );
  }
}

// ─── Ergebnis-Karte (eine Option) ─────────────────────────────

class _OptionCard extends StatelessWidget {
  final ShardOption option;
  final bool isCheapest;
  final bool showBadge;
  final double cheapestCost;
  final NumberFormatMode mode;

  /// Akzentfarbe der gewählten Währung (bzw. Lila bei ausgeschalteten
  /// Währungsfarben).
  final Color accent;

  const _OptionCard({
    required this.option,
    required this.isCheapest,
    required this.showBadge,
    required this.cheapestCost,
    required this.mode,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final item  = option.item;

    final carryText = option.carry == 0
        ? '(passt genau)'
        : '(+${AppFormat.number(option.carry)} Übertrag)';
    final difference = option.totalCost - cheapestCost;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color.alphaBlend(
          accent.withOpacity(isCheapest ? 0.10 : 0.04),
          AppColors.darkCard,
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isCheapest
              ? accent.withOpacity(0.55)
              : Colors.white.withOpacity(0.07),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ─ Kopf: Icon, Name, Badge ─────────────────────────
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color:        accent.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                  border:       Border.all(color: accent.withOpacity(0.25)),
                ),
                child: Icon(
                  shardIconFor(item.displayName, target: item.target),
                  color: accent,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  item.displayName,
                  style: theme.textTheme.titleMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (showBadge)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color:        accent.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                    border:       Border.all(color: accent.withOpacity(0.5)),
                  ),
                  child: Text(
                    'AM GÜNSTIGSTEN',
                    style: TextStyle(
                      color:         accent,
                      fontSize:      10,
                      fontWeight:    FontWeight.w800,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),

          // ─ Stückzahl (+ Stacks) ────────────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                formatCount(option.itemsNeeded),
                style: const TextStyle(
                  color:      Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize:   28,
                ),
              ),
              const SizedBox(width: 6),
              Text('Stück', style: theme.textTheme.bodyMedium),
            ],
          ),
          if (option.itemsNeeded >= stackSize) ...[
            const SizedBox(height: 2),
            Text(option.breakdown.display, style: theme.textTheme.bodySmall),
          ],
          const SizedBox(height: 6),
          Text(
            option.usesRecipe
                ? 'à ${_money(option.unitCost, mode)} — aus '
                    '${formatCount(option.rawPerUnit!)}× ${option.rawLabel}'
                : 'à ${_money(option.unitCost, mode)} im Markt',
            style: theme.textTheme.bodyMedium,
          ),
          if (option.usesRecipe) ...[
            const SizedBox(height: 2),
            Text(
              'Gesamt: ${formatCount(option.rawTotal!)}× ${option.rawLabel}'
              ' (${option.rawBreakdown!.display})',
              style: theme.textTheme.bodySmall,
            ),
          ],

          const SizedBox(height: 14),
          Divider(height: 1, color: Colors.white.withOpacity(0.06)),
          const SizedBox(height: 12),

          // ─ Kosten ──────────────────────────────────────────
          _StatRow(
            label: 'Kosten',
            child: Text(
              _money(option.totalCost, mode, whole: true),
              style: TextStyle(
                color:      isCheapest ? accent : Colors.white,
                fontWeight: FontWeight.w800,
                fontSize:   22,
              ),
            ),
          ),
          const SizedBox(height: 8),

          // ─ Erhaltene Shards/Redcoins + Übertrag ────────────
          _StatRow(
            label: item.currencyLabel,
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: AppFormat.number(option.received),
                    style: const TextStyle(
                      color:      AppColors.darkTextPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  TextSpan(
                    text: ' $carryText',
                    style: const TextStyle(color: AppColors.darkTextSecondary),
                  ),
                ],
              ),
              textAlign: TextAlign.right,
              style: const TextStyle(fontSize: 14),
            ),
          ),

          // ─ Differenz zur günstigsten Option ────────────────
          if (!isCheapest) ...[
            const SizedBox(height: 8),
            _StatRow(
              label: 'Differenz',
              child: Text(
                '+${_money(difference, mode, whole: true)}',
                style: const TextStyle(
                  color:      AppColors.error,
                  fontWeight: FontWeight.w700,
                  fontSize:   14,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  final String label;
  final Widget child;
  const _StatRow({required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(width: 12),
        Expanded(
          child: Align(alignment: Alignment.centerRight, child: child),
        ),
      ],
    );
  }
}
