import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../core/app_colors.dart';
import '../core/api_constants.dart';
import '../core/app_router.dart';
import '../widgets/app_background.dart';

class HelpScreen extends ConsumerWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(title: const Text('Hilfe & Support')),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // ─── Schnellzugriff-Karten ─────────────────────────
            _HelpCard(
              icon: Icons.terminal_outlined,
              title: 'Server Commands',
              description: 'Alle Commands mit Suche und Kategorien.',
              color: AppColors.accent,
              onTap: () => context.push(AppRoutes.commands),
            ),
            const SizedBox(height: 12),
            _HelpCard(
              icon: Icons.menu_book_outlined,
              title: 'Regelwerk',
              description: 'Alle Server-Regeln auf einen Blick.',
              color: AppColors.info,
              onTap: () => _openUrl(context, ApiConstants.rulesUrl),
            ),
            const SizedBox(height: 12),
            _HelpCard(
              icon: Icons.block_outlined,
              title: 'Restriktionen',
              description: 'Deaktivierte Items & Spielmechaniken.',
              color: AppColors.warning,
              onTap: () => _showRestrictions(context),
            ),
            const SizedBox(height: 12),
            _HelpCard(
              icon: Icons.language_outlined,
              title: 'Zur OPSUCHT Website',
              description: 'Offizielle Website, Neuigkeiten & mehr.',
              color: AppColors.darkTextSecondary,
              onTap: () => _openUrl(context, ApiConstants.websiteUrl),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openUrl(BuildContext context, String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Link konnte nicht geöffnet werden.')),
        );
      }
    }
  }

  void _showRestrictions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => const _RestrictionsSheet(),
    );
  }
}

// ─── Restriktionen Sheet ─────────────────────────────────────

class _RestrictionsSheet extends StatelessWidget {
  const _RestrictionsSheet();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Restriktionen', style: theme.textTheme.titleLarge),
          const SizedBox(height: 16),
          const _RestrictionTile(
            title: 'TNT & Explosionen',
            description: 'Explosionsschaden ist auf dem Server deaktiviert.',
          ),
          const _RestrictionTile(
            title: 'Bestimmte Farmingmechaniken',
            description:
                'Einige automatisierte Farm-Designs sind eingeschränkt.',
          ),
          const _RestrictionTile(
            title: 'PvP-Zonen',
            description: 'PvP ist nur in dafür vorgesehenen Bereichen erlaubt.',
          ),
          const SizedBox(height: 16),
          Text(
            'Vollständige Liste ist bald verfügbar.',
            style: theme.textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

class _RestrictionTile extends StatelessWidget {
  final String title, description;
  const _RestrictionTile({required this.title, required this.description});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.block, color: AppColors.warning, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: theme.textTheme.titleMedium),
                Text(description, style: theme.textTheme.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Hilfe-Karte ─────────────────────────────────────────────

class _HelpCard extends StatelessWidget {
  final IconData icon;
  final String title, description;
  final Color color;
  final VoidCallback onTap;

  const _HelpCard({
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
