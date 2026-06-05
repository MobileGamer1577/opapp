import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/app_colors.dart';
import '../data/repositories/market_repository.dart';
import '../data/models/market_item.dart';

class MarketScreen extends ConsumerStatefulWidget {
  const MarketScreen({super.key});

  @override
  ConsumerState<MarketScreen> createState() => _MarketScreenState();
}

class _MarketScreenState extends ConsumerState<MarketScreen> {
  final _searchCtrl  = TextEditingController();
  String _query      = '';
  String? _category;

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final marketAsync = ref.watch(marketProvider);
    final theme = Theme.of(context);

    return Scaffold(
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
                hintText:    'Item suchen …',
                prefixIcon:  Icon(Icons.search, size: 20),
              ),
            ),
          ),
          const SizedBox(height: 8),

          // ─── Kategorien ────────────────────────────────────
          marketAsync.when(
            data: (items) {
              final categories = items
                  .map((i) => i.category)
                  .toSet()
                  .toList()
                ..sort();
              return _CategoryBar(
                categories: categories,
                selected:   _category,
                onSelect:   (c) => setState(() => _category = c),
              );
            },
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
                  onRefresh: () => ref.refresh(marketProvider.future),
                  child: ListView.separated(
                    padding:     const EdgeInsets.all(16),
                    itemCount:   filtered.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (_, i) => _MarketItemCard(item: filtered[i]),
                  ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error:   (e, _) => Center(
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
    );
  }
}

// ─── Kategorie-Filter-Leiste ─────────────────────────────────

class _CategoryBar extends StatelessWidget {
  final List<String> categories;
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
        scrollDirection: Axis.horizontal,
        padding:         const EdgeInsets.symmetric(horizontal: 16),
        itemCount:       categories.length + 1,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          if (i == 0) {
            return FilterChip(
              label:    const Text('Alle'),
              selected: selected == null,
              onSelected: (_) => onSelect(null),
            );
          }
          final cat = categories[i - 1];
          return FilterChip(
            label:      Text(cat),
            selected:   selected == cat,
            onSelected: (_) => onSelect(selected == cat ? null : cat),
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
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(item.name, style: theme.textTheme.titleMedium),
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
            const SizedBox(height: 10),
            Row(
              children: [
                if (item.buyPrice != null)
                  _PriceChip(
                    label: 'Kaufen',
                    price: item.buyPrice!,
                    color: AppColors.buyColor,
                  ),
                if (item.buyPrice != null && item.sellPrice != null)
                  const SizedBox(width: 8),
                if (item.sellPrice != null)
                  _PriceChip(
                    label: 'Verkaufen',
                    price: item.sellPrice!,
                    color: AppColors.sellColor,
                  ),
                const Spacer(),
                Text(
                  '${item.stock}x',
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PriceChip extends StatelessWidget {
  final String label;
  final double price;
  final Color color;
  const _PriceChip({required this.label, required this.price, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodySmall),
        Text(
          '${price.toStringAsFixed(2)} ¢',
          style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 14),
        ),
      ],
    );
  }
}
