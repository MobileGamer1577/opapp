// ═══════════════════════════════════════════════════════════════
//  server_info_screen.dart – Server-Info-Screen
//
//  ✅ HIER ÄNDERN: Kartendesign
//  ❌ NICHT ÄNDERN: serverStatusProvider/serverPeakProvider-Aufrufe
//
//  ÄNDERUNGEN (Server-Status-Update):
//    - NEU: erreichbar über die Server-Status-Zeile auf dem
//      Dashboard. Zeigt Live-Status (Online/Offline + Spielerzahl,
//      siehe server_status_repository.dart – mc-api.io), Server-
//      Releasedatum + Countdown zum nächsten Jubiläum, sowie den
//      Spieler-Rekord (höchste je gemessene Online-Spielerzahl +
//      Datum, aus dem eigenen opapp-api Backend, /server/peak).
//    - Countdown wird beim Öffnen berechnet und alle 60s aktualisiert
//      (kein sekündlicher Timer nötig – ein Server-Geburtstag ist ein
//      Datum, keine kurzfristige Deadline wie eine Auktion).
// ═══════════════════════════════════════════════════════════════

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/app_colors.dart';
import '../core/app_format.dart';
import '../data/repositories/server_status_repository.dart';
import '../widgets/app_background.dart';

class ServerInfoScreen extends ConsumerStatefulWidget {
  const ServerInfoScreen({super.key});

  @override
  ConsumerState<ServerInfoScreen> createState() => _ServerInfoScreenState();
}

class _ServerInfoScreenState extends ConsumerState<ServerInfoScreen> {
  Timer? _minuteTimer;

  @override
  void initState() {
    super.initState();
    // Aktualisiert den Countdown-Text minütlich, falls der Screen
    // lange offen bleibt (kein sekündlicher Timer nötig).
    _minuteTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _minuteTimer?.cancel();
    super.dispose();
  }

  String _birthdayCountdownText() {
    final next = nextServerBirthday();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final days = next.difference(today).inDays;
    if (days == 0) return 'Heute ist der Geburtstag! \u{1F389}';
    return 'Noch $days Tag${days == 1 ? '' : 'e'} bis zum n\u00e4chsten Jubil\u00e4um';
  }

  @override
  Widget build(BuildContext context) {
    final statusAsync = ref.watch(serverStatusProvider);
    final peakAsync = ref.watch(serverPeakProvider);

    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(title: const Text('Server-Info')),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // ─ Live-Status ────────────────────────────────
            statusAsync.when(
              data: (status) => _InfoCard(
                icon: status.online ? Icons.circle : Icons.circle_outlined,
                iconColor: status.online ? AppColors.success : AppColors.error,
                label: 'Status',
                value: status.online ? 'Online' : 'Offline',
                sublabel: status.online
                    ? '${status.onlinePlayers} Spieler aktuell online'
                    : null,
              ),
              loading: () => const _InfoCardLoading(),
              error: (_, __) => const _InfoCard(
                icon: Icons.error_outline,
                iconColor: AppColors.darkTextSecondary,
                label: 'Status',
                value: 'Nicht verfügbar',
              ),
            ),
            const SizedBox(height: 12),

            // ─ Release-Datum + Countdown ────────────────────
            _InfoCard(
              icon: Icons.cake_outlined,
              iconColor: AppColors.sectionShards,
              label: 'Server gegründet',
              value: AppFormat.date(serverReleaseDate),
              sublabel: _birthdayCountdownText(),
            ),
            const SizedBox(height: 12),

            // ─ Spieler-Rekord ─────────────────────────────
            peakAsync.when(
              data: (peak) => peak.hasRecord
                  ? _InfoCard(
                      icon: Icons.emoji_events_outlined,
                      iconColor: AppColors.gold,
                      label: 'Spieler-Rekord',
                      value: '${peak.playerCount} Spieler',
                      sublabel:
                          'Erreicht am ${AppFormat.dateTime(peak.achievedAt!.toLocal())}',
                    )
                  : const _InfoCard(
                      icon: Icons.emoji_events_outlined,
                      iconColor: AppColors.darkTextSecondary,
                      label: 'Spieler-Rekord',
                      value: 'Noch keine Daten',
                      sublabel: 'Wird ab jetzt automatisch erfasst',
                    ),
              loading: () => const _InfoCardLoading(),
              error: (_, __) => const _InfoCard(
                icon: Icons.emoji_events_outlined,
                iconColor: AppColors.darkTextSecondary,
                label: 'Spieler-Rekord',
                value: 'Nicht verfügbar',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Info-Karte (Icon + Label + Wert + optionaler Sublabel) ──

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label, value;
  final String? sublabel;
  const _InfoCard({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    this.sublabel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.14),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: theme.textTheme.bodySmall),
                const SizedBox(height: 2),
                Text(value, style: theme.textTheme.titleMedium),
                if (sublabel != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    sublabel!,
                    style: theme.textTheme.bodySmall
                        ?.copyWith(color: AppColors.darkTextHint),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoCardLoading extends StatelessWidget {
  const _InfoCardLoading();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 76,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: const Center(
        child: SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.accent),
        ),
      ),
    );
  }
}
