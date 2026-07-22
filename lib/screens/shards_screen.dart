// ═══════════════════════════════════════════════════════════════
//  shards_screen.dart – OPShards-Wechselkurse
//
//  ✅ HIER ÄNDERN: Kartendesign, Detail-Sheet-Inhalt
//  ❌ NICHT ÄNDERN: shardRateProvider-Aufruf
//
//  ÄNDERUNGEN (gegenüber alter Version):
//    - Icon je Item (siehe shard_rate.dart → shardIconFor)
//    - Basiskurs wird unter dem Namen angezeigt
//    - Kurs ist grün (über Basis) / rot (unter Basis) eingefärbt
//    - kleines Prozent-Badge zeigt die Abweichung zur Basis
//
//  ÄNDERUNGEN (Allzeithoch-Update):
//    - NEU: Tap auf eine Item-Karte öffnet ein Detail-Sheet (gleiches
//      Muster wie Markt/Auktionshaus) mit aktuellem Kurs UND dem
//      Allzeithoch (Wert + Datum, aus dem eigenen opapp-shards-api
//      Backend, siehe shard_all_time_high_repository.dart).
//    - Schlägt der Allzeithoch-Request fehl (Backend down, kein Netz),
//      bleibt der Rest des Screens unberührt – nur das Sheet zeigt
//      dann "Nicht verfügbar" statt eines Rekordwerts.
//    - Platzhalter-Hinweis im Sheet für den künftigen Kursverlauf-Graph.
//
//  ÄNDERUNGEN (Kursverlauf-Update):
//    - NEU: Der Platzhalter ist jetzt ein echter Graph (fl_chart),
//      lädt vom eigenen Backend (shardHistoryProvider, siehe
//      shard_history_repository.dart). Umschalter zwischen 7 und 30
//      Tagen (_RangeToggle) direkt über dem Graphen.
//    - _ShardDetailSheet ist jetzt ConsumerStatefulWidget statt
//      ConsumerWidget, damit der gewählte Zeitraum (Standard: 7 Tage)
//      als lokaler State erhalten bleibt, während man im Sheet ist.
//    - SETUP: flutter pub add fl_chart
// ═══════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../core/app_colors.dart';
import '../core/app_format.dart';
import '../data/repositories/shard_repository.dart';
import '../data/repositories/shard_all_time_high_repository.dart';
import '../data/repositories/shard_history_repository.dart';
import '../data/models/shard_history_point.dart';
import '../data/models/shard_rate.dart';
import '../widgets/app_background.dart';

class ShardsScreen extends ConsumerWidget {
  const ShardsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shardAsync = ref.watch(shardRateProvider);
    final theme      = Theme.of(context);

    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('OPShards'),
          actions: [
            IconButton(
              icon:      const Icon(Icons.refresh),
              onPressed: () => ref.invalidate(shardRateProvider),
            ),
          ],
        ),
        body: shardAsync.when(
          data: (rates) {
            if (rates.items.isEmpty) {
              return const Center(
                child: Text('Keine Kursdaten verfügbar'),
              );
            }
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [

                // ─── Header ────────────────────────────────────
                Center(
                  child: Column(
                    children: [
                      const Icon(Icons.diamond, color: AppColors.accent, size: 48),
                      const SizedBox(height: 12),
                      Text(
                        'Aktuelle Wechselkurse',
                        style: theme.textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Zuletzt aktualisiert: ${_formatTime(rates.fetchedAt)}',
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // ─── Kurs-Liste (antippbar für Details + Allzeithoch) ──
                ...rates.items.map((item) => _ShardItemCard(item: item)),
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

  String _formatTime(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m Uhr';
  }
}

// ─── Einzelne Kurs-Karte (antippbar) ─────────────────────────

class _ShardItemCard extends StatelessWidget {
  final ShardItem item;
  const _ShardItemCard({required this.item});

  @override
  Widget build(BuildContext context) {
    // Farbe je nach Kurs vs. Basiswert: Grün = drüber, Rot = drunter
    final trendColor = item.isAboveBase
        ? AppColors.success
        : item.isBelowBase
            ? AppColors.error
            : AppColors.darkTextSecondary;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color:        AppColors.darkCard,
        borderRadius: BorderRadius.circular(16),
        border:       Border.all(color: Colors.white.withOpacity(0.07)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Theme.of(context).colorScheme.surface,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            builder: (_) => _ShardDetailSheet(item: item),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                // Icon je Item (siehe shard_rate.dart → shardIcons)
                Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(
                    color:        AppColors.accent.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                    border:       Border.all(color: AppColors.accent.withOpacity(0.25)),
                  ),
                  child: Icon(shardIconFor(item.displayName), color: AppColors.accent, size: 20),
                ),
                const SizedBox(width: 14),

                // Name + Basiskurs
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.displayName,
                        style: const TextStyle(
                          color:      Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize:   15,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Basis: ${item.displayBase}',
                        style: const TextStyle(
                          color:    AppColors.darkTextHint,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),

                // Aktueller Kurs + Veränderung zur Basis
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      item.displayRate,
                      style: TextStyle(
                        color:      trendColor,
                        fontWeight: FontWeight.w700,
                        fontSize:   15,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color:        trendColor.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        item.displayChange,
                        style: TextStyle(
                          color:      trendColor,
                          fontSize:   11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 4),
                Icon(Icons.chevron_right_rounded,
                    color: AppColors.darkTextHint, size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Detail-Sheet (bei Tap auf ein Item) ─────────────────────
// ConsumerStatefulWidget: lädt den Allzeithoch-Provider UND hält den
// lokal gewählten Kursverlauf-Zeitraum (7/30 Tage) als State.

class _ShardDetailSheet extends ConsumerStatefulWidget {
  final ShardItem item;
  const _ShardDetailSheet({required this.item});

  @override
  ConsumerState<_ShardDetailSheet> createState() => _ShardDetailSheetState();
}

class _ShardDetailSheetState extends ConsumerState<_ShardDetailSheet> {
  int _selectedDays = 7;

  @override
  Widget build(BuildContext context) {
    final theme    = Theme.of(context);
    final item     = widget.item;
    final athAsync = ref.watch(shardAllTimeHighProvider);
    final historyAsync = ref.watch(
      shardHistoryProvider(ShardHistoryQuery(item.athKey, _selectedDays)),
    );

    final trendColor = item.isAboveBase
        ? AppColors.success
        : item.isBelowBase
            ? AppColors.error
            : AppColors.darkTextSecondary;

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag-Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 18),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // ─ Titel ───────────────────────────────────────
          Row(
            children: [
              Container(
                width: 56, height: 56,
                decoration: BoxDecoration(
                  color:        AppColors.accent.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(14),
                  border:       Border.all(color: AppColors.accent.withOpacity(0.25)),
                ),
                child: Center(
                  child: Icon(shardIconFor(item.displayName), color: AppColors.accent, size: 30),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.displayName, style: theme.textTheme.titleLarge),
                    const SizedBox(height: 2),
                    Text('Basis: ${item.displayBase}', style: theme.textTheme.bodySmall),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),

          // ─ Aktueller Kurs ──────────────────────────────
          _ShardStatBox(
            label:    'Aktueller Kurs',
            value:    item.displayRate,
            sublabel: '${item.displayChange} über Basis',
            color:    trendColor,
          ),
          const SizedBox(height: 12),

          // ─ Allzeithoch (aus dem opapp-shards-api Backend) ──
          athAsync.when(
            data: (map) {
              final ath = map[item.athKey];
              if (ath == null) {
                return const _ShardStatBox(
                  label:    'Höchster Kurs',
                  value:    'Noch keine Daten',
                  sublabel: 'Wird ab jetzt automatisch erfasst',
                  color:    AppColors.darkTextSecondary,
                );
              }
              return _ShardStatBox(
                label:    'Höchster Kurs',
                value:    ath.displayRate,
                sublabel: '${ath.displayChange} über Basis · ${AppFormat.dateTime(ath.achievedAt.toLocal())}',
                color:    AppColors.gold,
              );
            },
            loading: () => const _ShardStatBoxLoading(),
            error: (_, __) => const _ShardStatBox(
              label:    'Höchster Kurs',
              value:    'Nicht verfügbar',
              sublabel: 'Verbindung zur Historie fehlgeschlagen',
              color:    AppColors.darkTextSecondary,
            ),
          ),
          const SizedBox(height: 22),

          // ─ Kursverlauf ─────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Kursverlauf', style: theme.textTheme.titleMedium),
              _RangeToggle(
                selectedDays: _selectedDays,
                onChanged: (d) => setState(() => _selectedDays = d),
              ),
            ],
          ),
          const SizedBox(height: 12),
          historyAsync.when(
            data: (points) => _ShardHistoryChart(points: points),
            loading: () => const SizedBox(
              height: 140,
              child: Center(
                child: SizedBox(
                  width: 20, height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.accent),
                ),
              ),
            ),
            error: (_, __) => SizedBox(
              height: 140,
              child: Center(
                child: Text(
                  'Kursverlauf nicht verfügbar',
                  style: theme.textTheme.bodySmall,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Wiederverwendbare Stat-Box im Detail-Sheet ──────────────

class _ShardStatBox extends StatelessWidget {
  final String label, value, sublabel;
  final Color color;
  const _ShardStatBox({
    required this.label,
    required this.value,
    required this.sublabel,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color:        color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border:       Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: theme.textTheme.bodySmall),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 18),
          ),
          const SizedBox(height: 2),
          Text(
            sublabel,
            style: theme.textTheme.bodySmall?.copyWith(color: AppColors.darkTextHint),
          ),
        ],
      ),
    );
  }
}

class _ShardStatBoxLoading extends StatelessWidget {
  const _ShardStatBoxLoading();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 74,
      decoration: BoxDecoration(
        color:        Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(14),
        border:       Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: const Center(
        child: SizedBox(
          width: 18, height: 18,
          child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.accent),
        ),
      ),
    );
  }
}

// ─── Zeitraum-Umschalter (7 Tage / 30 Tage) ──────────────────

class _RangeToggle extends StatelessWidget {
  final int selectedDays;
  final ValueChanged<int> onChanged;
  const _RangeToggle({required this.selectedDays, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color:        Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _RangeButton(
            label:    '7 Tage',
            selected: selectedDays == 7,
            onTap:    () => onChanged(7),
          ),
          _RangeButton(
            label:    '30 Tage',
            selected: selectedDays == 30,
            onTap:    () => onChanged(30),
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
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.accent.withOpacity(0.20)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? AppColors.accentLight : AppColors.darkTextSecondary,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}

// ─── Kursverlauf-Graph (fl_chart) ─────────────────────────────
// Bewusst simpel gehalten (keine Achsenbeschriftung von fl_chart
// selbst, keine Touch-Tooltips) – Start-/Enddatum werden stattdessen
// als einfache Text-Widgets darunter angezeigt. Reduziert die
// fl_chart-Konfiguration auf den sicher unterstützten Kern.

class _ShardHistoryChart extends StatelessWidget {
  final List<ShardHistoryPoint> points;
  const _ShardHistoryChart({required this.points});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (points.length < 2) {
      return Container(
        height: 140,
        alignment: Alignment.center,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color:        Colors.white.withOpacity(0.04),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          'Noch nicht genug Datenpunkte für diesen Zeitraum.',
          style: theme.textTheme.bodySmall,
          textAlign: TextAlign.center,
        ),
      );
    }

    final spots = <FlSpot>[
      for (int i = 0; i < points.length; i++) FlSpot(i.toDouble(), points[i].rate),
    ];

    final rates = points.map((p) => p.rate);
    final minY  = rates.reduce((a, b) => a < b ? a : b);
    final maxY  = rates.reduce((a, b) => a > b ? a : b);
    final pad   = (maxY - minY) == 0 ? 1.0 : (maxY - minY) * 0.15;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 140,
          child: LineChart(
            LineChartData(
              minY: minY - pad,
              maxY: maxY + pad,
              gridData:  const FlGridData(show: false),
              borderData: FlBorderData(show: false),
              titlesData: const FlTitlesData(
                bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles:    AxisTitles(sideTitles: SideTitles(showTitles: false)),
                leftTitles:   AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles:  AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              lineTouchData: const LineTouchData(enabled: false),
              lineBarsData: [
                LineChartBarData(
                  spots:    spots,
                  isCurved: true,
                  color:    AppColors.accent,
                  barWidth: 2.5,
                  dotData:  const FlDotData(show: false),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              AppFormat.date(points.first.fetchedAt.toLocal()),
              style: theme.textTheme.bodySmall?.copyWith(color: AppColors.darkTextHint),
            ),
            Text(
              AppFormat.date(points.last.fetchedAt.toLocal()),
              style: theme.textTheme.bodySmall?.copyWith(color: AppColors.darkTextHint),
            ),
          ],
        ),
      ],
    );
  }
}
