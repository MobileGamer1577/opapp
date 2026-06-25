// ═══════════════════════════════════════════════════════════════
//  settings_screen.dart – Einstellungen
//
//  ✅ HIER ÄNDERN: Echte Funktionalität pro Punkt ergänzen
//  ✅ HIER ÄNDERN: Neue Einstellungs-Karten hinzufügen
//  ❌ NICHT ÄNDERN: Card-/Listenaufbau (_SettingsCard)
//
//  STATUS: Reiner Platzhalter. Alle vier Punkte zeigen aktuell nur
//  einen Hinweis-SnackBar ("Diese Funktion ist noch nicht verfügbar.")
//  an. Sobald ein Bereich fertig implementiert ist, einfach den
//  onTap der jeweiligen _SettingsCard unten ersetzen – z.B. durch
//  context.push(AppRoutes.account) (Route dann in app_router.dart
//  ergänzen) oder direkt durch eine Aktion (z.B. Cache leeren).
//
//  GEPLANTE BEREICHE:
//    - Konto             → Account-Verknüpfung, Profil
//    - Erscheinungsbild   → Theme/Farben (App ist aktuell Dark-Mode-only,
//                           siehe app_theme.dart)
//    - Speicher           → z.B. Spielername-Cache leeren
//                           (siehe player_name_repository.dart)
//    - Über               → App-Version, Credits, Links
// ═══════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import '../core/app_colors.dart';
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
              description: 'App-Version & Infos.',
              color: AppColors.info,
              onTap: () => _showPlaceholder(context),
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
      const SnackBar(
        content: Text('Diese Funktion ist noch nicht verfügbar.'),
        duration: Duration(seconds: 2),
        backgroundColor: AppColors.darkCardElevated,
        behavior: SnackBarBehavior.floating,
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
