// ═══════════════════════════════════════════════════════════════
//  settings_screen.dart – Einstellungen
//
//  ✅ HIER ÄNDERN: Echte Funktionalität pro Punkt ergänzen
//  ✅ HIER ÄNDERN: Neue Einstellungs-Karten hinzufügen
//  ❌ NICHT ÄNDERN: Card-/Listenaufbau (_SettingsCard)
//
//  STATUS: "Über" und "Erscheinungsbild" (inkl. Zahlenformat) sind
//  fertig implementiert. Die restlichen zwei Punkte (Konto, Speicher)
//  zeigen weiterhin nur einen Hinweis-SnackBar an. Sobald ein Bereich
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
//    - NEU (historisch): Eigene Karte "Zahlenformat" mit Auswahl-Sheet
//      "Standard" / "Kurzschreibweise" – seit dem Erscheinungsbild-
//      Update unten in "Erscheinungsbild" verschoben, siehe nächster
//      Eintrag.
//
//  ÄNDERUNGEN (Erscheinungsbild-Update):
//    - Die eigenständige Karte "Zahlenformat" wurde ENTFERNT. Kein
//      eigener Menüpunkt mehr im Hauptmenü – inhaltlich sind Design
//      und Zahlendarstellung beides Anzeige-Einstellungen und gehören
//      zusammen.
//    - Das Zahlenformat ist jetzt Teil der Karte "Erscheinungsbild"
//      (_AppearanceSheet). Die Karten-Beschreibung zeigt weiterhin
//      den aktuell aktiven Modus an.
//    - Umbenennung: "Kurzschreibweise" → "Kompakte Zahlen" (klarerer,
//      verständlicherer Begriff für dieselbe Funktion – gleiche Logik,
//      nur der Anzeigetext hat sich geändert).
//    - Das Auswahl-Sheet heißt jetzt "Erscheinungsbild" mit dem
//      Unterabschnitt "ZAHLENFORMAT" – so ist im selben Sheet Platz
//      für künftige echte Erscheinungsbild-Optionen (z.B. Akzentfarbe),
//      ohne nochmal etwas umbenennen zu müssen.
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
            // ✅ "Erscheinungsbild" ist fertig implementiert – enthält
            // jetzt auch das Zahlenformat (siehe _AppearanceSheet unten).
            // Beschreibung zeigt live den aktuell aktiven Modus an.
            _SettingsCard(
              icon: Icons.palette_outlined,
              title: 'Erscheinungsbild',
              description: formatMode == NumberFormatMode.compact
                  ? 'Kompakte Zahlen – z.B. 40 Mio. \$'
                  : 'Standard – z.B. 40.000.000 \$',
              color: AppColors.sectionShards,
              onTap: () => _showAppearanceSheet(context),
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

  void _showAppearanceSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => const _AppearanceSheet(),
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

// ─── Erscheinungsbild-Sheet (enthält aktuell das Zahlenformat) ──
// ✅ HIER ÄNDERN: Weitere Erscheinungsbild-Optionen (z.B. Akzentfarbe)
// können hier als weiterer Abschnitt unterhalb von "ZAHLENFORMAT"
// ergänzt werden (gleiches Muster: Label + Options-Tiles).

class _AppearanceSheet extends ConsumerWidget {
  const _AppearanceSheet();

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
          Text('Erscheinungsbild', style: theme.textTheme.titleLarge),
          const SizedBox(height: 4),
          Text(
            'Design & Zahlendarstellung der App.',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 20),

          // ── Abschnitt: Zahlenformat ──────────────────────
          const Text(
            'ZAHLENFORMAT',
            style: TextStyle(
              color: AppColors.accentLight,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.6,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Wie sollen Preise in der App angezeigt werden?',
            style: theme.textTheme.bodySmall,
          ),
          const SizedBox(height: 12),

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
            title: 'Kompakte Zahlen',
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
