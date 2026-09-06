// ═══════════════════════════════════════════════════════════════
//  server_info_screen.dart – Server-Info-Screen
//
//  ✅ HIER ÄNDERN: Kartendesign
//  ❌ NICHT ÄNDERN: serverStatusProvider/serverPeakProvider/
//                   serverPeakTodayProvider-Aufrufe
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
//
//  ÄNDERUNGEN (Server-Info-Update):
//    - Screen jetzt mit 5 statt 3 Kacheln, in dieser Reihenfolge:
//        1. Status & Auslastung – UNVERÄNDERT: reine Online-Zahl,
//           bewusst KEIN "X/Y" (maxPlayers ist live geprüft immer
//           nur onlinePlayers+1, keine echte Kapazität – siehe
//           Kommentar in server_status.dart).
//        2. NEU: Peak heute – höchste Online-Spielerzahl SEIT
//           Mitternacht (Europe/Berlin), aus serverPeakTodayProvider
//           (neuer Endpunkt /server/peak/today im opapp-api Worker).
//        3. NEU: Unterstützte Versionen – aus status.versionRange
//           (KEIN zusätzlicher Request, kommt aus demselben
//           serverStatusProvider wie Kachel 1) + statische Zeile zur
//           Farmwelt-Version (farmWorldVersion-Konstante, kommt NICHT
//           aus der API, siehe server_status_repository.dart).
//        4. Spieler-Rekord (All-Time) – unverändert, nur an Position
//           4 statt 3 verschoben.
//        5. Server gegründet – Countdown-Text zeigt jetzt zusätzlich
//           die Jubiläums-Zahl ("...bis zum 8. Geburtstag" statt nur
//           "...zum nächsten Jubiläum", siehe nextServerBirthdayNumber()
//           in server_status_repository.dart).
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

  /// ✅ NEU (Server-Info-Update): zeigt jetzt zusätzlich die Jubiläums-
  /// Zahl (z.B. "8. Geburtstag" statt nur "nächstes Jubiläum") –
  /// siehe nextServerBirthdayNumber().
  String _birthdayCountdownText() {
    final next = nextServerBirthday();
    final number = nextServerBirthdayNumber();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final days = next.difference(today).inDays;
    if (days == 0) return 'Heute ist der $number. Geburtstag! \u{1F389}';
    return 'Noch $days Tag${days == 1 ? '' : 'e'} bis zum $number. Geburtstag';
  }

  @override
  Widget build(BuildContext context) {
    final statusAsync = ref.watch(serverStatusProvider);
    final peakTodayAsync = ref.watch(serverPeakTodayProvider);
    final peakAsync = ref.watch(serverPeakProvider);

    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(title: const Text('Server-Info')),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // ─ 1. Live-Status ────────────────────────────────
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

            // ─ 2. Peak heute (NEU) ────────────────────────────
            // Höchste Online-Spielerzahl seit Mitternacht (Europe/
            // Berlin) – neuer /server/peak/today-Endpunkt. Gleiches
            // ServerPeak-Modell wie der All-Time-Rekord in Kachel 4,
            // nur anderer Provider/Endpunkt.
            peakTodayAsync.when(
              data: (peak) => peak.hasRecord
                  ? _InfoCard(
                      icon: Icons.trending_up_rounded,
                      iconColor: AppColors.sectionAuction,
                      label: 'Peak heute',
                      value: '${peak.playerCount} Spieler',
                      sublabel:
                          'Erreicht um ${AppFormat.time(peak.achievedAt!.toLocal())}',
                    )
                  : const _InfoCard(
                      icon: Icons.trending_up_rounded,
                      iconColor: AppColors.darkTextSecondary,
                      label: 'Peak heute',
                      value: 'Noch keine Daten',
                      sublabel: 'Wird ab jetzt automatisch erfasst',
                    ),
              loading: () => const _InfoCardLoading(),
              error: (_, __) => const _InfoCard(
                icon: Icons.trending_up_rounded,
                iconColor: AppColors.darkTextSecondary,
                label: 'Peak heute',
                value: 'Nicht verfügbar',
              ),
            ),
            const SizedBox(height: 12),

            // ─ 3. Unterstützte Versionen (NEU) ────────────────
            // Nutzt DENSELBEN statusAsync wie Kachel 1 – kein
            // zusätzlicher Request nötig. Die "Farmwelten"-Zeile
            // kommt nicht aus der API, siehe farmWorldVersion-
            // Konstante in server_status_repository.dart.
            statusAsync.when(
              data: (status) => _InfoCard(
                icon: Icons.layers_outlined,
                iconColor: AppColors.info,
                label: 'Unterstützte Versionen',
                value: status.versionRange ?? 'Unbekannt',
                sublabel: 'Farmwelten laufen auf der $farmWorldVersion',
              ),
              loading: () => const _InfoCardLoading(),
              error: (_, __) => const _InfoCard(
                icon: Icons.layers_outlined,
                iconColor: AppColors.darkTextSecondary,
                label: 'Unterstützte Versionen',
                value: 'Nicht verfügbar',
              ),
            ),
            const SizedBox(height: 12),

            // ─ 4. Spieler-Rekord (All-Time) ────────────────────
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
            const SizedBox(height: 12),

            // ─ 5. Release-Datum + Countdown ────────────────────
            _InfoCard(
              icon: Icons.cake_outlined,
              iconColor: AppColors.sectionShards,
              label: 'Server gegründet',
              value: AppFormat.date(serverReleaseDate),
              sublabel: _birthdayCountdownText(),
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
