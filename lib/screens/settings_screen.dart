// ═══════════════════════════════════════════════════════════════
//  settings_screen.dart – Einstellungen
//
//  ✅ HIER ÄNDERN: Echte Funktionalität pro Punkt ergänzen
//  ✅ HIER ÄNDERN: Neue Einstellungs-Karten hinzufügen
//  ❌ NICHT ÄNDERN: Card-/Listenaufbau (_SettingsCard)
//
//  STATUS: "Über" und "Zahlenformat" sind fertig implementiert.
//  Die restlichen zwei Punkte (Konto, Erscheinungsbild) zeigen
//  weiterhin nur einen Hinweis-SnackBar an. Sobald ein Bereich
//  fertig implementiert ist, einfach den onTap der jeweiligen
//  _SettingsCard unten ersetzen – z.B. durch
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
//  ÄNDERUNGEN (Preisformat-Update):
//    - NEU: Karte "Zahlenformat" – öffnet ein Auswahl-Sheet mit
//      "Standard" (40.000.000 $) und "Kurzschreibweise" (40 Mio. $).
//      Die Auswahl steuert numberFormatProvider und wird dauerhaft
//      gespeichert (siehe number_format_repository.dart). Aktuell
//      wird der gewählte Modus im Auktionshaus verwendet
//      (AppFormat.currencyAuto() in auctions_screen.dart).
//    - Screen ist jetzt ein ConsumerWidget (Beschreibungstext der
//      neuen Karte zeigt den aktuell aktiven Modus an)
//
//  GEPLANTE BEREICHE:
//    - Konto             → Account-Verknüpfung, Profil
//    - Erscheinungsbild   → Theme/Farben (App ist aktuell Dark-Mode-only,
//                           siehe app_theme.dart)
//    - Speicher           → z.B. Spielername-Cache leeren
//                           (siehe player_name_repository.dart)
// ═══════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../core/app_colors.dart';
import '../core/app_format.dart';
import '../core/app_router.dart';
import '../data/repositories/number_format_repository.dart';
import '../widgets/app_background.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formatMode = ref.watch(numberFormatProvider);

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
            // ✅ "Zahlenformat" ist fertig implementiert.
            _SettingsCard(
              icon: Icons.numbers_rounded,
              title: 'Zahlenformat',
              description: formatMode == NumberFormatMode.compact
                  ? 'Kurzschreibweise – z.B. 40 Mio. \$'
                  : 'Standard – z.B. 40.000.000 \$',
              color: AppColors.silver,
              onTap: () => _showFormatSheet(context),
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

  void _showFormatSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => const _NumberFormatSheet(),
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

// ─── Zahlenformat-Auswahl (Bottom-Sheet) ─────────────────────
// ✅ HIER ÄNDERN: Weitere Modi ergänzen, falls später gewünscht
// (z.B. eine dritte Stufe für Milliarden).

class _NumberFormatSheet extends ConsumerWidget {
  const _NumberFormatSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = ref.watch(numberFormatProvider);
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
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
          Text('Zahlenformat', style: theme.textTheme.titleLarge),
          const SizedBox(height: 4),
          Text(
            'Wie sollen Preise in der App angezeigt werden?',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 18),

          _FormatOptionTile(
            title: 'Standard',
            example: AppFormat.currency(40000000),
            selected: current == NumberFormatMode.standard,
            onTap: () {
              ref
                  .read(numberFormatProvider.notifier)
                  .setMode(NumberFormatMode.standard);
              Navigator.pop(context);
            },
          ),
          const SizedBox(height: 10),
          _FormatOptionTile(
            title: 'Kurzschreibweise',
            example: AppFormat.compactCurrency(40000000),
            selected: current == NumberFormatMode.compact,
            onTap: () {
              ref
                  .read(numberFormatProvider.notifier)
                  .setMode(NumberFormatMode.compact);
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}

class _FormatOptionTile extends StatelessWidget {
  final String title;
  final String example;
  final bool selected;
  final VoidCallback onTap;
  const _FormatOptionTile({
    required this.title,
    required this.example,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.accent.withOpacity(0.14)
              : AppColors.darkCard,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected
                ? AppColors.accent.withOpacity(0.5)
                : Colors.white.withOpacity(0.07),
          ),
        ),
        child: Row(
          children: [
            Icon(
              selected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: selected ? AppColors.accent : AppColors.darkTextHint,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: selected ? AppColors.accentLight : Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    'z.B. $example',
                    style: const TextStyle(
                      color: AppColors.darkTextHint,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
