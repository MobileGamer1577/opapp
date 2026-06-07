import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/app_colors.dart';
import '../help/command_model.dart';
import '../help/commands_data.dart';
import '../widgets/app_background.dart';

class CommandsScreen extends StatefulWidget {
  const CommandsScreen({super.key});

  @override
  State<CommandsScreen> createState() => _CommandsScreenState();
}

class _CommandsScreenState extends State<CommandsScreen> {
  final _searchCtrl = TextEditingController();
  String _query = '';
  CommandCategory? _selectedCat;

  // Welche Command-Karten gerade aufgeklappt sind
  final Set<String> _expanded = {};

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<ServerCommand> get _filtered {
    return kServerCommands.where((c) {
      final matchQ = _query.isEmpty || c.matches(_query);
      final matchC = _selectedCat == null || c.category == _selectedCat;
      return matchQ && matchC;
    }).toList();
  }

  void _toggleExpand(String command) {
    setState(() {
      if (_expanded.contains(command)) {
        _expanded.remove(command);
      } else {
        _expanded.add(command);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final filtered = _filtered;

    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('Commands'),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Divider(
              height: 1,
              color: Colors.white.withOpacity(0.06),
            ),
          ),
        ),
        body: Column(
          children: [
            // ─── Suche ──────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: TextField(
                controller: _searchCtrl,
                onChanged: (v) => setState(() => _query = v),
                decoration: InputDecoration(
                  hintText: 'Command suchen …',
                  prefixIcon: const Icon(Icons.search, size: 20),
                  suffixIcon: _query.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.close, size: 18),
                          onPressed: () {
                            _searchCtrl.clear();
                            setState(() => _query = '');
                          },
                        )
                      : null,
                ),
              ),
            ),
            const SizedBox(height: 10),

            // ─── Kategorie-Filter ────────────────────────────
            SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _CatChip(
                    label: 'Alle',
                    selected: _selectedCat == null,
                    onTap: () => setState(() => _selectedCat = null),
                  ),
                  ...CommandCategory.values.map((c) => Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: _CatChip(
                          label: '${c.icon} ${c.label}',
                          selected: _selectedCat == c,
                          onTap: () => setState(
                            () => _selectedCat = _selectedCat == c ? null : c,
                          ),
                        ),
                      )),
                ],
              ),
            ),
            const SizedBox(height: 10),

            // ─── Trennlinie + Ergebnis-Zähler ───────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Text(
                    '${filtered.length} Command${filtered.length == 1 ? '' : 's'}',
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 6),

            // ─── Command-Liste ───────────────────────────────
            Expanded(
              child: filtered.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.search_off,
                              color: AppColors.darkTextHint, size: 36),
                          const SizedBox(height: 10),
                          Text(
                            'Kein Command gefunden',
                            style: theme.textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                      itemCount: filtered.length,
                      itemBuilder: (_, i) {
                        final cmd = filtered[i];
                        return _CommandCard(
                          command: cmd,
                          isExpanded: _expanded.contains(cmd.command),
                          onToggle: () => _toggleExpand(cmd.command),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Kategorie-Chip ──────────────────────────────────────────

class _CatChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _CatChip(
      {required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.accent.withOpacity(0.20)
              : AppColors.darkCard,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected
                ? AppColors.accent.withOpacity(0.50)
                : Colors.white.withOpacity(0.07),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color:
                selected ? AppColors.accentLight : AppColors.darkTextSecondary,
            fontSize: 12,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}

// ─── Command-Karte ───────────────────────────────────────────

class _CommandCard extends StatelessWidget {
  final ServerCommand command;
  final bool isExpanded;
  final VoidCallback onToggle;
  const _CommandCard({
    required this.command,
    required this.isExpanded,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.darkCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isExpanded
                ? AppColors.accent.withOpacity(0.25)
                : Colors.white.withOpacity(0.06),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─ Haupt-Zeile ──────────────────────────────────
            InkWell(
              onTap: command.hasSubCommands ? onToggle : null,
              onLongPress: () => _copyToClipboard(context, command.command),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Command-Name
                          Text(
                            command.command,
                            style: const TextStyle(
                              fontFamily: 'monospace',
                              color: AppColors.accent,
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 4),
                          // Beschreibung
                          Text(
                            command.description,
                            style: theme.textTheme.bodyMedium,
                          ),
                          // Aliases (wenn vorhanden)
                          if (command.aliases.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              command.aliases.join('  ·  '),
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: AppColors.darkTextHint,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    // Aufklapp-Indikator
                    if (command.hasSubCommands) ...[
                      const SizedBox(width: 8),
                      Column(
                        children: [
                          AnimatedRotation(
                            turns: isExpanded ? 0.5 : 0,
                            duration: const Duration(milliseconds: 200),
                            child: const Icon(
                              Icons.keyboard_arrow_down_rounded,
                              color: AppColors.darkTextSecondary,
                              size: 20,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${command.subCommands.length}',
                            style: const TextStyle(
                              color: AppColors.darkTextHint,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),

            // ─ Sub-Commands (aufgeklappt) ────────────────────
            if (command.hasSubCommands && isExpanded) ...[
              Divider(
                height: 1,
                color: Colors.white.withOpacity(0.06),
              ),
              ...command.subCommands.map(
                (sub) => _SubCommandTile(sub: sub),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _copyToClipboard(BuildContext context, String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$text kopiert'),
        duration: const Duration(seconds: 1),
        backgroundColor: AppColors.darkCardElevated,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

// ─── Sub-Command-Zeile ───────────────────────────────────────

class _SubCommandTile extends StatelessWidget {
  final SubCommand sub;
  const _SubCommandTile({required this.sub});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onLongPress: () {
        Clipboard.setData(ClipboardData(text: sub.command));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${sub.command} kopiert'),
            duration: const Duration(seconds: 1),
            backgroundColor: AppColors.darkCardElevated,
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 10, 14, 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Verbindungs-Indikator
            Column(
              children: [
                const SizedBox(height: 3),
                Container(
                  width: 2,
                  height: 14,
                  decoration: BoxDecoration(
                    color: AppColors.accent.withOpacity(0.30),
                    borderRadius: BorderRadius.circular(1),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    sub.command,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      color: AppColors.accentLight,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(sub.description, style: theme.textTheme.bodySmall),
                  if (sub.aliases.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      sub.aliases.join('  ·  '),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.darkTextHint,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
