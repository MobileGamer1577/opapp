// ═══════════════════════════════════════════════════════════════
//  market_screen.dart – Markt-Hauptseite
//
//  ✅ HIER ÄNDERN: Kartendesign, Anzahl "Meistgehandelt" (_topItemsCount)
//  ❌ NICHT ÄNDERN: marketProvider / marketCategoriesProvider-Struktur
//
//  AUFBAU (angelehnt an die offizielle OPSUCHT-App, aber im eigenen
//  violetten Dark-Theme):
//    1. Suchleiste – nur ein Tipp-Ziel: öffnet die Markt-Liste mit
//       sofort aktiver Tastatur (AppRoutes.marketListPath(focusSearch))
//    2. "Kategorien" – 2-spaltiges Grid mit Icon + Item-Anzahl,
//       "Alle anzeigen" öffnet die komplette Liste
//    3. "Meistgehandelt" – Top 10 nach Gesamtzahl der Aufträge
//       (BUY.activeOrders + SELL.activeOrders, siehe market_sort.dart)
//
//  Tap auf eine Kategorie → Markt-Liste mit vorgewählter Kategorie.
//  Tap auf ein Item       → Detail-Screen (Vollbild, Preisverlauf).
//
//  ÄNDERUNGEN (Markt-Update – kompletter Umbau):
//    - Vorher: Suche, Kategorie-Chips und Liste in EINEM Screen,
//      Item-Details als Bottom-Sheet. Jetzt: Hauptseite mit Grid,
//      Liste in market_list_screen.dart, Details in
//      market_item_screen.dart.
//    - Kategorie-Anzahl wird aus /market/prices gezählt (die
//      Kategorien-API liefert keine Anzahl).
//    - Die Item-Zeile (_MarketItemCard) ist jetzt das geteilte Widget
//      MarketItemTile (widgets/market_item_tile.dart).
//    - Pull-to-Refresh lädt Preise UND Kategorien neu.
// ═══════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../core/app_colors.dart';
import '../core/app_router.dart';
import '../data/repositories/market_repository.dart';
import '../data/models/market_category.dart';
import '../data/market_sort.dart';
import '../widgets/app_background.dart';
import '../widgets/market_item_tile.dart';
import '../widgets/network_icon.dart';

/// Wie viele Items im Bereich "Meistgehandelt" erscheinen.
const int _topItemsCount = 10;

class MarketScreen extends ConsumerWidget {
  const MarketScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final marketAsync     = ref.watch(marketProvider);
    final categoriesAsync = ref.watch(marketCategoriesProvider);
    final theme = Theme.of(context);

    // Item-Anzahl je Kategorie – null, solange die Preise noch laden.
    final items = marketAsync.value;
    Map<String, int>? counts;
    if (items != null) {
      counts = <String, int>{};
      for (final item in items) {
        counts[item.category] = (counts[item.category] ?? 0) + 1;
      }
    }

    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(title: const Text('Markt')),
        body: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(marketCategoriesProvider);
            try {
              await ref.refresh(marketProvider.future);
            } catch (_) {
              // Fehler wird unten im Screen angezeigt – hier nur
              // verhindern, dass der Refresh-Indikator hängen bleibt.
            }
          },
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              // ─── Suchleiste (öffnet die Liste) ─────────────
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                sliver: SliverToBoxAdapter(
                  child: TextField(
                    readOnly: true,
                    showCursor: false,
                    onTap: () => context
                        .push(AppRoutes.marketListPath(focusSearch: true)),
                    decoration: const InputDecoration(
                      hintText:   'Item suchen \u2026',
                      prefixIcon: Icon(Icons.search, size: 20),
                    ),
                  ),
                ),
              ),

              // ─── Kategorien ────────────────────────────────
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 22, 16, 12),
                sliver: SliverToBoxAdapter(
                  child: _SectionHeader(
                    title:       'Kategorien',
                    actionLabel: 'Alle anzeigen',
                    onAction:    () => context.push(AppRoutes.marketList),
                  ),
                ),
              ),
              categoriesAsync.when<Widget>(
                data: (categories) => SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverGrid(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount:   2,
                      mainAxisSpacing:  10,
                      crossAxisSpacing: 10,
                      mainAxisExtent:   76,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, i) {
                        final category = categories[i];
                        return _CategoryCard(
                          category:  category,
                          itemCount: counts?[category.name],
                          onTap: () => context.push(
                            AppRoutes.marketListPath(category: category.name),
                          ),
                        );
                      },
                      childCount: categories.length,
                    ),
                  ),
                ),
                loading: () => const SliverToBoxAdapter(
                  child: SizedBox(
                    height: 120,
                    child: Center(child: CircularProgressIndicator()),
                  ),
                ),
                // Kategorien nicht verfügbar → Grid weglassen, Suche und
                // "Meistgehandelt" funktionieren trotzdem.
                error: (_, __) => const SliverToBoxAdapter(child: SizedBox.shrink()),
              ),

              // ─── Meistgehandelt ────────────────────────────
              const SliverPadding(
                padding: EdgeInsets.fromLTRB(16, 26, 16, 12),
                sliver: SliverToBoxAdapter(
                  child: _SectionHeader(title: 'Meistgehandelt'),
                ),
              ),
              marketAsync.when<Widget>(
                data: (all) {
                  if (all.isEmpty) {
                    return SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Center(
                          child: Text('Keine Items gefunden',
                              style: theme.textTheme.bodyMedium),
                        ),
                      ),
                    );
                  }
                  final top = sortMarketItems(all, MarketSort.mostOrders)
                      .take(_topItemsCount)
                      .toList();
                  return SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, i) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: MarketItemTile(
                            item: top[i],
                            onTap: () => context.push(
                              AppRoutes.marketItemPath(top[i].material),
                            ),
                          ),
                        ),
                        childCount: top.length,
                      ),
                    ),
                  );
                },
                loading: () => const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 32),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                ),
                error: (e, _) => SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        const Icon(Icons.cloud_off,
                            color: AppColors.error, size: 40),
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
      ),
    );
  }
}

// ─── Abschnitts-Überschrift (optional mit Aktions-Pille) ─────

class _SectionHeader extends StatelessWidget {
  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;
  const _SectionHeader({
    required this.title,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(title, style: Theme.of(context).textTheme.titleLarge),
        ),
        if (actionLabel != null && onAction != null)
          InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: onAction,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                color:        AppColors.accent.withOpacity(0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    actionLabel!,
                    style: const TextStyle(
                      color:      AppColors.accentLight,
                      fontSize:   13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 2),
                  const Icon(Icons.chevron_right_rounded,
                      color: AppColors.accentLight, size: 18),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

// ─── Kategorie-Karte (Icon + Name + Item-Anzahl) ─────────────

class _CategoryCard extends StatelessWidget {
  final MarketCategory category;
  final int? itemCount;
  final VoidCallback onTap;
  const _CategoryCard({
    required this.category,
    required this.itemCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final count = itemCount;

    return Container(
      decoration: BoxDecoration(
        color:        AppColors.darkCard,
        borderRadius: BorderRadius.circular(16),
        border:       Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color:        AppColors.accent.withOpacity(0.10),
                    borderRadius: BorderRadius.circular(12),
                    border:       Border.all(color: AppColors.accent.withOpacity(0.18)),
                  ),
                  child: Center(
                    child: NetworkIcon(
                      url:      category.icon,
                      size:     30,
                      fallback: Icons.category_outlined,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        category.name,
                        style: theme.textTheme.titleMedium,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        count == null
                            ? '\u2026'
                            : '${formatCount(count)} Item${count == 1 ? '' : 's'}',
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
