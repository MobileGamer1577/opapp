// ═══════════════════════════════════════════════════════════════
//  shards_screen.dart – OPShards-Wechselkurse
//
//  ✅ HIER ÄNDERN: Kartendesign
//  ❌ NICHT ÄNDERN: shardRateProvider-Aufruf
//
//  ÄNDERUNGEN (gegenüber alter Version):
//    - Icon je Item (siehe shard_rate.dart → shardIconFor)
//    - Basiskurs wird unter dem Namen angezeigt
//    - Kurs ist grün (über Basis) / rot (unter Basis) eingefärbt
//    - kleines Prozent-Badge zeigt die Abweichung zur Basis
// ═══════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/app_colors.dart';
import '../data/repositories/shard_repository.dart';
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

                // ─── Kurs-Liste ────────────────────────────────
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

// ─── Einzelne Kurs-Karte ─────────────────────────────────────

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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color:        AppColors.darkCard,
        borderRadius: BorderRadius.circular(16),
        border:       Border.all(color: Colors.white.withOpacity(0.07)),
      ),
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
        ],
      ),
    );
  }
}
