// ═══════════════════════════════════════════════════════════════
//  command_model.dart – Datenstruktur für Server-Commands
//
//  ✅ HIER ÄNDERN: Neue Kategorie in CommandCategory ergänzen
//  ✅ HIER ÄNDERN: SubCommand für verwandte Befehle nutzen
//  ❌ NICHT ÄNDERN: Klassen-Grundstruktur
// ═══════════════════════════════════════════════════════════════

/// Kategorien für Commands (erscheint als Filter-Chip im Commands-Screen)
enum CommandCategory {
  economy(label: 'Wirtschaft', icon: '💰'),
  teleport(label: 'Teleport', icon: '✈️'),
  plot(label: 'Grundstücke', icon: '🏠'),
  crafting(label: 'Crafting', icon: '⚒️'),
  rank(label: 'Rang', icon: '⭐'),
  social(label: 'Community', icon: '👥'),
  server(label: 'Server', icon: '🖥️'),
  misc(label: 'Sonstiges', icon: '⚙️');

  const CommandCategory({required this.label, required this.icon});
  final String label;
  final String icon;
}

/// Verwandter Unter-Befehl (ohne eigene Kategorie, gehört zum Eltern-Command)
///
/// BEISPIEL:
///   subCommands: [
///     SubCommand(command: '/sethome', description: '...', aliases: ['/home set']),
///   ]
class SubCommand {
  final String command;
  final String description;
  final List<String> aliases;

  const SubCommand({
    required this.command,
    required this.description,
    this.aliases = const [],
  });

  bool matches(String query) {
    final q = query.toLowerCase();
    if (command.toLowerCase().contains(q)) return true;
    if (description.toLowerCase().contains(q)) return true;
    if (aliases.any((a) => a.toLowerCase().contains(q))) return true;
    return false;
  }
}

/// Haupt-Command mit optionalen verwandten Sub-Commands
class ServerCommand {
  final String command;
  final String description;
  final CommandCategory category;
  final List<String> aliases;

  /// Verwandte Commands – werden beim Aufklappen der Karte angezeigt.
  /// z.B. /sethome und /delhome gehören zu /home
  final List<SubCommand> subCommands;

  const ServerCommand({
    required this.command,
    required this.description,
    required this.category,
    this.aliases = const [],
    this.subCommands = const [],
  });

  bool get hasSubCommands => subCommands.isNotEmpty;

  /// Suche: trifft auf Command selbst UND alle Sub-Commands zu
  bool matches(String query) {
    final q = query.toLowerCase();
    if (command.toLowerCase().contains(q)) return true;
    if (description.toLowerCase().contains(q)) return true;
    if (aliases.any((a) => a.toLowerCase().contains(q))) return true;
    if (subCommands.any((s) => s.matches(q))) return true;
    return false;
  }
}
