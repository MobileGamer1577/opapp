// ═══════════════════════════════════════════════════════════════
//  command_model.dart – Datenstruktur für Server-Commands
//
//  ✅ HIER ÄNDERN: Neue Kategorie hinzufügen (CommandCategory)
//  ✅ HIER ÄNDERN: Suchlogik erweitern (matches Methode)
//  ❌ NICHT ÄNDERN: Klassen-Grundstruktur
//
//  NEUE KATEGORIE HINZUFÜGEN:
//    meineKat(label: 'Mein Label', icon: '🔧');
//  Die Kategorie erscheint automatisch im Filter des Hilfe-Screens.
// ═══════════════════════════════════════════════════════════════

/// Kategorien für Server-Commands.
/// Jede Kategorie hat ein Label (Text) und ein Emoji-Icon.
/// Die Kategorie erscheint im Hilfe-Screen als Filter-Chip.
enum CommandCategory {
  economy( label: 'Wirtschaft',   icon: '💰'),
  auction( label: 'Auktionshaus', icon: '🔨'),
  teleport(label: 'Teleport',     icon: '✈️'),
  plot(    label: 'Grundstücke',  icon: '🏠'),
  misc(    label: 'Sonstiges',    icon: '⚙️');
  // ← Neue Kategorie hier ergänzen:
  // meine(label: 'Meine Kategorie', icon: '🔧');

  const CommandCategory({required this.label, required this.icon});
  final String label;
  final String icon;
}

/// Repräsentiert einen einzelnen Server-Command mit allen Infos.
class ServerCommand {
  final String command;         // Der Command selbst, z.B. '/shop'
  final String description;     // Was der Command macht
  final CommandCategory category;
  final List<String> aliases;   // Alternative Schreibweisen, z.B. ['/s']

  const ServerCommand({
    required this.command,
    required this.description,
    required this.category,
    this.aliases = const [],    // Standard: leer (keine Aliases)
  });

  /// Suche: gibt true zurück wenn die Query auf diesen Command passt.
  /// Wird in help_screen.dart für die Suche verwendet.
  ///
  /// ERWEITERN: Weitere Felder hier durchsuchbar machen, z.B.:
  ///   if (category.label.toLowerCase().contains(q)) return true;
  bool matches(String query) {
    final q = query.toLowerCase();
    if (command.toLowerCase().contains(q))                     return true;
    if (description.toLowerCase().contains(q))                 return true;
    if (aliases.any((a) => a.toLowerCase().contains(q)))       return true;
    return false;
  }
}
