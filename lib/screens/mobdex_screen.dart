// ═══════════════════════════════════════════════════════════════
//  mobdex_screen.dart – Mobdex-Tracker für den Jägerjob
//
//  ✅ HIER ÄNDERN: Kartendesign, Texte, Kachelhöhe (_mobCardHeight)
//  ❌ NICHT ÄNDERN: mobdexProvider-Aufrufe (Logik liegt in
//                   mobdex_repository.dart), Mob-Daten (mobdex_data.dart)
//
//  AUFBAU (von oben nach unten):
//    1. Fortschrittskarte: X / Y Mobs gefangen + Balken
//    2. Cooldown-Karte: 21 Tage nach vollständigem Abschluss. Läuft
//       automatisch an, sobald der letzte Mob abgehakt wird; danach
//       werden alle Haken automatisch zurückgesetzt.
//    3. XP-Karte: Eingabefeld für die aktuelle Jägerjob-XP mit
//       Fortschrittsbalken zum Meilenstein (10 Mio. XP)
//    4. Suche + Filter: Status (Alle / Fehlend / Gefangen) und Welt
//    5. Mob-Grid (2 Spalten): Tippen = abhaken, langes Drücken =
//       Details (alle Biome ausgeschrieben)
//
//  Während des Cooldowns sind die Haken gesperrt (siehe Kommentar in
//  mobdex_repository.dart). Über das Symbol in der AppBar lässt sich
//  der Fortschritt komplett zurücksetzen (XP bleiben).
//
//  ÄNDERUNGEN (Mobdex-Update):
//    - NEU: Screen. Erreichbar über "Tools & Hilfe" (AppRoutes.mobdex).
// ═══════════════════════════════════════════════════════════════

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/app_colors.dart';
import '../core/app_format.dart';
import '../data/mobdex_data.dart';
import '../data/repositories/mobdex_repository.dart';
import '../widgets/app_background.dart';

/// Höhe einer Mob-Kachel im Grid (Name max. 2 Zeilen, Biome max. 4).
const double _mobCardHeight = 184;

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
        content: const Text(
          'Alle Haken und der Cooldown werden gelöscht. '
          'Deine Jägerjob-XP bleiben erhalten.',
        ),
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
        // ─── Fortschritt, Cooldown, XP ───────────────────────
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Column(
              children: [
                _ProgressCard(state: state),
                const SizedBox(height: 12),
                _CooldownCard(
                  state: state,
                  onDismissNotice: () =>
                      ref.read(mobdexProvider.notifier).dismissResetNotice(),
                ),
                const SizedBox(height: 12),
                // initialXp wird nur beim ersten Aufbau gelesen (der
                // Screen zeigt die Karte erst nach dem Laden).
                _XpCard(initialXp: state.hunterXp),
              ],
            ),
          ),
        ),

        // ─── Suche + Filter ──────────────────────────────────
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 18, 16, 0),
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

                // Status-Filter
                SizedBox(
                  height: 40,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      _FilterPill(
                        label: 'Alle ($total)',
                        selected: _status == _MobStatus.all,
                        onTap: () => setState(() => _status = _MobStatus.all),
                      ),
                      const SizedBox(width: 8),
                      _FilterPill(
                        label: 'Fehlend ($missingCount)',
                        selected: _status == _MobStatus.missing,
                        onTap: () =>
                            setState(() => _status = _MobStatus.missing),
                      ),
                      const SizedBox(width: 8),
                      _FilterPill(
                        label: 'Gefangen ($caughtCount)',
                        selected: _status == _MobStatus.caught,
                        onTap: () =>
                            setState(() => _status = _MobStatus.caught),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),

                // Welt-Filter
                SizedBox(
                  height: 40,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      _FilterPill(
                        label: 'Alle Welten',
                        selected: _world == null,
                        onTap: () => setState(() => _world = null),
                      ),
                      for (final w in kMobdexWorldFilters) ...[
                        const SizedBox(width: 8),
                        _FilterPill(
                          label: w,
                          selected: _world == w,
                          onTap: () =>
                              setState(() => _world = _world == w ? null : w),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  '${filtered.length} Mob${filtered.length == 1 ? '' : 's'}'
                  ' \u00b7 Tippen zum Abhaken, lang drücken für Details',
                  style: theme.textTheme.bodySmall,
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
                mainAxisExtent: _mobCardHeight,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, i) {
                  final mob = filtered[i];
                  final caught = state.caught.contains(mob.name);
                  return _MobCard(
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

// ─── Karten-Rahmen (gleicher Stil wie in appearance_screen.dart) ──

class _CardShell extends StatelessWidget {
  final Widget child;
  final Color? borderColor;
  final Color? fillColor;
  const _CardShell({required this.child, this.borderColor, this.fillColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: fillColor ?? AppColors.darkCard,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderColor ?? Colors.white.withOpacity(0.06)),
      ),
      child: child,
    );
  }
}

/// Runder Icon-Kasten links in den Info-Karten.
class _IconBox extends StatelessWidget {
  final IconData icon;
  final Color color;
  const _IconBox({required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: color.withOpacity(0.14),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, color: color, size: 22),
    );
  }
}

/// Abgerundeter Fortschrittsbalken.
class _Bar extends StatelessWidget {
  final double value;
  final Color color;
  const _Bar({required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: LinearProgressIndicator(
        value: value.clamp(0.0, 1.0),
        minHeight: 8,
        color: color,
        backgroundColor: Colors.white.withOpacity(0.07),
      ),
    );
  }
}

// ─── 1. Fortschrittskarte ─────────────────────────────────────

class _ProgressCard extends StatelessWidget {
  final MobdexState state;
  const _ProgressCard({required this.state});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final total = state.totalCount;
    final caught = state.caughtCount;
    final done = state.isComplete;
    final color = done ? AppColors.success : AppColors.accent;
    final pct = total == 0 ? 0.0 : caught / total;

    return _CardShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _IconBox(icon: Icons.pets_rounded, color: color),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Mobdex-Fortschritt', style: theme.textTheme.bodySmall),
                    const SizedBox(height: 2),
                    Text('$caught / $total Mobs gefangen',
                        style: theme.textTheme.titleMedium),
                  ],
                ),
              ),
              Text(
                '${(pct * 100).round()} %',
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _Bar(value: pct, color: color),
          if (done) ...[
            const SizedBox(height: 10),
            const Text(
              'Mobdex vollständig abgeschlossen!',
              style: TextStyle(
                color: AppColors.success,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ─── 2. Cooldown-Karte ────────────────────────────────────────

class _CooldownCard extends StatelessWidget {
  final MobdexState state;
  final VoidCallback onDismissNotice;
  const _CooldownCard({required this.state, required this.onDismissNotice});

  /// "12 Tage 4 Std 30 Min" / "4 Std 30 Min" / "weniger als 1 Min"
  String _formatRemaining(Duration d) {
    final days = d.inDays;
    final hours = d.inHours.remainder(24);
    final minutes = d.inMinutes.remainder(60);
    if (days > 0) {
      return '$days Tag${days == 1 ? '' : 'e'} $hours Std $minutes Min';
    }
    if (d.inHours > 0) return '${d.inHours} Std $minutes Min';
    if (d.inMinutes > 0) return '${d.inMinutes} Min';
    return 'weniger als 1 Min';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final days = kMobdexCooldown.inDays;

    // ── Zustand A: Cooldown gerade abgelaufen, Mobdex zurückgesetzt ──
    if (state.resetNotice) {
      return _CardShell(
        borderColor: AppColors.success.withOpacity(0.35),
        child: Row(
          children: [
            const _IconBox(
                icon: Icons.check_circle_outline_rounded,
                color: AppColors.success),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Cooldown', style: theme.textTheme.bodySmall),
                  const SizedBox(height: 2),
                  const Text(
                    'Cooldown abgelaufen – Mobdex wurde zurückgesetzt.',
                    style: TextStyle(
                      color: AppColors.success,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            TextButton(onPressed: onDismissNotice, child: const Text('OK')),
          ],
        ),
      );
    }

    // ── Zustand B: Cooldown läuft ──
    final endsAt = state.cooldownEndsAt;
    final completedAt = state.completedAt;
    if (state.cooldownActive && endsAt != null && completedAt != null) {
      final remaining = endsAt.difference(DateTime.now());
      final total = kMobdexCooldown.inSeconds;
      final elapsed = DateTime.now().difference(completedAt).inSeconds;
      final progress = total == 0 ? 1.0 : elapsed / total;

      return _CardShell(
        borderColor: AppColors.warning.withOpacity(0.35),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const _IconBox(
                    icon: Icons.hourglass_bottom_rounded,
                    color: AppColors.warning),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Cooldown aktiv ($days Tage)',
                          style: theme.textTheme.bodySmall),
                      const SizedBox(height: 2),
                      Text(
                        'Noch ${_formatRemaining(remaining)}',
                        style: const TextStyle(
                          color: AppColors.warning,
                          fontWeight: FontWeight.w700,
                          fontSize: 17,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            _Bar(value: progress, color: AppColors.warning),
            const SizedBox(height: 10),
            Text(
              'Abgeschlossen: ${AppFormat.dateTime(completedAt)}',
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: AppColors.darkTextHint),
            ),
            Text(
              'Zurücksetzung: ${AppFormat.dateTime(endsAt)}',
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: AppColors.darkTextHint),
            ),
          ],
        ),
      );
    }

    // ── Zustand C: noch nicht vollständig ──
    return _CardShell(
      child: Row(
        children: [
          const _IconBox(
              icon: Icons.hourglass_empty_rounded,
              color: AppColors.darkTextSecondary),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Cooldown', style: theme.textTheme.bodySmall),
                const SizedBox(height: 2),
                Text('Startet nach Abschluss',
                    style: theme.textTheme.titleMedium),
                const SizedBox(height: 2),
                Text(
                  'Sobald der letzte Mob abgehakt ist, läuft ein Cooldown von '
                  '$days Tagen. Danach wird der Mobdex zurückgesetzt.',
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: AppColors.darkTextHint),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── 3. XP-Karte (Meilenstein) ────────────────────────────────

class _XpCard extends ConsumerStatefulWidget {
  /// Startwert für das Eingabefeld (nur beim ersten Aufbau relevant).
  final int initialXp;
  const _XpCard({required this.initialXp});

  @override
  ConsumerState<_XpCard> createState() => _XpCardState();
}

class _XpCardState extends ConsumerState<_XpCard> {
  late final TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(
      text: widget.initialXp > 0
          ? AppFormat.number(widget.initialXp.toDouble(), decimals: 0)
          : '',
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  /// Liest die Eingabe tolerant: Punkte/Leerzeichen werden ignoriert
  /// ("2.500.000" == "2500000"). Maximal 12 Stellen.
  int _parseXp(String raw) {
    final digits = raw.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) return 0;
    if (digits.length > 12) return 999999999999;
    return int.parse(digits);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final xp = ref.watch(mobdexProvider.select((s) => s.hunterXp));
    final reached = xp >= kHunterMilestoneXp;
    final color = reached ? AppColors.gold : AppColors.accent;
    final progress = xp / kHunterMilestoneXp;
    final pctText = (progress.clamp(0.0, 1.0) * 100)
        .toStringAsFixed(1)
        .replaceAll('.', ',');
    final target = AppFormat.number(kHunterMilestoneXp.toDouble(), decimals: 0);

    return _CardShell(
      borderColor: reached ? AppColors.gold.withOpacity(0.4) : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _IconBox(
                icon: reached
                    ? Icons.emoji_events_rounded
                    : Icons.military_tech_outlined,
                color: color,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Jägerjob-XP', style: theme.textTheme.bodySmall),
                    const SizedBox(height: 2),
                    Text('Meilenstein: $target XP',
                        style: theme.textTheme.titleMedium),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _ctrl,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9.\s]')),
            ],
            onChanged: (v) =>
                ref.read(mobdexProvider.notifier).setHunterXp(_parseXp(v)),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 18,
            ),
            decoration: const InputDecoration(
              hintText: 'Aktuelle Jägerjob-XP, z.B. 2.500.000',
              suffixText: 'XP',
            ),
          ),
          const SizedBox(height: 14),
          _Bar(value: progress, color: color),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Text(
                  '${AppFormat.number(xp.toDouble(), decimals: 0)} / $target XP',
                  style: theme.textTheme.bodyMedium,
                ),
              ),
              Text(
                '$pctText %',
                style: TextStyle(color: color, fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            reached
                ? 'Meilenstein erreicht!'
                : 'Noch ${AppFormat.number((kHunterMilestoneXp - xp).toDouble(), decimals: 0)} XP bis zum Meilenstein',
            style: TextStyle(
              color: reached ? AppColors.gold : AppColors.darkTextHint,
              fontWeight: reached ? FontWeight.w700 : FontWeight.w400,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Filter-Pille (gleicher Stil wie _CatChip im Commands-Screen) ──

class _FilterPill extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _FilterPill({
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
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.accent.withOpacity(0.20)
              : AppColors.darkCard,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected
                ? AppColors.accent.withOpacity(0.50)
                : Colors.white.withOpacity(0.07),
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: selected
                  ? AppColors.accentLight
                  : AppColors.darkTextSecondary,
              fontSize: 12,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Mob-Kachel (abhakbar) ────────────────────────────────────

class _MobCard extends StatelessWidget {
  final MobdexMob mob;
  final bool caught;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  const _MobCard({
    required this.mob,
    required this.caught,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: caught
            ? Color.alphaBlend(
                AppColors.accent.withOpacity(0.12), AppColors.darkCard)
            : AppColors.darkCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: caught
              ? AppColors.accent.withOpacity(0.55)
              : Colors.white.withOpacity(0.06),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          onLongPress: onLongPress,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ─ Haken + Custom-Badge ─────────────────────
                Row(
                  children: [
                    Icon(
                      caught
                          ? Icons.check_circle_rounded
                          : Icons.circle_outlined,
                      color: caught ? AppColors.accent : AppColors.darkTextHint,
                      size: 22,
                    ),
                    const Spacer(),
                    if (mob.isCustom)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.accent.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'CUSTOM',
                          style: TextStyle(
                            color: AppColors.accentLight,
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.4,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),

                // ─ Name ─────────────────────────────────────
                Text(
                  mob.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 6),

                // ─ Welt ─────────────────────────────────────
                Row(
                  children: [
                    const Icon(Icons.public_rounded,
                        size: 12, color: AppColors.accentLight),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        mob.world,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.accentLight,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),

                // ─ Biome (gekürzt, vollständig im Detail-Sheet) ──
                Expanded(
                  child: Text(
                    mob.biomes,
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontSize: 11,
                      color: AppColors.darkTextSecondary,
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
