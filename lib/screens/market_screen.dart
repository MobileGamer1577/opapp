// ═══════════════════════════════════════════════════════════════
//  market_screen.dart – Markt-Screen
//
//  ✅ HIER ÄNDERN: Kartendesign, Filter-Logik
//  ❌ NICHT ÄNDERN: marketProvider / marketCategoriesProvider-Struktur
//
//  ÄNDERUNGEN:
//    - Echte Preise aus /market/prices (BUY = Kaufpreis, SELL = Verkaufspreis)
//    - Item-Icons aus /market/items
//    - Kategorie-Chips jetzt mit echten Kategorien + Icon (/market/categories)
//    - Tap auf Item öffnet Detail-Sheet mit aktiven Angeboten
//      (Preisverlauf folgt später, siehe Markierung in _MarketItemSheet)
// ═══════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/app_colors.dart';
import '../core/app_format.dart';
import '../data/repositories/market_repository.dart';
import '../data/models/market_item.dart';
import '../data/models/market_category.dart';
import '../widgets/app_background.dart';

class MarketScreen extends ConsumerStatefulWidget {
  const MarketScreen({super.key});

  @override
  ConsumerState<MarketScreen> createState() => _MarketScreenState();
}

class _MarketScreenState extends ConsumerState<MarketScreen> {
  final _searchCtrl = TextEditingController();
  String _query     = '';
  String? _category;

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final marketAsync     = ref.watch(marketProvider);
    final categoriesAsync = ref.watch(marketCategoriesProvider);
    final theme = Theme.of(context);

    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(title: const Text('Markt')),
        body: Column(
          children: [
            // ─── Suche ────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: TextField(
                controller: _searchCtrl,
                onChanged:  (v) => setState(() => _query = v),
                decoration: const InputDecoration(
                  hintText:   'Item suchen \u2026',
                  prefixIcon: Icon(Icons.search, size: 20),
                ),
              ),
            ),
            const SizedBox(height: 8),

            // ─── Kategorien (mit Icon aus /market/categories) ──
            categoriesAsync.when(
              data: (categories) => _CategoryBar(
                categories: categories,
                selected:   _category,
                onSelect:   (c) => setState(() => _category = c),
              ),
              loading: () => const SizedBox(height: 44),
              error:   (_, __) => const SizedBox.shrink(),
            ),

            // ─── Liste ────────────────────────────────────────
            Expanded(
              child: marketAsync.when(
                data: (items) {
                  final filtered = items.where((item) {
                    final matchQ = _query.isEmpty ||
                        item.name.toLowerCase().contains(_query.toLowerCase());
                    final matchC = _category == null || item.category == _category;
                    return matchQ && matchC;
                  }).toList();

                  if (filtered.isEmpty) {
                    return Center(
                      child: Text('Keine Items gefunden',
                          style: theme.textTheme.bodyMedium),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () async {
                      ref.invalidate(marketCategoriesProvider);
                      await ref.refresh(marketProvider.future);
                    },
                    child: ListView.separated(
                      padding:          const EdgeInsets.all(16),
                      itemCount:        filtered.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder:      (_, i) => _MarketItemCard(item: filtered[i]),
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
                        onPressed: () => ref.invalidate(marketProvider),
                        child: const Text('Erneut versuchen'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Netzwerk-Icon mit Lade-/Fehler-Fallback ─────────────────
// Wird für Item-Icons UND Kategorie-Icons verwendet.

class _NetworkIcon extends StatelessWidget {
  final String? url;
  final double size;
  final IconData fallback;

  const _NetworkIcon({
    required this.url,
    this.size = 28,
    this.fallback = Icons.inventory_2_outlined,
  });

  @override
  Widget build(BuildContext context) {
    if (url == null || url!.isEmpty) {
      return Icon(fallback, color: AppColors.darkTextHint, size: size * 0.6);
    }
    return Image.network(
      url!,
      width:  size,
      height: size,
      fit:    BoxFit.contain,
      filterQuality: FilterQuality.none, // Pixel-Art bleibt scharf
      errorBuilder: (_, __, ___) =>
          Icon(fallback, color: AppColors.darkTextHint, size: size * 0.6),
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return SizedBox(
          width: size,
          height: size,
          child: Center(
            child: SizedBox(
              width: size * 0.4,
              height: size * 0.4,
              child: const CircularProgressIndicator(
                  strokeWidth: 1.5, color: AppColors.accent),
            ),
          ),
        );
      },
    );
  }
}

// ─── Kategorie-Filter-Leiste ─────────────────────────────────

class _CategoryBar extends StatelessWidget {
  final List<MarketCategory> categories;
  final String? selected;
  final ValueChanged<String?> onSelect;

  const _CategoryBar({
    required this.categories,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection:  Axis.horizontal,
        padding:          const EdgeInsets.symmetric(horizontal: 16),
        itemCount:        categories.length + 1,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          if (i == 0) {
            return FilterChip(
              label:      const Text('Alle'),
              selected:   selected == null,
              onSelected: (_) => onSelect(null),
            );
          }
          final cat = categories[i - 1];
          return FilterChip(
            avatar: _NetworkIcon(
              url:      cat.icon,
              size:     18,
              fallback: Icons.category_outlined,
            ),
            label:      Text(cat.name),
            selected:   selected == cat.name,
            onSelected: (_) => onSelect(selected == cat.name ? null : cat.name),
          );
        },
      ),
    );
  }
}

// ─── Item-Karte ──────────────────────────────────────────────

class _MarketItemCard extends StatelessWidget {
  final MarketItem item;
  const _MarketItemCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Theme.of(context).colorScheme.surface,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          builder: (_) => _MarketItemSheet(item: item),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // ─ Icon ─────────────────────────────────────
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color:        AppColors.accent.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(12),
                  border:       Border.all(color: Colors.white.withOpacity(0.06)),
                ),
                child: Center(child: _NetworkIcon(url: item.icon, size: 28)),
              ),
              const SizedBox(width: 12),

              // ─ Name, Kategorie, Preise ──────────────────
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            item.name,
                            style: theme.textTheme.titleMedium,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color:        AppColors.accent.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            item.category,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: AppColors.accent,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _PriceChip(
                          label: 'Kaufen',
                          price: item.buyPrice,
                          color: AppColors.buyColor,
                        ),
                        const SizedBox(width: 10),
                        _PriceChip(
                          label: 'Verkaufen',
                          price: item.sellPrice,
                          color: AppColors.sellColor,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 4),
              Icon(Icons.chevron_right_rounded,
                  color: theme.textTheme.bodySmall?.color),
            ],
          ),
        ),
      ),
    );
  }
}

class _PriceChip extends StatelessWidget {
  final String label;
  final double price;
  final Color  color;
  const _PriceChip({
    required this.label,
    required this.price,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodySmall),
        Text(
          AppFormat.currency(price, decimals: 2),
          style: TextStyle(
            color:      color,
            fontWeight: FontWeight.w700,
            fontSize:   14,
          ),
        ),
      ],
    );
  }
}

// ─── Detail-Sheet (bei Tap auf ein Item) ─────────────────────

class _MarketItemSheet extends StatelessWidget {
  final MarketItem item;
  const _MarketItemSheet({required this.item});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color:        AppColors.accent.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(14),
                  border:       Border.all(color: AppColors.accent.withOpacity(0.25)),
                ),
                child: Center(child: _NetworkIcon(url: item.icon, size: 36)),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.name, style: theme.textTheme.titleLarge),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color:        AppColors.accent.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        item.category,
                        style: theme.textTheme.bodySmall?.copyWith(color: AppColors.accent),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          _DetailPriceRow(
            label:    'Kaufpreis',
            sublabel: 'Das zahlst du im Markt',
            price:    item.buyPrice,
            orders:   item.buyOrders,
            color:    AppColors.buyColor,
          ),
          const SizedBox(height: 12),
          _DetailPriceRow(
            label:    'Verkaufspreis',
            sublabel: 'Das bekommst du im Markt',
            price:    item.sellPrice,
            orders:   item.sellOrders,
            color:    AppColors.sellColor,
          ),

          // ✅ HIER ÄNDERN: Preisverlauf-Chart hier einfügen,
          // sobald ein entsprechender API-Endpunkt verfügbar ist.
        ],
      ),
    );
  }
}

class _DetailPriceRow extends StatelessWidget {
  final String label, sublabel;
  final double price;
  final int orders;
  final Color color;

  const _DetailPriceRow({
    required this.label,
    required this.sublabel,
    required this.price,
    required this.orders,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color:        color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border:       Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: theme.textTheme.titleMedium?.copyWith(color: color)),
                Text(sublabel, style: theme.textTheme.bodySmall),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                AppFormat.currency(price, decimals: 2),
                style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 18),
              ),
              const SizedBox(height: 2),
              Text(
                '$orders aktive Angebote',
                style: theme.textTheme.bodySmall?.copyWith(color: AppColors.darkTextHint),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
