import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/app_colors.dart';
import '../data/repositories/auction_repository.dart';
import '../data/models/auction_item.dart';
import '../core/api_constants.dart';
import '../widgets/app_background.dart';

class AuctionsScreen extends ConsumerWidget {
  const AuctionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auctAsync = ref.watch(auctionsProvider);
    final theme     = Theme.of(context);

    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Auktionshaus'),
        actions: [
          // Live-Indikator
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8, height: 8,
                  decoration: const BoxDecoration(
                    color: AppColors.success,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  'Live',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.success,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // ─── Refresh-Info-Banner ───────────────────────
          Container(
            width:   double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
            color: Colors.white.withOpacity(0.04),
            child: Text(
              'Aktualisiert alle ${ApiConstants.auctionRefreshInterval.inSeconds} Sekunden automatisch',
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.accent,
              ),
              textAlign: TextAlign.center,
            ),
          ),

          // ─── Liste ────────────────────────────────────
          Expanded(
            child: auctAsync.when(
              data: (items) {
                if (items.isEmpty) {
                  return const Center(child: Text('Keine aktiven Auktionen'));
                }
                return RefreshIndicator(
                  onRefresh: () => ref.read(auctionsProvider.notifier).refresh(),
                  child: ListView.separated(
                    padding:     const EdgeInsets.all(16),
                    itemCount:   items.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (_, i) => _AuctionCard(item: items[i]),
                  ),
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
                      onPressed: () => ref.read(auctionsProvider.notifier).refresh(),
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

// ─── Auktions-Karte ──────────────────────────────────────────

class _AuctionCard extends StatelessWidget {
  final AuctionItem item;
  const _AuctionCard({required this.item});

  String _formatDuration(Duration d) {
    if (d.isNegative) return 'Abgelaufen';
    if (d.inHours > 0) return '${d.inHours}h ${d.inMinutes.remainder(60)}m';
    return '${d.inMinutes}m ${d.inSeconds.remainder(60)}s';
  }

  @override
  Widget build(BuildContext context) {
    final theme    = Theme.of(context);
    final timeLeft = _formatDuration(item.timeLeft);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─ Titel + Kategorie
            Row(
              children: [
                Expanded(
                  child: Text(
                    item.amount > 1
                        ? '${item.itemName} ×${item.amount}'
                        : item.itemName,
                    style: theme.textTheme.titleMedium,
                  ),
                ),
                Text(
                  item.category,
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
            const SizedBox(height: 10),

            // ─ Preise
            Row(
              children: [
                // Aktuelles Gebot
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Gebot', style: theme.textTheme.bodySmall),
                    Text(
                      '${item.currentBid.toStringAsFixed(0)} Coins',
                      style: const TextStyle(
                        color:      AppColors.accent,
                        fontWeight: FontWeight.w700,
                        fontSize:   16,
                      ),
                    ),
                  ],
                ),
                if (item.hasBuyNow) ...[
                  const SizedBox(width: 20),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Sofort-Kauf', style: theme.textTheme.bodySmall),
                      Text(
                        '${item.buyNowPrice!.toStringAsFixed(0)} Coins',
                        style: const TextStyle(
                          color:      AppColors.gold,
                          fontWeight: FontWeight.w600,
                          fontSize:   14,
                        ),
                      ),
                    ],
                  ),
                ],
                const Spacer(),
                // Restzeit
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('Restzeit', style: theme.textTheme.bodySmall),
                    Text(
                      timeLeft,
                      style: TextStyle(
                        color: item.isExpired ? AppColors.error : AppColors.darkTextPrimary,
                        fontWeight: FontWeight.w600,
                        fontSize:   13,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            // ─ Enchants (wenn vorhanden)
            if (item.hasEnchants) ...[
              const SizedBox(height: 10),
              Wrap(
                spacing: 6,
                children: item.enchants
                    .take(4)
                    .map((e) => _EnchantChip(label: e))
                    .toList(),
              ),
            ],

            // ─ Verkäufer
            const SizedBox(height: 8),
            Text(
              'von ${item.sellerName}',
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

class _EnchantChip extends StatelessWidget {
  final String label;
  const _EnchantChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color:        Colors.purple.withOpacity(0.15),
        borderRadius: BorderRadius.circular(6),
        border:       Border.all(color: Colors.purple.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color:    Colors.purpleAccent,
          fontSize: 11,
        ),
      ),
      ),
    );
  }
}