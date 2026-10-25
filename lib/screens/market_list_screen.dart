// ═══════════════════════════════════════════════════════════════
//  market_list_screen.dart – Markt-Liste (alle Items)
//
//  ✅ HIER ÄNDERN: Kartendesign (Item-Zeile selbst: market_item_tile.dart)
//  ❌ NICHT ÄNDERN: marketProvider / marketCategoriesProvider-Aufrufe,
//                   Sortier-Logik (liegt in data/market_sort.dart)
//
//  Erreichbar von der Markt-Hauptseite über:
//    - Tipp auf die Suchleiste        → ?focus=1 (Tastatur sofort aktiv)
//    - Tipp auf eine Kategorie-Karte  → ?category=<Name> (vorgewählt)
//    - "Alle anzeigen"                → ohne Parameter
//
//  FUNKTIONEN:
//    - Suche (Deutsch/Englisch, siehe search_translations.dart)
//    - Kategorie-Chips (Auswahl wirkt lokal, ohne neue Navigation)
//    - Sortieren über das Symbol neben der Suche (Bottom-Sheet),
//      Standard "Meiste Aufträge" (BUY + SELL activeOrders)
//    - Tap auf ein Item → Detail-Screen (Vollbild)
// ═══════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../core/app_colors.dart';
import '../core/app_router.dart';
import '../data/repositories/market_repository.dart';
import '../data/models/market_item.dart';
import '../data/models/market_category.dart';
import '../data/market_sort.dart';
import '../data/search_translations.dart';
import '../widgets/app_background.dart';
import '../widgets/market_item_tile.dart';
import '../widgets/network_icon.dart';

class MarketListScreen extends ConsumerStatefulWidget {
  /// Vorausgewählte Kategorie (Name wie in /market/categories).
  final String? initialCategory;

  /// true → Suchfeld wird beim Öffnen fokussiert.
  final bool autofocusSearch;

  const MarketListScreen({
    super.key,
    this.initialCategory,
    this.autofocusSearch = false,
  });

  @override
  ConsumerState<MarketListScreen> createState() => _MarketListScreenState();
}

class _MarketListScreenState extends ConsumerState<MarketListScreen> {
  final _searchCtrl = TextEditingController();
  String _query = '';
  String? _category;
  MarketSort _sort = MarketSort.mostOrders;

  @override
  void initState() {
    super.initState();
    _category = widget.initialCategory;
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  /// Prüft ob ein Markt-Item auf den Suchbegriff passt – direkter
  /// Treffer gegen den (englischen) Anzeigenamen ODER die deutsch/
  /// englisch-Erweiterung gegen Name UND Material.
  bool _matchesQuery(MarketItem item) {
    if (_query.isEmpty) return true;
    if (matchesWithTranslation(_query, item.name)) return true;
    if (matchesWithTranslation(_query, item.material)) return true;
    return false;
  }

  void _openSortSheet() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _SortSheet(
        selected: _sort,
        onSelect: (sort) => setState(() => _sort = sort),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final marketAsync     = ref.watch(marketProvider);
    final categoriesAsync = ref.watch(marketCategoriesProvider);
    final theme = Theme.of(context);

    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(title: Text(_category ?? 'Alle Items')),
        body: Column(
          children: [
            // ─── Suche + Sortier-Button ─────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchCtrl,
                      autofocus:  widget.autofocusSearch,
                      onChanged:  (v) => setState(() => _query = v),
                      decoration: InputDecoration(
                        hintText:   'Item suchen \u2026',
                        prefixIcon: const Icon(Icons.search, size: 20),
                        suffixIcon: _query.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.close, size: 18),
                                onPressed: () {
                                  _searchCtrl.clear();
                                  setState(() => _query = '');
                                },
                              )
                            : null,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  _SortButton(
                    highlighted: _sort != MarketSort.mostOrders,
                    onTap: _openSortSheet,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // ─── Kategorie-Chips ────────────────────────────
            categoriesAsync.when(
              data: (categories) => _CategoryBar(
                categories: categories,
                selected:   _category,
                onSelect:   (c) => setState(() => _category = c),
              ),
              loading: () => const SizedBox(height: 44),
              error:   (_, __) => const SizedBox.shrink(),
            ),

            // ─── Liste ──────────────────────────────────────
            Expanded(
              child: marketAsync.when(
                data: (items) {
                  final filtered = items.where((item) {
                    final matchQ = _matchesQuery(item);
                    final matchC = _category == null || item.category == _category;
                    return matchQ && matchC;
                  }).toList();
                  final sorted = sortMarketItems(filtered, _sort);

                  if (sorted.isEmpty) {
                    return Center(
                      child: Text('Keine Items gefunden',
                          style: theme.textTheme.bodyMedium),
                    );
                  }

                  return Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            '${formatCount(sorted.length)} Items \u00b7 ${_sort.label}',
                            style: theme.textTheme.bodySmall,
                          ),
                        ),
                      ),
                      Expanded(
                        child: RefreshIndicator(
                          onRefresh: () async {
                            ref.invalidate(marketCategoriesProvider);
                            try {
                              await ref.refresh(marketProvider.future);
                            } catch (_) {}
                          },
                          child: ListView.separated(
                            padding:          const EdgeInsets.all(16),
                            itemCount:        sorted.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 8),
                            itemBuilder: (_, i) => MarketItemTile(
                              item: sorted[i],
                              onTap: () => context.push(
                                AppRoutes.marketItemPath(sorted[i].material),
                              ),
                            ),
                          ),
                        ),
                      ),
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

// ─── Sortier-Button (neben der Suche) ────────────────────────
// highlighted = true, sobald NICHT mehr die Standard-Sortierung
// aktiv ist – so sieht man auf einen Blick, dass sortiert wird.

class _SortButton extends StatelessWidget {
  final bool highlighted;
  final VoidCallback onTap;
  const _SortButton({required this.highlighted, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'Sortieren',
      child: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          color: highlighted
              ? AppColors.accent.withOpacity(0.18)
              : AppColors.darkCard,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: highlighted ? AppColors.accent : AppColors.darkBorder,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            child: Icon(
              Icons.sort_rounded,
              color: highlighted
                  ? AppColors.accentLight
                  : AppColors.darkTextSecondary,
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Sortier-Bottom-Sheet ────────────────────────────────────

class _SortSheet extends StatelessWidget {
  final MarketSort selected;
  final ValueChanged<MarketSort> onSelect;
  const _SortSheet({required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag-Handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Text('Sortieren', style: theme.textTheme.titleLarge),
            const SizedBox(height: 6),
            for (final sort in MarketSort.values)
              InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: () {
                  onSelect(sort);
                  Navigator.of(context).pop();
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          sort.label,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: sort == selected
                                ? AppColors.accentLight
                                : AppColors.darkTextPrimary,
                            fontWeight: sort == selected
                                ? FontWeight.w700
                                : FontWeight.w500,
                          ),
                        ),
                      ),
                      if (sort == selected)
                        const Icon(Icons.check_rounded,
                            color: AppColors.accent, size: 22),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
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
            avatar: NetworkIcon(
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
