// ═══════════════════════════════════════════════════════════════
//  item_database_screen.dart – Item-Datenbank (BETA)
//
//  ✅ HIER ÄNDERN: Zeilendesign (_ItemTile), Detail-Sheet-Inhalt,
//                  Texte, Bildhöhe (_loreImageMaxHeight)
//  ❌ NICHT ÄNDERN: catalogItemsProvider-Aufruf (Logik liegt in
//                   catalog_repository.dart)
//
//  AUFBAU:
//    - AppBar mit BETA-Badge + TabBar (Neu / Suche)
//    - Hinweis-Banner: Datenbank ist im Aufbau, Daten können sich
//      ändern oder wieder entfernt werden
//    - Tab "Neu":   nur die Items des neuesten Import-Tages (lokale
//      Zeitzone), Uhrzeit absteigend. Kontroll-Ansicht für neue
//      Imports – daher steht rechts je Zeile die Uhrzeit.
//    - Tab "Suche": EINE Suchleiste über Item-Name, Kategorie und
//      Kollektion. Mehrere Wörter müssen ALLE irgendwo vorkommen
//      (z.B. "schwert waffen"). Bindestriche zählen wie Leerzeichen.
//      Ohne Suchbegriff: gesamter Katalog, alphabetisch.
//    - Tap auf ein Item → Detail-Sheet: Titel, Lore-Bild (Ladeindikator
//      + Fallback), Verzauberungen, Minecraft-ID, Kategorie,
//      Kollektion, Hinzugefügt am, Preis.
//
//  Beide Tabs teilen sich einen Ladevorgang (catalogItemsProvider),
//  Pull-to-Refresh lädt neu. Keine Verkaufsstatistiken (Vorgabe).
//
//  ÄNDERUNGEN (Item-Datenbank-Update):
//    - NEU: Datei.
//    - Preise laufen über AppFormat.currencyAuto() und beachten damit
//      die Einstellung "Zahlenformat". Fehlt der Preis (null), steht
//      "Kein Preis vorhanden" da.
// ═══════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/app_colors.dart';
import '../core/app_format.dart';
import '../data/models/catalog_item.dart';
import '../data/repositories/catalog_repository.dart';
import '../data/repositories/number_format_repository.dart';
import '../widgets/app_background.dart';
import '../widgets/beta_badge.dart';

/// Maximale Höhe des Lore-Bildes im Detail-Sheet.
const double _loreImageMaxHeight = 320;

/// Lädt die Datenbank neu (Pull-to-Refresh). Fehler werden hier nur
/// geschluckt, damit der Indikator nicht hängen bleibt – der Fehler
/// selbst wird im Screen angezeigt.
Future<void> _refresh(WidgetRef ref) async {
  try {
    await ref.refresh(catalogItemsProvider.future);
  } catch (_) {}
}

class ItemDatabaseScreen extends ConsumerWidget {
  const ItemDatabaseScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itemsAsync = ref.watch(catalogItemsProvider);
    final theme = Theme.of(context);

    return AppBackground(
      child: DefaultTabController(
        length: 2,
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            title: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(child: Text('Item-Datenbank')),
                SizedBox(width: 10),
                BetaBadge(),
              ],
            ),
            bottom: TabBar(
              indicatorColor: AppColors.accent,
              labelColor: AppColors.accentLight,
              unselectedLabelColor: AppColors.darkTextSecondary,
              dividerColor: Colors.white.withOpacity(0.06),
              labelStyle:
                  const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
              tabs: const [
                Tab(text: 'Neu'),
                Tab(text: 'Suche'),
              ],
            ),
          ),
          body: Column(
            children: [
              const _BetaInfoBanner(),
              Expanded(
                child: itemsAsync.when(
                  data: (items) => TabBarView(
                    children: [
                      _NewTab(items: items),
                      _SearchTab(items: items),
                    ],
                  ),
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.cloud_off,
                              color: AppColors.error, size: 40),
                          const SizedBox(height: 12),
                          Text(
                            e.toString(),
                            style: theme.textTheme.bodyMedium,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 12),
                          ElevatedButton(
                            onPressed: () =>
                                ref.invalidate(catalogItemsProvider),
                            child: const Text('Erneut versuchen'),
                          ),
                        ],
                      ),
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

// ─── BETA-Hinweis-Banner ──────────────────────────────────────

class _BetaInfoBanner extends StatelessWidget {
  const _BetaInfoBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 10, 16, 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.warning.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.warning.withOpacity(0.30)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.construction_rounded,
              color: AppColors.warning, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'BETA – Die Datenbank ist noch im Aufbau. Daten können sich '
              'ändern oder wieder entfernt werden.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.warning,
                    fontSize: 11.5,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Tab "Neu" ────────────────────────────────────────────────

class _NewTab extends ConsumerWidget {
  final List<CatalogItem> items;
  const _NewTab({required this.items});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final latest = itemsOfLatestImportDay(items);

    return RefreshIndicator(
      onRefresh: () => _refresh(ref),
      child: latest.isEmpty
          ? ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: const [
                _EmptyHint(
                  icon: Icons.inbox_outlined,
                  text: 'Noch keine Items importiert',
                ),
              ],
            )
          : ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              // Index 0 = Kopfzeile, danach die Items.
              itemCount: latest.length + 1,
              itemBuilder: (_, i) {
                if (i == 0) {
                  final day = latest.first.createdAt!;
                  return Padding(
                    padding: const EdgeInsets.only(left: 4, bottom: 10),
                    child: Text(
                      'Import vom ${AppFormat.date(day)}'
                      ' \u00b7 ${latest.length} Item${latest.length == 1 ? '' : 's'}',
                      style: theme.textTheme.bodySmall,
                    ),
                  );
                }
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _ItemTile(item: latest[i - 1], showTime: true),
                );
              },
            ),
    );
  }
}

// ─── Tab "Suche" ──────────────────────────────────────────────

class _SearchTab extends ConsumerStatefulWidget {
  final List<CatalogItem> items;
  const _SearchTab({required this.items});

  @override
  ConsumerState<_SearchTab> createState() => _SearchTabState();
}

class _SearchTabState extends ConsumerState<_SearchTab> {
  final _searchCtrl = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  /// Bindestriche wie Leerzeichen, alles klein – "Mob-Cap" == "mob cap".
  String _norm(String s) => s.toLowerCase().replaceAll('-', ' ');

  /// Filtert über Name + Kategorie + Kollektion gleichzeitig.
  /// Jedes eingegebene Wort muss irgendwo in diesen drei Feldern
  /// vorkommen. Ergebnis alphabetisch nach Name.
  List<CatalogItem> _filtered() {
    final tokens = _norm(_query.trim())
        .split(RegExp(r'\s+'))
        .where((t) => t.isNotEmpty)
        .toList();

    final result = tokens.isEmpty
        ? [...widget.items]
        : widget.items.where((item) {
            final haystack = _norm(
              '${item.name} ${item.categoryName ?? ''} ${item.collectionName ?? ''}',
            );
            return tokens.every((t) => haystack.contains(t));
          }).toList();

    result.sort(
      (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
    );
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final filtered = _filtered();

    return Column(
      children: [
        // ─── Suchleiste ────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: TextField(
            controller: _searchCtrl,
            onChanged: (v) => setState(() => _query = v),
            decoration: InputDecoration(
              hintText: 'Item, Kategorie oder Kollektion \u2026',
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
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 6),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              '${filtered.length} Item${filtered.length == 1 ? '' : 's'}',
              style: theme.textTheme.bodySmall,
            ),
          ),
        ),

        // ─── Liste ─────────────────────────────────────────
        Expanded(
          child: RefreshIndicator(
            onRefresh: () => _refresh(ref),
            child: filtered.isEmpty
                ? ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: const [
                      _EmptyHint(
                        icon: Icons.search_off,
                        text: 'Kein Item gefunden',
                      ),
                    ],
                  )
                : ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                    itemCount: filtered.length,
                    itemBuilder: (_, i) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: _ItemTile(item: filtered[i]),
                    ),
                  ),
          ),
        ),
      ],
    );
  }
}

// ─── Leer-Hinweis ─────────────────────────────────────────────

class _EmptyHint extends StatelessWidget {
  final IconData icon;
  final String text;
  const _EmptyHint({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 60),
      child: Column(
        children: [
          Icon(icon, color: AppColors.darkTextHint, size: 36),
          const SizedBox(height: 10),
          Text(text, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}

// ─── Item-Zeile (kompakt) ─────────────────────────────────────
// Name, darunter dezent Kategorie · Kollektion (nur wenn vorhanden).
// [showTime] = Uhrzeit rechts (Tab "Neu").

class _ItemTile extends StatelessWidget {
  final CatalogItem item;
  final bool showTime;
  const _ItemTile({required this.item, this.showTime = false});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final subParts = <String>[
      if (item.categoryName != null) item.categoryName!,
      if (item.collectionName != null) item.collectionName!,
    ];

    return Container(
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showItemSheet(context, item),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name,
                        style: theme.textTheme.titleMedium,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (subParts.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          subParts.join(' \u00b7 '),
                          style: theme.textTheme.bodySmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                if (showTime && item.createdAt != null) ...[
                  const SizedBox(width: 8),
                  Text(
                    AppFormat.time(item.createdAt!),
                    style: theme.textTheme.bodySmall
                        ?.copyWith(color: AppColors.darkTextHint),
                  ),
                ],
                const SizedBox(width: 4),
                const Icon(Icons.chevron_right_rounded,
                    color: AppColors.darkTextHint, size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Detail-Sheet ─────────────────────────────────────────────

void _showItemSheet(BuildContext context, CatalogItem item) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Theme.of(context).colorScheme.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => _ItemDetailSheet(item: item),
  );
}

class _ItemDetailSheet extends ConsumerWidget {
  final CatalogItem item;
  const _ItemDetailSheet({required this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final formatMode = ref.watch(numberFormatProvider);

    final price = item.price;
    final priceText = price == null
        ? 'Kein Preis vorhanden'
        : AppFormat.currencyAuto(price.toDouble(), mode: formatMode);

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
            // Drag-Handle
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

            // ─ Titel ────────────────────────────────────────
            Text(item.name, style: theme.textTheme.titleLarge),
            const SizedBox(height: 16),

            // ─ Lore-Bild ────────────────────────────────────
            _LoreImage(url: item.loreImageUrl),
            const SizedBox(height: 22),

            // ─ Verzauberungen ───────────────────────────────
            Text('Verzauberungen', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            if (item.enchantments.isEmpty)
              Text(
                'Keine Verzauberungen',
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: AppColors.darkTextHint),
              )
            else
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: item.enchantments
                    .map((e) => _EnchantChip(label: e))
                    .toList(),
              ),
            const SizedBox(height: 22),

            // ─ Stammdaten ───────────────────────────────────
            _DetailRow(
              icon: Icons.tag_rounded,
              label: 'Minecraft Item-ID',
              value: item.minecraftId.isEmpty ? 'Unbekannt' : item.minecraftId,
            ),
            const SizedBox(height: 14),
            _DetailRow(
              icon: Icons.category_outlined,
              label: 'Kategorie',
              value: item.categoryName ?? 'Unbekannt',
            ),
            const SizedBox(height: 14),
            _DetailRow(
              icon: Icons.collections_bookmark_outlined,
              label: 'Kollektion',
              value: item.collectionName ?? 'Keine',
            ),
            const SizedBox(height: 14),
            _DetailRow(
              icon: Icons.event_available_outlined,
              label: 'Hinzugefügt am',
              value: item.createdAt != null
                  ? AppFormat.dateTime(item.createdAt!)
                  : 'Unbekannt',
            ),
            const SizedBox(height: 14),
            _DetailRow(
              icon: Icons.sell_outlined,
              label: 'Preis',
              value: priceText,
              valueColor:
                  price == null ? AppColors.darkTextHint : AppColors.gold,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Lore-Bild (Ladeindikator + Fallback) ─────────────────────

class _LoreImage extends StatelessWidget {
  final String? url;
  const _LoreImage({required this.url});

  Widget _fallback(BuildContext context, IconData icon, String text) {
    return Container(
      width: double.infinity,
      height: 110,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppColors.darkTextHint, size: 28),
          const SizedBox(height: 8),
          Text(text, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final u = url;
    if (u == null || u.isEmpty) {
      return _fallback(
          context, Icons.image_not_supported_outlined, 'Kein Lore-Bild vorhanden');
    }

    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxHeight: _loreImageMaxHeight),
      alignment: Alignment.center,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Image.network(
        u,
        fit: BoxFit.contain,
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          final total = progress.expectedTotalBytes;
          return SizedBox(
            height: 140,
            child: Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.accent,
                  value: total != null
                      ? progress.cumulativeBytesLoaded / total
                      : null,
                ),
              ),
            ),
          );
        },
        errorBuilder: (context, _, __) => _fallback(
          context,
          Icons.broken_image_outlined,
          'Bild konnte nicht geladen werden',
        ),
      ),
    );
  }
}

// ─── Verzauberungs-Tag ────────────────────────────────────────

class _EnchantChip extends StatelessWidget {
  final String label;
  const _EnchantChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.purple.withOpacity(0.15),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.purple.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: const TextStyle(color: Colors.purpleAccent, fontSize: 12),
      ),
    );
  }
}

// ─── Detail-Zeile (Icon + Label + Wert) ───────────────────────

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label, value;
  final Color? valueColor;
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
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
              const SizedBox(height: 2),
              Text(
                value,
                style: theme.textTheme.bodyLarge?.copyWith(color: valueColor),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
