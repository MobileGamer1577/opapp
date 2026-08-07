// ═══════════════════════════════════════════════════════════════
//  settings_screen.dart – Einstellungen
//
//  ✅ HIER ÄNDERN: Echte Funktionalität pro Punkt ergänzen
//  ✅ HIER ÄNDERN: Neue Einstellungs-Karten hinzufügen
//  ❌ NICHT ÄNDERN: Card-/Listenaufbau (_SettingsCard)
//
//  STATUS: "Über", "Erscheinungsbild" und "Dienstverfügbarkeit" sind
//  fertig implementiert. "Konto" zeigt weiterhin nur einen Hinweis-
//  SnackBar an. Sobald ein Bereich fertig implementiert ist, einfach
//  den onTap der jeweiligen _SettingsCard unten ersetzen – z.B. durch
//  context.push(AppRoutes.account) (Route dann in app_router.dart
//  ergänzen) oder direkt durch eine Aktion.
//
//  ÄNDERUNGEN (Einstellungen-Update):
//    - "Über"-Karte öffnet AboutScreen (AppRoutes.about)
//    - Platzhalter-SnackBar deutlich sichtbarer gemacht
//
//  ÄNDERUNGEN (Erscheinungsbild-Update, historisch):
//    - "Zahlenformat" war eigene Karte, dann Teil eines Bottom-Sheets
//      unter "Erscheinungsbild" – siehe nächster Eintrag, warum sich
//      das nochmal geändert hat.
//
//  ÄNDERUNGEN (Screen-Update):
//    - "Erscheinungsbild" ist jetzt ein EIGENER SCREEN
//      (AppRoutes.appearance, siehe appearance_screen.dart) statt
//      eines Bottom-Sheets – mehr Platz für künftige Optionen, gleiches
//      Karten-Gruppen-Muster wie "Über".
//    - "Speicher" wurde zu "Dienstverfügbarkeit" (AppRoutes.
//      serviceStatus, siehe service_status_screen.dart) – zeigt den
//      Live-Status (Online/Offline + Ping) aller von der App
//      genutzten APIs (OPSUCHT, mc-api.io, eigenes Shards-Backend).
//
//  ÄNDERUNGEN (Redcoins-Update):
//    - "Erscheinungsbild"-Beschreibung ist jetzt ein kurzer FESTER
//      Text statt live nur den aktuellen Zahlenformat-Wert zu zeigen.
//      Grund: seit dem Kursverlauf- und Redcoins-Update stecken dort
//      inzwischen 3 unabhängige Optionen (Zahlenformat, Kursverlauf-
//      Graph, Währungsfarben) – ein einzeiliger Live-Wert konnte immer
//      nur EINE davon zeigen, was so aussah, als gäbe es nur diese
//      eine Einstellung. Jetzt gleiches Muster wie "Über"/
//      "Dienstverfügbarkeit": ein knapper, immer gleicher
//      Überblickssatz statt eines Live-Werts.
//    - Dadurch wird numberFormatProvider hier nicht mehr gebraucht →
//      SettingsScreen ist jetzt StatelessWidget statt ConsumerWidget.
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
            // ✅ Eigener Screen – fester Überblickssatz statt eines
            // einzelnen Live-Werts (siehe Changelog oben).
            _SettingsCard(
              icon: Icons.palette_outlined,
              title: 'Erscheinungsbild',
              description: 'Zahlenformat, Kursverlauf & Wertstoffhändler-Farben.',
              color: AppColors.sectionShards,
              onTap: () => context.push(AppRoutes.appearance),
            ),
            const SizedBox(height: 12),
            // ✅ "Speicher" → "Dienstverfügbarkeit": Live-Status +
            // Ping aller von der App genutzten APIs.
            _SettingsCard(
              icon: Icons.network_check_rounded,
              title: 'Dienstverfügbarkeit',
              description: 'Status & Ping aller genutzten APIs.',
              color: AppColors.warning,
              onTap: () => context.push(AppRoutes.serviceStatus),
            ),
            const SizedBox(height: 12),
            _SettingsCard(
              icon: Icons.info_outline,
              title: 'Über',
              description: 'App-Version, Links & Credits.',
              color: AppColors.info,
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
