/// Kategorien für Server-Commands
enum CommandCategory {
  economy(label: 'Wirtschaft',    icon: '💰'),
  auction(label: 'Auktionshaus',  icon: '🔨'),
  teleport(label: 'Teleport',     icon: '✈️'),
  plot(label: 'Grundstücke',      icon: '🏠'),
  misc(label: 'Sonstiges',        icon: '⚙️');

  const CommandCategory({required this.label, required this.icon});
  final String label;
  final String icon;
}

/// Ein einzelner Server-Command
class ServerCommand {
  final String command;
  final String description;
  final CommandCategory category;
  final List<String> aliases;

  const ServerCommand({
    required this.command,
    required this.description,
    required this.category,
    this.aliases = const [],
  });

  /// Für die Suche: gibt true zurück wenn der Begriff passt
  bool matches(String query) {
    final q = query.toLowerCase();
    if (command.toLowerCase().contains(q))     return true;
    if (description.toLowerCase().contains(q)) return true;
    if (aliases.any((a) => a.toLowerCase().contains(q))) return true;
    return false;
  }
}
