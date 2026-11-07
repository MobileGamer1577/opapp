// ═══════════════════════════════════════════════════════════════
//  fish_log_screen.dart – Fischerei-Logbuch für den Fischerjob
//
//  ✅ HIER ÄNDERN: Zeilendesign, Texte, Abstände (_FishRow),
//                  Seltenheits-Farben (_rarityColor)
//  ❌ NICHT ÄNDERN: fishLogProvider-Aufrufe (Logik liegt in
//                   fish_repository.dart), Fisch-Daten (fish_data.dart)
//
//  AUFBAU (von oben nach unten, bewusst identisch zum Mobdex):
//    1. Kompakter Kopf: "X / Y" + Prozent + schlanker Balken
//    2. Suche (Fisch, Biomgruppe oder Seltenheit)
//    3. Status-Umschalter (Alle / Fehlend / Gefangen)
//       + Biomgruppen-Chips (End, Flüsse, … – 8 Gruppen)
//       + Seltenheits-Chips (Häufig … Sensation)
//    4. Fisch-Liste (flache Zeilen): Tippen = abhaken, langes Drücken =
//       Details (Biomgruppe, Seltenheit, Job-XP je Fang)
//
//  Kein Cooldown (anders als der Mobdex) – siehe fish_repository.dart.
//  Über das Symbol in der AppBar lässt sich der Fortschritt komplett
//  zurücksetzen.
//
//  ÄNDERUNGEN (Fischerei-Logbuch-Update):
//    - NEU: Datei. Die kleinen Hilfs-Widgets (_SegmentBar, _FilterChip,
//      _CheckDot, _Tag, _DetailLine) sind bewusst als private Kopien
//      aus mobdex_screen.dart übernommen, damit der Mobdex unangetastet
//      bleibt.
//    - Seltenheits-Farben nutzen ausschließlich vorhandene AppColors
//      (Häufig = silver, Episch = accentLight, Legendär = sectionAuction,
//      Spektakulär = sectionHelp, Sensation = gold).
// ═══════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/app_colors.dart';
import '../core/app_format.dart';
import '../data/fish_data.dart';
import '../data/repositories/fish_repository.dart';
import '../widgets/app_background.dart';

enum _FishStatus { all, missing, caught }

/// ✅ HIER ÄNDERN: Farbe je Seltenheit (nur vorhandene AppColors nutzen).
Color _rarityColor(FishRarity rarity) {
  switch (rarity) {
    case FishRarity.common:
      return AppColors.silver;
    case FishRarity.epic:
      return AppColors.accentLight;
    case FishRarity.legendary:
      return AppColors.sectionAuction;
    case FishRarity.spectacular:
      return AppColors.sectionHelp;
    case FishRarity.sensation:
      return AppColors.gold;
  }
}

class FishLogScreen extends ConsumerStatefulWidget {
  const FishLogScreen({super.key});

  @override
  ConsumerState<FishLogScreen> createState() => _FishLogScreenState();
}

class _FishLogScreenState extends ConsumerState<FishLogScreen> {
  final _searchCtrl = TextEditingController();
  String _query = '';
  _FishStatus _status = _FishStatus.all;
  String? _biome; // null = alle Biomgruppen
  FishRarity? _rarity; // null = alle Seltenheiten

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<FishSpecies> _filtered(FishLogState state) {
    final q = _query.trim().toLowerCase();
    return kFishSpecies.where((f) {
      final caught = state.caught.contains(f.name);
      if (_status == _FishStatus.caught && !caught) return false;
      if (_status == _FishStatus.missing && caught) return false;
      if (_biome != null && f.biomeGroup != _biome) return false;
      if (_rarity != null && f.rarity != _rarity) return false;
      if (q.isNotEmpty) {
        final hit = f.name.toLowerCase().contains(q) ||
            f.biomeGroup.toLowerCase().contains(q) ||
            f.rarity.label.toLowerCase().contains(q);
        if (!hit) return false;
      }
      return true;
    }).toList();
  }

  void _onTapFish(FishSpecies fish) {
    ref.read(fishLogProvider.notifier).toggle(fish.name);
  }

  void _showDetail(FishSpecies fish, bool caught) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _FishDetailSheet(fish: fish, caught: caught),
    );
  }

  Future<void> _confirmReset() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Fortschritt zurücksetzen?'),
        content: const Text('Alle Haken im Fischerei-Logbuch werden gelöscht.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Abbrechen'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text(
              'Zurücksetzen',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
    if (ok == true && mounted) {
      ref.read(fishLogProvider.notifier).resetAll();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = ref.watch(fishLogProvider);

    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('Fischerei-Logbuch'),
          actions: [
            IconButton(
              icon: const Icon(Icons.restart_alt_rounded),
              tooltip: 'Fortschritt zurücksetzen',
              onPressed: state.loaded ? _confirmReset : null,
            ),
          ],
        ),
        body: !state.loaded
            ? const Center(child: CircularProgressIndicator())
            : _buildBody(theme, state),
      ),
    );
  }

  Widget _buildBody(ThemeData theme, FishLogState state) {
    final filtered = _filtered(state);
    final total = state.totalCount;
    final caughtCount = state.caughtCount;
    final missingCount = total - caughtCount;

    return CustomScrollView(
      slivers: [
        // ─── Kompakter Kopf (Fortschritt) ────────────────────
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
            child: _HeaderCard(state: state),
          ),
        ),

        // ─── Suche + Filter ──────────────────────────────────
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _searchCtrl,
                  onChanged: (v) => setState(() => _query = v),
                  decoration: InputDecoration(
                    hintText: 'Fisch, Biomgruppe oder Seltenheit \u2026',
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
                const SizedBox(height: 10),

                // Status-Umschalter (Segment)
                _SegmentBar(
                  labels: [
                    'Alle ($total)',
                    'Fehlend ($missingCount)',
                    'Gefangen ($caughtCount)',
                  ],
                  selected: _status.index,
                  onSelect: (i) =>
                      setState(() => _status = _FishStatus.values[i]),
                ),
                const SizedBox(height: 10),

                // Biomgruppen-Filter
                SizedBox(
                  height: 32,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      _FilterChip(
                        label: 'Alle Biome',
                        selected: _biome == null,
                        onTap: () => setState(() => _biome = null),
                      ),
                      for (final g in kFishBiomeGroups) ...[
                        const SizedBox(width: 8),
                        _FilterChip(
                          label: g,
                          selected: _biome == g,
                          onTap: () =>
                              setState(() => _biome = _biome == g ? null : g),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 8),

                // Seltenheits-Filter
                SizedBox(
                  height: 32,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      _FilterChip(
                        label: 'Alle Seltenheiten',
                        selected: _rarity == null,
                        onTap: () => setState(() => _rarity = null),
                      ),
                      for (final r in FishRarity.values) ...[
                        const SizedBox(width: 8),
                        _FilterChip(
                          label: r.label,
                          selected: _rarity == r,
                          color: _rarityColor(r),
                          onTap: () =>
                              setState(() => _rarity = _rarity == r ? null : r),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  '${filtered.length} Fisch${filtered.length == 1 ? '' : 'e'}'
                  ' \u00b7 Tippen = abhaken \u00b7 Lang drücken = Details',
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: AppColors.darkTextHint),
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ),

        // ─── Fisch-Liste (flache Zeilen) ─────────────────────
        if (filtered.isEmpty)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 40),
              child: Column(
                children: [
                  const Icon(Icons.search_off,
                      color: AppColors.darkTextHint, size: 36),
                  const SizedBox(height: 10),
                  Text('Kein Fisch gefunden', style: theme.textTheme.bodyMedium),
                ],
              ),
            ),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, i) {
                  final fish = filtered[i];
                  final caught = state.caught.contains(fish.name);
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: _FishRow(
                      fish: fish,
                      caught: caught,
                      onTap: () => _onTapFish(fish),
                      onLongPress: () => _showDetail(fish, caught),
                    ),
                  );
                },
                childCount: filtered.length,
              ),
            ),
          ),
      ],
    );
  }
}

// ─── Kompakter Kopf: Fortschritt ──────────────────────────────

class _HeaderCard extends StatelessWidget {
  final FishLogState state;
  const _HeaderCard({required this.state});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final total = state.totalCount;
    final caught = state.caughtCount;
    final done = state.isComplete;
    final pct = total == 0 ? 0.0 : caught / total;
    final barColor = done ? AppColors.success : AppColors.accent;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ─ Zahl + Label + Prozent ───────────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '$caught',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 24,
                ),
              ),
              Text(
                ' / $total',
                style: const TextStyle(
                  color: AppColors.darkTextSecondary,
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text('Fische gefangen', style: theme.textTheme.bodySmall),
              ),
              Text(
                '${(pct * 100).round()} %',
                style: TextStyle(
                  color: barColor,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // ─ Schlanker Balken ─────────────────────────────────
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: pct.clamp(0.0, 1.0),
              minHeight: 5,
              color: barColor,
              backgroundColor: Colors.white.withOpacity(0.07),
            ),
          ),

          // ─ Hinweiszeile ─────────────────────────────────────
          const SizedBox(height: 8),
          if (done)
            const Row(
              children: [
                Icon(Icons.check_circle_outline_rounded,
                    color: AppColors.success, size: 16),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Logbuch vollständig – alle Fische gefangen!',
                    style: TextStyle(
                      color: AppColors.success,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            )
          else
            Text(
              'Dein Ingame-Logbuch öffnest du mit /logbuch.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.darkTextHint,
                fontSize: 11,
              ),
            ),
        ],
      ),
    );
  }
}

// ─── Status-Umschalter (Segment-Leiste) ───────────────────────

class _SegmentBar extends StatelessWidget {
  final List<String> labels;
  final int selected;
  final ValueChanged<int> onSelect;
  const _SegmentBar({
    required this.labels,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Row(
        children: [
          for (int i = 0; i < labels.length; i++)
            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => onSelect(i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 160),
                  padding: const EdgeInsets.symmetric(vertical: 9),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: i == selected
                        ? AppColors.accent.withOpacity(0.20)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: Text(
                    labels[i],
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: i == selected
                          ? AppColors.accentLight
                          : AppColors.darkTextSecondary,
                      fontSize: 12,
                      fontWeight:
                          i == selected ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ─── Filter-Chip (klein, zurückhaltend) ───────────────────────
// [color] = optionale Akzentfarbe im gewählten Zustand (Seltenheiten);
// ohne Angabe gilt der normale Akzent (wie _WorldChip im Mobdex).

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final Color? color;
  final VoidCallback onTap;
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final accent = color ?? AppColors.accent;
    final textColor = selected
        ? (color ?? AppColors.accentLight)
        : AppColors.darkTextSecondary;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 14),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? accent.withOpacity(0.18) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected
                ? accent.withOpacity(0.50)
                : Colors.white.withOpacity(0.10),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: textColor,
            fontSize: 12,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

// ─── Fisch-Zeile (flach, abhakbar) ────────────────────────────

class _FishRow extends StatelessWidget {
  final FishSpecies fish;
  final bool caught;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  const _FishRow({
    required this.fish,
    required this.caught,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final rarityColor = _rarityColor(fish.rarity);

    return Container(
      decoration: BoxDecoration(
        color: caught
            ? Color.alphaBlend(
                AppColors.accent.withOpacity(0.08), AppColors.darkCard)
            : AppColors.darkCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: caught
              ? AppColors.accent.withOpacity(0.35)
              : Colors.white.withOpacity(0.05),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          onLongPress: onLongPress,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
            child: Row(
              children: [
                _CheckDot(checked: caught),
                const SizedBox(width: 12),

                // ─ Name + Biomgruppe ───────────────────────────
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        fish.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        fish.biomeGroup,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.accentLight,
                          fontWeight: FontWeight.w600,
                          fontSize: 11.5,
                        ),
                      ),
                    ],
                  ),
                ),

                // ─ Seltenheits-Label (dezent) ───────────────
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: rarityColor.withOpacity(0.45)),
                  ),
                  child: Text(
                    fish.rarity.label.toUpperCase(),
                    style: TextStyle(
                      color: rarityColor,
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                    ),
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

/// Rundes Abhak-Symbol: leerer Ring → gefüllter Kreis mit Haken.
class _CheckDot extends StatelessWidget {
  final bool checked;
  const _CheckDot({required this.checked});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: checked ? AppColors.accent : Colors.transparent,
        border: Border.all(
          color: checked ? AppColors.accent : Colors.white.withOpacity(0.20),
          width: 1.5,
        ),
      ),
      child: checked
          ? const Icon(Icons.check_rounded, color: Colors.white, size: 15)
          : null,
    );
  }
}

// ─── Detail-Sheet (langes Drücken auf eine Fisch-Zeile) ──────

class _FishDetailSheet extends StatelessWidget {
  final FishSpecies fish;
  final bool caught;
  const _FishDetailSheet({required this.fish, required this.caught});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final statusColor = caught ? AppColors.success : AppColors.darkTextSecondary;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
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
            Text(fish.name, style: theme.textTheme.titleLarge),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: [
                _Tag(
                  label: caught ? 'Gefangen' : 'Noch fehlend',
                  color: statusColor,
                ),
                _Tag(
                  label: fish.rarity.label,
                  color: _rarityColor(fish.rarity),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _DetailLine(
              icon: Icons.terrain_rounded,
              label: 'Biomgruppe',
              value: fish.biomeGroup,
            ),
            const SizedBox(height: 14),
            _DetailLine(
              icon: Icons.star_rounded,
              label: 'Job-XP je Fang',
              value:
                  '${AppFormat.number(fish.rarity.xp.toDouble(), decimals: 0)} XP',
            ),
          ],
        ),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  final String label;
  final Color color;
  const _Tag({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.14),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.30)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _DetailLine extends StatelessWidget {
  final IconData icon;
  final String label, value;
  const _DetailLine({
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
              const SizedBox(height: 2),
              Text(value, style: theme.textTheme.bodyLarge),
            ],
          ),
        ),
      ],
    );
  }
}
