import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/routing/app_router.dart';
import '../../../data/repositories/shard_repository.dart';
import '../../../data/repositories/auction_repository.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme      = Theme.of(context);
    final shardAsync = ref.watch(shardRateProvider);
    final auctAsync  = ref.watch(auctionsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('OPSUCHT.NET'),
        actions: [
          // Theme Toggle
          IconButton(
            icon: const Icon(Icons.brightness_6_outlined),
            onPressed: () => ref.read(themeModeProvider.notifier).toggle(),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [

          // ─── Begrüßung ──────────────────────────────────
          Text(
            'Dashboard',
            style: theme.textTheme.headlineMedium,
          ),
          const SizedBox(height: 4),
          Text(
            'Deine OPSUCHT.NET Übersicht',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),

          // ─── OPShard Kurs Karte ─────────────────────────
          _SectionLabel(label: 'OPShard Kurs'),
          const SizedBox(height: 8),
          shardAsync.when(
            data: (rate) => _ShardRateCard(rate: rate.displayRate),
            loading: () => const _LoadingCard(height: 80),
            error: (e, _) => _ErrorCard(message: e.toString()),
          ),
          const SizedBox(height: 20),

          // ─── Auktionen Vorschau ─────────────────────────
          _SectionLabel(
            label: 'Aktuelle Auktionen',
            trailing: TextButton(
              onPressed: () => context.go(AppRoutes.auctions),
              child: const Text('Alle anzeigen'),
            ),
          ),
          const SizedBox(height: 8),
          auctAsync.when(
            data: (items) {
              if (items.isEmpty) return const _EmptyCard(text: 'Keine Auktionen');
              return Column(
                children: items
                    .take(3)
                    .map((item) => _PreviewTile(
                          title:    item.itemName,
                          subtitle: '${item.currentBid.toStringAsFixed(0)} Coins',
                          icon:     Icons.gavel,
                        ))
                    .toList(),
              );
            },
            loading: () => const _LoadingCard(height: 140),
            error:   (e, _) => _ErrorCard(message: e.toString()),
          ),
          const SizedBox(height: 20),

          // ─── Quick-Links ────────────────────────────────
          _SectionLabel(label: 'Schnellzugriff'),
          const SizedBox(height: 8),
          Row(
            children: [
              _QuickLink(
                label: 'Markt',
                icon:  Icons.storefront_outlined,
                onTap: () => context.go(AppRoutes.market),
              ),
              const SizedBox(width: 12),
              _QuickLink(
                label: 'Hilfe',
                icon:  Icons.help_outline,
                onTap: () => context.go(AppRoutes.help),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Hilfswidgets ────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String label;
  final Widget? trailing;
  const _SectionLabel({required this.label, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: Theme.of(context).textTheme.titleMedium),
        if (trailing != null) trailing!,
      ],
    );
  }
}

class _ShardRateCard extends StatelessWidget {
  final String rate;
  const _ShardRateCard({required this.rate});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.diamond, color: AppColors.accent),
            const SizedBox(width: 12),
            Text(rate, style: Theme.of(context).textTheme.titleMedium),
          ],
        ),
      ),
    );
  }
}

class _PreviewTile extends StatelessWidget {
  final String title, subtitle;
  final IconData icon;
  const _PreviewTile({required this.title, required this.subtitle, required this.icon});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Card(
        child: ListTile(
          leading: Icon(icon, color: AppColors.accent, size: 20),
          title:   Text(title, style: theme.textTheme.bodyLarge),
          trailing: Text(
            subtitle,
            style: theme.textTheme.bodyMedium?.copyWith(
              color:      AppColors.accent,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

class _QuickLink extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  const _QuickLink({required this.label, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        child: InkWell(
          onTap:        onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              children: [
                Icon(icon, color: AppColors.accent),
                const SizedBox(height: 8),
                Text(label, style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LoadingCard extends StatelessWidget {
  final double height;
  const _LoadingCard({required this.height});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: const Center(child: CircularProgressIndicator()),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  final String message;
  const _ErrorCard({required this.message});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            const Icon(Icons.error_outline, color: AppColors.error, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Text(message, style: Theme.of(context).textTheme.bodySmall),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyCard extends StatelessWidget {
  final String text;
  const _EmptyCard({required this.text});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: Text(text, style: Theme.of(context).textTheme.bodyMedium),
        ),
      ),
    );
  }
}
