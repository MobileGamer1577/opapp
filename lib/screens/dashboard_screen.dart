import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../core/app_colors.dart';
import '../core/app_router.dart';
import '../data/repositories/shard_repository.dart';
import '../data/repositories/auction_repository.dart';
import '../widgets/app_background.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme      = Theme.of(context);
    final shardAsync = ref.watch(shardRateProvider);
    final auctAsync  = ref.watch(auctionsProvider);

    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            children: [

              // ─── Header ────────────────────────────────────
              Row(
                children: [
                  Container(
                    width: 42, height: 42,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.accent, AppColors.accentDark],
                        begin:  Alignment.topLeft,
                        end:    Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.language, color: Colors.white, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'OPSUCHT.NET',
                        style: theme.textTheme.titleLarge?.copyWith(fontSize: 20),
                      ),
                      Text('Companion App', style: theme.textTheme.bodySmall),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 28),

              // ─── Live-Kurs Banner ──────────────────────────
              shardAsync.when(
                data:    (rate) => _RateBanner(rate: rate.displayRate),
                loading: () => const _RateBannerLoading(),
                error:   (_, __) => const SizedBox.shrink(),
              ),
              const SizedBox(height: 28),

              // ─── Auktionen Vorschau ────────────────────────
              auctAsync.when(
                data: (items) {
                  if (items.isEmpty) return const SizedBox.shrink();
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Aktuelle Auktionen',
                              style: theme.textTheme.titleMedium),
                          GestureDetector(
                            onTap: () => context.push(AppRoutes.auctions),
                            child: Text(
                              'Alle anzeigen',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: AppColors.accent,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ...items.take(2).map((item) => _AuctionPreviewTile(
                            name: item.amount > 1
                                ? '${item.itemName} x${item.amount}'
                                : item.itemName,
                            bid:  '${item.currentBid.toStringAsFixed(0)} Coins',
                          )),
                      const SizedBox(height: 24),
                    ],
                  );
                },
                loading: () => const SizedBox.shrink(),
                error:   (_, __) => const SizedBox.shrink(),
              ),

              // ─── Section-Label ─────────────────────────────
              Text('Bereiche', style: theme.textTheme.titleMedium),
              const SizedBox(height: 14),

              // ─── Feature-Karten (Orbit-Stil) ───────────────
              // context.push() statt go() – damit back-Button funktioniert
              _FeatureCard(
                icon:     Icons.storefront,
                color:    AppColors.sectionMarket,
                title:    'Markt',
                subtitle: 'Items • Kauf & Verkauf • Kategorien',
                onTap:    () => context.push(AppRoutes.market),
              ),
              const SizedBox(height: 10),
              _FeatureCard(
                icon:     Icons.gavel,
                color:    AppColors.sectionAuction,
                title:    'Auktionshaus',
                subtitle: 'Live-Auktionen • Enchants • Lore',
                onTap:    () => context.push(AppRoutes.auctions),
              ),
              const SizedBox(height: 10),
              _FeatureCard(
                icon:     Icons.diamond,
                color:    AppColors.sectionShards,
                title:    'OPShards',
                subtitle: 'Aktueller Wechselkurs',
                onTap:    () => context.push(AppRoutes.shards),
              ),
              const SizedBox(height: 10),
              _FeatureCard(
                icon:     Icons.help_rounded,
                color:    AppColors.sectionHelp,
                title:    'Hilfe & Support',
                subtitle: 'Commands • Regelwerk • Restriktionen',
                onTap:    () => context.push(AppRoutes.help),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Rate Banner ─────────────────────────────────────────────
class _RateBanner extends StatelessWidget {
  final String rate;
  const _RateBanner({required this.rate});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color:        Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border:       Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color:        AppColors.sectionShards.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.diamond, color: AppColors.sectionShards, size: 18),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'OPShard Kurs',
                style: TextStyle(color: AppColors.darkTextSecondary, fontSize: 11),
              ),
              Text(
                rate,
                style: const TextStyle(
                  color:      Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize:   15,
                ),
              ),
            ],
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color:        AppColors.success.withOpacity(0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Container(
                  width: 6, height: 6,
                  decoration: const BoxDecoration(
                    color: AppColors.success,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 5),
                const Text(
                  'Live',
                  style: TextStyle(
                    color:      AppColors.success,
                    fontSize:   11,
                    fontWeight: FontWeight.w600,
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

class _RateBannerLoading extends StatelessWidget {
  const _RateBannerLoading();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color:        Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(16),
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

// ─── Auktion Preview Tile ────────────────────────────────────
class _AuctionPreviewTile extends StatelessWidget {
  final String name, bid;
  const _AuctionPreviewTile({required this.name, required this.bid});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: BoxDecoration(
        color:        Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(12),
        border:       Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Row(
        children: [
          const Icon(Icons.gavel, color: AppColors.sectionAuction, size: 16),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              name,
              style: const TextStyle(
                color:      Colors.white,
                fontSize:   13,
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            bid,
            style: const TextStyle(
              color:      AppColors.accent,
              fontWeight: FontWeight.w700,
              fontSize:   13,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Feature Card (Orbit-Stil) ───────────────────────────────
class _FeatureCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title, subtitle;
  final VoidCallback onTap;

  const _FeatureCard({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color:        AppColors.darkCard,
          borderRadius: BorderRadius.circular(20),
          border:       Border.all(color: Colors.white.withOpacity(0.07)),
        ),
        child: Row(
          children: [
            Container(
              width: 52, height: 52,
              decoration: BoxDecoration(
                color:        color.withOpacity(0.18),
                borderRadius: BorderRadius.circular(15),
                border:       Border.all(color: color.withOpacity(0.30)),
              ),
              child: Icon(icon, color: color, size: 26),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color:      Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize:   16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color:   AppColors.darkTextSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.darkTextHint,
              size:  22,
            ),
          ],
        ),
      ),
    );
  }
}
