// ═══════════════════════════════════════════════════════════════
//  market_item_screen.dart – Markt-Item-Details (Vollbild)
//
//  ✅ HIER ÄNDERN: Kartendesign, Chart-Höhe (_chartHeight), Achsen-
//                  Beschriftung (_axisDate / _axisValue)
//  ❌ NICHT ÄNDERN: marketProvider- / marketHistoryProvider-Aufrufe,
//                   Zuordnung Zeitraum → Datenquelle (liegt in
//                   MarketHistory.pointsFor, market_history.dart)
//
//  AUFBAU:
//    1. Kopf: Icon, Name, Kategorie
//    2. "Sofort kaufen" / "Sofort verkaufen" (Preis + Anzahl)
//       + Spanne zwischen Kauf und Verkauf
//    3. Karte "Preisverlauf":
//         - Zeitraum-Buttons (genau 4): 24 h, 7 T, 30 T, Max
//         - Graph: Linie = Ø Preis, Band = Tief/Hoch je Zeitabschnitt,
//           Touch → Tooltip (Ø Preis, Tief/Hoch, Stück, Transaktionen,
//           Datum)
//         - 6 Statistik-Kacheln: Ø Preis, Veränderung, Tief, Hoch,
//           Gehandelt, Transaktionen
//
//  DATENQUELLEN:
//    - Preise/Aufträge kommen aus marketProvider (/market/prices) –
//      das Item wird per Material-ID gesucht (kein eigener Request,
//      die Daten liegen schon durch die Liste im Cache).
//    - Der Verlauf kommt aus marketHistoryProvider (EIN Request, alle
//      Zeitreihen). Der Zeitraum-Wechsel filtert nur lokal.
//
//  SPANNE KAUF/VERKAUF: Differenz Kaufpreis − Verkaufspreis, Prozent
//  bezogen auf den Kaufpreis (z.B. 3,3 $ / 1,4 $ → 1,9 $ = 57,6 %,
//  deckt sich mit der offiziellen App). Nur sichtbar, wenn beide
//  Preise vorhanden sind.
//
//  GRAPH-DETAILS:
//    - X-Achse ist ZEITBASIERT (nicht nach Index): Stunden ohne Handel
//      fehlen in den API-Daten und würden sonst die Zeitachse
//      verzerren.
//    - Y-Bereich richtet sich nach dem Ø-Preis. Einzelne extreme
//      Tief/Hoch-Ausreißer würden die Linie sonst flach drücken – das
//      Band wird deshalb an den sichtbaren Bereich gekappt.
//    - Zeitstempel sind lokale Zeit (siehe market_history.dart).
// ═══════════════════════════════════════════════════════════════

import 'dart:math' as math;
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/app_colors.dart';
import '../core/app_format.dart';
import '../data/models/market_history.dart';
import '../data/models/market_item.dart';
import '../data/repositories/market_history_repository.dart';
import '../data/repositories/market_repository.dart';
import '../widgets/app_background.dart';
import '../widgets/market_item_tile.dart' show formatCount;
import '../widgets/network_icon.dart';

const double _chartHeight = 220;

const List<String> _monthNames = [
  'Jan.', 'Feb.', 'März', 'Apr.', 'Mai', 'Juni',
  'Juli', 'Aug.', 'Sept.', 'Okt.', 'Nov.', 'Dez.',
];

class MarketItemScreen extends ConsumerStatefulWidget {
  /// Material-ID des Items, z.B. "DIAMOND_BLOCK".
  final String material;
  const MarketItemScreen({super.key, required this.material});

  @override
  ConsumerState<MarketItemScreen> createState() => _MarketItemScreenState();
}

class _MarketItemScreenState extends ConsumerState<MarketItemScreen> {
  MarketHistoryRange _range = MarketHistoryRange.h24;

  @override
  Widget build(BuildContext context) {
    final theme       = Theme.of(context);
    final marketAsync = ref.watch(marketProvider);

    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(title: const Text('Markt')),
        body: marketAsync.when(
          data: (items) {
            MarketItem? item;
            for (final candidate in items) {
              if (candidate.material == widget.material) {
                item = candidate;
                break;
              }
            }
            if (item == null) {
              return Center(
                child: Text('Item nicht gefunden',
                    style: theme.textTheme.bodyMedium),
              );
            }
            return _buildContent(context, item);
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
                  onPressed: () => ref.invalidate(marketProvider),
                  child: const Text('Erneut versuchen'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, MarketItem item) {
    final theme        = Theme.of(context);
    final historyAsync = ref.watch(marketHistoryProvider(item.material));

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
      children: [
        // ─── Kopf ────────────────────────────────────────
        Row(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color:        AppColors.accent.withOpacity(0.12),
                borderRadius: BorderRadius.circular(16),
                border:       Border.all(color: AppColors.accent.withOpacity(0.25)),
              ),
              child: Center(
                child: NetworkIcon(
                  url: item.icon,
                  size: 40,
                  assetFallback: item.material.isNotEmpty
                      ? minecraftAssetPath(item.material)
                      : null,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: theme.textTheme.headlineMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color:        AppColors.accent.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      item.category,
                      style: theme.textTheme.bodySmall
                          ?.copyWith(color: AppColors.accent),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // ─── Sofort kaufen / Sofort verkaufen ────────────
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _PriceBox(
                label:    'Sofort kaufen',
                price:    item.displayBuyPrice,
                sublabel: '${formatCount(item.buyOrders)} Angebote',
                active:   item.hasBuyPrice,
                color:    AppColors.buyColor,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _PriceBox(
                label:    'Sofort verkaufen',
                price:    item.displaySellPrice,
                sublabel: '${formatCount(item.sellOrders)} Kaufaufträge',
                active:   item.hasSellPrice,
                color:    AppColors.sellColor,
              ),
            ),
          ],
        ),

        // ─── Spanne zwischen Kauf und Verkauf ────────────
        if (item.hasBuyPrice && item.hasSellPrice) ...[
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              'Spanne zwischen Kauf und Verkauf: '
              '${AppFormat.currency(item.buyPrice - item.sellPrice, decimals: 2)} '
              '(${_percent((item.buyPrice - item.sellPrice) / item.buyPrice * 100, withSign: false)})',
              style: theme.textTheme.bodyMedium,
            ),
          ),
        ],
        const SizedBox(height: 20),

        // ─── Preisverlauf ────────────────────────────────
        _HistoryCard(
          historyAsync:    historyAsync,
          range:           _range,
          onRangeChanged:  (r) => setState(() => _range = r),
          onRetry:         () => ref.invalidate(marketHistoryProvider(item.material)),
        ),
      ],
    );
  }
}

// ─── Preis-Box (Sofort kaufen / verkaufen) ───────────────────

class _PriceBox extends StatelessWidget {
  final String label, price, sublabel;
  final bool active;
  final Color color;
  const _PriceBox({
    required this.label,
    required this.price,
    required this.sublabel,
    required this.active,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color:        color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border:       Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: theme.textTheme.bodySmall),
          const SizedBox(height: 6),
          Text(
            price,
            style: TextStyle(
              color:      active ? color : AppColors.darkTextHint,
              fontWeight: FontWeight.w800,
              fontSize:   22,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            sublabel,
            style: theme.textTheme.bodySmall
                ?.copyWith(color: AppColors.darkTextHint),
          ),
        ],
      ),
    );
  }
}

// ─── Preisverlauf-Karte ──────────────────────────────────────

class _HistoryCard extends StatelessWidget {
  final AsyncValue<MarketHistory> historyAsync;
  final MarketHistoryRange range;
  final ValueChanged<MarketHistoryRange> onRangeChanged;
  final VoidCallback onRetry;

  const _HistoryCard({
    required this.historyAsync,
    required this.range,
    required this.onRangeChanged,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color:        AppColors.darkCard,
        borderRadius: BorderRadius.circular(20),
        border:       Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Preisverlauf', style: theme.textTheme.titleLarge),
          const SizedBox(height: 2),
          Text('\u00d8 Preis pro Stück', style: theme.textTheme.bodyMedium),
          const SizedBox(height: 14),

          // ─ Zeitraum-Buttons (genau 4) ───────────────────
          Row(
            children: [
              for (int i = 0; i < MarketHistoryRange.values.length; i++) ...[
                if (i > 0) const SizedBox(width: 8),
                Expanded(
                  child: _RangeButton(
                    label:    MarketHistoryRange.values[i].label,
                    selected: MarketHistoryRange.values[i] == range,
                    onTap:    () => onRangeChanged(MarketHistoryRange.values[i]),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 18),

          // ─ Graph + Statistiken ──────────────────────────
          historyAsync.when<Widget>(
            data: (history) {
              final points = history.pointsFor(range);
              final stats  = MarketHistoryStats.fromPoints(points);
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _PriceChart(points: points, range: range),
                  const SizedBox(height: 18),
                  _StatsGrid(stats: stats),
                ],
              );
            },
            loading: () => const SizedBox(
              height: _chartHeight,
              child: Center(
                child: SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.accent,
                  ),
                ),
              ),
            ),
            error: (_, __) => SizedBox(
              height: _chartHeight,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.cloud_off,
                        color: AppColors.darkTextSecondary, size: 32),
                    const SizedBox(height: 8),
                    Text('Preisverlauf nicht verfügbar',
                        style: theme.textTheme.bodyMedium),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: onRetry,
                      child: const Text('Erneut versuchen'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RangeButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _RangeButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        height: 40,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? AppColors.accent : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? AppColors.accent : AppColors.darkBorder,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : AppColors.darkTextSecondary,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}

// ─── Preis-Graph (fl_chart) ──────────────────────────────────
// Drei Linien-Serien: [0] Hoch (unsichtbar), [1] Tief (unsichtbar),
// [2] Ø Preis (sichtbar). Zwischen [0] und [1] wird per
// BetweenBarsData das Tief/Hoch-Band gefüllt. Touch-Tooltip nur für
// die Ø-Linie (Index 2), die beiden Rand-Serien liefern null.

class _PriceChart extends StatelessWidget {
  final List<MarketHistoryPoint> points;
  final MarketHistoryRange range;
  const _PriceChart({required this.points, required this.range});

  static const int _avgBarIndex = 2;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (points.length < 2) {
      return Container(
        height: _chartHeight,
        alignment: Alignment.center,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color:        Colors.white.withOpacity(0.04),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Text(
          points.isEmpty
              ? 'Keine Verlaufsdaten für diesen Zeitraum.'
              : 'Noch nicht genug Datenpunkte für diesen Zeitraum.',
          style: theme.textTheme.bodySmall,
          textAlign: TextAlign.center,
        ),
      );
    }

    // ── X-Achse: Millisekunden seit dem ersten Punkt ────────
    final t0 = points.first.timestamp.millisecondsSinceEpoch;
    double xOf(MarketHistoryPoint p) =>
        (p.timestamp.millisecondsSinceEpoch - t0).toDouble();
    final rawMaxX = xOf(points.last);
    final maxX = rawMaxX <= 0 ? 1.0 : rawMaxX;
    final xInterval = maxX / 4;

    // ── Y-Achse: richtet sich nach dem Ø-Preis ──────────────
    var lo = points.first.avgPrice;
    var hi = points.first.avgPrice;
    for (final p in points) {
      lo = math.min(lo, p.avgPrice);
      hi = math.max(hi, p.avgPrice);
    }
    final span = hi - lo;
    final pad = span == 0 ? (hi == 0 ? 1.0 : hi * 0.1) : span * 0.15;
    final minY = math.max(0.0, lo - pad);
    final maxY = hi + pad;
    final yInterval = (maxY - minY) / 3;

    double clampY(double v) => v < minY ? minY : (v > maxY ? maxY : v);

    final avgSpots = <FlSpot>[
      for (final p in points) FlSpot(xOf(p), p.avgPrice),
    ];
    final highSpots = <FlSpot>[
      for (final p in points) FlSpot(xOf(p), clampY(p.maxPrice)),
    ];
    final lowSpots = <FlSpot>[
      for (final p in points) FlSpot(xOf(p), clampY(p.minPrice)),
    ];

    LineChartBarData invisibleBar(List<FlSpot> spots) => LineChartBarData(
          spots:    spots,
          isCurved: false,
          color:    Colors.transparent,
          barWidth: 0,
          dotData:  const FlDotData(show: false),
        );

    const labelStyle = TextStyle(
      color: AppColors.darkTextSecondary,
      fontSize: 11,
    );

    return SizedBox(
      height: _chartHeight,
      child: LineChart(
        LineChartData(
          minX: 0,
          maxX: maxX,
          minY: minY,
          maxY: maxY,
          clipData: const FlClipData.all(),
          borderData: FlBorderData(show: false),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: yInterval,
            getDrawingHorizontalLine: (_) => FlLine(
              color: Colors.white.withOpacity(0.06),
              strokeWidth: 1,
            ),
          ),
          titlesData: FlTitlesData(
            topTitles:   const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles:   true,
                reservedSize: 44,
                interval:     yInterval,
                getTitlesWidget: (value, meta) => SideTitleWidget(
                  meta: meta,
                  child: Text(_axisValue(value), style: labelStyle),
                ),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles:   true,
                reservedSize: 28,
                interval:     xInterval,
                getTitlesWidget: (value, meta) {
                  // Randbeschriftungen weglassen, sonst überlappen sie
                  // mit der Y-Achse bzw. werden abgeschnitten.
                  if (value < xInterval * 0.5 || value > maxX - xInterval * 0.5) {
                    return const SizedBox.shrink();
                  }
                  final date = DateTime.fromMillisecondsSinceEpoch(
                    t0 + value.round(),
                  );
                  return SideTitleWidget(
                    meta: meta,
                    child: Text(_axisDate(date, range), style: labelStyle),
                  );
                },
              ),
            ),
          ),
          lineBarsData: [
            invisibleBar(highSpots),
            invisibleBar(lowSpots),
            LineChartBarData(
              spots:            avgSpots,
              isCurved:         false,
              color:            AppColors.accent,
              barWidth:         2.5,
              isStrokeCapRound: true,
              dotData:          const FlDotData(show: false),
            ),
          ],
          betweenBarsData: [
            BetweenBarsData(
              fromIndex: 0,
              toIndex:   1,
              color:     AppColors.accent.withOpacity(0.14),
            ),
          ],
          lineTouchData: LineTouchData(
            handleBuiltInTouches: true,
            touchSpotThreshold:   24,
            // Touch-Markierung nur auf der Ø-Linie zeigen.
            getTouchedSpotIndicator: (barData, spotIndexes) {
              return spotIndexes.map((_) {
                if (barData.color == Colors.transparent) {
                  return const TouchedSpotIndicatorData(
                    FlLine(color: Colors.transparent),
                    FlDotData(show: false),
                  );
                }
                return TouchedSpotIndicatorData(
                  FlLine(color: Colors.white.withOpacity(0.25), strokeWidth: 1),
                  const FlDotData(show: true),
                );
              }).toList();
            },
            touchTooltipData: LineTouchTooltipData(
              maxContentWidth:         260,
              fitInsideHorizontally:   true,
              fitInsideVertically:     true,
              tooltipPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              getTooltipColor: (_) => AppColors.darkCardElevated,
              getTooltipItems: (touchedSpots) {
                return touchedSpots.map<LineTooltipItem?>((spot) {
                  if (spot.barIndex != _avgBarIndex) return null;
                  final p = points[spot.spotIndex];
                  return LineTooltipItem(
                    '${AppFormat.currency(p.avgPrice, decimals: 2)}\n',
                    const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                    textAlign: TextAlign.left,
                    children: [
                      TextSpan(
                        text:
                            'Tief ${AppFormat.currency(p.minPrice, decimals: 2)}'
                            ' \u00b7 Hoch ${AppFormat.currency(p.maxPrice, decimals: 2)}\n'
                            '${formatCount(p.items)} Stk. in '
                            '${formatCount(p.transactions)} Transaktionen\n'
                            '${_tooltipDate(p.timestamp, range)}',
                        style: const TextStyle(
                          color: AppColors.darkTextSecondary,
                          fontWeight: FontWeight.w500,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  );
                }).toList();
              },
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Statistik-Kacheln (2 Spalten × 3 Zeilen) ────────────────

class _StatsGrid extends StatelessWidget {
  final MarketHistoryStats? stats;
  const _StatsGrid({required this.stats});

  @override
  Widget build(BuildContext context) {
    final s = stats;
    const dash = '–';

    // Veränderung: Farbe + Pfeil je nach Vorzeichen. Auf eine
    // Nachkommastelle gerundet, damit "+0,0 %" nicht grün wird.
    Color changeColor = AppColors.darkTextPrimary;
    IconData? changeIcon;
    String changeText = dash;
    if (s != null) {
      final rounded = (s.changePercent * 10).round() / 10;
      changeText = _percent(rounded, withSign: true);
      if (rounded > 0) {
        changeColor = AppColors.success;
        changeIcon  = Icons.arrow_upward_rounded;
      } else if (rounded < 0) {
        changeColor = AppColors.error;
        changeIcon  = Icons.arrow_downward_rounded;
      } else {
        changeColor = AppColors.darkTextSecondary;
        changeIcon  = Icons.remove_rounded;
      }
    }

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _StatTile(
                label: '\u00d8 Preis',
                value: s == null ? dash : AppFormat.currency(s.avgPrice, decimals: 2),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _StatTile(
                label:      'Veränderung',
                value:      changeText,
                valueColor: changeColor,
                icon:       changeIcon,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _StatTile(
                label: 'Tief',
                value: s == null ? dash : AppFormat.currency(s.lowPrice, decimals: 2),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _StatTile(
                label: 'Hoch',
                value: s == null ? dash : AppFormat.currency(s.highPrice, decimals: 2),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _StatTile(
                label: 'Gehandelt',
                value: s == null ? dash : formatCount(s.itemsTraded),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _StatTile(
                label: 'Transaktionen',
                value: s == null ? dash : formatCount(s.transactions),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  final String label, value;
  final Color? valueColor;
  final IconData? icon;
  const _StatTile({
    required this.label,
    required this.value,
    this.valueColor,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = valueColor ?? AppColors.darkTextPrimary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color:        Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(14),
        border:       Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: theme.textTheme.bodySmall),
          const SizedBox(height: 4),
          Row(
            children: [
              if (icon != null) ...[
                Icon(icon, color: color, size: 18),
                const SizedBox(width: 4),
              ],
              Expanded(
                child: Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color:      color,
                    fontWeight: FontWeight.w700,
                    fontSize:   17,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Formatierungs-Helfer (nur für diesen Screen) ────────────

String _two(int v) => v.toString().padLeft(2, '0');

/// 56.25 → "56,3 %", mit withSign zusätzlich "+17,8 %" / "-3,2 %".
String _percent(double value, {required bool withSign}) {
  final text = value.abs().toStringAsFixed(1).replaceAll('.', ',');
  final sign = value < 0 ? '-' : (withSign && value > 0 ? '+' : '');
  return '$sign$text %';
}

/// 1.2 → "1,2" (überflüssiges ",0" entfällt).
String _trimDecimal(double v) {
  var s = v.toStringAsFixed(1);
  if (s.endsWith('.0')) s = s.substring(0, s.length - 2);
  return s.replaceAll('.', ',');
}

/// Y-Achsen-Beschriftung ohne Währungszeichen, platzsparend.
String _axisValue(double v) {
  final a = v.abs();
  if (a >= 1000) return '${_trimDecimal(v / 1000)}k';
  if (a >= 100) return v.toStringAsFixed(0);
  return _trimDecimal(v);
}

/// X-Achsen-Beschriftung je Zeitraum.
String _axisDate(DateTime d, MarketHistoryRange range) {
  switch (range) {
    case MarketHistoryRange.h24:
      return '${_two(d.hour)}:${_two(d.minute)}';
    case MarketHistoryRange.d7:
    case MarketHistoryRange.d30:
      return '${_two(d.day)}.${_two(d.month)}.';
    case MarketHistoryRange.max:
      return '${_monthNames[d.month - 1]} ${_two(d.year % 100)}';
  }
}

/// Datumszeile im Tooltip – Genauigkeit passend zur Datenquelle
/// (Stunde / Tag / Monat).
String _tooltipDate(DateTime d, MarketHistoryRange range) {
  switch (range) {
    case MarketHistoryRange.h24:
    case MarketHistoryRange.d7:
      return '${d.day}. ${_monthNames[d.month - 1]}, '
          '${_two(d.hour)}:${_two(d.minute)} Uhr';
    case MarketHistoryRange.d30:
      return '${d.day}. ${_monthNames[d.month - 1]} ${d.year}';
    case MarketHistoryRange.max:
      return '${_monthNames[d.month - 1]} ${d.year}';
  }
}
