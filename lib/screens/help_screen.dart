import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../core/app_colors.dart';
import '../core/api_constants.dart';
import '../help/commands_data.dart';
import '../help/command_model.dart';

class HelpScreen extends ConsumerStatefulWidget {
  const HelpScreen({super.key});

  @override
  ConsumerState<HelpScreen> createState() => _HelpScreenState();
}

class _HelpScreenState extends ConsumerState<HelpScreen> {
  final _searchCtrl = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<ServerCommand> get _filtered => _query.isEmpty
      ? kServerCommands
      : kServerCommands.where((c) => c.matches(_query)).toList();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(title: const Text('Hilfe & Support')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [

          // ─── Globale Command-Suche ─────────────────────────
          TextField(
            controller: _searchCtrl,
            onChanged:  (v) => setState(() => _query = v),
            decoration: const InputDecoration(
              hintText:    'Command suchen … (z.B. shop, plot, tpa)',
              prefixIcon:  Icon(Icons.search, size: 20),
            ),
          ),
          const SizedBox(height: 16),

          // ─── Such-Ergebnisse ───────────────────────────────
          if (_query.isNotEmpty) ...[
            Text(
              '${_filtered.length} Ergebnis${_filtered.length == 1 ? '' : 'se'} für „$_query"',
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: 12),
            ..._filtered.map((c) => _CommandTile(command: c)),
            const SizedBox(height: 8),
            const Divider(),
            const SizedBox(height: 16),
          ],

          // ─── Schnellzugriff-Karten ─────────────────────────
          _HelpCard(
            icon:        Icons.menu_book_outlined,
            title:       'Regelwerk',
            description: 'Alle Server-Regeln auf einen Blick.',
            color:       AppColors.info,
            onTap:       () => _openUrl(ApiConstants.rulesUrl),
          ),
          const SizedBox(height: 12),
          _HelpCard(
            icon:        Icons.terminal_outlined,
            title:       'Server Commands',
            description: '${kServerCommands.length} Commands mit Beschreibung.',
            color:       AppColors.accent,
            onTap:       () => _showAllCommands(context),
          ),
          const SizedBox(height: 12),
          _HelpCard(
            icon:        Icons.block_outlined,
            title:       'Restriktionen',
            description: 'Deaktivierte Items & Spielmechaniken.',
            color:       AppColors.warning,
            onTap:       () => _showRestrictions(context),
          ),
          const SizedBox(height: 12),
          _HelpCard(
            icon:        Icons.language_outlined,
            title:       'Zur OPSUCHT Website',
            description: 'Offizielle Website, Neuigkeiten & mehr.',
            color:       AppColors.darkTextSecondary,
            onTap:       () => _openUrl(ApiConstants.websiteUrl),
          ),
        ],
      ),
    );
  }

  Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Link konnte nicht geöffnet werden.')),
        );
      }
    }
  }

  void _showAllCommands(BuildContext context) {
    showModalBottomSheet(
      context:       context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.85,
        builder: (_, ctrl) => _CommandsSheet(scrollCtrl: ctrl),
      ),
    );
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

// ─── Commands Bottom Sheet ────────────────────────────────────

class _CommandsSheet extends StatefulWidget {
  final ScrollController scrollCtrl;
  const _CommandsSheet({required this.scrollCtrl});

  @override
  State<_CommandsSheet> createState() => _CommandsSheetState();
}

class _CommandsSheetState extends State<_CommandsSheet> {
  final _ctrl = TextEditingController();
  String _q   = '';
  CommandCategory? _cat;

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final theme    = Theme.of(context);
    final filtered = kServerCommands.where((c) {
      final matchQ = _q.isEmpty || c.matches(_q);
      final matchC = _cat == null || c.category == _cat;
      return matchQ && matchC;
    }).toList();

    return Column(
      children: [
        const SizedBox(height: 12),
        Container(
          width: 36, height: 4,
          decoration: BoxDecoration(
            color: AppColors.darkBorder,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text('Server Commands', style: theme.textTheme.titleLarge),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: TextField(
            controller: _ctrl,
            onChanged:  (v) => setState(() => _q = v),
            decoration: const InputDecoration(hintText: 'Suchen …', prefixIcon: Icon(Icons.search, size: 20)),
          ),
        ),
        const SizedBox(height: 8),
        // Kategorie-Filter
        SizedBox(
          height: 40,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              FilterChip(label: const Text('Alle'), selected: _cat == null, onSelected: (_) => setState(() => _cat = null)),
              ...CommandCategory.values.map((c) => Padding(
                padding: const EdgeInsets.only(left: 8),
                child: FilterChip(
                  label:      Text('${c.icon} ${c.label}'),
                  selected:   _cat == c,
                  onSelected: (_) => setState(() => _cat = _cat == c ? null : c),
                ),
              )),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: ListView.builder(
            controller:  widget.scrollCtrl,
            padding:     const EdgeInsets.symmetric(horizontal: 16),
            itemCount:   filtered.length,
            itemBuilder: (_, i) => _CommandTile(command: filtered[i]),
          ),
        ),
      ],
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
          // Platzhalter – wird mit echten Daten befüllt
          const _RestrictionTile(
            title:       'TNT & Explosionen',
            description: 'Explosionsschaden ist auf dem Server deaktiviert.',
          ),
          const _RestrictionTile(
            title:       'Bestimmte Farmingmechaniken',
            description: 'Einige automatisierte Farm-Designs sind eingeschränkt.',
          ),
          const _RestrictionTile(
            title:       'PvP-Zonen',
            description: 'PvP ist nur in dafür vorgesehenen Bereichen erlaubt.',
          ),
          const SizedBox(height: 16),
          Text(
            'Vollständige Liste auf der offiziellen Website.',
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

// ─── Command Tile ────────────────────────────────────────────

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
        onTap:        onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color:        color.withOpacity(0.12),
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
              Icon(Icons.chevron_right, color: theme.textTheme.bodySmall?.color),
            ],
          ),
        ),
      ),
    );
  }
}

class _CommandTile extends StatelessWidget {
  final ServerCommand command;
  const _CommandTile({required this.command});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    command.command,
                    style: const TextStyle(
                      fontFamily:  'monospace',
                      color:       AppColors.accent,
                      fontWeight:  FontWeight.w700,
                      fontSize:    14,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color:        AppColors.accent.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '${command.category.icon} ${command.category.label}',
                      style: theme.textTheme.bodySmall?.copyWith(fontSize: 10),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(command.description, style: theme.textTheme.bodyMedium),
              if (command.aliases.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  'Alias: ${command.aliases.join(', ')}',
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
