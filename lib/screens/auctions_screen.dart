// ═══════════════════════════════════════════════════════════════
//  auctions_screen.dart – Auktionshaus-Screen
//
//  ✅ HIER ÄNDERN: Kartendesign, angezeigte Felder
//  ❌ NICHT ÄNDERN: playerNameProvider-Aufruf in _AuctionCard
//
//  AUKTIONSHAUS-UPDATE:
//    - Suche nach Item-Namen
//    - Zweistufiger Kategorie-Filter (Top-Level-Gruppen in Reihe 1,
//      Unterkategorien der gewählten Gruppe in Reihe 2 – siehe
//      buildAuctionCategoryGroups() in auction_category.dart)
//    - Tap auf eine Karte öffnet ein Detail-Sheet mit Verkäufer,
//      Start-/Endzeit (Datum + Uhrzeit), Lore, Startpreis,
//      Sofort-Kauf-Preis und einem live tickenden Countdown
// ═══════════════════════════════════════════════════════════════

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/app_colors.dart';
import '../core/app_format.dart';
import '../data/repositories/auction_repository.dart';
import '../data/repositories/player_name_repository.dart';
import '../data/models/auction_item.dart';
import '../data/models/auction_category.dart';
import '../core/api_constants.dart';
import '../widgets/app_background.dart';
import '../widgets/network_icon.dart';

class AuctionsScreen extends ConsumerStatefulWidget {
  const AuctionsScreen({super.key});

  @override
  ConsumerState<AuctionsScreen> createState() => _AuctionsScreenState();
}

class _AuctionsScreenState extends ConsumerState<AuctionsScreen> {
  final _searchCtrl = TextEditingController();
  String _query = '';

  // "name" der gewählten Top-Kategorie, z.B. "parent_armor" oder "custom_items"
  String? _selectedTopCategory;
  // "name" der gewählten Unterkategorie, z.B. "sub_helmets"
  // (nur relevant, wenn die Top-Kategorie eine Gruppe mit Kindern ist)
  String? _selectedSubCategory;

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _onSelectTop(String? top) {
    setState(() {
      _selectedTopCategory = top;
      _selectedSubCategory = null; // beim Wechsel der Gruppe zurücksetzen
    });
  }

  void _onSelectSub(String? sub) {
    setState(() => _selectedSubCategory = sub);
  }

  /// Prüft ob ein Auktions-Item zur aktuellen Filter-Auswahl passt.
  ///   - Keine Top-Kategorie gewählt           → alles passt
  ///   - Unterkategorie gewählt                → exakter Treffer
  ///   - Nur Top-Kategorie (= Gruppe) gewählt  → Treffer auf JEDE
  ///     Unterkategorie dieser Gruppe (z.B. "Rüstungen" zeigt Helme,
  ///     Brustplatten, Beinschutz, Stiefel UND Aufwertungen)
  ///   - Nur Top-Kategorie (= eigenständig, z.B. "custom_items")
  ///     → exakter Treffer
  bool _matchesCategory(AuctionItem item, List<AuctionCategoryGroup> groups) {
    if (_selectedTopCategory == null) return true;
    if (_selectedSubCategory != null) {
      return item.category == _selectedSubCategory;
    }

    AuctionCategoryGroup? group;
    for (final g in groups) {
      if (g.category.name == _selectedTopCategory) {
        group = g;
        break;
      }
    }
    if (group == null || !group.hasChildren) {
      return item.category == _selectedTopCategory;
    }
    return item.category == _selectedTopCategory ||
        group.children.any((c) => c.name == item.category);
  }

  @override
  Widget build(BuildContext context) {
    final auctAsync       = ref.watch(auctionsProvider);
    final categoriesAsync = ref.watch(auctionCategoriesProvider);
    final theme = Theme.of(context);

    // Lookup: Kategorie-Schlüssel → AuctionCategory (Anzeigename + Icon)
    final categories = categoriesAsync.value ?? const <AuctionCategory>[];
    final categoryMap = {for (final c in categories) c.name: c};
    final groups = buildAuctionCategoryGroups(categories);

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
                    width: 8,
                    height: 8,
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
            // ─── Suche ──────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: TextField(
                controller: _searchCtrl,
                onChanged: (v) => setState(() => _query = v),
                decoration: InputDecoration(
                  hintText: 'Item suchen \u2026',
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
            const SizedBox(height: 10),

            // ─── Kategorie-Filter (zweistufig) ──────────────
            categoriesAsync.when(
              data: (cats) => _CategoryFilterBar(
                groups:      buildAuctionCategoryGroups(cats),
                selectedTop: _selectedTopCategory,
                selectedSub: _selectedSubCategory,
                onSelectTop: _onSelectTop,
                onSelectSub: _onSelectSub,
              ),
              loading: () => const SizedBox(height: 44),
              error:   (_, __) => const SizedBox.shrink(),
            ),
            const SizedBox(height: 10),

            // ─── Refresh-Info-Banner ───────────────────────
            Container(
              width: double.infinity,
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
                  final filtered = items.where((item) {
                    final matchQ = _query.isEmpty ||
                        item.itemName.toLowerCase().contains(_query.toLowerCase());
                    final matchC = _matchesCategory(item, groups);
                    return matchQ && matchC;
                  }).toList();

                  if (filtered.isEmpty) {
                    return Center(
                      child: Text(
                        'Keine Auktionen gefunden',
                        style: theme.textTheme.bodyMedium,
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () =>
                        ref.read(auctionsProvider.notifier).refresh(),
                    child: ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: filtered.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (_, i) {
                        final auction = filtered[i];
                        return _AuctionCard(
                          item: auction,
                          categoryLabel:
                              categoryMap[auction.category]?.displayName ??
                                  auction.category,
                        );
                      },
                    ),
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.cloud_off,
                          color: AppColors.error, size: 40),
                      const SizedBox(height: 12),
                      Text(e.toString(), style: theme.textTheme.bodyMedium),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: () =>
                            ref.read(auctionsProvider.notifier).refresh(),
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

// ─── Kategorie-Filter-Leiste (zweistufig) ────────────────────

class _CategoryFilterBar extends StatelessWidget {
  final List<AuctionCategoryGroup> groups;
  final String? selectedTop;
  final String? selectedSub;
  final ValueChanged<String?> onSelectTop;
  final ValueChanged<String?> onSelectSub;

  const _CategoryFilterBar({
    required this.groups,
    required this.selectedTop,
    required this.selectedSub,
    required this.onSelectTop,
    required this.onSelectSub,
  });

  @override
  Widget build(BuildContext context) {
    AuctionCategoryGroup? selectedGroup;
    for (final g in groups) {
      if (g.category.name == selectedTop) {
        selectedGroup = g;
        break;
      }
    }

    return Column(
      children: [
        // ── Reihe 1: Top-Level-Gruppen ─────────────────────
        SizedBox(
          height: 44,
          child: ListView.separated(
            scrollDirection:  Axis.horizontal,
            padding:          const EdgeInsets.symmetric(horizontal: 16),
            itemCount:        groups.length + 1,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (_, i) {
              if (i == 0) {
                return FilterChip(
                  label:      const Text('Alle'),
                  selected:   selectedTop == null,
                  onSelected: (_) => onSelectTop(null),
                );
              }
              final group = groups[i - 1];
              return FilterChip(
                avatar: NetworkIcon(
                  url:      group.category.icon,
                  size:     18,
                  fallback: Icons.category_outlined,
                ),
                label:      Text(group.category.displayName),
                selected:   selectedTop == group.category.name,
                onSelected: (_) => onSelectTop(
                  selectedTop == group.category.name ? null : group.category.name,
                ),
              );
            },
          ),
        ),

        // ── Reihe 2: Unterkategorien (nur bei Gruppen mit Kindern) ──
        if (selectedGroup != null && selectedGroup.hasChildren) ...[
          const SizedBox(height: 8),
          SizedBox(
            height: 36,
            child: ListView.separated(
              scrollDirection:  Axis.horizontal,
              padding:          const EdgeInsets.symmetric(horizontal: 16),
              itemCount:        selectedGroup.children.length + 1,
              separatorBuilder: (_, __) => const SizedBox(width: 6),
              itemBuilder: (_, i) {
                if (i == 0) {
                  return _SubChip(
                    label:    'Alle',
                    selected: selectedSub == null,
                    onTap:    () => onSelectSub(null),
                  );
                }
                final child = selectedGroup!.children[i - 1];
                return _SubChip(
                  label:    child.displayName,
                  selected: selectedSub == child.name,
                  onTap:    () => onSelectSub(
                    selectedSub == child.name ? null : child.name,
                  ),
                );
              },
            ),
          ),
        ],
      ],
    );
  }
}

class _SubChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _SubChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.accent.withOpacity(0.20)
              : AppColors.darkCard,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: selected
                ? AppColors.accent.withOpacity(0.50)
                : Colors.white.withOpacity(0.07),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? AppColors.accentLight : AppColors.darkTextSecondary,
            fontSize: 12,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}

// ─── Auktions-Karte ──────────────────────────────────────────
// ConsumerWidget wegen playerNameProvider

class _AuctionCard extends ConsumerWidget {
  final AuctionItem item;
  final String categoryLabel;
  const _AuctionCard({required this.item, required this.categoryLabel});

  /// Formatiert die verbleibende Zeit – kurz, für die Listen-Karte.
  /// null = Endzeit unbekannt.
  String _formatDuration(Duration? d) {
    if (d == null) return 'Unbekannt';
    if (d.isNegative) return 'Abgelaufen';
    if (d.inHours > 0) return '${d.inHours}h ${d.inMinutes.remainder(60)}m';
    return '${d.inMinutes}m ${d.inSeconds.remainder(60)}s';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme    = Theme.of(context);
    final timeLeft = _formatDuration(item.timeLeft);

    // UUID → Spielername (aus 7-Tage-Cache oder mc-api.io)
    final nameAsync = ref.watch(playerNameProvider(item.sellerId));
    final sellerDisplay = nameAsync.when(
      data:    (name) => name,
      loading: () => 'Lädt\u2026',
      error:   (_, __) => 'Unbekannt',
    );

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
          builder: (_) => _AuctionDetailSheet(
            item:          item,
            categoryLabel: categoryLabel,
          ),
        ),
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
                          ? '${item.itemName} \u00d7${item.amount}'
                          : item.itemName,
                      style: theme.textTheme.titleMedium,
                    ),
                  ),
                  Text(
                    categoryLabel,
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
                        AppFormat.currency(item.currentBid),
                        style: const TextStyle(
                          color: AppColors.accent,
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
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
                          AppFormat.currency(item.buyNowPrice!),
                          style: const TextStyle(
                            color: AppColors.gold,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
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
                          color: item.isExpired
                              ? AppColors.error
                              : AppColors.darkTextPrimary,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
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

              // ─ Verkäufer (Klarname statt UUID) + Tap-Hinweis
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'von $sellerDisplay',
                      style: theme.textTheme.bodySmall,
                    ),
                  ),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: theme.textTheme.bodySmall?.color,
                    size: 18,
                  ),
                ],
              ),
            ],
          ),
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
        color: Colors.purple.withOpacity(0.15),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.purple.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.purpleAccent,
          fontSize: 11,
        ),
      ),
    );
  }
}

// ─── Detail-Sheet (bei Tap auf eine Auktion) ─────────────────

class _AuctionDetailSheet extends ConsumerWidget {
  final AuctionItem item;
  final String categoryLabel;
  const _AuctionDetailSheet({
    required this.item,
    required this.categoryLabel,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    final nameAsync = ref.watch(playerNameProvider(item.sellerId));
    final sellerDisplay = nameAsync.when(
      data:    (name) => name,
      loading: () => 'Lädt\u2026',
      error:   (_, __) => 'Unbekannt',
    );

    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag-Handle (visueller Hinweis: Inhalt ist scrollbar)
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 18),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // ─ Titel ───────────────────────────────────────
            Text(
              item.amount > 1
                  ? '${item.itemName} \u00d7${item.amount}'
                  : item.itemName,
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.accent.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                categoryLabel,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.accent,
                ),
              ),
            ),
            const SizedBox(height: 22),

            // ─ Verkäufer ───────────────────────────────────
            _DetailRow(
              icon:  Icons.person_outline,
              label: 'Verkäufer',
              value: sellerDisplay,
            ),
            const SizedBox(height: 14),

            // ─ Startzeit ───────────────────────────────────
            _DetailRow(
              icon:  Icons.play_circle_outline,
              label: 'Gestartet',
              value: item.startTime != null
                  ? AppFormat.dateTime(item.startTime!.toLocal())
                  : 'Unbekannt',
            ),
            const SizedBox(height: 14),

            // ─ Endzeit + Countdown ─────────────────────────
            _DetailRow(
              icon:  Icons.event_outlined,
              label: 'Endet',
              value: item.endsAt != null
                  ? AppFormat.dateTime(item.endsAt!.toLocal())
                  : 'Unbekannt',
            ),
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.only(left: 32),
              child: Row(
                children: [
                  const Icon(Icons.timer_outlined,
                      size: 14, color: AppColors.darkTextHint),
                  const SizedBox(width: 6),
                  _CountdownText(endsAt: item.endsAt),
                ],
              ),
            ),
            const SizedBox(height: 22),

            // ─ Preise ──────────────────────────────────────
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _PriceBox(
                    label: 'Startpreis',
                    price: item.startBid,
                    color: AppColors.darkTextSecondary,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _PriceBox(
                    label: 'Gebot',
                    price: item.currentBid,
                    color: AppColors.accent,
                  ),
                ),
                if (item.hasBuyNow) ...[
                  const SizedBox(width: 8),
                  Expanded(
                    child: _PriceBox(
                      label: 'Sofort-Kauf',
                      price: item.buyNowPrice!,
                      color: AppColors.gold,
                    ),
                  ),
                ],
              ],
            ),

            // ─ Verzauberungen ──────────────────────────────
            if (item.hasEnchants) ...[
              const SizedBox(height: 22),
              Text('Verzauberungen', style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),
              Wrap(
                spacing:   6,
                runSpacing: 6,
                children: item.enchants
                    .map((e) => _EnchantChip(label: e))
                    .toList(),
              ),
            ],

            // ─ Lore / Beschreibung ─────────────────────────
            if (item.hasLore) ...[
              const SizedBox(height: 22),
              Text('Beschreibung', style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.darkCard,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.white.withOpacity(0.06)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: item.lore
                      .map((line) => Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Text(line, style: theme.textTheme.bodyMedium),
                          ))
                      .toList(),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ─── Detail-Zeile (Icon + Label + Wert) ──────────────────────

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label, value;
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppColors.darkTextSecondary, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: theme.textTheme.bodySmall),
              Text(value, style: theme.textTheme.bodyLarge),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── Preis-Box (für das Detail-Sheet) ────────────────────────

class _PriceBox extends StatelessWidget {
  final String label;
  final double price;
  final Color color;
  const _PriceBox({
    required this.label,
    required this.price,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: theme.textTheme.bodySmall),
          const SizedBox(height: 4),
          Text(
            AppFormat.currency(price),
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w700,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Live-Countdown (tickt jede Sekunde) ─────────────────────

class _CountdownText extends StatefulWidget {
  final DateTime? endsAt;
  const _CountdownText({required this.endsAt});

  @override
  State<_CountdownText> createState() => _CountdownTextState();
}

class _CountdownTextState extends State<_CountdownText> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final endsAt = widget.endsAt;
    if (endsAt == null) {
      return const Text(
        'Unbekannt',
        style: TextStyle(color: AppColors.darkTextSecondary, fontSize: 13),
      );
    }

    final remaining = endsAt.difference(DateTime.now());
    final isExpired = remaining.isNegative;

    return Text(
      isExpired ? 'Auktion beendet' : _formatCountdown(remaining),
      style: TextStyle(
        color: isExpired ? AppColors.error : AppColors.success,
        fontWeight: FontWeight.w700,
        fontSize: 13,
      ),
    );
  }
}

/// Formatiert die Restzeit ausführlich (inkl. Tage), z.B. "2T 3Std 14Min"
String _formatCountdown(Duration d) {
  final days    = d.inDays;
  final hours   = d.inHours.remainder(24);
  final minutes = d.inMinutes.remainder(60);
  final seconds = d.inSeconds.remainder(60);

  if (days > 0) return '${days}T ${hours}Std ${minutes}Min';
  if (hours > 0) return '${hours}Std ${minutes}Min ${seconds}Sek';
  return '${minutes}Min ${seconds}Sek';
}
