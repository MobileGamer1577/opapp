// ═══════════════════════════════════════════════════════════════
//  appearance_screen.dart – "Erscheinungsbild"-Screen
//
//  ✅ HIER ÄNDERN: Weitere Erscheinungsbild-Optionen (z.B. Akzentfarbe,
//                  künftige Theme-Varianten) als neue Sektion unterhalb
//                  von "ZAHLENFORMAT" ergänzen (gleiches Muster:
//                  _SectionLabel + gruppierte Karte)
//  ❌ NICHT ÄNDERN: numberFormatProvider-Aufruf
//
//  ÄNDERUNGEN (Screen-Update):
//    - War bisher ein Bottom-Sheet (_AppearanceSheet in
//      settings_screen.dart), ist jetzt ein eigener Screen – gleiches
//      Karten-Gruppen-Muster wie about_screen.dart (Sektions-Label +
//      abgerundete Karte mit Zeilen, durch Linien getrennt). Mehr
//      Platz für künftige Optionen, ohne dass ein Sheet aus allen
//      Nähten platzt.
// ═══════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/app_colors.dart';
import '../core/app_format.dart';
import '../data/repositories/number_format_repository.dart';
import '../widgets/app_background.dart';

class AppearanceScreen extends StatelessWidget {
  const AppearanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(title: const Text('Erscheinungsbild')),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const _SectionLabel('ZAHLENFORMAT'),
            const SizedBox(height: 4),
            Text(
              'Wie sollen Preise in der App angezeigt werden?',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 10),
            const _FormatGroupCard(),

            // ← Weitere Erscheinungsbild-Sektionen hier ergänzen,
            // z.B.:
            // const SizedBox(height: 24),
            // const _SectionLabel('AKZENTFARBE'),
            // const SizedBox(height: 10),
            // const _AccentColorGroupCard(),
          ],
        ),
      ),
    );
  }
}

// ─── Sektions-Label (kleine Überschrift über einer Gruppen-Karte) ──
// Gleicher Stil wie _SectionLabel in about_screen.dart

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        text,
        style: const TextStyle(
          color:         AppColors.accentLight,
          fontSize:      12,
          fontWeight:    FontWeight.w700,
          letterSpacing: 0.6,
        ),
      ),
    );
  }
}

// ─── Gruppierte Karte mit den beiden Zahlenformat-Optionen ───────

class _FormatGroupCard extends ConsumerWidget {
  const _FormatGroupCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = ref.watch(numberFormatProvider);

    return Container(
      decoration: BoxDecoration(
        color:        AppColors.darkCard,
        borderRadius: BorderRadius.circular(18),
        border:       Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Column(
        children: [
          _FormatOptionRow(
            title:    'Standard',
            example:  AppFormat.currency(40000000),
            selected: current == NumberFormatMode.standard,
            isFirst:  true,
            isLast:   false,
            onTap: () => ref
                .read(numberFormatProvider.notifier)
                .setMode(NumberFormatMode.standard),
          ),
          Divider(
            height:    1,
            indent:    16,
            endIndent: 16,
            color:     Colors.white.withOpacity(0.06),
          ),
          _FormatOptionRow(
            title:    'Kompakte Zahlen',
            example:  AppFormat.compactCurrency(40000000),
            selected: current == NumberFormatMode.compact,
            isFirst:  false,
            isLast:   true,
            onTap: () => ref
                .read(numberFormatProvider.notifier)
                .setMode(NumberFormatMode.compact),
          ),
        ],
      ),
    );
  }
}

class _FormatOptionRow extends StatelessWidget {
  final String title, example;
  final bool selected, isFirst, isLast;
  final VoidCallback onTap;

  const _FormatOptionRow({
    required this.title,
    required this.example,
    required this.selected,
    required this.isFirst,
    required this.isLast,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.vertical(
        top:    isFirst ? const Radius.circular(18) : Radius.zero,
        bottom: isLast  ? const Radius.circular(18) : Radius.zero,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                color: (selected ? AppColors.accent : AppColors.darkTextSecondary)
                    .withOpacity(0.14),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.numbers_rounded,
                color: selected ? AppColors.accent : AppColors.darkTextSecondary,
                size: 20,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: theme.textTheme.titleMedium),
                  Text('z.B. $example', style: theme.textTheme.bodySmall),
                ],
              ),
            ),
            Icon(
              selected ? Icons.check_circle_rounded : Icons.circle_outlined,
              color: selected ? AppColors.accent : AppColors.darkTextHint,
              size: 22,
            ),
          ],
        ),
      ),
    );
  }
}
