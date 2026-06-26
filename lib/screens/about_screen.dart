// ═══════════════════════════════════════════════════════════════
//  about_screen.dart – "Über"-Screen (App-Infos, Links, Credits)
//
//  ✅ HIER ÄNDERN: Links in den Listen unten ergänzen/anpassen
//  ✅ HIER ÄNDERN: Farben/Icons der einzelnen Einträge anpassen
//  ❌ NICHT ÄNDERN: appInfoProvider-Aufruf, Gruppen-Karten-Struktur
//
//  AUFBAU:
//    1. App-Info-Karte: Icon, Name, Version + Build-Typ-Badge
//       (Version live über package_info_plus, Build-Typ automatisch
//       über kReleaseMode – siehe app_info_repository.dart)
//    2. "Links": Bio (guns.lol), Discord, GitHub
//    3. "Credits": alle externen APIs/Webseiten, die die App nutzt
// ═══════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../core/app_colors.dart';
import '../core/api_constants.dart';
import '../data/models/app_info.dart';
import '../data/repositories/app_info_repository.dart';
import '../widgets/app_background.dart';

class AboutScreen extends ConsumerWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appInfoAsync = ref.watch(appInfoProvider);

    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(title: const Text('Über')),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // ─── App-Info-Karte ───────────────────────────────
            _AppInfoCard(appInfoAsync: appInfoAsync),
            const SizedBox(height: 28),

            // ─── Links ────────────────────────────────────────
            const _SectionLabel('Links'),
            const SizedBox(height: 10),
            _LinkGroupCard(
              items: [
                _LinkItem(
                  icon:      Icons.link,
                  iconColor: AppColors.accent,
                  title:     'Bio-Link',
                  subtitle:  'guns.lol/mobilegamer1577',
                  url:       ApiConstants.bioUrl,
                ),
                _LinkItem(
                  icon:      Icons.forum,
                  iconColor: const Color(0xFF5865F2), // Discord-Blau
                  title:     'Discord',
                  subtitle:  'Unserem Server beitreten',
                  url:       ApiConstants.discordUrl,
                ),
                _LinkItem(
                  icon:      Icons.code,
                  iconColor: AppColors.darkTextSecondary,
                  title:     'GitHub',
                  subtitle:  'Quellcode von OPAPP',
                  url:       ApiConstants.githubUrl,
                ),
              ],
            ),
            const SizedBox(height: 28),

            // ─── Credits ──────────────────────────────────────
            const _SectionLabel('Credits'),
            const SizedBox(height: 10),
            _LinkGroupCard(
              items: [
                _LinkItem(
                  icon:      Icons.cloud,
                  iconColor: AppColors.sectionMarket,
                  title:     'OPSUCHT API',
                  subtitle:  'Markt-, Auktions- & Wechselkursdaten',
                  url:       ApiConstants.baseUrl,
                ),
                _LinkItem(
                  icon:      Icons.language_outlined,
                  iconColor: AppColors.sectionHelp,
                  title:     'OPSUCHT.NET',
                  subtitle:  'Offizielle Website',
                  url:       ApiConstants.websiteUrl,
                ),
                _LinkItem(
                  icon:      Icons.menu_book_outlined,
                  iconColor: AppColors.info,
                  title:     'OPSUCHT Wiki',
                  subtitle:  'Regelwerk & Hilfe',
                  url:       ApiConstants.rulesUrl,
                ),
                _LinkItem(
                  icon:      Icons.fingerprint,
                  iconColor: AppColors.sectionShards,
                  title:     'mc-api.io',
                  subtitle:  'Spielernamen & Item-Icons',
                  url:       ApiConstants.mcApiCreditUrl,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─── App-Info-Karte (Icon, Name, Version, Build-Typ) ─────────

class _AppInfoCard extends StatelessWidget {
  final AsyncValue<AppInfo> appInfoAsync;
  const _AppInfoCard({required this.appInfoAsync});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
      decoration: BoxDecoration(
        color:        AppColors.darkCard,
        borderRadius: BorderRadius.circular(20),
        border:       Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Column(
        children: [
          // App-Icon – gleicher Stil wie der Header im Dashboard
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.accent, AppColors.accentDark],
                begin:  Alignment.topLeft,
                end:    Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(Icons.language, color: Colors.white, size: 36),
          ),
          const SizedBox(height: 16),
          Text('OPAPP', style: theme.textTheme.headlineMedium),
          const SizedBox(height: 4),
          Text(
            'Companion App für OPSUCHT.NET',
            style: theme.textTheme.bodySmall,
          ),
          const SizedBox(height: 16),

          // Versions-/Build-Typ-Badges
          appInfoAsync.when(
            data: (info) => Wrap(
              alignment: WrapAlignment.center,
              spacing: 8,
              children: [
                _InfoChip(label: info.displayVersion),
                _InfoChip(
                  label: info.buildLabel,
                  color: info.isRelease ? AppColors.success : AppColors.warning,
                ),
              ],
            ),
            loading: () => const SizedBox(
              height: 22,
              width: 22,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.accent,
              ),
            ),
            error: (_, __) => const _InfoChip(label: 'Version unbekannt'),
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final String label;
  final Color? color;
  const _InfoChip({required this.label, this.color});

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.darkTextSecondary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color:        c.withOpacity(0.14),
        borderRadius: BorderRadius.circular(20),
        border:       Border.all(color: c.withOpacity(0.30)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color:         c,
          fontSize:      12,
          fontWeight:    FontWeight.w700,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

// ─── Section-Label (kleine Überschrift über einer Link-Gruppe) ──

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        text.toUpperCase(),
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

// ─── Gruppierte Link-Karte (mehrere Zeilen, durch Linien getrennt) ──

class _LinkItem {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final String url;

  const _LinkItem({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.url,
  });
}

class _LinkGroupCard extends StatelessWidget {
  final List<_LinkItem> items;
  const _LinkGroupCard({required this.items});

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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color:        AppColors.darkCard,
        borderRadius: BorderRadius.circular(18),
        border:       Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Column(
        children: [
          for (int i = 0; i < items.length; i++) ...[
            InkWell(
              borderRadius: BorderRadius.vertical(
                top:    i == 0 ? const Radius.circular(18) : Radius.zero,
                bottom: i == items.length - 1 ? const Radius.circular(18) : Radius.zero,
              ),
              onTap: () => _openUrl(context, items[i].url),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color:        items[i].iconColor.withOpacity(0.14),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(items[i].icon, color: items[i].iconColor, size: 20),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(items[i].title, style: theme.textTheme.titleMedium),
                          Text(items[i].subtitle, style: theme.textTheme.bodySmall),
                        ],
                      ),
                    ),
                    Icon(Icons.chevron_right_rounded,
                        color: theme.textTheme.bodySmall?.color),
                  ],
                ),
              ),
            ),
            if (i != items.length - 1)
              Divider(
                height:    1,
                indent:    16,
                endIndent: 16,
                color:     Colors.white.withOpacity(0.06),
              ),
          ],
        ],
      ),
    );
  }
}
