// ═══════════════════════════════════════════════════════════════
//  mobdex_screen.dart – Mobdex-Tracker für den Jägerjob
//
//  ✅ HIER ÄNDERN: Kartendesign, Texte, Kachelhöhe (_mobTileHeight)
//  ❌ NICHT ÄNDERN: mobdexProvider-Aufrufe (Logik liegt in
//                   mobdex_repository.dart), Mob-Daten (mobdex_data.dart)
//
//  AUFBAU (von oben nach unten):
//    1. Kompakter Kopf: "X / Y" + Prozent + schlanker Balken. Darin
//       (nur wenn nötig) eine Zeile für den 21-Tage-Cooldown bzw. den
//       Hinweis "Cooldown abgelaufen – Mobdex zurückgesetzt".
//    2. Suche
//    3. Status-Umschalter (Alle / Fehlend / Gefangen) + Welt-Chips
//       (Farmwelt / Nether / End)
//    4. Mob-Grid (2 Spalten): Tippen = abhaken, langes Drücken =
//       Details (alle Biome ausgeschrieben)
//
//  Während des Cooldowns sind die Haken gesperrt (siehe Kommentar in
//  mobdex_repository.dart). Über das Symbol in der AppBar lässt sich
//  der Fortschritt komplett zurücksetzen.
//
//  ÄNDERUNGEN (Mobdex-Überarbeitung):
//    - XP-Karte (Jägerjob-XP / 10 Mio.) komplett entfernt.
//    - Fortschritts- und Cooldown-Karte zu EINEM kompakten Kopf
//      zusammengefasst (vorher zwei große Karten).
//    - Mob-Kacheln minimalistisch: Name, rundes Abhak-Symbol, Welt
//      (+ "Custom") und Biome auf max. 2 Zeilen – kein Badge-Wirrwarr
//      mehr, niedrigere Kacheln, ruhigere Abstände.
//    - Status-Filter als Segment-Umschalter statt loser Chips.
//    - Welt-Filter: "Overworld" entfällt, ist identisch mit "Farmwelt".
// ═══════════════════════════════════════════════════════════════

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/app_colors.dart';
import '../core/app_format.dart';
import '../data/mobdex_data.dart';
import '../data/repositories/mobdex_repository.dart';
import '../widgets/app_background.dart';

/// Höhe einer Mob-Kachel im Grid (Name max. 2 Zeilen, Biome max. 2).
const double _mobTileHeight = 128;

enum _MobStatus { all, missing, caught }

class MobdexScreen extends ConsumerStatefulWidget {
  const MobdexScreen({super.key});

  @override
  ConsumerState<MobdexScreen> createState() => _MobdexScreenState();
}

class _MobdexScreenState extends ConsumerState<MobdexScreen> {
  final _searchCtrl = TextEditingController();
  String _query = '';
  _MobStatus _status = _MobStatus.all;
  String? _world; // null = alle Welten

  Timer? _minuteTimer;

  @override
  void initState() {
    super.initState();
    // Minütlich: Cooldown-Anzeige aktualisieren und prüfen, ob der
    // Cooldown abgelaufen ist (dann setzt der Notifier zurück).
    _minuteTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      if (!mounted) return;
      ref.read(mobdexProvider.notifier).checkExpiry();
      setState(() {});
    });
  }

  @override
  void dispose() {
    _minuteTimer?.cancel();
    _searchCtrl.dispose();
    super.dispose();
  }

  List<MobdexMob> _filtered(MobdexState state) {
    final q = _query.trim().toLowerCase();
    return kMobdexMobs.where((m) {
      final caught = state.caught.contains(m.name);
      if (_status == _MobStatus.caught && !caught) return false;
      if (_status == _MobStatus.missing && caught) return false;
      if (_world != null && !m.worlds.contains(_world)) return false;
      if (q.isNotEmpty) {
        final hit = m.name.toLowerCase().contains(q) ||
            m.world.toLowerCase().contains(q) ||
            m.biomes.toLowerCase().contains(q);
        if (!hit) return false;
      }
      return true;
    }).toList();
  }

  void _showSnack(String text) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(text),
          duration: const Duration(seconds: 2),
          backgroundColor: AppColors.darkCardElevated,
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  void _onTapMob(MobdexMob mob) {
    final state = ref.read(mobdexProvider);
    if (state.cooldownActive) {
      _showSnack('Cooldown aktiv – die Haken sind bis zum Ablauf gesperrt.');
      return;
    }
    ref.read(mobdexProvider.notifier).toggle(mob.name);
  }

  void _showDetail(MobdexMob mob, bool caught) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _MobDetailSheet(mob: mob, caught: caught),
    );
  }

  Future<void> _confirmReset() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Fortschritt zurücksetzen?'),
        content: const Text('Alle Haken und der Cooldown werden gelöscht.'),
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
      ref.read(mobdexProvider.notifier).resetAll();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = ref.watch(mobdexProvider);

    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('Mobdex'),
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

  Widget _buildBody(ThemeData theme, MobdexState state) {
    final filtered = _filtered(state);
    final total = state.totalCount;
    final caughtCount = state.caughtCount;
    final missingCount = total - caughtCount;

    return CustomScrollView(
      slivers: [
        // ─── Kompakter Kopf (Fortschritt + Cooldown) ─────────
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
            child: _HeaderCard(
              state: state,
              onDismissNotice: () =>
                  ref.read(mobdexProvider.notifier).dismissResetNotice(),
            ),
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
                    hintText: 'Mob, Welt oder Biom suchen \u2026',
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
                  onSelect: (i) => setState(() => _status = _MobStatus.values[i]),
                ),
                const SizedBox(height: 10),

                // Welt-Filter
                SizedBox(
                  height: 32,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      _WorldChip(
                        label: 'Alle Welten',
                        selected: _world == null,
                        onTap: () => setState(() => _world = null),
                      ),
                      for (final w in kMobdexWorldFilters) ...[
                        const SizedBox(width: 8),
                        _WorldChip(
                          label: w,
                          selected: _world == w,
                          onTap: () =>
                              setState(() => _world = _world == w ? null : w),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  '${filtered.length} Mob${filtered.length == 1 ? '' : 's'}'
                  ' \u00b7 Tippen = abhaken \u00b7 Lang drücken = Details',
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: AppColors.darkTextHint),
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ),

        // ─── Mob-Grid ────────────────────────────────────────
        if (filtered.isEmpty)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 40),
              child: Column(
                children: [
                  const Icon(Icons.search_off,
                      color: AppColors.darkTextHint, size: 36),
                  const SizedBox(height: 10),
                  Text('Kein Mob gefunden', style: theme.textTheme.bodyMedium),
                ],
              ),
            ),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                mainAxisExtent: _mobTileHeight,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, i) {
                  final mob = filtered[i];
                  final caught = state.caught.contains(mob.name);
                  return _MobTile(
                    mob: mob,
                    caught: caught,
                    onTap: () => _onTapMob(mob),
                    onLongPress: () => _showDetail(mob, caught),
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

// ─── Kompakter Kopf: Fortschritt + Cooldown in EINER Karte ────

class _HeaderCard extends StatelessWidget {
  final MobdexState state;
  final VoidCallback onDismissNotice;
  const _HeaderCard({required this.state, required this.onDismissNotice});

  /// "12 Tage 4 Std" / "4 Std 30 Min" / "weniger als 1 Min"
  String _formatRemaining(Duration d) {
    final days = d.inDays;
    final hours = d.inHours.remainder(24);
    final minutes = d.inMinutes.remainder(60);
    if (days > 0) return '$days Tag${days == 1 ? '' : 'e'} $hours Std';
    if (d.inHours > 0) return '${d.inHours} Std $minutes Min';
    if (d.inMinutes > 0) return '${d.inMinutes} Min';
    return 'weniger als 1 Min';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final total = state.totalCount;
    final caught = state.caughtCount;
    final done = state.isComplete;
    final pct = total == 0 ? 0.0 : caught / total;
    final barColor = done ? AppColors.success : AppColors.accent;

    final endsAt = state.cooldownEndsAt;
    final cooling =
        state.cooldownActive && endsAt != null && state.completedAt != null;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: cooling
              ? AppColors.warning.withOpacity(0.30)
              : Colors.white.withOpacity(0.06),
        ),
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
                child: Text('Mobs gefangen', style: theme.textTheme.bodySmall),
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

          // ─ Cooldown-Zeile (nur wenn relevant) ───────────────
          if (state.resetNotice) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(Icons.check_circle_outline_rounded,
                    color: AppColors.success, size: 16),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Cooldown abgelaufen – Mobdex zurückgesetzt.',
                    style: TextStyle(
                      color: AppColors.success,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: onDismissNotice,
                  style: TextButton.styleFrom(
                    minimumSize: Size.zero,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text('OK'),
                ),
              ],
            ),
          ] else if (cooling) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(Icons.hourglass_bottom_rounded,
                    color: AppColors.warning, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Cooldown · noch ${_formatRemaining(endsAt.difference(DateTime.now()))}',
                    style: const TextStyle(
                      color: AppColors.warning,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Padding(
              padding: const EdgeInsets.only(left: 24),
              child: Text(
                'Zurücksetzung: ${AppFormat.dateTime(endsAt)}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.darkTextHint,
                  fontSize: 11,
                ),
              ),
            ),
          ] else if (!done) ...[
            const SizedBox(height: 8),
            Text(
              'Nach Abschluss startet ein Cooldown von '
              '${kMobdexCooldown.inDays} Tagen.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.darkTextHint,
                fontSize: 11,
              ),
            ),
          ],
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

// ─── Welt-Chip (klein, zurückhaltend) ─────────────────────────

class _WorldChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _WorldChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 14),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected
              ? AppColors.accent.withOpacity(0.18)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected
                ? AppColors.accent.withOpacity(0.50)
                : Colors.white.withOpacity(0.10),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color:
                selected ? AppColors.accentLight : AppColors.darkTextSecondary,
            fontSize: 12,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

// ─── Mob-Kachel (minimalistisch, abhakbar) ────────────────────

class _MobTile extends StatelessWidget {
  final MobdexMob mob;
  final bool caught;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  const _MobTile({
    required this.mob,
    required this.caught,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: caught
            ? Color.alphaBlend(
                AppColors.accent.withOpacity(0.10), AppColors.darkCard)
            : AppColors.darkCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: caught
              ? AppColors.accent.withOpacity(0.40)
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
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ─ Name + Abhak-Symbol ──────────────────────
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        mob.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          height: 1.25,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    _CheckDot(checked: caught),
                  ],
                ),
                const SizedBox(height: 4),

                // ─ Welt (+ Custom) ──────────────────────────
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: mob.world,
                        style: const TextStyle(
                          color: AppColors.accentLight,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (mob.isCustom)
                        const TextSpan(
                          text: '  \u00b7  Custom',
                          style: TextStyle(color: AppColors.darkTextSecondary),
                        ),
                    ],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 11),
                ),
                const SizedBox(height: 6),

                // ─ Biome (max. 2 Zeilen, voll im Detail-Sheet) ──
                Expanded(
                  child: Text(
                    mob.biomes,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.darkTextSecondary,
                      fontSize: 11,
                      height: 1.3,
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

// ─── Detail-Sheet (langes Drücken auf eine Mob-Kachel) ────────

class _MobDetailSheet extends StatelessWidget {
  final MobdexMob mob;
  final bool caught;
  const _MobDetailSheet({required this.mob, required this.caught});

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
            Text(mob.name, style: theme.textTheme.titleLarge),
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
                  label: mob.isCustom ? 'Custom-Mob' : 'Vanilla-Mob',
                  color: AppColors.accent,
                ),
              ],
            ),
            const SizedBox(height: 20),
            _DetailLine(
              icon: Icons.public_rounded,
              label: 'Welt',
              value: mob.world,
            ),
            const SizedBox(height: 14),
            _DetailLine(
              icon: Icons.terrain_rounded,
              label: 'Spawn-Biome',
              value: mob.biomes,
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
