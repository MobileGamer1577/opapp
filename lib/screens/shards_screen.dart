import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/app_colors.dart';
import '../data/repositories/shard_repository.dart';
import '../widgets/app_background.dart';

class ShardsScreen extends ConsumerWidget {
  const ShardsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shardAsync = ref.watch(shardRateProvider);
    final theme = Theme.of(context);

    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('OPShards'),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () => ref.invalidate(shardRateProvider),
            ),
          ],
        ),
        body: shardAsync.when(
          data: (rate) => ListView(
            padding: const EdgeInsets.all(24),
            children: [
              // ─── Kurs-Karte ────────────────────────────────
              Center(
                child: Column(
                  children: [
                    const Icon(Icons.diamond,
                        color: AppColors.accent, size: 48),
                    const SizedBox(height: 16),
                    Text('Aktueller Wechselkurs',
                        style: theme.textTheme.headlineMedium),
                    const SizedBox(height: 24),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          children: [
                            Text(
                              rate.displayRate,
                              style: theme.textTheme.headlineLarge?.copyWith(
                                color: AppColors.accent,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '1 Shard = ${rate.coinsPerShard.toStringAsFixed(4)} Coins',
                              style: theme.textTheme.bodyMedium,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Zuletzt aktualisiert: ${_formatTime(rate.fetchedAt)}',
                              style: theme.textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
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
