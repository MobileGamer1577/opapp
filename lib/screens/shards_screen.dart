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
    final theme = Theme.of(context);
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
          // Diamond icon als Platzhalter
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              color:        AppColors.accent.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
              border:       Border.all(color: AppColors.accent.withOpacity(0.25)),
            ),
            child: const Icon(Icons.diamond, color: AppColors.accent, size: 20),
          ),
          const SizedBox(width: 14),

          // Name
          Expanded(
            child: Text(
              item.displayName,
              style: const TextStyle(
                color:      Colors.white,
                fontWeight: FontWeight.w600,
                fontSize:   15,
              ),
            ),
          ),

          // Kurs-Wert
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                item.displayRate,
                style: const TextStyle(
                  color:      AppColors.accent,
                  fontWeight: FontWeight.w700,
                  fontSize:   15,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
