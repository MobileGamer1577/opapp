// ═══════════════════════════════════════════════════════════════
//  settings_screen.dart – Einstellungen
//
//  ✅ HIER ÄNDERN: Echte Funktionalität pro Punkt ergänzen
//  ✅ HIER ÄNDERN: Neue Einstellungs-Karten hinzufügen
//  ❌ NICHT ÄNDERN: Card-/Listenaufbau (_SettingsCard)
//
//  STATUS: "Über" ist jetzt fertig implementiert (→ AboutScreen).
//  Die restlichen drei Punkte (Konto, Erscheinungsbild, Speicher)
//  zeigen weiterhin nur einen Hinweis-SnackBar an. Sobald ein
//  Bereich fertig implementiert ist, einfach den onTap der
//  jeweiligen _SettingsCard unten ersetzen – z.B. durch
//  context.push(AppRoutes.account) (Route dann in app_router.dart
//  ergänzen) oder direkt durch eine Aktion (z.B. Cache leeren).
//
//  ÄNDERUNGEN (Einstellungen-Update):
//    - "Über"-Karte öffnet jetzt AboutScreen (AppRoutes.about)
//    - Platzhalter-SnackBar deutlich sichtbarer gemacht (Icon,
//      fetter weißer Text, farbiger Rahmen statt unauffälligem
//      dunklem Hintergrund ohne Kontrast – war vorher auf dem
//      dunklen Verlauf kaum erkennbar)
//
//  GEPLANTE BEREICHE:
//    - Konto             → Account-Verknüpfung, Profil
//    - Erscheinungsbild   → Theme/Farben (App ist aktuell Dark-Mode-only,
//                           siehe app_theme.dart)
//    - Speicher           → z.B. Spielername-Cache leeren
//                           (siehe player_name_repository.dart)
// ═══════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../core/app_colors.dart';
import '../core/app_router.dart';
import '../widgets/app_background.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(title: const Text('Einstellungen')),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _SettingsCard(
              icon: Icons.person_outline,
              title: 'Konto',
              description: 'Account-Verknüpfung & Profil.',
              color: AppColors.accent,
              onTap: () => _showPlaceholder(context),
            ),
            const SizedBox(height: 12),
            _SettingsCard(
              icon: Icons.palette_outlined,
              title: 'Erscheinungsbild',
              description: 'Design & Farben der App.',
              color: AppColors.sectionShards,
              onTap: () => _showPlaceholder(context),
            ),
            const SizedBox(height: 12),
            _SettingsCard(
              icon: Icons.storage_outlined,
              title: 'Speicher',
              description: 'Cache & lokale Daten verwalten.',
              color: AppColors.warning,
              onTap: () => _showPlaceholder(context),
            ),
            const SizedBox(height: 12),
            _SettingsCard(
              icon: Icons.info_outline,
              title: 'Über',
              description: 'App-Version, Links & Credits.',
              color: AppColors.info,
              // ✅ "Über" ist fertig implementiert → eigener Screen
              onTap: () => context.push(AppRoutes.about),
            ),
          ],
        ),
      ),
    );
  }

  // ✅ HIER ÄNDERN: Sobald ein Bereich implementiert ist, den
  // jeweiligen onTap der _SettingsCard oben ersetzen.
  void _showPlaceholder(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: const [
            Icon(Icons.construction_rounded, color: AppColors.warning, size: 20),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'Diese Funktion ist noch nicht verfügbar.',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        duration: const Duration(seconds: 2),
        backgroundColor: AppColors.darkCardElevated,
        behavior: SnackBarBehavior.floating,
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(color: AppColors.warning.withOpacity(0.35)),
        ),
      ),
    );
  }
}

// ─── Einstellungs-Karte ──────────────────────────────────────
// Gleicher Stil wie _HelpCard in help_screen.dart

class _SettingsCard extends StatelessWidget {
  final IconData icon;
  final String title, description;
  final Color color;
  final VoidCallback onTap;

  const _SettingsCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: theme.textTheme.titleMedium),
                    Text(description, style: theme.textTheme.bodyMedium),
                  ],
                ),
              ),
              Icon(Icons.chevron_right,
                  color: theme.textTheme.bodySmall?.color),
            ],
          ),
        ),
      ),
    );
  }
}
